import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler.dart';
import '../../core/utils/id_generator.dart';
import '../models/attachment.dart';

/// Something picked by the user that can be copied into local storage.
abstract interface class MediaSource {
  String get name;

  /// Writes the source content to [destinationPath].
  Future<void> copyTo(String destinationPath);
}

/// Owns the private `media/` folder where every attachment is stored.
final class MediaStorage {
  Directory? _root;

  Directory get root {
    final Directory? dir = _root;
    if (dir == null) throw StateError('MediaStorage used before init()');
    return dir;
  }

  Future<void> init() async {
    if (_root != null) return;
    final Directory docs = await getApplicationDocumentsDirectory();
    final Directory media = Directory(p.join(docs.path, AppConfig.mediaFolder));
    if (!media.existsSync()) await media.create(recursive: true);
    _root = media;
  }

  String pathOf(String fileName) => p.join(root.path, fileName);

  File fileOf(Attachment attachment) => File(pathOf(attachment.fileName));

  bool exists(Attachment attachment) => fileOf(attachment).existsSync();

  /// Builds a unique file name that keeps the original extension.
  String newFileName(String extension) {
    final String ext = extension.isEmpty
        ? ''
        : '.${extension.replaceFirst('.', '')}';
    return '${IdGenerator.next()}$ext';
  }

  /// Copies a picked [source] into the media folder.
  Future<Attachment> import(MediaSource source, AttachmentType type) {
    return ErrorHandler.guard(
      () async {
        final String fileName = newFileName(p.extension(source.name));
        final String target = pathOf(fileName);
        await source.copyTo(target);
        final int size = await File(target).length();
        return Attachment(
          id: IdGenerator.next(),
          type: type,
          fileName: fileName,
          displayName: source.name,
          sizeBytes: size,
          createdAt: DateTime.now(),
        );
      },
      (Object e, StackTrace s) =>
          MediaException(AppStrings.errorMedia, cause: e, stackTrace: s),
    );
  }

  /// Persists in-memory [bytes] (e.g. a drawing) as a new attachment.
  Future<Attachment> saveBytes(
    Uint8List bytes, {
    required AttachmentType type,
    required String extension,
    required String displayName,
  }) {
    return ErrorHandler.guard(
      () async {
        final String fileName = newFileName(extension);
        await File(pathOf(fileName)).writeAsBytes(bytes, flush: true);
        return Attachment(
          id: IdGenerator.next(),
          type: type,
          fileName: fileName,
          displayName: displayName,
          sizeBytes: bytes.length,
          createdAt: DateTime.now(),
        );
      },
      (Object e, StackTrace s) =>
          MediaException(AppStrings.errorMedia, cause: e, stackTrace: s),
    );
  }

  /// Wraps a file that was already written inside the media folder
  /// (used by the recorder).
  Future<Attachment> adopt(
    String absolutePath, {
    required AttachmentType type,
    required String displayName,
    Duration? duration,
  }) {
    return ErrorHandler.guard(
      () async {
        final File file = File(absolutePath);
        return Attachment(
          id: IdGenerator.next(),
          type: type,
          fileName: p.basename(absolutePath),
          displayName: displayName,
          sizeBytes: await file.length(),
          durationMs: duration?.inMilliseconds,
          createdAt: DateTime.now(),
        );
      },
      (Object e, StackTrace s) =>
          MediaException(AppStrings.errorMedia, cause: e, stackTrace: s),
    );
  }

  /// Copies an attachment's file so a duplicated note owns its own media
  /// (deleting one note must never remove the other's files).
  Future<Attachment> duplicate(Attachment source) {
    return ErrorHandler.guard(
      () async {
        final String fileName = newFileName(p.extension(source.fileName));
        await fileOf(source).copy(pathOf(fileName));
        return Attachment(
          id: IdGenerator.next(),
          type: source.type,
          fileName: fileName,
          displayName: source.displayName,
          sizeBytes: source.sizeBytes,
          durationMs: source.durationMs,
          createdAt: DateTime.now(),
        );
      },
      (Object e, StackTrace s) =>
          MediaException(AppStrings.errorMedia, cause: e, stackTrace: s),
    );
  }

  /// Deletes files silently; a missing file is not an error.
  Future<void> deleteFiles(Iterable<String> fileNames) async {
    for (final String name in fileNames) {
      try {
        final File file = File(pathOf(name));
        if (file.existsSync()) await file.delete();
      } on FileSystemException catch (e, s) {
        ErrorHandler.log(e, s, 'deleteFiles');
      }
    }
  }

  Future<void> deletePath(String absolutePath) async {
    try {
      final File file = File(absolutePath);
      if (file.existsSync()) await file.delete();
    } on FileSystemException catch (e, s) {
      ErrorHandler.log(e, s, 'deletePath');
    }
  }
}
