import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import 'widgets/drawer_header_card.dart';
import 'widgets/drawer_labels_section.dart';
import 'widgets/drawer_nav_section.dart';
import 'widgets/drawer_settings_section.dart';
import 'widgets/storage_card.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      child: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: AppInsets.allMd,
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed(<Widget>[
                  DrawerHeaderCard(),
                  SizedBox(height: AppSpacing.md),
                  DrawerNavSection(),
                  SizedBox(height: AppSpacing.md),
                  DrawerLabelsSection(),
                  SizedBox(height: AppSpacing.md),
                  StorageCard(),
                  SizedBox(height: AppSpacing.md),
                  DrawerBinSection(),
                  SizedBox(height: AppSpacing.md),
                  DrawerSettingsSection(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
