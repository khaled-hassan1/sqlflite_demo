import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/constants.dart';
import '../../data/models/attachment.dart';
import '../../logic/note_editor_controller.dart';
import '../drawing/drawing_screen.dart';
import '../recorder/voice_recorder_sheet.dart';
import '../viewer/image_viewer_screen.dart';
import '../../logic/editor_launch_action.dart';
import '../widgets/app_bottom_sheet.dart';

/// Editor actions that need navigation (sheets, screens). Shared by the
/// bottom toolbar and the quick-capture launch actions — one implementation.
abstract final class EditorActions {
  static Future<void> run(BuildContext context, EditorLaunchAction action) =>
      switch (action) {
        EditorLaunchAction.none => Future<void>.value(),
        EditorLaunchAction.image => addImage(context),
        EditorLaunchAction.drawing => draw(context),
        EditorLaunchAction.audio => record(context),
      };

  /// Lets the user choose gallery or camera.
  static Future<void> addImage(BuildContext context) async {
    final NoteEditorController editor = context.read<NoteEditorController>();
    final bool? fromCamera = await showAppBottomSheet<bool>(
      context: context,
      builder: (BuildContext context) => const _ImageSourceSheet(),
    );
    if (fromCamera == null) return;
    await (fromCamera ? editor.captureImage() : editor.pickGalleryImages());
  }

  static Future<void> attachFile(BuildContext context) =>
      context.read<NoteEditorController>().pickFiles();

  static Future<void> draw(BuildContext context) async {
    final NoteEditorController editor = context.read<NoteEditorController>();
    final Uint8List? png = await DrawingScreen.open(context);
    if (png != null) await editor.addDrawing(png);
  }

  static Future<void> record(BuildContext context) async {
    final NoteEditorController editor = context.read<NoteEditorController>();
    final Attachment? audio = await VoiceRecorderSheet.show(context);
    if (audio != null) editor.addAttachments(<Attachment>[audio]);
  }

  static void openVisual(
    BuildContext context,
    List<Attachment> visuals,
    int index,
  ) {
    final NoteEditorController editor = context.read<NoteEditorController>();
    ImageViewerScreen.open(
      context,
      images: visuals
          .map(
            (Attachment a) => (id: a.id, path: editor.media.pathOf(a.fileName)),
          )
          .toList(),
      initialIndex: index,
    );
  }
}

class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.photo_library_outlined),
          title: const Text(AppStrings.gallery),
          onTap: () => Navigator.pop(context, false),
        ),
        ListTile(
          leading: const Icon(Icons.photo_camera_outlined),
          title: const Text(AppStrings.camera),
          onTap: () => Navigator.pop(context, true),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}
