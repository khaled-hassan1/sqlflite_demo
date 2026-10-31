import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';

/// Replaces Flutter's red error screen in release builds with a quiet
/// placeholder, so a single broken widget never takes the page down.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key});

  static Widget fromDetails(FlutterErrorDetails details) {
    if (kDebugMode) return ErrorWidget(details.exception);
    return const ErrorView();
  }

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: AppInsets.allMd,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.error_outline_rounded,
            size: AppSizes.iconSm,
            color: AppColors.lightOutline,
          ),
          SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              AppStrings.errorScreen,
              textDirection: TextDirection.rtl,
              style: AppTextStyles.labelMd,
            ),
          ),
        ],
      ),
    );
  }
}
