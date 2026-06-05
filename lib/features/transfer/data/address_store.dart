import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/recent_recipient.dart';
import '../domain/saved_address.dart';

/// Local persistence for the address book + recent recipients (JSON in
/// SharedPreferences). Nothing secret here — just public addresses and labels.
class AddressStore {
  static const _savedKey = 'transfer.saved_addresses.v1';
  static const _recentsKey = 'transfer.recent_recipients.v1';
  static const maxRecents = 12;

  Future<List<SavedAddress>> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    return _decode(prefs.getString(_savedKey), SavedAddress.fromJson);
  }

  Future<void> saveSaved(List<SavedAddress> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _savedKey, jsonEncode([for (final e in list) e.toJson()]));
  }

  /// Recents, newest first, capped at [maxRecents].
  Future<List<RecentRecipient>> loadRecents() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _decode(prefs.getString(_recentsKey), RecentRecipient.fromJson)
      ..sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
    return list;
  }

  Future<void> saveRecents(List<RecentRecipient> list) async {
    final trimmed = [...list]
      ..sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recentsKey,
        jsonEncode([for (final e in trimmed.take(maxRecents)) e.toJson()]));
  }

  List<T> _decode<T>(String? raw, T Function(Map<String, dynamic>) from) {
    if (raw == null || raw.isEmpty) return [];
    try {
      return [
        for (final e in jsonDecode(raw) as List)
          from(e as Map<String, dynamic>),
      ];
    } catch (e) {
      debugPrint('AddressStore decode failed: $e');
      return [];
    }
  }
}
