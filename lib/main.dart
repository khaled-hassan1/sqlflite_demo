import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite_demo/widgets/app_settings.dart';

import '../screens/home_page.dart';
import './generated/l10n.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.light;
  bool _isDark = true;

  void _toggleThemeMode() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

      _isDark = !_isDark;
    });
  }

  void _changeLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  Future<void> _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString('language_code') ?? 'ar';
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  Future<void> _saveLocale(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
  }

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (BuildContext context) {
        final localizations = S.of(context);
        return localizations.appName;
      },
      locale: _locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      darkTheme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)))),
        cardTheme: const CardThemeData(color: AppSettings.white, elevation: 0),
        appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(
              color: Colors.white,
              size: 28,
            ),
            elevation: 0,
            titleTextStyle: TextStyle(color: AppSettings.white, fontSize: 25),
            backgroundColor: Color.fromARGB(234, 228, 73, 22)),
        colorScheme: ColorScheme.fromSeed(seedColor: AppSettings.deepOrange),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: HomePageScreen(
          isDark: _isDark,
          onThemeModeChanged: _toggleThemeMode,
          locale: _locale,
          onLocaleChanged: (locale, langCode) {
            _saveLocale(langCode);
            _changeLocale(locale);
          }),
    );
  }
}
