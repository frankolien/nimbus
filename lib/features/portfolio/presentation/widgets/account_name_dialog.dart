import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';

/// Prompts for a new account name. Returns the entered name, or null if the
/// user cancelled / left it blank / unchanged.
Future<String?> showAccountNameDialog(
  BuildContext context, {
  required String current,
}) async {
  final result = await showDialog<String>(
    context: context,
    builder: (_) => _AccountNameDialog(current: current),
  );
  final trimmed = result?.trim();
  if (trimmed == null || trimmed.isEmpty || trimmed == current) return null;
  return trimmed;
}

/// A stateful dialog so the [TextEditingController]'s lifecycle is tied to the
/// widget — disposed in [State.dispose] after the route is gone, never while the
/// field is still mounted during the close animation.
class _AccountNameDialog extends StatefulWidget {
  const _AccountNameDialog({required this.current});
  final String current;

  @override
  State<_AccountNameDialog> createState() => _AccountNameDialogState();
}

class _AccountNameDialogState extends State<_AccountNameDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.current);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: NB.surface,
      title: Text('Account name', style: NB.font(18, weight: FontWeight.w800)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 24,
        style: NB.font(15, color: NB.text),
        decoration: InputDecoration(
          hintText: 'e.g. Main, Savings',
          hintStyle: NB.font(15, color: NB.text3),
          counterStyle: NB.font(11, color: NB.text3),
          enabledBorder:
              const UnderlineInputBorder(borderSide: BorderSide(color: NB.border)),
          focusedBorder:
              const UnderlineInputBorder(borderSide: BorderSide(color: NB.orange)),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: NB.font(14, color: NB.text2)),
        ),
        TextButton(
          onPressed: _submit,
          child: Text('Save',
              style: NB.font(14, weight: FontWeight.w700, color: NB.orange)),
        ),
      ],
    );
  }
}
