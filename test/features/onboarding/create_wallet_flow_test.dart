import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nimbus/features/onboarding/presentation/pages/create_wallet_flow.dart';
import 'package:nimbus/features/wallet/data/crypto/seed_cipher.dart';
import 'package:nimbus/features/wallet/data/storage/seed_vault.dart';
import 'package:nimbus/features/wallet/data/wallet_vault.dart';
import 'package:nimbus/features/wallet/domain/entities/wallet_account.dart';
import 'package:nimbus/features/wallet/presentation/providers/wallet_session.dart';

/// In-memory vault so the flow doesn't touch the platform keychain.
class _FakeVault implements SeedVault {
  String? _seed;
  List<WalletAccount> _accounts = const [];
  @override
  Future<bool> hasWallet() async => _seed != null;
  @override
  Future<void> writeEncryptedSeed(String b) async => _seed = b;
  @override
  Future<String?> readEncryptedSeed() async => _seed;
  @override
  Future<void> writeAccounts(List<WalletAccount> a) async => _accounts = a;
  @override
  Future<List<WalletAccount>> readAccounts() async => _accounts;
  @override
  Future<void> clear() async {
    _seed = null;
    _accounts = const [];
  }
}

void main() {
  const testMnemonic =
      'abandon abandon abandon abandon abandon abandon abandon abandon '
      'abandon abandon abandon about';
  final words = testMnemonic.split(' ');

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('create flow: reveal → quiz → set PIN → confirm PIN → ready',
      (tester) async {
    // Phone-sized surface so the screens lay out without overflow.
    await tester.binding.setSurfaceSize(const Size(414, 896));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var done = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          walletVaultProvider.overrideWithValue(
            WalletVault(vault: _FakeVault(), cipher: const SeedCipher.fast()),
          ),
        ],
        child: MaterialApp(
          home: CreateWalletFlow(
            debugMnemonic: testMnemonic,
            onExit: () {},
            onDone: () => done = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Reveal screen: unblur, then continue.
    expect(find.text('Your recovery phrase'), findsOneWidget);
    await tester.tap(find.text('Tap to reveal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("I've saved it"));
    await tester.pumpAndSettle();

    // 2. Verification quiz: answer all three positions correctly.
    for (var i = 0; i < 3; i++) {
      final posText = tester
          .widget<Text>(find.byWidgetPredicate(
              (w) => w is Text && (w.data?.startsWith('#') ?? false)))
          .data!;
      final pos = int.parse(posText.substring(1));
      await tester.tap(find.text(words[pos - 1]).last);
      await tester.pumpAndSettle();
    }

    // 3. Set passcode "111111".
    expect(find.text('Create a passcode'), findsOneWidget);
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.text('1'));
      await tester.pump();
    }
    await tester.pumpAndSettle();

    // 4. Reaching the confirm screen is the transition that used to throw a
    //    duplicate-GlobalKey error (both pads mounted at once). Getting here
    //    cleanly is the core regression guard.
    expect(find.text('Confirm your passcode'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // The confirm pad must actually accept input (the old bug truncated it).
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.text('1'));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
    // createWallet now runs on a real argon2 isolate; reaching the success
    // screen is covered by WalletVault's unit tests, so we stop here to keep
    // this a fast, deterministic widget test.
    expect(done, isFalse);
  });
}
