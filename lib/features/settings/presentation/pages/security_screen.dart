import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../widgets/settings_row.dart';
import '../widgets/settings_scaffold.dart';
import '../widgets/settings_section.dart';
import '../widgets/wallet_removal.dart';
import 'reveal_phrase_screen.dart';

/// Security & Privacy: how the wallet is protected and backed up, phrase
/// export, and removing the wallet. There is no passcode or lock; Face ID
/// approves each signature.
class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsScaffold(
      title: 'Security & Privacy',
      children: [
        const SettingsSection(
          title: 'Protection',
          children: [
            SettingsRow(
              icon: Icons.face_outlined,
              accent: NB.violet,
              label: 'Face ID',
              subtitle: 'Approves every transaction and phrase export',
              trailing: SizedBox.shrink(),
            ),
            SettingsRow(
              icon: Icons.memory_outlined,
              accent: NB.blue,
              label: 'Secure Enclave key',
              subtitle: 'Your signing key never leaves this phone',
              trailing: SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SettingsSection(
          title: 'Backup',
          children: [
            const SettingsRow(
              icon: Icons.cloud_done_outlined,
              accent: NB.green,
              label: 'iCloud Keychain',
              subtitle: 'Restores this wallet on your other Apple devices',
              trailing: SizedBox.shrink(),
            ),
            SettingsRow(
              icon: Icons.vpn_key_outlined,
              accent: NB.orange,
              label: 'Recovery phrase',
              subtitle: 'Export your words with Face ID',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RevealPhraseScreen(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SettingsSection(
          title: 'Danger zone',
          children: [
            SettingsRow(
              icon: Icons.phonelink_erase_outlined,
              accent: NB.red,
              label: 'Remove wallet from this device',
              subtitle: 'Keeps the iCloud backup',
              danger: true,
              onTap: () => confirmRemoveWallet(context, ref),
            ),
            SettingsRow(
              icon: Icons.delete_forever_outlined,
              accent: NB.red,
              label: 'Erase wallet and iCloud backup',
              subtitle: 'Permanent without your recovery phrase',
              danger: true,
              onTap: () => confirmEraseWallet(context, ref),
            ),
          ],
        ),
      ],
    );
  }
}
