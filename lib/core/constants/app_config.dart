/// App-wide configuration values (storage keys, limits, file naming).
abstract final class AppConfig {
  static const String appVersion = '2.0.0';
  static const String privacyPolicyUrl =
      'https://www.freeprivacypolicy.com/live/bc52653c-a977-4a20-9736-fca01fab04b7';

  // Hive boxes & keys.
  static const String notesBox = 'notes_v1';
  static const String settingsBox = 'settings_v1';
  static const String themeModeKey = 'theme_mode';
  static const String gridViewKey = 'grid_view';
  static const String themeColorKey = 'theme_color';
  static const String legacyImportedKey = 'legacy_sqlite_imported';

  // Notes database of version 1.x (sqflite). Read once, never modified.
  static const String legacyDbName = 'sqflite.db';
  static const String legacyNotesTable = 'notes';
  static const String legacyIdPrefix = 'legacy_';

  // Local media folder inside the app documents directory.
  static const String mediaFolder = 'media';

  // Backup archive layout.
  static const String backupNotesEntry = 'notes.json';
  static const String backupMediaPrefix = 'media/';
  static const String backupFilePrefix = 'my_notes_backup_';
  static const String backupExtension = 'zip';
  static const int backupSchemaVersion = 1;

  // Recording.
  static const String recordingExtension = 'm4a';
  static const int recordingBitRate = 128000;
  static const int recordingSampleRate = 44100;
  static const int waveformBars = 32;
  static const int liveWaveformBars = 36;
  static const double silenceDb = -60;

  // Images.
  static const double pickedImageMaxSide = 2048;
  static const int pickedImageQuality = 85;
  static const String drawingExtension = 'png';

  // Card previews.
  static const int cardMaxChecklistItems = 5;
  static const int cardMaxTags = 3;
  static const int cardTitleMaxLines = 2;
  static const int cardContentMaxLines = 8;

  // Decoding notes in a background isolate beyond this count.
  static const int isolateDecodeThreshold = 300;

  static const List<double> playbackSpeeds = <double>[1, 1.5, 2];
}
