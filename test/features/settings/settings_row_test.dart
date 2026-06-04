import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/features/settings/presentation/widgets/settings_row.dart';
import 'package:nimbus/features/settings/presentation/widgets/settings_section.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders label, subtitle and badge', (tester) async {
    await tester.pumpWidget(host(
      const SettingsRow(
        icon: Icons.shield_outlined,
        label: 'Security & Privacy',
        subtitle: 'Passkey, recovery, auto-lock',
        badge: '2',
      ),
    ));

    expect(find.text('Security & Privacy'), findsOneWidget);
    expect(find.text('Passkey, recovery, auto-lock'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('fires onTap when pressed', (tester) async {
    var taps = 0;
    await tester.pumpWidget(host(
      SettingsRow(
        icon: Icons.tune,
        label: 'Preferences',
        onTap: () => taps++,
      ),
    ));

    await tester.tap(find.text('Preferences'));
    expect(taps, 1);
  });

  testWidgets('section draws a divider between each pair of rows',
      (tester) async {
    await tester.pumpWidget(host(
      const SettingsSection(
        children: [
          SettingsRow(icon: Icons.tune, label: 'A'),
          SettingsRow(icon: Icons.tune, label: 'B'),
          SettingsRow(icon: Icons.tune, label: 'C'),
        ],
      ),
    ));

    // Three rows → two dividers between them.
    expect(find.byType(Divider), findsNWidgets(2));
  });
}
