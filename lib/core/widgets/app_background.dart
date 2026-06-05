import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/background_options.dart';
import '../theme/background_provider.dart';
import '../theme/nimbus_theme.dart';

/// Paints the app-wide background behind every route. Installed once in
/// `MaterialApp.builder`, it sits under the (transparent) scaffolds so a chosen
/// wallpaper shows through across the whole app — home, pushed screens and all.
///
/// When no image is selected it's just solid [NB.bg], so the app looks exactly
/// as it did before. The base [NB.bg] also guarantees we never flash white while
/// an image decodes or if one fails to load.
class AppBackground extends ConsumerWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final option = ref.watch(backgroundProvider).active;
    return ColoredBox(
      color: NB.bg,
      child: Stack(
        children: [
          if (option.isImage)
            Positioned.fill(
              child: RepaintBoundary(child: _Wallpaper(option: option)),
            ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Wallpaper extends StatelessWidget {
  const _Wallpaper({required this.option});

  final BackgroundOption option;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // Decode at screen resolution to cap memory on large photos.
    final cacheWidth = (mq.size.width * mq.devicePixelRatio).round();
    final s = option.scrim;
    double a(double extra) => (s + extra).clamp(0.0, 0.92);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: Stack(
        // Re-key on the source so switching wallpapers crossfades cleanly.
        key: ValueKey(option.filePath ?? option.id),
        fit: StackFit.expand,
        children: [
          _image(cacheWidth > 0 ? cacheWidth : null),
          // Legibility scrim: darker at the very top (status bar + balance) and
          // bottom (nav bar), lighter through the body so the image breathes.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.20, 0.78, 1.0],
                colors: [
                  Colors.black.withValues(alpha: a(0.22)),
                  Colors.black.withValues(alpha: s),
                  Colors.black.withValues(alpha: s),
                  Colors.black.withValues(alpha: a(0.30)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _image(int? cacheWidth) {
    // A decode failure must never blank the wallet — fall back to NB.bg.
    Widget onError(_, __, ___) => const ColoredBox(color: NB.bg);
    if (option.isCustom) {
      return Image.file(
        File(option.filePath!),
        fit: BoxFit.cover,
        alignment: Alignment.center,
        cacheWidth: cacheWidth,
        errorBuilder: onError,
      );
    }
    return Image.asset(
      option.asset!,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      cacheWidth: cacheWidth,
      errorBuilder: onError,
    );
  }
}
