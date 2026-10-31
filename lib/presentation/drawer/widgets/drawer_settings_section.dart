import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../logic/settings_provider.dart';
import '../../widgets/app_logo.dart';
import 'drawer_group.dart';
import 'theme_color_picker.dart';

/// Dark-mode switch and "about".
class DrawerSettingsSection extends StatelessWidget {
  const DrawerSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return DrawerGroup(
      children: <Widget>[
        const _DarkModeTile(),
        const ThemeColorPicker(),
        ListTile(
          leading: const Icon(Icons.info_outline_rounded),
          title: const Text(AppStrings.about),
          onTap: () => showAboutDialog(
            context: context,
            applicationName: AppStrings.appName,
            applicationVersion: AppConfig.appVersion,
            applicationIcon: const AppLogo(size: AppSizes.logoLarge),
            children: const <Widget>[Text(AppStrings.aboutBody)],
          ),
        ),
      ],
    );
  }
}

class _DarkModeTile extends StatelessWidget {
  const _DarkModeTile();

  @override
  Widget build(BuildContext context) {
    final Brightness platform = MediaQuery.platformBrightnessOf(context);
    return Selector<SettingsProvider, bool>(
      selector: (_, SettingsProvider s) => s.isDarkEffective(platform),
      builder: (BuildContext context, bool isDark, _) => SwitchListTile(
        secondary: const Icon(Icons.palette_outlined),
        title: const Text(AppStrings.darkMode),
        subtitle: const Text(AppStrings.darkModeSubtitle),
        value: isDark,
        thumbIcon: WidgetStatePropertyAll<Icon>(
          Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: context.colors.primary,
          ),
        ),
        onChanged: context.read<SettingsProvider>().setDarkMode,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),
    );
  }
}
