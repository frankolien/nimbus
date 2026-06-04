import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the last-known portfolio snapshot per account so the wallet shows
/// real values instantly on relaunch/hot-restart instead of fetching from
/// scratch. Stores plain JSON (addresses + amounts + prices — all public data;
/// no secrets) keyed by account index.
class PortfolioCache {
  static const _prefix = 'portfolio.cache.v1.';

  // Keyed by cluster too, so mainnet and devnet balances never overwrite or
  // shadow each other.
  String _key(int accountIndex, String clusterId) =>
      '$_prefix$clusterId.$accountIndex';

  Future<void> save(
      int accountIndex, String clusterId, Map<String, dynamic> json) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key(accountIndex, clusterId), jsonEncode(json));
    } catch (e) {
      debugPrint('PortfolioCache.save failed: $e');
    }
  }

  Future<Map<String, dynamic>?> load(int accountIndex, String clusterId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key(accountIndex, clusterId));
      if (raw == null) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('PortfolioCache.load failed: $e');
      return null;
    }
  }
}
