import 'dart:collection';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/constants.dart';
import '../core/utils/app_messenger.dart';
import '../core/utils/debouncer.dart';
import '../core/utils/safe_runner.dart';
import '../data/models/attachment.dart';
import '../data/models/checklist_item.dart';
import '../data/models/note.dart';
import '../data/models/note_color.dart';
import '../data/models/note_query.dart';
import '../data/models/notes_overview.dart';
import '../data/repositories/note_repository.dart';
import '../data/services/backup_service.dart';
import '../data/services/picker_service.dart';
import '../data/services/share_service.dart';

/// Single source of truth for all notes.
///
/// Derived data (visible notes, counters, tags, storage usage) is computed
/// lazily and cached until the next mutation, so `Selector`s that read it
/// receive the *same instance* and skip rebuilding when nothing changed.
final class NotesProvider extends ChangeNotifier with SafeRunner {
  NotesProvider({
    required this._repository,
    required this._backup,
    required this._picker,
    this._share = const ShareService(),
    List<Note> initialNotes = const <Note>[],
  }) : _notes = List<Note>.of(initialNotes);

  final NoteRepository _repository;
  final BackupService _backup;
  final PickerService _picker;
  final ShareService _share;

  final List<Note> _notes;
  final Debouncer _searchDebouncer = Debouncer(AppDurations.searchDebounce);

  /// Lower-cased searchable text per note instance (GC-friendly cache).
  final Expando<String> _searchIndex = Expando<String>('search');

  /// `true` while a backup/restore is running.
  final ValueNotifier<bool> isBusy = ValueNotifier<bool>(false);

  NoteQuery _query = const NoteQuery();
  String _search = '';

  /// Ids of notes selected for bulk actions. Replaced (never mutated) on
  /// change so `Selector`s can compare it by identity.
  Set<String> _selected = const <String>{};

  /// Below this gap between neighbours, a group's order is renumbered.
  static const double _minOrderGap = 1e-6;

  NotesView? _view;
  NoteCounts? _counts;
  List<TagCount>? _tags;
  StorageUsage? _usage;

  // ───────────────────────── Read API ─────────────────────────

  NoteQuery get query => _query;
  String get search => _search;
  bool get isSearching => _search.isNotEmpty;

  UnmodifiableListView<Note> get all => UnmodifiableListView<Note>(_notes);

  NotesView get view => _view ??= _buildView();
  NoteCounts get counts => _counts ??= _buildCounts();
  List<TagCount> get tags => _tags ??= _buildTags();
  StorageUsage get usage => _usage ??= _buildUsage();

  Set<String> get selectedIds => _selected;
  bool get isSelecting => _selected.isNotEmpty;
  bool isSelected(String id) => _selected.contains(id);

  Note? byId(String id) {
    for (final Note note in _notes) {
      if (note.id == id) return note;
    }
    return null;
  }

  // ───────────────────────── Navigation / filtering ─────────────────────────

  void setQuery(NoteQuery query) {
    if (query == _query) return;
    _query = query;
    _selected = const <String>{};
    _invalidate(viewOnly: true);
  }

  void setCategory(NoteCategory category) => setQuery(
    NoteQuery(section: _query.section, category: category, tag: _query.tag),
  );

  void openSection(NoteSection section) =>
      setQuery(NoteQuery(section: section));

  void openTag(String tag) => setQuery(NoteQuery(tag: tag));

  void setSearch(String text) {
    _searchDebouncer.run(() {
      final String normalized = text.trim().toLowerCase();
      if (normalized == _search) return;
      _search = normalized;
      _invalidate(viewOnly: true);
    });
  }

  // ───────────────────────── Mutations ─────────────────────────

  /// Inserts or replaces [note] and persists it.
  Future<void> upsert(Note note) async {
    final int index = _indexOf(note.id);
    final Note? previous = index < 0 ? null : _notes[index];
    if (identical(previous, note)) return;
    index < 0 ? _notes.insert(0, note) : _notes[index] = note;
    _invalidate();
    final bool? saved = await runSafe<bool>(() async {
      await _repository.save(note);
      return true;
    });
    if (saved == null) _rollback(note.id, previous);
  }

  Future<void> togglePin(Note note) =>
      upsert(note.copyWith(isPinned: !note.isPinned));

  Future<void> setColor(Note note, NoteColor color) {
    if (color == note.color) return Future<void>.value();
    return upsert(note.copyWith(color: color));
  }

  /// Moves a note between active/archive/trash, with an undo snack bar.
  Future<void> setStatus(Note note, NoteStatus status) =>
      _setStatusMany(<Note>[note], status);

  /// Moves [notes] to [status] in one write; offers undo when hiding them.
  Future<void> _setStatusMany(List<Note> notes, NoteStatus status) async {
    final List<Note> targets = notes
        .where((Note n) => n.status != status)
        .toList(growable: false);
    if (targets.isEmpty) {
      notifyListeners(); // Selection may have been cleared.
      return;
    }
    await _saveMany(<Note>[
      for (final Note n in targets)
        n.copyWith(
          status: status,
          isPinned: status == NoteStatus.active && n.isPinned,
        ),
    ]);
    if (status == NoteStatus.active) return;
    AppMessenger.info(
      status == NoteStatus.trashed
          ? AppStrings.movedToTrash
          : AppStrings.archived,
      actionLabel: AppStrings.undo,
      onAction: () => _saveMany(<Note>[
        for (final Note original in targets)
          if (byId(original.id) case final Note current)
            current.copyWith(
              status: original.status,
              isPinned: original.isPinned,
            ),
      ]),
    );
  }

  // ───────────────────────── Manual ordering ─────────────────────────

  /// Whether [draggedId] may be dropped on [targetId] (same visible group).
  bool canMove(String draggedId, String targetId) {
    if (draggedId == targetId) return false;
    final List<Note>? group = _groupOf(draggedId);
    return group != null && group.any((Note n) => n.id == targetId);
  }

  /// Moves [draggedId] to the position currently held by [targetId].
  Future<void> moveNote(String draggedId, String targetId) async {
    final List<Note>? group = _groupOf(draggedId);
    if (group == null) return;
    final int from = group.indexWhere((Note n) => n.id == draggedId);
    final int to = group.indexWhere((Note n) => n.id == targetId);
    if (from < 0 || to < 0 || from == to) return;

    final List<Note> ordered = List<Note>.of(group);
    final Note dragged = ordered.removeAt(from);
    ordered.insert(to, dragged);

    final Note? before = to > 0 ? ordered[to - 1] : null;
    final Note? after = to < ordered.length - 1 ? ordered[to + 1] : null;
    final bool tooClose =
        before != null &&
        after != null &&
        (before.sortOrder - after.sortOrder).abs() < _minOrderGap;

    if (tooClose) {
      // Renumber the whole group once instead of splitting a tiny gap.
      final double top = ordered.first.sortOrder + ordered.length;
      await _saveMany(<Note>[
        for (int i = 0; i < ordered.length; i++)
          ordered[i].copyWith(
            sortOrder: top - i,
            updatedAt: ordered[i].updatedAt,
          ),
      ]);
      return;
    }
    final double order = switch ((before, after)) {
      (null, final Note a?) => a.sortOrder + 1,
      (final Note b?, null) => b.sortOrder - 1,
      (final Note b?, final Note a?) => (b.sortOrder + a.sortOrder) / 2,
      _ => dragged.sortOrder,
    };
    // Reordering is not an edit: keep updatedAt untouched.
    await upsert(
      dragged.copyWith(sortOrder: order, updatedAt: dragged.updatedAt),
    );
  }

  List<Note>? _groupOf(String id) {
    final NotesView v = view;
    if (v.pinned.any((Note n) => n.id == id)) return v.pinned;
    if (v.others.any((Note n) => n.id == id)) return v.others;
    return null;
  }

  // ───────────────────────── Multi-select ─────────────────────────

  void toggleSelection(String id) {
    final Set<String> next = Set<String>.of(_selected);
    if (!next.remove(id)) next.add(id);
    _setSelection(next);
  }

  void selectAllVisible() => _setSelection(<String>{
    for (final Note n in view.pinned) n.id,
    for (final Note n in view.others) n.id,
  });

  void clearSelection() => _setSelection(const <String>{});

  /// Pins all selected notes, or unpins them if all are already pinned.
  Future<void> togglePinSelected() {
    final List<Note> notes = _takeSelection();
    final bool pin = notes.any((Note n) => !n.isPinned);
    return _saveMany(<Note>[
      for (final Note n in notes)
        if (n.isPinned != pin)
          n.copyWith(isPinned: pin, updatedAt: n.updatedAt),
    ]);
  }

  Future<void> setColorSelected(NoteColor color) => _saveMany(<Note>[
    for (final Note n in _takeSelection())
      if (n.color != color) n.copyWith(color: color),
  ]);

  Future<void> setStatusSelected(NoteStatus status) =>
      _setStatusMany(_takeSelection(), status);

  Future<void> deleteSelectedForever() => _deleteMany(_takeSelection());

  void _setSelection(Set<String> next) {
    if (setEquals(next, _selected)) return;
    _selected = Set<String>.unmodifiable(next);
    notifyListeners();
  }

  /// Returns the selected notes and leaves selection mode.
  List<Note> _takeSelection() {
    final List<Note> notes = <Note>[
      for (final String id in _selected)
        if (byId(id) case final Note note) note,
    ];
    _selected = const <String>{};
    return notes;
  }

  Future<void> deleteForever(Note note) => _deleteMany(<Note>[note]);

  // ───────────────────────── Share / copy / duplicate ─────────────────────────

  Future<void> share(List<Note> notes) async {
    if (!_hasText(notes)) return;
    await runSafe(() => _share.share(notes));
  }

  Future<void> copyText(List<Note> notes) async {
    if (!_hasText(notes)) return;
    final bool? copied = await runSafe<bool>(() async {
      await _share.copy(notes);
      return true;
    });
    if (copied ?? false) AppMessenger.info(AppStrings.textCopied);
  }

  Future<void> duplicate(List<Note> notes) async {
    final List<Note> copies = <Note>[];
    for (final Note note in notes) {
      final Note? copy = await runSafe<Note>(() => _repository.duplicate(note));
      if (copy != null) copies.add(copy);
    }
    if (copies.isEmpty) return;
    _notes.insertAll(0, copies);
    _invalidate();
    AppMessenger.info(AppStrings.noteDuplicated);
  }

  Future<void> shareSelected() => share(_endSelection());
  Future<void> copySelected() => copyText(_endSelection());
  Future<void> duplicateSelected() => duplicate(_endSelection());

  /// Like [_takeSelection] for actions that do not mutate notes themselves.
  List<Note> _endSelection() {
    final List<Note> notes = _takeSelection();
    notifyListeners();
    return notes;
  }

  static bool _hasText(List<Note> notes) {
    if (ShareService.textOf(notes).isNotEmpty) return true;
    AppMessenger.info(AppStrings.nothingToShare);
    return false;
  }

  Future<void> emptyTrash() => _deleteMany(
    _notes.where((Note n) => n.isTrashed).toList(growable: false),
  );

  /// Removes a note that became empty while editing (no undo needed).
  Future<void> discard(String id) async {
    final Note? note = byId(id);
    if (note != null) await _deleteMany(<Note>[note]);
  }

  Future<void> _deleteMany(List<Note> targets) async {
    if (targets.isEmpty) {
      notifyListeners();
      return;
    }
    final Set<String> ids = targets.map((Note n) => n.id).toSet();
    _notes.removeWhere((Note n) => ids.contains(n.id));
    _invalidate();
    await runSafe(() => _repository.deleteForever(targets));
  }

  // ───────────────────────── Backup ─────────────────────────

  Future<void> exportBackup() => _busy(() async {
    final bool? saved = await runSafe(
      () => _backup.export(List<Note>.of(_notes)),
    );
    if (saved ?? false) AppMessenger.info(AppStrings.backupDone);
  });

  Future<void> importBackup() => _busy(() async {
    final PlatformFile? file = await runSafe<PlatformFile?>(_picker.pickBackup);
    if (file == null) return;
    final List<Note>? restored = await runSafe(() => _backup.restore(file));
    if (restored == null || restored.isEmpty) return;
    final bool? ok = await runSafe<bool>(() async {
      await _repository.saveAll(restored);
      return true;
    });
    if (ok == null) return;
    for (final Note note in restored) {
      final int index = _indexOf(note.id);
      index < 0 ? _notes.add(note) : _notes[index] = note;
    }
    _invalidate();
    AppMessenger.info(AppStrings.restoreDone);
  });

  Future<void> _busy(Future<void> Function() action) async {
    if (isBusy.value) return;
    isBusy.value = true;
    try {
      await action();
    } finally {
      isBusy.value = false;
    }
  }

  // ───────────────────────── Internals ─────────────────────────

  int _indexOf(String id) => _notes.indexWhere((Note n) => n.id == id);

  /// Replaces several notes with one notification and one disk write,
  /// rolling back on failure.
  Future<void> _saveMany(List<Note> updated) async {
    if (updated.isEmpty) {
      notifyListeners(); // Selection may have been cleared.
      return;
    }
    final Map<String, Note?> previous = <String, Note?>{
      for (final Note n in updated) n.id: byId(n.id),
    };
    for (final Note note in updated) {
      final int index = _indexOf(note.id);
      index < 0 ? _notes.insert(0, note) : _notes[index] = note;
    }
    _invalidate();
    final bool? saved = await runSafe<bool>(() async {
      await _repository.saveAll(updated);
      return true;
    });
    if (saved != null) return;
    previous.forEach(_restore);
    _invalidate();
  }

  void _rollback(String id, Note? previous) {
    _restore(id, previous);
    _invalidate();
  }

  void _restore(String id, Note? previous) {
    final int index = _indexOf(id);
    if (previous == null) {
      if (index >= 0) _notes.removeAt(index);
    } else if (index >= 0) {
      _notes[index] = previous;
    }
  }

  void _invalidate({bool viewOnly = false}) {
    _view = null;
    if (!viewOnly) {
      _counts = null;
      _tags = null;
      _usage = null;
    }
    notifyListeners();
  }

  NotesView _buildView() {
    final NoteStatus status = switch (_query.section) {
      NoteSection.notes => NoteStatus.active,
      NoteSection.archive => NoteStatus.archived,
      NoteSection.trash => NoteStatus.trashed,
    };
    final bool groupPinned = _query.section == NoteSection.notes;
    final List<Note> pinned = <Note>[];
    final List<Note> others = <Note>[];

    for (final Note note in _notes) {
      if (note.status != status ||
          !_matchesCategory(note) ||
          !_matchesTag(note) ||
          !_matchesSearch(note)) {
        continue;
      }
      (groupPinned && note.isPinned ? pinned : others).add(note);
    }
    int byOrder(Note a, Note b) => b.sortOrder.compareTo(a.sortOrder);
    pinned.sort(byOrder);
    others.sort(byOrder);
    return NotesView(
      pinned: List<Note>.unmodifiable(pinned),
      others: List<Note>.unmodifiable(others),
    );
  }

  bool _matchesCategory(Note note) => switch (_query.category) {
    NoteCategory.all => true,
    NoteCategory.audio => note.hasAudio,
    NoteCategory.checklists => note.isChecklist,
    NoteCategory.attachments => note.hasMedia,
    NoteCategory.drawings => note.hasDrawing,
  };

  bool _matchesTag(Note note) =>
      _query.tag == null || note.tags.contains(_query.tag);

  bool _matchesSearch(Note note) {
    if (_search.isEmpty) return true;
    final String text = _searchIndex[note] ??= <String>[
      note.title,
      note.content,
      ...note.checklist.map((ChecklistItem i) => i.text),
      ...note.tags,
      ...note.attachments.map((Attachment a) => a.displayName),
    ].join('\n').toLowerCase();
    return text.contains(_search);
  }

  NoteCounts _buildCounts() {
    int notes = 0,
        audio = 0,
        checklists = 0,
        drawings = 0,
        archive = 0,
        trash = 0;
    for (final Note note in _notes) {
      switch (note.status) {
        case NoteStatus.archived:
          archive++;
        case NoteStatus.trashed:
          trash++;
        case NoteStatus.active:
          notes++;
          if (note.hasAudio) audio++;
          if (note.isChecklist) checklists++;
          if (note.hasDrawing) drawings++;
      }
    }
    return NoteCounts(
      notes: notes,
      audio: audio,
      checklists: checklists,
      drawings: drawings,
      archive: archive,
      trash: trash,
    );
  }

  List<TagCount> _buildTags() {
    final Map<String, int> counter = <String, int>{};
    for (final Note note in _notes) {
      if (note.isTrashed) continue;
      for (final String tag in note.tags) {
        counter[tag] = (counter[tag] ?? 0) + 1;
      }
    }
    final List<TagCount> result =
        counter.entries
            .map((MapEntry<String, int> e) => TagCount(e.key, e.value))
            .toList()
          ..sort((TagCount a, TagCount b) => b.count.compareTo(a.count));
    return List<TagCount>.unmodifiable(result);
  }

  StorageUsage _buildUsage() {
    int audio = 0, images = 0, text = 0;
    for (final Note note in _notes) {
      text += utf8.encode(note.title).length + utf8.encode(note.content).length;
      for (final Attachment a in note.attachments) {
        switch (a.type) {
          case AttachmentType.audio:
            audio += a.sizeBytes;
          case AttachmentType.image:
          case AttachmentType.drawing:
            images += a.sizeBytes;
          case AttachmentType.file:
            text += a.sizeBytes;
        }
      }
    }
    return StorageUsage(audioBytes: audio, imageBytes: images, textBytes: text);
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    isBusy.dispose();
    super.dispose();
  }
}
