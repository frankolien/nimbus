import 'package:flutter/material.dart';

import 'core/theme/nimbus_theme.dart';
import 'features/onboarding/presentation/pages/onboarding_gate.dart';

class NimbusApp extends StatelessWidget {
  const NimbusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nimbus',
      debugShowCheckedModeBanner: false,
      theme: NB.theme(),
      home: const OnboardingGate(),
    );
  }
}
