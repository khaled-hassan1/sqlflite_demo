import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../data/models/attachment.dart';
import '../../data/models/checklist_item.dart';
import '../../data/models/note_color.dart';
import '../../data/services/file_opener.dart';
import '../../logic/audio_playback_provider.dart';
import '../../logic/editor_launch_action.dart';
import '../../logic/note_editor_controller.dart';
import 'ios_voice_recorder_sheet.dart';
import 'ios_drawing_screen.dart';

class IosNoteEditorScreen extends StatelessWidget {
  const IosNoteEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    _runLaunchAction(context);
    return PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) context.read<NoteEditorController>().close();
      },
      child: Selector<NoteEditorController, NoteColor>(
        selector: (_, NoteEditorController editor) => editor.note.color,
        builder: (BuildContext context, NoteColor color, Widget? body) =>
            CupertinoPageScaffold(
              backgroundColor: color == NoteColor.none
                  ? null
                  : color.container(CupertinoTheme.brightnessOf(context)),
              navigationBar: CupertinoNavigationBar(
                leading: CupertinoNavigationBarBackButton(
                  onPressed: () => Navigator.of(context).pop(),
                ),
                middle: Text(
                  context.read<NoteEditorController>().isNew
                      ? AppStrings.newNote
                      : AppStrings.editNote,
                ),
                trailing: const _MoreButton(),
              ),
              child: body!,
            ),
        child: const SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(child: _EditorContent()),
              _EditorToolbar(),
            ],
          ),
        ),
      ),
    );
  }

  void _runLaunchAction(BuildContext context) {
    final EditorLaunchAction action = context
        .read<NoteEditorController>()
        .takeLaunchAction();
    if (action == EditorLaunchAction.none) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      if (action == EditorLaunchAction.image) {
        _EditorToolbar.showImageSource(context);
      } else if (action == EditorLaunchAction.audio) {
        _EditorToolbar.record(context);
      } else if (action == EditorLaunchAction.drawing) {
        _EditorToolbar.draw(context);
      }
    });
  }
}

class _EditorContent extends StatelessWidget {
  const _EditorContent();

  @override
  Widget build(BuildContext context) {
    final NoteEditorController editor = context.read<NoteEditorController>();
    return ListView(
      padding: const EdgeInsets.all(20),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: <Widget>[
        CupertinoTextField.borderless(
          controller: editor.titleController,
          placeholder: AppStrings.titleHint,
          maxLines: null,
          textInputAction: TextInputAction.next,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Selector<NoteEditorController, bool>(
          selector: (_, NoteEditorController e) => e.note.isChecklist,
          builder: (BuildContext context, bool checklist, _) => checklist
              ? const _Checklist()
              : CupertinoTextField.borderless(
                  controller: editor.contentController,
                  placeholder: AppStrings.contentHint,
                  maxLines: null,
                  minLines: 8,
                  keyboardType: TextInputType.multiline,
                ),
        ),
        const _Attachments(),
        const _Tags(),
      ],
    );
  }
}

class _Checklist extends StatelessWidget {
  const _Checklist();

  @override
  Widget build(BuildContext context) =>
      Selector<NoteEditorController, List<ChecklistItem>>(
        selector: (_, NoteEditorController editor) => editor.note.checklist,
        builder: (BuildContext context, List<ChecklistItem> items, _) {
          final NoteEditorController editor = context
              .read<NoteEditorController>();
          return Column(
            children: <Widget>[
              for (final ChecklistItem item in items)
                Row(
                  key: ValueKey<String>(item.id),
                  children: <Widget>[
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => editor.toggleItem(item.id),
                      child: Icon(
                        item.isDone
                            ? CupertinoIcons.check_mark_circled_solid
                            : CupertinoIcons.circle,
                      ),
                    ),
                    Expanded(
                      child: CupertinoTextField.borderless(
                        controller: editor.itemController(item.id),
                        focusNode: editor.itemFocus(item.id),
                        placeholder: AppStrings.listItemHint,
                        maxLines: null,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => editor.removeItem(item.id),
                      child: const Icon(CupertinoIcons.minus_circle, size: 20),
                    ),
                  ],
                ),
              CupertinoButton(
                onPressed: editor.addItem,
                child: const Text(AppStrings.addListItem),
              ),
            ],
          );
        },
      );
}

class _Attachments extends StatelessWidget {
  const _Attachments();

  @override
  Widget build(
    BuildContext context,
  ) => Selector<NoteEditorController, List<Attachment>>(
    selector: (_, NoteEditorController editor) => editor.note.attachments,
    builder: (BuildContext context, List<Attachment> attachments, _) {
      if (attachments.isEmpty) return const SizedBox.shrink();
      final NoteEditorController editor = context.read<NoteEditorController>();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 24),
          const Text(
            AppStrings.attachments,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          for (final Attachment attachment in attachments)
            RepaintBoundary(
              key: ValueKey<String>(attachment.id),
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: <Widget>[
                    if (attachment.type.isVisual)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(editor.media.pathOf(attachment.fileName)),
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                          cacheWidth: 228,
                          errorBuilder: (_, _, _) => const Icon(
                            CupertinoIcons.exclamationmark_triangle,
                          ),
                        ),
                      )
                    else
                      const Icon(CupertinoIcons.paperclip),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerRight,
                        onPressed: () {
                          final String path = editor.media.pathOf(
                            attachment.fileName,
                          );
                          if (attachment.type == AttachmentType.audio) {
                            context.read<AudioPlaybackProvider>().toggle(path);
                          } else {
                            FileOpener.open(path);
                          }
                        },
                        child: Text(
                          attachment.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => editor.removeAttachment(attachment),
                      child: const Icon(CupertinoIcons.clear_circled, size: 20),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _Tags extends StatelessWidget {
  const _Tags();

  @override
  Widget build(BuildContext context) =>
      Selector<NoteEditorController, List<String>>(
        selector: (_, NoteEditorController editor) => editor.note.tags,
        builder: (BuildContext context, List<String> tags, _) => Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Wrap(
            spacing: 6,
            children: <Widget>[
              for (final String tag in tags)
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: () =>
                      context.read<NoteEditorController>().removeTag(tag),
                  child: Text('#$tag ×'),
                ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                onPressed: () => _addTag(context),
                child: const Text(AppStrings.addTag),
              ),
            ],
          ),
        ),
      );

  void _addTag(BuildContext context) {
    final NoteEditorController editor = context.read<NoteEditorController>();
    final TextEditingController input = TextEditingController();
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => CupertinoAlertDialog(
        title: const Text(AppStrings.addTag),
        content: CupertinoTextField(
          controller: input,
          placeholder: AppStrings.tagHint,
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          CupertinoDialogAction(
            onPressed: () {
              editor.addTag(input.text);
              Navigator.pop(dialogContext);
            },
            child: const Text(AppStrings.add),
          ),
        ],
      ),
    ).whenComplete(input.dispose);
  }
}

class _EditorToolbar extends StatelessWidget {
  const _EditorToolbar();

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(color: CupertinoColors.separator.resolveFrom(context)),
      ),
    ),
    height: 54,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () =>
              context.read<NoteEditorController>().toggleChecklist(),
          child: const Icon(CupertinoIcons.checkmark_square),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => showImageSource(context),
          child: const Icon(CupertinoIcons.photo),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.read<NoteEditorController>().pickFiles(),
          child: const Icon(CupertinoIcons.paperclip),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => record(context),
          child: const Icon(CupertinoIcons.mic),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => draw(context),
          child: const Icon(CupertinoIcons.pencil),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showColors(context),
          child: const Icon(CupertinoIcons.paintbrush),
        ),
      ],
    ),
  );

  static void showImageSource(BuildContext context) {
    final NoteEditorController editor = context.read<NoteEditorController>();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext popupContext) => CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(popupContext);
              editor.pickGalleryImages();
            },
            child: const Text(AppStrings.gallery),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(popupContext);
              editor.captureImage();
            },
            child: const Text(AppStrings.camera),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(popupContext),
          child: const Text(AppStrings.cancel),
        ),
      ),
    );
  }

  static Future<void> record(BuildContext context) async {
    final NoteEditorController editor = context.read<NoteEditorController>();
    final Attachment? audio = await IosVoiceRecorderSheet.show(context);
    if (audio != null) editor.addAttachments(<Attachment>[audio]);
  }

  static Future<void> draw(BuildContext context) async {
    final NoteEditorController editor = context.read<NoteEditorController>();
    final png = await IosDrawingScreen.open(context);
    if (png != null) await editor.addDrawing(png);
  }

  void _showColors(BuildContext context) {
    final NoteEditorController editor = context.read<NoteEditorController>();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext popupContext) => CupertinoActionSheet(
        title: const Text(AppStrings.changeColor),
        actions: <Widget>[
          for (final NoteColor color in NoteColor.values)
            CupertinoActionSheetAction(
              onPressed: () {
                editor.setColor(color);
                Navigator.pop(popupContext);
              },
              child: Text(
                color == NoteColor.none ? AppStrings.colorDefault : color.name,
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(popupContext),
          child: const Text(AppStrings.cancel),
        ),
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  const _MoreButton();

  @override
  Widget build(BuildContext context) => CupertinoButton(
    padding: EdgeInsets.zero,
    onPressed: () {
      final NoteEditorController editor = context.read<NoteEditorController>();
      showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext popupContext) => CupertinoActionSheet(
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () {
                editor.togglePin();
                Navigator.pop(popupContext);
              },
              child: Text(
                editor.note.isPinned ? AppStrings.unpin : AppStrings.pin,
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(popupContext);
                editor.toggleArchive().then((_) {
                  if (context.mounted) Navigator.pop(context);
                });
              },
              child: Text(
                editor.note.isArchived
                    ? AppStrings.unarchive
                    : AppStrings.archiveAction,
              ),
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(popupContext);
                editor.moveToTrash().then((_) {
                  if (context.mounted) Navigator.pop(context);
                });
              },
              child: const Text(AppStrings.moveToTrash),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(popupContext),
            child: const Text(AppStrings.cancel),
          ),
        ),
      );
    },
    child: const Icon(CupertinoIcons.ellipsis),
  );
}
