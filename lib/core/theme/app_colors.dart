import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Base Palette
  static const Color black      = Color(0xFF000000);
  static const Color deepBlack  = Color(0xFF080808);
  static const Color surfaceBlack  = Color(0xFF0D0D0D);
  static const Color cardBlack     = Color(0xFF111111);
  static const Color elevatedBlack = Color(0xFF161616);

  // Anthracite Grays
  static const Color anthracite      = Color(0xFF1C1C1E);
  static const Color anthraciteMid   = Color(0xFF2C2C2E);
  static const Color anthraciteLight = Color(0xFF3A3A3C);
  static const Color gray            = Color(0xFF48484A);
  static const Color grayMid         = Color(0xFF636366);
  static const Color grayLight       = Color(0xFF8E8E93);

  // White Accents
  static const Color white        = Color(0xFFFFFFFF);
  static const Color whiteAlpha90 = Color(0xE6FFFFFF);
  static const Color whiteAlpha70 = Color(0xB3FFFFFF);
  static const Color whiteAlpha50 = Color(0x80FFFFFF);
  static const Color whiteAlpha30 = Color(0x4DFFFFFF);
  static const Color whiteAlpha15 = Color(0x26FFFFFF);
  static const Color whiteAlpha10 = Color(0x1AFFFFFF);
  static const Color whiteAlpha05 = Color(0x0DFFFFFF);

  // Glass Effects
  static const Color glassSurface     = Color(0x0DFFFFFF);
  static const Color glassBorder      = Color(0x1AFFFFFF);
  static const Color glassBorderStrong = Color(0x33FFFFFF);

  // ── Default Accent — Cosmic Purple ────────────────────────────────────────
  static const Color defaultAccent = Color(0xFF8B5CF6);

  // Accent (runtime — use ThemeService.accent instead of these directly in widgets)
  static const Color accent     = Color(0xFF8B5CF6); // Cosmic Purple
  static const Color accentDim  = Color(0xFF6D28D9);
  static const Color accentGlow = Color(0x338B5CF6);
  static const Color accentSoft = Color(0x1A8B5CF6);

  // Secondary Accent
  static const Color accentPurple    = Color(0xFF7C3AED);
  static const Color accentPurpleDim = Color(0xFF5B21B6);

  // ── Preset Color Palette (for color picker) ───────────────────────────────
  static const List<AccentPreset> accentPresets = [
    AccentPreset(color: Color(0xFF8B5CF6), name: 'Cosmic Purple'),
    AccentPreset(color: Color(0xFF00D4FF), name: 'Stellar Cyan'),
    AccentPreset(color: Color(0xFF3B82F6), name: 'Nebula Blue'),
    AccentPreset(color: Color(0xFF10B981), name: 'Aurora Green'),
    AccentPreset(color: Color(0xFFF59E0B), name: 'Solar Gold'),
    AccentPreset(color: Color(0xFFEF4444), name: 'Nova Red'),
    AccentPreset(color: Color(0xFFEC4899), name: 'Rose Quartz'),
    AccentPreset(color: Color(0xFF06B6D4), name: 'Ice Teal'),
  ];

  // Status Colors
  static const Color success    = Color(0xFF34C759);
  static const Color successDim = Color(0xFF248A3D);
  static const Color warning    = Color(0xFFFF9F0A);
  static const Color warningDim = Color(0xFFB25000);
  static const Color error      = Color(0xFFFF453A);
  static const Color errorDim   = Color(0xFFB22E2E);

  // NUKE Button
  static const Color nukeRed       = Color(0xFFCC0000);
  static const Color nukeRedBright = Color(0xFFFF1A1A);
  static const Color nukeRedDark   = Color(0xFF8B0000);
  static const Color nukeGlow      = Color(0x66CC0000);
  static const Color nukeGlowBright = Color(0x33FF1A1A);

  // Privacy indicator
  static const Color privacyGreen    = Color(0xFF00E676);
  static const Color privacyGreenDim = Color(0xFF00A152);

  // Gradient backgrounds
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0A0A), Color(0xFF000000)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
  );

  static const LinearGradient nukeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFCC0000), Color(0xFF8B0000)],
  );

  static const RadialGradient nukeGlowGradient = RadialGradient(
    colors: [Color(0x66CC0000), Color(0x00000000)],
    radius: 1.0,
  );

  // Build accent-dependent glow/soft colors at runtime
  static Color accentGlowOf(Color c) => c.withOpacity(0.20);
  static Color accentSoftOf(Color c) => c.withOpacity(0.10);
  static Color accentDimOf(Color c)  => HSLColor.fromColor(c)
      .withLightness((HSLColor.fromColor(c).lightness - 0.12).clamp(0.0, 1.0))
      .toColor();
}

class AccentPreset {
  final Color color;
  final String name;
  const AccentPreset({required this.color, required this.name});
}
