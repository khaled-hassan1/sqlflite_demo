import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_palette.dart';

/// Shows a destructive-action confirmation. Resolves to `true` on confirm.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = AppStrings.confirm,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: context.colors.error,
            foregroundColor: context.colors.onError,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Single text-field dialog (used for adding tags). Resolves to the text or
/// `null` when cancelled.
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  required String hint,
}) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) =>
        _TextInputDialog(title: title, hint: hint),
  );
}

/// Stateful only to own the [TextEditingController]'s lifecycle
/// (no `setState` involved).
class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    final String value = _controller.text.trim();
    Navigator.pop(context, value.isEmpty ? null : value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixText: AppStrings.tagPrefix,
          border: const UnderlineInputBorder(),
          enabledBorder: const UnderlineInputBorder(),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: context.colors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(onPressed: _submit, child: const Text(AppStrings.add)),
      ],
    );
  }
}
