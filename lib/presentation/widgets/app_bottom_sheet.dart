import 'package:flutter/material.dart';

/// Single entry point for every modal bottom sheet in the app.
///
/// The app draws edge-to-edge, and `useSafeArea` only guards the top/sides,
/// so the content is wrapped in a bottom [SafeArea] to keep it clear of the
/// system navigation bar (gesture pill or 3-button bar).
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useSafeArea: true,
    isScrollControlled: isScrollControlled,
    builder: (BuildContext sheetContext) =>
        SafeArea(top: false, child: builder(sheetContext)),
  );
}
