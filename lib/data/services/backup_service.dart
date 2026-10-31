import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../../core/constants/constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler.dart';
import '../datasources/media_storage.dart';
import '../models/attachment.dart';
import '../models/note.dart';

/// Creates and restores a single `.zip` containing `notes.json` + all media.
///
/// Zipping/unzipping runs on a background isolate so the UI never janks.
final class BackupService {
  const BackupService(this._media);

  final MediaStorage _media;

  /// Returns `true` when saved, `false` if the user cancelled the dialog.
  Future<bool> export(List<Note> notes) {
    return ErrorHandler.guard(
      () async {
        final String json = jsonEncode(<String, dynamic>{
          'version': AppConfig.backupSchemaVersion,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'notes': notes.map((Note n) => n.toJson()).toList(growable: false),
        });
        final List<String> mediaPaths = <String>[
          for (final Note note in notes)
            for (final Attachment a in note.attachments)
              _media.pathOf(a.fileName),
        ];

        final Uint8List bytes = await Isolate.run(() => _zip(json, mediaPaths));
        final Uri? saved = await FilePicker.saveFile(
          fileName:
              '${AppConfig.backupFilePrefix}${DateTime.now().millisecondsSinceEpoch}.${AppConfig.backupExtension}',
          bytes: bytes,
          mimeType: 'application/zip',
        );
        return saved != null;
      },
      (Object e, StackTrace s) =>
          BackupException(AppStrings.errorBackup, cause: e, stackTrace: s),
    );
  }

  /// Extracts media into local storage and returns the notes contained in
  /// the archive.
  Future<List<Note>> restore(PlatformFile file) {
    return ErrorHandler.guard(
      () async {
        final Uint8List bytes = await file.readAsBytes();
        final String mediaRoot = _media.root.path;
        return Isolate.run(() => _unzip(bytes, mediaRoot));
      },
      (Object e, StackTrace s) =>
          BackupException(AppStrings.errorRestore, cause: e, stackTrace: s),
    );
  }

  static Uint8List _zip(String notesJson, List<String> mediaPaths) {
    final Archive archive = Archive()
      ..add(ArchiveFile.string(AppConfig.backupNotesEntry, notesJson));
    for (final String path in mediaPaths) {
      final File file = File(path);
      if (!file.existsSync()) continue;
      archive.add(
        ArchiveFile.bytes(
          '${AppConfig.backupMediaPrefix}${p.basename(path)}',
          file.readAsBytesSync(),
        ),
      );
    }
    return ZipEncoder().encodeBytes(archive);
  }

  static List<Note> _unzip(Uint8List bytes, String mediaRoot) {
    final Archive archive = ZipDecoder().decodeBytes(bytes);
    String? notesJson;

    for (final ArchiveFile entry in archive) {
      if (!entry.isFile) continue;
      if (entry.name == AppConfig.backupNotesEntry) {
        notesJson = utf8.decode(entry.content);
      } else if (entry.name.startsWith(AppConfig.backupMediaPrefix)) {
        // basename() blocks path traversal ("../") from crafted archives.
        final String target = p.join(mediaRoot, p.basename(entry.name));
        File(target).writeAsBytesSync(entry.content, flush: true);
      }
    }

    if (notesJson == null) throw const FormatException('notes.json missing');
    final Map<String, dynamic> root =
        jsonDecode(notesJson) as Map<String, dynamic>;
    final List<dynamic> list =
        root['notes'] as List<dynamic>? ?? const <dynamic>[];
    return list
        .whereType<Map<String, dynamic>>()
        .map(Note.fromJson)
        .toList(growable: false);
  }
}
