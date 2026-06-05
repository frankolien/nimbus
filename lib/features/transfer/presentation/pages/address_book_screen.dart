import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../wallet/domain/entities/chain_family.dart';
import '../providers/address_providers.dart';
import '../widgets/recipient_tile.dart';
import '../widgets/save_address_sheet.dart';
import '../widgets/transfer_header.dart';

/// Manage recents and saved addresses for one chain [family]: add, edit, or
/// delete saved entries, and re-use or save a recent one.
class AddressBookScreen extends ConsumerWidget {
  const AddressBookScreen({super.key, required this.family});

  final ChainFamily family;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref
        .watch(savedAddressesProvider)
        .where((s) => s.family == family)
        .toList();
    final recents = ref
        .watch(recentRecipientsProvider)
        .where((r) => r.family == family)
        .toList();

    String? savedLabel(String address) {
      for (final s in saved) {
        if (s.address == address) return s.label;
      }
      return null;
    }

    return Scaffold(
      backgroundColor: NB.bg,
      body: SafeArea(
        child: Column(
          children: [
            const TransferHeader(title: 'Address book'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Row(
                    children: [
                      Text('Saved', style: NB.font(16, weight: FontWeight.w800)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            showSaveAddressSheet(context, family: family),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            const Icon(Icons.add, size: 18, color: NB.orange),
                            const SizedBox(width: 4),
                            Text('Add',
                                style: NB.font(13.5,
                                    weight: FontWeight.w700, color: NB.orange)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (saved.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('No saved addresses yet.',
                          style: NB.font(13.5, color: NB.text3)),
                    )
                  else
                    for (final s in saved)
                      RecipientTile(
                        title: s.label,
                        subtitle: Fmt.address(s.address),
                        onTap: () => showSaveAddressSheet(context,
                            family: family, existing: s),
                        trailing: IconButton(
                          onPressed: () => ref
                              .read(savedAddressesProvider.notifier)
                              .remove(s),
                          icon: const Icon(Icons.delete_outline,
                              size: 20, color: NB.text3),
                        ),
                      ),
                  if (recents.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Text('Recent', style: NB.font(16, weight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    for (final r in recents)
                      RecipientTile(
                        title: savedLabel(r.address) ?? Fmt.address(r.address),
                        subtitle: 'Recent',
                        onTap: () => showSaveAddressSheet(context,
                            family: family, prefillAddress: r.address),
                        trailing: const Icon(Icons.bookmark_add_outlined,
                            size: 20, color: NB.text3),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
