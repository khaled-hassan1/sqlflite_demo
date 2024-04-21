// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import '../screens/home_page.dart';
// import 'generated/l10n.dart';
//
// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     Locale locale = Locale('en');
//     return MaterialApp(
//       locale: locale,
//       localizationsDelegates: const [
//         S.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: const [
//         Locale('en'),
//         Locale('ar'),
//       ],
//       debugShowCheckedModeBanner: false,
//       title: 'sqlite',
//       theme: ThemeData(
//         inputDecorationTheme: const InputDecorationTheme(
//             border: OutlineInputBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(20)))),
//         cardTheme: const CardTheme(color: Colors.white, elevation: 0),
//         appBarTheme: const AppBarTheme(
//             iconTheme: IconThemeData(
//               color: Colors.white,
//               size: 28,
//             ),
//             elevation: 0,
//             titleTextStyle: TextStyle(color: Colors.white, fontSize: 25),
//             backgroundColor: Color.fromARGB(234, 228, 73, 22)),
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
//         useMaterial3: true,
//       ),
//       home:  HomePageScreen(locale: locale,),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
  Locale _locale = const Locale('ar');

  void _changeLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)))),
        cardTheme: const CardTheme(color: Colors.white, elevation: 0),
        appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(
              color: Colors.white,
              size: 28,
            ),
            elevation: 0,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 25),
            backgroundColor: Color.fromARGB(234, 228, 73, 22)),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: HomePageScreen(
        locale: _locale,
        onLocaleChanged: (locale) => _changeLocale(locale),
      ),
    );
  }
}
