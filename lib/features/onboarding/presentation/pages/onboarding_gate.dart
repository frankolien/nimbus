import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../portfolio/presentation/pages/home_screen.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../widgets/nimbus_widgets.dart';
import 'create_wallet_flow.dart';
import 'import_wallet_flow.dart';
import 'welcome_screen.dart';

/// Single source of truth for first-launch routing. Watches the wallet status
/// and shows a brief loader, then onboarding (no wallet) or the main app.
/// There is no lock screen: Face ID gates each signature instead.
class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(walletSessionProvider.select((s) => s.status));

    final Widget screen = switch (status) {
      // The session never reports locked; treat it like loading.
      VaultStatus.unknown || VaultStatus.locked => const _Loader(),
      VaultStatus.noWallet => _WelcomeHost(),
      VaultStatus.unlocked => const HomeScreen(),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(key: ValueKey(status), child: screen),
    );
  }
}

/// Welcome screen plus the navigation into the create / import flows (pushed as
/// routes so the success screen survives the status flip to "unlocked").
class _WelcomeHost extends StatelessWidget {
  Route<void> _slide(Widget page) => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 360),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );

  @override
  Widget build(BuildContext context) {
    // Capture the navigator up front. Creating or importing flips the session to
    // unlocked, which disposes this widget, so its context is gone by "Open wallet".
    final nav = Navigator.of(context);
    return WelcomeScreen(
      onCreate: () => nav.push(
        _slide(CreateWalletFlow(
          onExit: () => nav.maybePop(),
          onDone: () => nav.popUntil((r) => r.isFirst),
        )),
      ),
      onImport: () => nav.push(
        _slide(ImportWalletFlow(
          onExit: () => nav.maybePop(),
          onDone: () => nav.popUntil((r) => r.isFirst),
        )),
      ),
    );
  }
}

class _Loader extends StatelessWidget {
  const _Loader();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: NB.bg,
      body: Center(
        child: SizedBox(
          width: 120,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NimbusLogo(size: 72),
              SizedBox(height: 20),
              Wordmark(size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
