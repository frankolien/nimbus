import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../onboarding/presentation/widgets/nimbus_widgets.dart';
import '../../../wallet/domain/entities/chain_family.dart';
import '../../data/evm_send_service.dart';
import '../../data/solana_send_service.dart';
import '../../domain/saved_address.dart';
import '../providers/address_providers.dart';

/// Add or edit a saved address. Pass [existing] to edit, or [prefillAddress] to
/// seed a new entry from the recipient field. The address is validated against
/// [family].
Future<void> showSaveAddressSheet(
  BuildContext context, {
  required ChainFamily family,
  SavedAddress? existing,
  String? prefillAddress,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: NB.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _SaveAddressSheet(
      family: family,
      existing: existing,
      prefillAddress: prefillAddress,
    ),
  );
}

class _SaveAddressSheet extends ConsumerStatefulWidget {
  const _SaveAddressSheet({
    required this.family,
    this.existing,
    this.prefillAddress,
  });

  final ChainFamily family;
  final SavedAddress? existing;
  final String? prefillAddress;

  @override
  ConsumerState<_SaveAddressSheet> createState() => _SaveAddressSheetState();
}

class _SaveAddressSheetState extends ConsumerState<_SaveAddressSheet> {
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.label ?? '');
  late final TextEditingController _address = TextEditingController(
      text: widget.existing?.address ?? widget.prefillAddress ?? '');
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  bool _isValidAddress(String a) => widget.family == ChainFamily.solana
      ? SolanaSendService.isValidAddress(a)
      : EvmSendService.isValidAddress(a);

  Future<void> _save() async {
    final label = _name.text.trim();
    final address = _address.text.trim();
    if (label.isEmpty) {
      setState(() => _error = 'Give this address a name.');
      return;
    }
    if (!_isValidAddress(address)) {
      setState(() => _error = 'That doesn\'t look like a valid address.');
      return;
    }
    final entry =
        SavedAddress(address: address, label: label, family: widget.family);
    final notifier = ref.read(savedAddressesProvider.notifier);
    if (widget.existing != null) {
      await notifier.replace(widget.existing!, entry);
    } else {
      await notifier.add(entry);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: NB.surface3, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 18),
          Text(editing ? 'Edit address' : 'Save address',
              style: NB.font(19, weight: FontWeight.w800)),
          const SizedBox(height: 18),
          _label('Name'),
          _field(_name, 'e.g. My Ledger'),
          const SizedBox(height: 14),
          _label('Address'),
          _field(_address, 'Recipient address'),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: NB.font(13, color: NB.red)),
          ],
          const SizedBox(height: 22),
          NbButton(label: editing ? 'Save changes' : 'Save address', onTap: _save),
        ],
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(t,
            style: NB.font(13, weight: FontWeight.w700, color: NB.text2)),
      );

  Widget _field(TextEditingController c, String hint) => Container(
        decoration: BoxDecoration(
          color: NB.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: NB.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: c,
          autocorrect: false,
          enableSuggestions: false,
          onChanged: (_) => setState(() => _error = null),
          style: NB.font(15, color: NB.text),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: NB.font(15, color: NB.text3),
          ),
        ),
      );
}
