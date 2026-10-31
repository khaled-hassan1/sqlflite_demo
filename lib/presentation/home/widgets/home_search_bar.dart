import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../logic/notes_provider.dart';
import '../../../logic/settings_provider.dart';

/// Pill-shaped header: menu, logo, search field, layout toggle, avatar.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    return Padding(
      padding: AppInsets.screen,
      child: Material(
        color: colors.surfaceContainerHigh,
        borderRadius: AppRadius.searchAll,
        child: SizedBox(
          height: AppSizes.searchBarHeight,
          child: Row(
            children: <Widget>[
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                tooltip: AppStrings.openMenu,
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
              // const AppLogo(),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextField(
                  onTapUpOutside: (event) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  onChanged: context.read<NotesProvider>().setSearch,
                  textInputAction: TextInputAction.search,
                  style: context.texts.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: AppStrings.searchHint,
                  ),
                ),
              ),
              const _LayoutToggle(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LayoutToggle extends StatelessWidget {
  const _LayoutToggle();

  @override
  Widget build(BuildContext context) {
    return Selector<SettingsProvider, bool>(
      selector: (_, SettingsProvider s) => s.isGridView,
      builder: (BuildContext context, bool isGrid, _) => IconButton(
        tooltip: isGrid ? AppStrings.listView : AppStrings.gridView,
        icon: Icon(
          isGrid ? Icons.view_agenda_outlined : Icons.grid_view_outlined,
        ),
        onPressed: context.read<SettingsProvider>().toggleGridView,
      ),
    );
  }
}
