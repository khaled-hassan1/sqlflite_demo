import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/status_badge.dart';
import 'drawer_group.dart';

class DrawerHeaderCard extends StatelessWidget {
  const DrawerHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DrawerGroup(
      color: context.colors.surfaceContainerHigh,
      padding: AppInsets.allLg,
      children: <Widget>[
        Row(
          children: <Widget>[
            const AppLogo(size: AppSizes.logoLarge),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          AppStrings.appName,
                          style: context.texts.titleLarge,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const StatusBadge.local(label: AppStrings.localBadge),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    AppStrings.appSubtitle,
                    style: context.texts.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.cloud_off_rounded, color: context.colors.outline),
          ],
        ),
      ],
    );
  }
}
