import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../onboarding/presentation/xend_error_text.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';

/// Removes the wallet from this device after confirmation. The iCloud backup
/// stays, so the wallet comes back on next launch here or on another device.
Future<void> confirmRemoveWallet(BuildContext context, WidgetRef ref) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => const _ConfirmDialog(
      title: 'Remove wallet from this device?',
      body: 'The signing key is deleted from this phone. Your iCloud Keychain '
          'backup is kept, so the wallet can be restored on any device signed '
          'in to your Apple account. Your funds stay on-chain.',
      action: 'Remove',
    ),
  );
  if (ok != true || !context.mounted) return;
  await _delete(context, ref, wipeBackup: false);
}

/// Erases the wallet and its iCloud backup. Needs the user to type ERASE.
Future<void> confirmEraseWallet(BuildContext context, WidgetRef ref) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => const _ConfirmDialog(
      title: 'Erase wallet and iCloud backup?',
      body: 'This deletes the wallet from this phone and from your iCloud '
          'Keychain, on every device. It cannot be undone. Unless you have '
          'written down your recovery phrase, any funds in this wallet are '
          'lost forever.',
      action: 'Erase',
      typeToConfirm: 'ERASE',
    ),
  );
  if (ok != true || !context.mounted) return;
  await _delete(context, ref, wipeBackup: true);
}

Future<void> _delete(
  BuildContext context,
  WidgetRef ref, {
  required bool wipeBackup,
}) async {
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref
        .read(walletSessionProvider.notifier)
        .deleteWallet(wipeBackup: wipeBackup);
    // The gate now shows onboarding; drop any settings pages above it.
    navigator.popUntil((r) => r.isFirst);
  } catch (e) {
    debugPrint('deleteWallet failed: ${e.runtimeType}');
    messenger.showSnackBar(SnackBar(
      backgroundColor: NB.surface2,
      behavior: SnackBarBehavior.floating,
      content: Text(xendErrorText(e), style: NB.font(13, color: NB.text)),
    ));
  }
}

class _ConfirmDialog extends StatefulWidget {
  const _ConfirmDialog({
    required this.title,
    required this.body,
    required this.action,
    this.typeToConfirm,
  });

  final String title;
  final String body;
  final String action;

  /// When set, the action stays disabled until this word is typed.
  final String? typeToConfirm;

  @override
  State<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<_ConfirmDialog> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  bool get _armed =>
      widget.typeToConfirm == null || _input.text.trim() == widget.typeToConfirm;

  @override
  Widget build(BuildContext context) {
    final word = widget.typeToConfirm;
    return AlertDialog(
      backgroundColor: NB.surface,
      title: Text(widget.title,
          style: NB.font(18, weight: FontWeight.w800, color: NB.red)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.body, style: NB.font(14, color: NB.text2, height: 1.5)),
          if (word != null) ...[
            const SizedBox(height: 16),
            Text('Type $word to confirm.',
                style: NB.font(13, weight: FontWeight.w700, color: NB.text)),
            const SizedBox(height: 8),
            TextField(
              controller: _input,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.characters,
              cursorColor: NB.red,
              onChanged: (_) => setState(() {}),
              style: NB.font(15, weight: FontWeight.w700, color: NB.text),
              decoration: InputDecoration(
                isDense: true,
                hintText: word,
                hintStyle: NB.font(15, color: NB.text3),
                enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: NB.border)),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: NB.red)),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel', style: NB.font(14, color: NB.text2)),
        ),
        TextButton(
          onPressed: _armed ? () => Navigator.pop(context, true) : null,
          child: Text(widget.action,
              style: NB.font(14,
                  weight: FontWeight.w700,
                  color: _armed ? NB.red : NB.text3)),
        ),
      ],
    );
  }
}
