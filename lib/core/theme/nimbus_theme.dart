import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Nimbus design tokens, reconstructed from the Claude Design handoff.
///
/// Dark, near-black surfaces; an orange primary gradient; a green
/// security/success accent; Manrope type. Keep these values in sync with the
/// design bundle — screens read everything from here, never hard-coded hexes.
abstract final class NB {
  // Surfaces
  static const bg = Color(0xFF0B0B0D);
  static const surface = Color(0xFF161619);
  static const surface2 = Color(0xFF1E1E23);
  static const surface3 = Color(0xFF26262C);

  // Lines
  static const border = Color(0x12FFFFFF); // rgba(255,255,255,0.07)
  static const borderHi = Color(0x24FFFFFF); // rgba(255,255,255,0.14)

  // Text
  static const text = Color(0xFFFFFFFF);
  static const text2 = Color(0xFF9C9CA6);
  static const text3 = Color(0xFF646470);

  // Brand + state
  static const orange = Color(0xFFF2611C);
  static const orangeHi = Color(0xFFFF7A2E);
  static const green = Color(0xFF2FD37E);
  static const greenDim = Color(0x242FD37E); // rgba(47,211,126,0.14)
  static const blue = Color(0xFF2F80ED);
  static const violet = Color(0xFF9A6BFF);
  static const pink = Color(0xFFFF5BA8);
  static const red = Color(0xFFFF5C5C);

  // Logo mark gradient
  static const markFrom = Color(0xFFF0500F);
  static const markTo = Color(0xFFFF8A3D);
  static const markWedge = Color(0xFFC8430C);

  /// Primary button gradient (top → bottom).
  static const primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [orangeHi, orange],
  );

  /// Glow shadow under primary buttons / accents.
  static List<BoxShadow> orangeGlow = const [
    BoxShadow(color: Color(0x59F2611C), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static TextStyle font(
    double size, {
    FontWeight weight = FontWeight.w600,
    Color color = text,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.manrope(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// App-wide dark theme using the Nimbus tokens.
  static ThemeData theme() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      // Transparent so AppBackground (installed in MaterialApp.builder) owns
      // the canvas; a chosen wallpaper then shows through every scaffold.
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: base.colorScheme.copyWith(
        primary: orange,
        secondary: green,
        surface: surface,
        error: red,
      ),
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme)
          .apply(bodyColor: text, displayColor: text),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }
}
