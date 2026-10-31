import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../core/constants/constants.dart';
import '../core/utils/app_messenger.dart';
import '../core/utils/debouncer.dart';
import '../core/utils/safe_runner.dart';
import '../data/datasources/media_storage.dart';
import '../data/models/attachment.dart';
import '../data/models/checklist_item.dart';
import '../data/models/note.dart';
import '../data/models/note_color.dart';
import '../data/services/picker_service.dart';
import 'audio_playback_provider.dart';
import 'editor_launch_action.dart';
import 'notes_provider.dart';

/// Editing session for one note.
///
/// Text typed in the title/body/checklist fields only updates the in-memory
/// note and schedules an autosave — it never calls [notifyListeners], so
/// typing causes zero widget rebuilds. Structural changes (color, pin,
/// attachments, checklist rows) notify, and widgets pick the exact slice they
/// need through `Selector`.
final class NoteEditorController extends ChangeNotifier with SafeRunner {
  NoteEditorController({
    required Note note,
    required this._isNew,
    required this._notes,
    required this._media,
    required this._picker,
    required this._playback,
    this._launchAction = EditorLaunchAction.none,
  }) : _note = note,
       titleController = TextEditingController(text: note.title),
       contentController = TextEditingController(text: note.content) {
    titleController.addListener(_onTitleChanged);
    contentController.addListener(_onContentChanged);
    for (final ChecklistItem item in note.checklist) {
      _createItemController(item);
    }
    // Save immediately if the app goes to background mid-debounce.
    _lifecycle = AppLifecycleListener(
      onPause: _flushPending,
      onHide: _flushPending,
    );
  }

  late final AppLifecycleListener _lifecycle;

  final NotesProvider _notes;
  final MediaStorage _media;
  final PickerService _picker;
  final AudioPlaybackProvider _playback;
  final bool _isNew;
  bool get isNew => _isNew;

  final TextEditingController titleController;
  final TextEditingController contentController;
  final Map<String, TextEditingController> _itemControllers =
      <String, TextEditingController>{};
  final Map<String, FocusNode> _itemFocus = <String, FocusNode>{};
  final Debouncer _autosave = Debouncer(AppDurations.autosaveDebounce);

  /// Whether the color palette row is expanded.
  final ValueNotifier<bool> isPaletteOpen = ValueNotifier<bool>(false);

  Note _note;
  bool _closed = false;
  EditorLaunchAction _launchAction;

  /// Returns the pending quick-capture action once, then [EditorLaunchAction.none].
  EditorLaunchAction takeLaunchAction() {
    final EditorLaunchAction action = _launchAction;
    _launchAction = EditorLaunchAction.none;
    return action;
  }

  Note get note => _note;
  MediaStorage get media => _media;

  List<ChecklistItem> get pendingItems => _note.checklist
      .where((ChecklistItem i) => !i.isDone)
      .toList(growable: false);
  List<ChecklistItem> get doneItems => _note.checklist
      .where((ChecklistItem i) => i.isDone)
      .toList(growable: false);

  TextEditingController itemController(String id) => _itemControllers[id]!;
  FocusNode itemFocus(String id) => _itemFocus[id]!;

  // ───────────────────────── Text ─────────────────────────

  void _onTitleChanged() {
    if (titleController.text == _note.title) return;
    _note = _note.copyWith(title: titleController.text);
    _scheduleSave();
  }

  void _onContentChanged() {
    if (contentController.text == _note.content) return;
    _note = _note.copyWith(content: contentController.text);
    _scheduleSave();
  }

  // ───────────────────────── Checklist ─────────────────────────

  /// Switches between free text and checklist, converting the content.
  void toggleChecklist() {
    if (_note.isChecklist) {
      final String text = _note.checklist
          .where((ChecklistItem i) => !i.isBlank)
          .map((ChecklistItem i) => i.text)
          .join('\n');
      _disposeItemControllers();
      contentController.text = text;
      _update(
        _note.copyWith(
          isChecklist: false,
          checklist: const <ChecklistItem>[],
          content: text,
        ),
      );
    } else {
      final List<ChecklistItem> items = _note.content
          .split('\n')
          .where((String line) => line.trim().isNotEmpty)
          .map(ChecklistItem.create)
          .toList();
      if (items.isEmpty) items.add(ChecklistItem.create());
      items.forEach(_createItemController);
      contentController.text = '';
      _update(_note.copyWith(isChecklist: true, checklist: items, content: ''));
    }
  }

  void addItem({String? afterId}) {
    final ChecklistItem item = ChecklistItem.create();
    _createItemController(item);
    final List<ChecklistItem> items = List<ChecklistItem>.of(_note.checklist);
    final int index = afterId == null
        ? -1
        : items.indexWhere((ChecklistItem i) => i.id == afterId);
    index < 0 ? items.add(item) : items.insert(index + 1, item);
    _update(_note.copyWith(checklist: items));
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _itemFocus[item.id]?.requestFocus(),
    );
  }

  void removeItem(String id) {
    _update(
      _note.copyWith(
        checklist: _note.checklist
            .where((ChecklistItem i) => i.id != id)
            .toList(growable: false),
      ),
    );
    // Dispose after the row has left the tree.
    final TextEditingController? controller = _itemControllers.remove(id);
    final FocusNode? focus = _itemFocus.remove(id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller?.dispose();
      focus?.dispose();
    });
  }

  /// Moves a pending (unchecked) item from [oldIndex] to [newIndex]
  /// (already adjusted, as given by `onReorderItem`). Completed items keep
  /// their place after the pending ones.
  void reorderPending(int oldIndex, int newIndex) {
    final List<ChecklistItem> pending = List<ChecklistItem>.of(pendingItems);
    if (oldIndex < 0 || oldIndex >= pending.length || oldIndex == newIndex) {
      return;
    }
    final int target = newIndex.clamp(0, pending.length - 1);
    pending.insert(target, pending.removeAt(oldIndex));
    _update(
      _note.copyWith(checklist: <ChecklistItem>[...pending, ...doneItems]),
    );
  }

  void toggleItem(String id) =>
      _replaceItem(id, (ChecklistItem i) => i.copyWith(isDone: !i.isDone));

  void _onItemTextChanged(String id) {
    final String text = _itemControllers[id]?.text ?? '';
    final int index = _note.checklist.indexWhere(
      (ChecklistItem i) => i.id == id,
    );
    if (index < 0 || _note.checklist[index].text == text) return;
    final List<ChecklistItem> items = List<ChecklistItem>.of(_note.checklist);
    items[index] = items[index].copyWith(text: text);
    // Silent: typing must not rebuild the list.
    _note = _note.copyWith(checklist: items);
    _scheduleSave();
  }

  void _replaceItem(String id, ChecklistItem Function(ChecklistItem) change) {
    _update(
      _note.copyWith(
        checklist: _note.checklist
            .map((ChecklistItem i) => i.id == id ? change(i) : i)
            .toList(growable: false),
      ),
    );
  }

  void _createItemController(ChecklistItem item) {
    final TextEditingController controller = TextEditingController(
      text: item.text,
    );
    controller.addListener(() => _onItemTextChanged(item.id));
    _itemControllers[item.id] = controller;
    _itemFocus[item.id] = FocusNode();
  }

  void _disposeItemControllers() {
    final List<TextEditingController> controllers = _itemControllers.values
        .toList();
    final List<FocusNode> nodes = _itemFocus.values.toList();
    _itemControllers.clear();
    _itemFocus.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final TextEditingController c in controllers) {
        c.dispose();
      }
      for (final FocusNode f in nodes) {
        f.dispose();
      }
    });
  }

  // ───────────────────────── Meta ─────────────────────────

  void setColor(NoteColor color) {
    if (color != _note.color) _update(_note.copyWith(color: color));
  }

  void togglePin() => _update(_note.copyWith(isPinned: !_note.isPinned));

  void togglePalette() => isPaletteOpen.value = !isPaletteOpen.value;

  void addTag(String raw) {
    final String tag = raw
        .trim()
        .replaceAll(AppStrings.tagPrefix, '')
        .replaceAll(' ', '_');
    if (tag.isEmpty || _note.tags.contains(tag)) return;
    _update(_note.copyWith(tags: <String>[..._note.tags, tag]));
  }

  void removeTag(String tag) => _update(
    _note.copyWith(
      tags: _note.tags.where((String t) => t != tag).toList(growable: false),
    ),
  );

  // ───────────────────────── Attachments ─────────────────────────

  Future<void> pickGalleryImages() =>
      _importFrom(_picker.pickGalleryImages, AttachmentType.image);

  Future<void> captureImage() =>
      _importFrom(_picker.captureImage, AttachmentType.image);

  Future<void> pickFiles() =>
      _importFrom(_picker.pickFiles, AttachmentType.file);

  Future<void> addDrawing(Uint8List png) async {
    final Attachment? attachment = await runSafe(
      () => _media.saveBytes(
        png,
        type: AttachmentType.drawing,
        extension: AppConfig.drawingExtension,
        displayName: '${AppStrings.drawingTitle}.${AppConfig.drawingExtension}',
      ),
    );
    if (attachment != null) addAttachments(<Attachment>[attachment]);
  }

  void addAttachments(List<Attachment> attachments) {
    if (attachments.isEmpty) return;
    _update(
      _note.copyWith(
        attachments: <Attachment>[..._note.attachments, ...attachments],
      ),
    );
  }

  Future<void> removeAttachment(Attachment attachment) async {
    await _playback.release(_media.pathOf(attachment.fileName));
    _update(
      _note.copyWith(
        attachments: _note.attachments
            .where((Attachment a) => a.id != attachment.id)
            .toList(growable: false),
      ),
    );
    await _media.deleteFiles(<String>[attachment.fileName]);
  }

  Future<void> _importFrom(
    Future<List<MediaSource>> Function() pick,
    AttachmentType type,
  ) async {
    final List<MediaSource>? sources = await runSafe(pick);
    if (sources == null || sources.isEmpty) return;
    final List<Attachment> added = <Attachment>[];
    for (final MediaSource source in sources) {
      final Attachment? attachment = await runSafe(
        () => _media.import(source, type),
      );
      if (attachment != null) added.add(attachment);
    }
    if (!_closed) {
      addAttachments(added);
    } else {
      // Screen closed while copying: don't leak files.
      await _media.deleteFiles(added.map((Attachment a) => a.fileName));
    }
  }

  // ───────────────────────── Lifecycle ─────────────────────────

  /// Moves the note to the trash and ends the session.
  Future<void> moveToTrash() async {
    _autosave.cancel();
    _closed = true;
    if (_note.isEmpty) {
      await _notes.discard(_note.id);
      return;
    }
    await _notes.upsert(_note);
    await _notes.setStatus(_note, NoteStatus.trashed);
  }

  /// Toggles archive state, persists, and ends the session.
  Future<void> toggleArchive() async {
    _autosave.cancel();
    _closed = true;
    if (_note.isEmpty) return;
    await _notes.upsert(_note);
    await _notes.setStatus(
      _note,
      _note.isArchived ? NoteStatus.active : NoteStatus.archived,
    );
  }

  /// Flushes pending changes; discards the note if it ended up empty.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _autosave.cancel();
    if (_note.isEmpty) {
      if (_notes.byId(_note.id) != null) await _notes.discard(_note.id);
      if (_isNew) AppMessenger.info(AppStrings.emptyNoteDiscarded);
      return;
    }
    await _persist();
  }

  void _update(Note next) {
    _note = next;
    notifyListeners();
    _scheduleSave();
  }

  void _flushPending() => _autosave.flush(() => unawaited(_persist()));

  void _scheduleSave() {
    if (!_closed) _autosave.run(() => unawaited(_persist()));
  }

  Future<void> _persist() async {
    if (_note.isEmpty) return;
    final Note? stored = _notes.byId(_note.id);
    if (identical(stored, _note)) return;
    await _notes.upsert(_note);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _autosave.dispose();
    titleController.dispose();
    contentController.dispose();
    for (final TextEditingController c in _itemControllers.values) {
      c.dispose();
    }
    for (final FocusNode f in _itemFocus.values) {
      f.dispose();
    }
    isPaletteOpen.dispose();
    super.dispose();
  }
}
