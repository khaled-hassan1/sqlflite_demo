import 'package:flutter/material.dart';

import '../screens/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'sqlite',
      theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)))),
        cardTheme: const CardTheme(color: Colors.white, elevation: 0),
        appBarTheme: const AppBarTheme(
            elevation: 0,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 25),
            backgroundColor: Color.fromARGB(234, 228, 73, 22)),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const HomePageScreen(),
    );
  }
}
