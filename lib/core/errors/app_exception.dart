/// Base type of every error the app knows how to present to the user.
///
/// Lower layers catch raw platform/IO errors and rethrow them as one of these
/// subtypes carrying a user-friendly [message]; the presentation layer only
/// ever has to deal with [AppException].
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause, this.stackTrace});

  /// Localized, user-facing message.
  final String message;

  /// Original error, kept for logging.
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() =>
      '$runtimeType: $message${cause == null ? '' : ' (cause: $cause)'}';
}

/// Reading or writing the local database failed.
final class StorageException extends AppException {
  const StorageException(super.message, {super.cause, super.stackTrace});
}

/// Copying, reading or deleting a media file failed.
final class MediaException extends AppException {
  const MediaException(super.message, {super.cause, super.stackTrace});
}

/// A runtime permission (microphone, camera, photos) was denied.
final class PermissionException extends AppException {
  const PermissionException(super.message, {super.cause, super.stackTrace});
}

/// Recording or playing audio failed.
final class AudioException extends AppException {
  const AudioException(super.message, {super.cause, super.stackTrace});
}

/// Creating or restoring a backup archive failed.
final class BackupException extends AppException {
  const BackupException(super.message, {super.cause, super.stackTrace});
}
