import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../core/errors/app_exception.dart';
import '../core/errors/error_handler.dart';
import '../core/theme/app_theme_color.dart';
import '../core/utils/safe_runner.dart';
import '../data/datasources/settings_local_source.dart';

/// Theme mode and layout preferences.
final class SettingsProvider extends ChangeNotifier with SafeRunner {
  SettingsProvider(this._source)
    : _themeMode = _source.themeMode,
      _themeColor = _source.themeColor,
      _isGridView = _source.isGridView;

  final SettingsLocalSource _source;

  ThemeMode _themeMode;
  AppThemeColor _themeColor;
  bool _isGridView;

  ThemeMode get themeMode => _themeMode;
  AppThemeColor get themeColor => _themeColor;
  bool get isGridView => _isGridView;

  /// Whether dark mode is effectively on, given the platform brightness.
  bool isDarkEffective(Brightness platformBrightness) => switch (_themeMode) {
    ThemeMode.dark => true,
    ThemeMode.light => false,
    ThemeMode.system => platformBrightness == Brightness.dark,
  };

  Future<void> setDarkMode(bool isDark) =>
      setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _persist(() => _source.setThemeMode(mode));
  }

  Future<void> setThemeColor(AppThemeColor color) async {
    if (color == _themeColor) return;
    _themeColor = color;
    notifyListeners();
    await _persist(() => _source.setThemeColor(color));
  }

  Future<void> toggleGridView() async {
    _isGridView = !_isGridView;
    notifyListeners();
    await _persist(() => _source.setGridView(_isGridView));
  }

  Future<void> _persist(Future<void> Function() write) => runSafe(
    () => ErrorHandler.guard(
      write,
      (Object e, StackTrace s) =>
          StorageException(AppStrings.errorSettings, cause: e, stackTrace: s),
    ),
  );
}
