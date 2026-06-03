import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../wallet/data/crypto/seed_cipher.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../widgets/nimbus_widgets.dart';
import '../widgets/passcode_pad.dart';

/// Lock screen shown when a wallet exists but the session is locked. On a
/// correct passcode the session unlocks and the gate routes to home.
class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  final _padKey = GlobalKey<PasscodePadState>();
  String? _error;
  bool _busy = false;

  Future<void> _submit(String pin) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(walletSessionProvider.notifier).unlock(pin);
      // Gate rebuilds to home on success — nothing else to do here.
    } on InvalidPasscodeException {
      if (mounted) {
        setState(() => _error = 'Wrong passcode — try again');
        _padKey.currentState?.shakeAndClear();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not unlock. Try again.');
        _padKey.currentState?.shakeAndClear();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NB.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 30),
          child: Column(
            children: [
              const Spacer(),
              const NimbusLogo(size: 64),
              const SizedBox(height: 28),
              PasscodePad(
                key: _padKey,
                title: 'Enter passcode',
                subtitle: 'Unlock Nimbus to continue.',
                errorText: _error,
                busy: _busy,
                onCompleted: _submit,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
