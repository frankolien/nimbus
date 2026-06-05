import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/custom_background_service.dart';
import 'background_options.dart';

/// The active background plus the user's stored custom photo (kept even when
/// another background is active, so they can switch back to it without having
/// to re-pick).
class BackgroundState {
  const BackgroundState({required this.active, this.customPhoto});

  final BackgroundOption active;
  final BackgroundOption? customPhoto;

  BackgroundState withActive(BackgroundOption next) =>
      BackgroundState(active: next, customPhoto: customPhoto);
}

/// Owns the selected wallet background, persisted so it survives restarts — an
/// appearance preference, not session state. Defaults to [kNoneBackground], so
/// before a real choice loads the app looks identical to before.
class BackgroundController extends StateNotifier<BackgroundState> {
  BackgroundController({CustomBackgroundService? service})
      : _service = service ?? CustomBackgroundService(),
        super(const BackgroundState(active: kNoneBackground)) {
    _load();
  }

  final CustomBackgroundService _service;

  static const _idKey = 'appearance.background.v1';
  static const _pathKey = 'appearance.background.custom_path.v1';
  static const _scrimKey = 'appearance.background.custom_scrim.v1';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_idKey);
      final path = prefs.getString(_pathKey);

      BackgroundOption? custom;
      if (path != null && await File(path).exists()) {
        custom = _customOption(path, prefs.getDouble(_scrimKey) ?? 0.5);
      }

      final active = (id == kCustomBackgroundId && custom != null)
          ? custom
          : backgroundOptionById(id);
      state = BackgroundState(active: active, customPhoto: custom);
    } catch (e) {
      debugPrint('Background load failed: $e');
    }
  }

  Future<void> select(BackgroundOption option) async {
    state = state.withActive(option);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_idKey, option.id);
    } catch (e) {
      debugPrint('Background save failed: $e');
    }
  }

  /// Open the gallery, store the chosen photo as the active background, and
  /// persist it. Returns true if a photo was set (false on cancel or error).
  Future<bool> pickCustomPhoto() async {
    try {
      final result = await _service.pickAndStore();
      if (result == null) return false; // cancelled

      final previous = state.customPhoto?.filePath;
      final option = _customOption(result.path, result.scrim);
      state = BackgroundState(active: option, customPhoto: option);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_idKey, kCustomBackgroundId);
      await prefs.setString(_pathKey, result.path);
      await prefs.setDouble(_scrimKey, result.scrim);

      if (previous != null && previous != result.path) {
        await _service.deleteQuietly(previous);
      }
      return true;
    } catch (e) {
      debugPrint('Pick custom background failed: $e');
      return false;
    }
  }

  BackgroundOption _customOption(String path, double scrim) => BackgroundOption(
        id: kCustomBackgroundId,
        label: 'Your photo',
        filePath: path,
        scrim: scrim,
      );
}

final backgroundProvider =
    StateNotifierProvider<BackgroundController, BackgroundState>(
        (ref) => BackgroundController());
