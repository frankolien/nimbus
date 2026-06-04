import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../widgets/settings_feedback.dart';
import '../widgets/settings_row.dart';
import '../widgets/settings_scaffold.dart';
import '../widgets/settings_section.dart';
import 'reveal_phrase_screen.dart';

/// Security & Privacy: back up the recovery phrase, manage the passcode, and
/// lock the session. Rows backed by the vault are live; the rest are honestly
/// marked "coming soon".
class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  void _lock(BuildContext context, WidgetRef ref) {
    ref.read(walletSessionProvider.notifier).lock();
    // Drop back to the gate, which now routes to the unlock screen.
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsScaffold(
      title: 'Security & Privacy',
      children: [
        SettingsSection(
          title: 'Backup',
          children: [
            SettingsRow(
              icon: Icons.vpn_key_outlined,
              accent: NB.green,
              label: 'Recovery phrase',
              subtitle: 'Reveal your 12-word phrase',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RevealPhraseScreen(),
                ),
              ),
            ),
            SettingsRow(
              icon: Icons.password_outlined,
              accent: NB.orange,
              label: 'Change passcode',
              subtitle: 'Update your 6-digit PIN',
              onTap: () => showComingSoon(context),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SettingsSection(
          title: 'Session',
          children: [
            SettingsRow(
              icon: Icons.lock_clock_outlined,
              accent: NB.blue,
              label: 'Auto-lock',
              subtitle: 'Require passcode after inactivity',
              onTap: () => showComingSoon(context),
            ),
            SettingsRow(
              icon: Icons.fingerprint,
              accent: NB.violet,
              label: 'Biometric unlock',
              subtitle: 'Face ID / Touch ID — coming soon',
              onTap: () => showComingSoon(context),
            ),
            SettingsRow(
              icon: Icons.lock_outline,
              accent: NB.orange,
              label: 'Lock wallet now',
              subtitle: 'End this session',
              trailing: const SizedBox.shrink(),
              onTap: () => _lock(context, ref),
            ),
          ],
        ),
      ],
    );
  }
}
