import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/dependencies.dart';
import 'app/notes_app.dart';
import 'app/startup_error_app.dart';
import 'core/errors/error_handler.dart';
import 'presentation/widgets/error_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorHandler.installGlobalHandlers();
  ErrorWidget.builder = ErrorView.fromDetails;
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  try {
    final AppDependencies dependencies = await AppDependencies.init();
    runApp(NotesApp(dependencies: dependencies));
  } catch (error, stackTrace) {
    ErrorHandler.log(error, stackTrace, 'Startup failed');
    runApp(const StartupErrorApp());
  }
}
