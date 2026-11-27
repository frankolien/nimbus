// Drives Nimbus's real screens on a simulator against a running Xend backend on Solana
// devnet: create wallet → fund → send SOL through the UI → wait for confirmation.
//
// The new wallet needs devnet SOL. The test prints `NIMBUS_ADDR=<address>` and waits for
// a balance; fund it from another shell, e.g.
//   solana transfer --url devnet --allow-unfunded-recipient <address> 0.05
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nimbus/features/transfer/presentation/widgets/slide_to_confirm.dart';
import 'package:nimbus/main.dart' as app;
import 'package:xend/xend.dart';

const recipient = 'AxMZj6QHB4Zxe7wpUCidh1cS7ueN2MGsiWLKCMokTA64';

Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  final texts = find
      .byType(Text)
      .evaluate()
      .map((e) => (e.widget as Text).data)
      .whereType<String>()
      .join(' | ');
  throw TestFailure('Timed out waiting for $finder\nOn screen: $texts');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('create, fund, and send SOL through the Nimbus UI', (tester) async {
    // Start from a clean device so onboarding shows.
    Xend.configure(const XendConfig(backendUrl: 'http://localhost:8080'));
    final old = await XendWallet.load();
    if (old != null) await old.delete(wipeBackup: true);

    app.main();
    await waitFor(tester, find.text('Create a new wallet'));
    await tester.tap(find.text('Create a new wallet'));
    await waitFor(tester, find.text('Open wallet'));

    final wallet = (await XendWallet.load())!;
    // ignore: avoid_print
    print('NIMBUS_ADDR=${wallet.address}');

    await tester.tap(find.text('Open wallet'));
    await waitFor(tester, find.text('Send'));

    // Wait for the funding transfer to land.
    final end = DateTime.now().add(const Duration(minutes: 3));
    while ((await wallet.balance()).amount == BigInt.zero) {
      if (DateTime.now().isAfter(end)) throw TestFailure('Wallet was never funded');
      await tester.pump(const Duration(seconds: 2));
    }

    await tester.tap(find.text('Send').first);
    await waitFor(tester, find.text('Select Token'));
    await tester.pump(const Duration(milliseconds: 500)); // sheet animation
    await tester.tap(find.text('Solana').last); // the picker row, above the home list

    final toField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == 'Address or .sol name',
    );
    await waitFor(tester, toField);
    await tester.enterText(toField, recipient);
    await tester.pump(const Duration(milliseconds: 300));
    await waitFor(tester, find.text('Continue'));
    await tester.tap(find.text('Continue'));

    // 0.01 SOL on the keypad.
    await waitFor(tester, find.text('Max'));
    // The screen reads the portfolio, which refreshes every 15s; wait for the funding.
    await waitFor(tester, find.textContaining('0.05'), timeout: const Duration(seconds: 45));
    for (final k in ['0', '.', '0', '1']) {
      await tester.tap(find.text(k).last);
      await tester.pump(const Duration(milliseconds: 150));
    }
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Confirm'));

    await waitFor(tester, find.text('Slide to confirm'));
    final slider = tester.getTopLeft(find.byType(SlideToConfirm));
    await tester.dragFrom(slider + const Offset(29, 29), const Offset(600, 0));
    await tester.pump(const Duration(milliseconds: 300));

    // Success screen with live status from wallet.watch().
    await waitFor(
      tester,
      find.textContaining(RegExp(r'^(Confirmed|Finalized) · Devnet')),
      timeout: const Duration(seconds: 90),
    );

    final history = await wallet.history();
    expect(history.first.to, recipient);
    expect(history.first.amount, BigInt.from(10000000));

    await wallet.delete(wipeBackup: true);
  });
}
