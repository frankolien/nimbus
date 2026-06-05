import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether balances are hidden behind a mask (the eye toggle in the wallet top
/// bar). Persisted so the choice survives restarts — a privacy preference, not
/// session state. Defaults to visible.
class BalanceHiddenNotifier extends StateNotifier<bool> {
  BalanceHiddenNotifier() : super(false) {
    _load();
  }

  static const _key = 'balance.hidden.v1';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(_key) ?? false;
    } catch (e) {
      debugPrint('BalanceHidden load failed: $e');
    }
  }

  Future<void> toggle() async {
    state = !state;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, state);
    } catch (e) {
      debugPrint('BalanceHidden save failed: $e');
    }
  }
}

final balanceHiddenProvider =
    StateNotifierProvider<BalanceHiddenNotifier, bool>(
        (ref) => BalanceHiddenNotifier());
