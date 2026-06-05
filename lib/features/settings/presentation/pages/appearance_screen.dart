import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/background_options.dart';
import '../../../../core/theme/background_provider.dart';
import '../../../../core/theme/nimbus_theme.dart';
import '../widgets/settings_scaffold.dart';

/// Appearance settings: choose the wallet background — a bundled image or your
/// own photo. Tapping a tile applies it live everywhere (the whole app reads
/// [backgroundProvider]).
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  Future<void> _choosePhoto(WidgetRef ref) =>
      ref.read(backgroundProvider.notifier).pickCustomPhoto();

  void _select(WidgetRef ref, BackgroundOption option) =>
      ref.read(backgroundProvider.notifier).select(option);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(backgroundProvider);
    final active = state.active;
    final custom = state.customPhoto;

    return SettingsScaffold(
      title: 'Appearance',
      intro: 'Personalize your wallet with a background — pick one of ours or '
          'choose your own photo. Darker images keep text the most readable.',
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.60,
          children: [
            _ChoosePhotoTile(onTap: () => _choosePhoto(ref)),
            if (custom != null)
              _BackgroundTile(
                option: custom,
                selected: active.isCustom,
                onTap: () => _select(ref, custom),
              ),
            for (final option in kBackgroundOptions)
              _BackgroundTile(
                option: option,
                selected: !active.isCustom && option.id == active.id,
                onTap: () => _select(ref, option),
              ),
          ],
        ),
      ],
    );
  }
}

/// The "+ Choose from photos" action tile. Always opens the gallery.
class _ChoosePhotoTile extends StatelessWidget {
  const _ChoosePhotoTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: NB.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: NB.borderHi),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                gradient: NB.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_a_photo_outlined,
                  size: 22, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('Choose from photos',
                  textAlign: TextAlign.center,
                  style: NB.font(13, weight: FontWeight.w700, color: NB.text2)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundTile extends StatelessWidget {
  const _BackgroundTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final BackgroundOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? NB.orange : NB.border,
            width: selected ? 2.5 : 1,
          ),
          boxShadow: selected ? NB.orangeGlow : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _preview(),
              // Keep the label readable over any image.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                    stops: [0.55, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NB.font(13.5, weight: FontWeight.w700),
                ),
              ),
              if (selected)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: NB.orange,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.check, size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _preview() {
    if (option.isCustom) {
      return Image.file(
        File(option.filePath!),
        fit: BoxFit.cover,
        cacheWidth: 320,
        errorBuilder: (_, __, ___) => const ColoredBox(color: NB.surface2),
      );
    }
    if (option.isImage) {
      return Image.asset(
        option.asset!,
        fit: BoxFit.cover,
        cacheWidth: 320,
        errorBuilder: (_, __, ___) => const ColoredBox(color: NB.surface2),
      );
    }
    return const _NoneTile();
  }
}

class _NoneTile extends StatelessWidget {
  const _NoneTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NB.surface,
      alignment: Alignment.center,
      child: const Icon(Icons.block, color: NB.text3, size: 30),
    );
  }
}
