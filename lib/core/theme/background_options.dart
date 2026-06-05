/// Catalog of wallet background options shown in the Appearance picker.
///
/// An option is one of: the solid-black default (no [asset]/[filePath]), a
/// bundled image under `assets/backgrounds/` ([asset]), or the user's own photo
/// on disk ([filePath]). [scrim] is how strongly we darken the image behind the
/// UI so white text stays legible — tuned per bundled image, and derived from
/// brightness for a custom photo (see [scrimFromLuminance]). Ids are stable and
/// decoupled from filenames so a saved choice survives if an asset is renamed.
/// Pure Dart (no Flutter) so it stays unit-testable.
class BackgroundOption {
  const BackgroundOption({
    required this.id,
    required this.label,
    this.asset,
    this.filePath,
    this.scrim = 0.4,
  });

  final String id;
  final String label;

  /// Bundled asset path, or null.
  final String? asset;

  /// A user-chosen photo on disk, or null. Mutually exclusive with [asset].
  final String? filePath;

  /// 0–1 darkening applied over the image through the body of the screen.
  final double scrim;

  bool get isImage => asset != null || filePath != null;
  bool get isCustom => filePath != null;
}

/// The default: no image, just the solid [NB.bg]. Until a real choice loads,
/// the app looks exactly as it did before this feature existed.
const BackgroundOption kNoneBackground =
    BackgroundOption(id: 'none', label: 'Solid black');

/// Stable id for the user's own photo. Not part of [kBackgroundOptions] — it's
/// reconstructed from the persisted file path at load time.
const String kCustomBackgroundId = 'custom';

const List<BackgroundOption> kBackgroundOptions = [
  kNoneBackground,
  BackgroundOption(
    id: 'time-vortex',
    label: 'Time Vortex',
    asset: 'assets/backgrounds/IMG_0173.JPG',
    scrim: 0.42,
  ),
  BackgroundOption(
    id: 'event-horizon',
    label: 'Event Horizon',
    asset: 'assets/backgrounds/IMG_0174.JPG',
    scrim: 0.40,
  ),
  BackgroundOption(
    id: 'checkmate',
    label: 'Checkmate',
    asset: 'assets/backgrounds/IMG_0175.JPG',
    scrim: 0.36,
  ),
  BackgroundOption(
    id: 'ravens',
    label: 'Ravens',
    asset: 'assets/backgrounds/IMG_0176.JPG',
    // Bright white sky — needs a heavy scrim to keep white text readable.
    scrim: 0.60,
  ),
  BackgroundOption(
    id: 'archangel',
    label: 'Archangel',
    asset: 'assets/backgrounds/IMG_0177.JPG',
    scrim: 0.38,
  ),
  BackgroundOption(
    id: 'spotlight',
    label: 'Spotlight',
    asset: 'assets/backgrounds/IMG_0178.JPG',
    scrim: 0.34,
  ),
];

/// Resolve a persisted id back to its option, falling back to [kNoneBackground]
/// for unknown or null ids (e.g. an asset removed in a later version). The
/// custom-photo option is handled separately by the controller, not here.
BackgroundOption backgroundOptionById(String? id) {
  for (final option in kBackgroundOptions) {
    if (option.id == id) return option;
  }
  return kNoneBackground;
}

/// Map an image's average luminance (0 = black … 1 = white) to a legibility
/// scrim. Brighter photos need a heavier scrim to keep white text readable;
/// clamped to a safe band so a near-black photo still protects the nav/header
/// a little and a near-white one never fully hides the image.
double scrimFromLuminance(double luminance) {
  final l = luminance.clamp(0.0, 1.0);
  return (0.30 + 0.45 * l).clamp(0.30, 0.70);
}
