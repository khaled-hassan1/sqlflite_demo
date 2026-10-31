import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

import '../../core/constants/app_config.dart';
import '../../core/theme/app_theme_color.dart';

/// Small key/value store for user preferences.
final class SettingsLocalSource {
  Box<dynamic>? _box;

  Box<dynamic> get _settings {
    final Box<dynamic>? box = _box;
    if (box == null || !box.isOpen) {
      throw StateError('SettingsLocalSource used before init()');
    }
    return box;
  }

  Future<void> init() async {
    _box ??= await Hive.openBox<dynamic>(AppConfig.settingsBox);
  }

  ThemeMode get themeMode {
    final Object? index = _settings.get(AppConfig.themeModeKey);
    return index is int && index >= 0 && index < ThemeMode.values.length
        ? ThemeMode.values[index]
        : ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _settings.put(AppConfig.themeModeKey, mode.index);

  bool get isGridView =>
      _settings.get(AppConfig.gridViewKey, defaultValue: true) as bool? ?? true;

  Future<void> setGridView(bool value) =>
      _settings.put(AppConfig.gridViewKey, value);

  AppThemeColor get themeColor =>
      AppThemeColor.fromName(_settings.get(AppConfig.themeColorKey) as String?);

  Future<void> setThemeColor(AppThemeColor color) =>
      _settings.put(AppConfig.themeColorKey, color.name);

  /// Whether notes from version 1.x were already copied into Hive.
  bool get legacyImported =>
      _settings.get(AppConfig.legacyImportedKey, defaultValue: false)
          as bool? ??
      false;

  Future<void> setLegacyImported() =>
      _settings.put(AppConfig.legacyImportedKey, true);
}
