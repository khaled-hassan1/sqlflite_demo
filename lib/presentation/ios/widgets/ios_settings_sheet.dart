import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_messenger.dart';
import '../../../data/models/note_query.dart';
import '../../../logic/notes_provider.dart';
import '../../../logic/settings_provider.dart';

class IosSettingsSheet extends StatelessWidget {
  const IosSettingsSheet({super.key});

  static void show(BuildContext context) => showCupertinoModalPopup<void>(
    context: context,
    builder: (_) => const IosSettingsSheet(),
  );

  @override
  Widget build(BuildContext context) {
    final NotesProvider notes = context.read<NotesProvider>();
    return CupertinoActionSheet(
      title: const Text(AppStrings.appName),
      message: const Text(AppStrings.aboutBody),
      actions: <Widget>[
        _action(context, AppStrings.mainNotes, const NoteQuery(), notes),
        _action(
          context,
          AppStrings.voiceRecordings,
          const NoteQuery(category: NoteCategory.audio),
          notes,
        ),
        _action(
          context,
          AppStrings.checklists,
          const NoteQuery(category: NoteCategory.checklists),
          notes,
        ),
        _action(
          context,
          AppStrings.archive,
          const NoteQuery(section: NoteSection.archive),
          notes,
        ),
        _action(
          context,
          AppStrings.trash,
          const NoteQuery(section: NoteSection.trash),
          notes,
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            final BuildContext navigatorContext = Navigator.of(context).context;
            Navigator.pop(context);
            _showTheme(navigatorContext);
          },
          child: const Text(AppStrings.darkMode),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            notes.exportBackup();
          },
          child: const Text(AppStrings.backup),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            notes.importBackup();
          },
          child: const Text(AppStrings.restore),
        ),
        CupertinoActionSheetAction(
          onPressed: () => showCupertinoDialog<void>(
            context: context,
            builder: (BuildContext dialogContext) => CupertinoAlertDialog(
              title: const Text(AppStrings.privacy),
              content: const Text(AppStrings.privacyBody),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _openPrivacyPolicy();
                  },
                  child: const Text(AppStrings.openPrivacyPolicy),
                ),
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(AppStrings.done),
                ),
              ],
            ),
          ),
          child: const Text(AppStrings.privacy),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        child: const Text(AppStrings.cancel),
      ),
    );
  }

  Widget _action(
    BuildContext context,
    String title,
    NoteQuery query,
    NotesProvider notes,
  ) => CupertinoActionSheetAction(
    onPressed: () {
      notes.setQuery(query);
      Navigator.pop(context);
    },
    child: Text(title),
  );

  void _showTheme(BuildContext context) {
    final SettingsProvider settings = context.read<SettingsProvider>();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext popupContext) => CupertinoActionSheet(
        title: const Text(AppStrings.darkMode),
        actions: <Widget>[
          for (final (ThemeMode mode, String label)
              in const <(ThemeMode, String)>[
                (ThemeMode.system, AppStrings.followSystem),
                (ThemeMode.light, 'فاتح'),
                (ThemeMode.dark, 'داكن'),
              ])
            CupertinoActionSheetAction(
              onPressed: () {
                settings.setThemeMode(mode);
                Navigator.pop(popupContext);
              },
              child: Text(label),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(popupContext),
          child: const Text(AppStrings.cancel),
        ),
      ),
    );
  }

  Future<void> _openPrivacyPolicy() async {
    try {
      final bool opened = await launchUrl(
        Uri.parse(AppConfig.privacyPolicyUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) AppMessenger.error(AppStrings.errorGeneric);
    } on Exception catch (error) {
      AppMessenger.error(error);
    }
  }
}
