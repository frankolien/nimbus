import 'package:flutter/material.dart';

import 'core/theme/nimbus_theme.dart';
import 'core/widgets/app_background.dart';
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
      builder: (context, child) =>
          AppBackground(child: child ?? const SizedBox.shrink()),
    );
  }
}
