import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../theme/background_options.dart';

/// Picks a photo from the gallery to use as the wallet background: copies it
/// into the app's documents directory (so it survives the original being moved
/// or deleted) and estimates a legibility scrim from the image's brightness.
///
/// The pixel work lives here; the pure luminance→scrim mapping is
/// [scrimFromLuminance] so it can be unit-tested without an engine.
class CustomBackgroundService {
  CustomBackgroundService({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Opens the gallery and stores the chosen photo. Returns its on-disk path
  /// and a derived scrim, or null if the user cancelled.
  Future<({String path, double scrim})?> pickAndStore() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2000, // cap dimensions so we don't keep a huge bitmap around
      imageQuality: 88,
      requestFullMetadata: false, // pixels only — avoids a permission prompt
    );
    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    final scrim = await _scrimFor(bytes);

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/custom_bg_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(bytes, flush: true);

    return (path: file.path, scrim: scrim);
  }

  /// Best-effort removal of a previous custom background file.
  Future<void> deleteQuietly(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('Old background delete failed: $e');
    }
  }

  /// Average the luminance of a downscaled decode and map it to a scrim. Falls
  /// back to a safe middle value if the image can't be decoded.
  Future<double> _scrimFor(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 24,
        targetHeight: 48,
      );
      final frame = await codec.getNextFrame();
      final data =
          await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
      frame.image.dispose();
      codec.dispose();
      if (data == null) return 0.5;

      final px = data.buffer.asUint8List();
      var sum = 0.0;
      var count = 0;
      for (var i = 0; i + 3 < px.length; i += 4) {
        sum += (0.299 * px[i] + 0.587 * px[i + 1] + 0.114 * px[i + 2]) / 255.0;
        count++;
      }
      return count == 0 ? 0.5 : scrimFromLuminance(sum / count);
    } catch (e) {
      debugPrint('Scrim estimate failed: $e');
      return 0.5;
    }
  }
}
