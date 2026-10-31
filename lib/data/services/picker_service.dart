import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import '../../core/constants/constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler.dart';
import '../datasources/media_storage.dart';

/// [MediaSource] backed by an `image_picker` [XFile] (always a real path).
final class _XFileSource implements MediaSource {
  const _XFileSource(this._file);

  final XFile _file;

  @override
  String get name => _file.name;

  @override
  Future<void> copyTo(String destinationPath) => _file.saveTo(destinationPath);
}

/// [MediaSource] backed by a `file_picker` [PlatformFile], which may be a
/// `content://` uri on Android, so it is streamed instead of copied by path.
final class _PlatformFileSource implements MediaSource {
  const _PlatformFileSource(this._file);

  final PlatformFile _file;

  @override
  String get name => _file.name;

  @override
  Future<void> copyTo(String destinationPath) async {
    final String? path = _file.path;
    if (path != null) {
      await File(path).copy(destinationPath);
      return;
    }
    final IOSink sink = File(destinationPath).openWrite();
    try {
      await sink.addStream(_file.readAsByteStream());
    } finally {
      await sink.close();
    }
  }
}

/// Wraps the image and file pickers and normalizes their errors.
final class PickerService {
  PickerService({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker() {
    // Use the system Android Photo Picker: no READ_MEDIA_* permission needed
    // (required by Google Play's photo & video permissions policy).
    final ImagePickerPlatform platform = ImagePickerPlatform.instance;
    if (platform is ImagePickerAndroid) platform.useAndroidPhotoPicker = true;
  }

  final ImagePicker _imagePicker;

  Future<List<MediaSource>> pickGalleryImages() => _guard(() async {
    final List<XFile> files = await _imagePicker.pickMultiImage(
      maxWidth: AppConfig.pickedImageMaxSide,
      maxHeight: AppConfig.pickedImageMaxSide,
      imageQuality: AppConfig.pickedImageQuality,
    );
    return files.map<MediaSource>(_XFileSource.new).toList(growable: false);
  });

  Future<List<MediaSource>> captureImage() => _guard(() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: AppConfig.pickedImageMaxSide,
      maxHeight: AppConfig.pickedImageMaxSide,
      imageQuality: AppConfig.pickedImageQuality,
    );
    return file == null
        ? const <MediaSource>[]
        : <MediaSource>[_XFileSource(file)];
  });

  Future<List<MediaSource>> pickFiles() => _guard(() async {
    final List<PlatformFile> files = await FilePicker.pickFiles();
    return files
        .map<MediaSource>(_PlatformFileSource.new)
        .toList(growable: false);
  });

  /// Picks a backup archive; returns `null` if the user cancelled.
  Future<PlatformFile?> pickBackup() => ErrorHandler.guard(
    () => FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const <String>[AppConfig.backupExtension],
    ),
    (Object e, StackTrace s) =>
        MediaException(AppStrings.errorPicker, cause: e, stackTrace: s),
  );

  Future<List<MediaSource>> _guard(
    Future<List<MediaSource>> Function() action,
  ) {
    return ErrorHandler.guard(action, (Object e, StackTrace s) {
      if (e is PlatformException && e.code.contains('access_denied')) {
        return PermissionException(
          AppStrings.errorCameraPermission,
          cause: e,
          stackTrace: s,
        );
      }
      return MediaException(AppStrings.errorPicker, cause: e, stackTrace: s);
    });
  }
}
