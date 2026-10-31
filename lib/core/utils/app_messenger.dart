import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../constants/constants.dart';
import '../errors/app_exception.dart';

/// Shows snack bars from anywhere (providers included) without needing a
/// [BuildContext], through a global [ScaffoldMessengerState] key.
abstract final class AppMessenger {
  static final GlobalKey<ScaffoldMessengerState> key =
      GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void info(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(message, actionLabel: actionLabel, onAction: onAction);
  }

  static void error(Object error) {
    _show(
      error is AppException ? error.message : AppStrings.errorGeneric,
      isError: true,
    );
  }

  static void _show(
    String message, {
    bool isError = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final ScaffoldMessengerState? messenger = key.currentState;
    if (messenger == null && !isError) {
      // Deferred like the dialog below, so a pop callback can show it.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showCupertinoSnackBar(message, actionLabel, onAction),
      );
      return;
    }
    if (messenger == null) {
      // Deferred so callers in the middle of a navigation (e.g. a pop
      // callback) don't push while the navigator is locked.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final BuildContext? context = navigatorKey.currentContext;
        if (context == null) return;
        showCupertinoDialog<void>(
          context: context,
          builder: (BuildContext dialogContext) => CupertinoAlertDialog(
            content: Text(message),
            actions: <Widget>[
              if (actionLabel != null && onAction != null)
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    onAction();
                  },
                  child: Text(actionLabel),
                ),
              CupertinoDialogAction(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(AppStrings.done),
              ),
            ],
          ),
        );
      });
      return;
    }
    final ColorScheme colors = Theme.of(messenger.context).colorScheme;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: AppDurations.snackBar,
          backgroundColor: isError ? colors.error : null,
          action: actionLabel == null || onAction == null
              ? null
              : SnackBarAction(label: actionLabel, onPressed: onAction),
        ),
      );
  }

  static OverlayEntry? _cupertinoSnackBar;

  static void _showCupertinoSnackBar(
    String message,
    String? actionLabel,
    VoidCallback? onAction,
  ) {
    final OverlayState? overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;
    _cupertinoSnackBar?.remove();
    late final OverlayEntry entry;
    void dismiss() {
      if (_cupertinoSnackBar != entry) return;
      entry.remove();
      _cupertinoSnackBar = null;
    }

    entry = OverlayEntry(
      builder: (_) => _CupertinoSnackBar(
        message: message,
        actionLabel: actionLabel,
        onAction: onAction == null
            ? null
            : () {
                dismiss();
                onAction();
              },
        onDismissed: dismiss,
      ),
    );
    _cupertinoSnackBar = entry;
    overlay.insert(entry);
  }
}

/// iOS counterpart of a Material [SnackBar]: slides up from the bottom and
/// hides itself after [AppDurations.snackBar].
class _CupertinoSnackBar extends StatefulWidget {
  const _CupertinoSnackBar({
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.onDismissed,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismissed;

  @override
  State<_CupertinoSnackBar> createState() => _CupertinoSnackBarState();
}

class _CupertinoSnackBarState extends State<_CupertinoSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  )..forward();

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(AppDurations.snackBar, () async {
      if (!mounted) return;
      await _controller.reverse();
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Positioned(
    left: 16,
    right: 16,
    bottom: MediaQuery.paddingOf(context).bottom + 16,
    child: FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: const Color(0xF0323232),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 14,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              if (widget.actionLabel != null && widget.onAction != null)
                CupertinoButton(
                  padding: const EdgeInsetsDirectional.only(start: 12),
                  minimumSize: const Size(0, 36),
                  onPressed: widget.onAction,
                  child: Text(
                    widget.actionLabel!,
                    style: const TextStyle(
                      color: Color(0xFF8FD3C4),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
