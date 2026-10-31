import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../core/constants/constants.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_theme_color.dart';
import '../core/utils/app_messenger.dart';
import '../data/datasources/media_storage.dart';
import '../data/services/picker_service.dart';
import '../logic/audio_playback_provider.dart';
import '../logic/notes_provider.dart';
import '../logic/settings_provider.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/ios/ios_home_screen.dart';
import 'dependencies.dart';

class NotesApp extends StatelessWidget {
  const NotesApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  static const Locale _arabic = Locale('ar');

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<MediaStorage>.value(value: dependencies.media),
        Provider<PickerService>.value(value: dependencies.picker),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(dependencies.settings),
        ),
        ChangeNotifierProvider<AudioPlaybackProvider>(
          create: (_) => AudioPlaybackProvider(),
        ),
        ChangeNotifierProvider<NotesProvider>(
          create: (_) => NotesProvider(
            repository: dependencies.repository,
            backup: dependencies.backup,
            picker: dependencies.picker,
            initialNotes: dependencies.initialNotes,
          ),
        ),
      ],
      // Only the theme mode and color can rebuild MaterialApp.
      child: Selector<SettingsProvider, (ThemeMode, AppThemeColor)>(
        selector: (_, SettingsProvider s) => (s.themeMode, s.themeColor),
        builder:
            (
              BuildContext context,
              (ThemeMode, AppThemeColor) look,
              Widget? home,
            ) {
              final (ThemeMode mode, AppThemeColor color) = look;
              if (defaultTargetPlatform == TargetPlatform.iOS) {
                return CupertinoApp(
                  title: AppStrings.appShortName,
                  debugShowCheckedModeBanner: false,
                  navigatorKey: AppMessenger.navigatorKey,
                  theme: CupertinoThemeData(
                    brightness: switch (mode) {
                      ThemeMode.dark => Brightness.dark,
                      ThemeMode.light => Brightness.light,
                      ThemeMode.system => MediaQuery.platformBrightnessOf(
                        context,
                      ),
                    },
                    primaryColor: color.seed,
                    textTheme: CupertinoTextThemeData(
                      // Without this the back button falls back to systemBlue.
                      primaryColor: color.seed,
                      textStyle: const TextStyle(
                        fontFamily: 'NotoSansArabic',
                        color: CupertinoColors.label,
                      ),
                    ),
                  ),
                  locale: _arabic,
                  supportedLocales: const <Locale>[_arabic],
                  localizationsDelegates: GlobalMaterialLocalizations.delegates,
                  home: const IosHomeScreen(),
                );
              }
              return MaterialApp(
                title: AppStrings.appName,
                debugShowCheckedModeBanner: false,
                scaffoldMessengerKey: AppMessenger.key,
                theme: AppTheme.of(color, Brightness.light),
                darkTheme: AppTheme.of(color, Brightness.dark),
                themeMode: mode,
                locale: _arabic,
                supportedLocales: const <Locale>[_arabic],
                localizationsDelegates: GlobalMaterialLocalizations.delegates,
                home: home,
              );
            },
        child: const HomeScreen(),
      ),
    );
  }
}
