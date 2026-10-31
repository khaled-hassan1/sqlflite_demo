import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/constants.dart';
import '../core/theme/app_theme.dart';
import '../presentation/widgets/empty_state.dart';

/// Shown when local storage could not be opened at launch.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(child: Text(AppStrings.errorLoad)),
        ),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: EmptyState(
            icon: Icons.error_outline_rounded,
            message: AppStrings.errorLoad,
          ),
        ),
      ),
    );
  }
}
