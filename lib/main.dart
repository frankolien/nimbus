import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/first_run_guard.dart';
import 'core/services/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  // Wipe any keychain data orphaned by a previous install (iOS keeps the
  // keychain across app deletion) so a reinstall starts cleanly.
  await FirstRunGuard().ensureFreshInstall();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: NimbusApp(),
    ),
  );
}
