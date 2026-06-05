import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/chain_dots.dart';
import '../../../../core/widgets/coin_logo.dart';
import '../../../wallet/domain/entities/chain_family.dart';
import '../../../wallet/domain/entities/wallet_account.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../widgets/account_avatar.dart';
import '../widgets/settings_scaffold.dart';
import '../widgets/settings_section.dart';

/// Account detail / edit: rename the account, copy its address on each chain,
/// and remove it. Resolves the account live from the session by [index] so it
/// reflects renames and disappears cleanly if removed elsewhere.
class AccountDetailScreen extends ConsumerStatefulWidget {
  const AccountDetailScreen({super.key, required this.index});
  final int index;

  @override
  ConsumerState<AccountDetailScreen> createState() =>
      _AccountDetailScreenState();
}

class _AccountDetailScreenState extends ConsumerState<AccountDetailScreen> {
  static const _chainOrder = [
    ChainFamily.solana,
    ChainFamily.evm,
    ChainFamily.bitcoin,
    ChainFamily.sui,
  ];

  final _name = TextEditingController();
  String _initial = '';

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  WalletAccount? _find(List<WalletAccount> accounts) {
    for (final a in accounts) {
      if (a.index == widget.index) return a;
    }
    return null;
  }

  List<ChainFamily> _families(WalletAccount a) =>
      [for (final f in _chainOrder) if (a.account(f) != null) f];

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty || name == _initial) return;
    FocusScope.of(context).unfocus();
    try {
      await ref
          .read(walletSessionProvider.notifier)
          .renameAccount(widget.index, name);
      if (!mounted) return;
      setState(() => _initial = name);
      _toast('Name updated');
    } catch (e) {
      debugPrint('renameAccount failed: $e');
      if (mounted) _toast('Couldn’t save name');
    }
  }

  Future<void> _remove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _RemoveDialog(),
    );
    if (confirmed != true) return;
    try {
      await ref.read(walletSessionProvider.notifier).removeAccount(widget.index);
      if (mounted) Navigator.of(context).maybePop();
    } catch (e) {
      debugPrint('removeAccount failed: $e');
      if (mounted) _toast('Couldn’t remove account');
    }
  }

  void _copy(String label, String address) {
    Clipboard.setData(ClipboardData(text: address));
    _toast('$label address copied');
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: NB.surface2,
        behavior: SnackBarBehavior.floating,
        content: Text(msg, style: NB.font(13, color: NB.text)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(walletSessionProvider);
    final account = _find(session.accounts);

    // Removed elsewhere — leave this screen.
    if (account == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
      return const Scaffold(backgroundColor: Colors.transparent);
    }

    // Seed the name field once.
    if (_initial.isEmpty && account.label.isNotEmpty) {
      _initial = account.label;
      _name.text = account.label;
    }

    final families = _families(account);
    final canRemove = session.accounts.length > 1;

    return SettingsScaffold(
      title: 'Account',
      children: [
        Center(child: AccountAvatar(label: account.label, size: 76)),
        const SizedBox(height: 12),
        Center(
          child: ChainDots(
            networks: [for (final f in families) ChainDots.representative(f)],
            size: 24,
          ),
        ),
        const SizedBox(height: 24),
        _NameField(controller: _name, onSave: _save),
        const SizedBox(height: 20),
        SettingsSection(
          title: 'Addresses',
          children: [
            for (final f in families)
              _AddressRow(
                family: f,
                address: account.account(f)!.address,
                onCopy: () => _copy(f.displayName, account.account(f)!.address),
              ),
          ],
        ),
        if (canRemove) ...[
          const SizedBox(height: 22),
          _RemoveButton(onTap: _remove),
        ],
      ],
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller, required this.onSave});
  final TextEditingController controller;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text('NAME',
              style: NB.font(11.5,
                  weight: FontWeight.w700,
                  color: NB.text3,
                  letterSpacing: 0.6)),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
          decoration: BoxDecoration(
            color: NB.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: NB.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLength: 24,
                  cursorColor: NB.orange,
                  style: NB.font(16, weight: FontWeight.w600, color: NB.text),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    counterText: '',
                    border: InputBorder.none,
                    hintText: 'Account name',
                    hintStyle: NB.font(16, color: NB.text3),
                  ),
                  onSubmitted: (_) => onSave(),
                ),
              ),
              TextButton(
                onPressed: onSave,
                child: Text('Save',
                    style: NB.font(14,
                        weight: FontWeight.w700, color: NB.orange)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddressRow extends StatelessWidget {
  const _AddressRow({
    required this.family,
    required this.address,
    required this.onCopy,
  });

  final ChainFamily family;
  final String address;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          CoinLogo(network: ChainDots.representative(family), size: 34),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(family.displayName,
                    style: NB.font(15, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(Fmt.address(address, head: 8, tail: 6),
                    style: NB.font(13, color: NB.text2)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCopy,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.copy_rounded, size: 18, color: NB.text2),
            ),
          ),
        ],
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NB.red.withValues(alpha: 0.5), width: 1.5),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_outline, size: 18, color: NB.red),
            const SizedBox(width: 8),
            Text('Remove account',
                style: NB.font(16, weight: FontWeight.w700, color: NB.red)),
          ],
        ),
      ),
    );
  }
}

class _RemoveDialog extends StatelessWidget {
  const _RemoveDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: NB.surface,
      title: Text('Remove account?',
          style: NB.font(18, weight: FontWeight.w800, color: NB.red)),
      content: Text(
        'This hides the account on this device. It stays recoverable from your '
        'recovery phrase, and you can re-add it later.',
        style: NB.font(14, color: NB.text2, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel', style: NB.font(14, color: NB.text2)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Remove',
              style: NB.font(14, weight: FontWeight.w700, color: NB.red)),
        ),
      ],
    );
  }
}
