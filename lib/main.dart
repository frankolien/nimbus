import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xend/xend.dart';

import 'app.dart';
import 'core/services/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  // Wallet keys, signing, balances, sends and history all go through Xend. The
  // simulator reaches a local backend on localhost; a device needs the host's LAN IP.
  final xendUrl = dotenv.env['XEND_BACKEND_URL'];
  Xend.configure(XendConfig(
    backendUrl: (xendUrl == null || xendUrl.isEmpty) ? 'http://localhost:8080' : xendUrl,
    apiKey: dotenv.env['XEND_API_KEY'],
  ));


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
