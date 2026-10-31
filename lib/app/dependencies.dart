import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../core/errors/error_handler.dart';
import '../data/datasources/legacy_note_source.dart';
import '../data/datasources/media_storage.dart';
import '../data/datasources/note_local_source.dart';
import '../data/datasources/settings_local_source.dart';
import '../data/models/note.dart';
import '../data/repositories/note_repository.dart';
import '../data/services/backup_service.dart';
import '../data/services/picker_service.dart';

/// Composition root: creates and initializes every long-lived object once,
/// before the first frame, so the UI starts with data already loaded.
final class AppDependencies {
  AppDependencies._({
    required this.settings,
    required this.media,
    required this.repository,
    required this.backup,
    required this.picker,
    required this.initialNotes,
  });

  final SettingsLocalSource settings;
  final MediaStorage media;
  final NoteRepository repository;
  final BackupService backup;
  final PickerService picker;
  final List<Note> initialNotes;

  static Future<AppDependencies> init() async {
    await Hive.initFlutter();

    final SettingsLocalSource settings = SettingsLocalSource();
    final NoteLocalSource notes = NoteLocalSource();
    final MediaStorage media = MediaStorage();
    await Future.wait(<Future<void>>[
      settings.init(),
      notes.init(),
      media.init(),
    ]);
    await _importLegacyNotes(settings, notes);

    final NoteRepository repository = LocalNoteRepository(notes, media);
    return AppDependencies._(
      settings: settings,
      media: media,
      repository: repository,
      backup: BackupService(media),
      picker: PickerService(),
      initialNotes: await repository.loadAll(),
    );
  }

  /// Copies notes of version 1.x into Hive the first time v2 starts.
  ///
  /// Notes already present (same id) are skipped, so an interrupted import
  /// can safely run again. The flag is only set after a successful write;
  /// on failure the app still starts and retries on the next launch.
  static Future<void> _importLegacyNotes(
    SettingsLocalSource settings,
    NoteLocalSource notes,
  ) async {
    if (settings.legacyImported) return;
    try {
      final List<Note> legacy = await const LegacyNoteSource().readAll();
      final List<Note> missing = legacy
          .where((Note n) => !notes.contains(n.id))
          .toList(growable: false);
      if (missing.isNotEmpty) await notes.putAll(missing);
      await settings.setLegacyImported();
    } catch (error, stackTrace) {
      ErrorHandler.log(error, stackTrace, 'Legacy notes import failed');
    }
  }
}
