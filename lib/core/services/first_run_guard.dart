import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/wallet/data/storage/seed_vault.dart';

/// On iOS the Keychain (where the encrypted seed lives) survives app deletion,
/// so a reinstalled app would still "find" an old wallet and show the unlock
/// screen forever. SharedPreferences/NSUserDefaults, by contrast, IS cleared on
/// uninstall — so we use a flag there to detect a genuinely fresh install and
/// wipe any orphaned keychain data, giving a clean onboarding.
class FirstRunGuard {
  FirstRunGuard({SeedVault? vault}) : _vault = vault ?? SecureSeedVault();

  final SeedVault _vault;
  static const _installedFlag = 'nimbus.installed.v1';

  /// Call once at startup before building the app.
  Future<void> ensureFreshInstall() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final installedBefore = prefs.getBool(_installedFlag) ?? false;
      if (!installedBefore) {
        // Fresh install (or first run after this guard shipped): clear any
        // seed left in the keychain from a previous install.
        await _vault.clear();
        await prefs.setBool(_installedFlag, true);
      }
    } catch (e) {
      // Never block startup on this housekeeping step.
      debugPrint('FirstRunGuard failed: $e');
    }
  }
}
