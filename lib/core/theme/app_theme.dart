import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  GALAXY COLOUR SYSTEM
// ─────────────────────────────────────────────

class GalaxyColors {
  // ── Shared cosmic accents ──
  static const Color nebulaPurple  = Color(0xFF7C3AED);
  static const Color nebulaViolet  = Color(0xFF8B5CF6);
  static const Color cosmicBlue    = Color(0xFF3B82F6);
  static const Color auroraGreen   = Color(0xFF10B981);
  static const Color stardustPink  = Color(0xFFEC4899);
  static const Color solarGold     = Color(0xFFF59E0B);
  static const Color cometOrange   = Color(0xFFF97316);
  static const Color supernovaRed  = Color(0xFFEF4444);

  // ── DARK MODE (deep space) ──
  static const Color darkBg         = Color(0xFF080B1A);
  static const Color darkSurface    = Color(0xFF0F1330);
  static const Color darkSurface2   = Color(0xFF161B3E);
  static const Color darkBorder     = Color(0xFF1E2654);
  static const Color darkTextPrimary= Color(0xFFE8EEFF);
  static const Color darkTextSecond = Color(0xFF8B9FC9);
  static const Color darkTextHint   = Color(0xFF4A5580);

  static const Color darkGamesCard     = Color(0xFF111A3A);
  static const Color darkChatCard      = Color(0xFF140E2E);
  static const Color darkSpeakCard     = Color(0xFF0D2218);
  static const Color darkCommunityCard = Color(0xFF1E1008);
  static const Color darkProgressCard  = Color(0xFF111A3A);
  static const Color darkSubCard       = Color(0xFF140E2E);

  // ── LIGHT MODE (aurora nebula pastels) ──
  static const Color lightBg         = Color(0xFFF0F2FF);
  static const Color lightSurface    = Color(0xFFFFFFFF);
  static const Color lightSurface2   = Color(0xFFF5F3FF);
  static const Color lightBorder     = Color(0xFFDDD6FE);
  static const Color lightTextPrimary= Color(0xFF1A1040);
  static const Color lightTextSecond = Color(0xFF6B7280);
  static const Color lightTextHint   = Color(0xFF9CA3AF);

  static const Color lightGamesCard     = Color(0xFFDBEAFF);
  static const Color lightChatCard      = Color(0xFFEDE9FE);
  static const Color lightSpeakCard     = Color(0xFFD1FAE5);
  static const Color lightCommunityCard = Color(0xFFFFEDD5);
  static const Color lightProgressCard  = Color(0xFFDBEAFF);
  static const Color lightSubCard       = Color(0xFFEDE9FE);

  // Star particle colours
  static const List<Color> starColors = [
    Color(0xFFFFFFFF), Color(0xFFBFD4FF),
    Color(0xFFD4BBFF), Color(0xFFFFEEBB), Color(0xFFBBEEFF),
  ];

  // Nebula gradients
  static const List<Color> darkNebulaGradient = [
    Color(0xFF0A0E22), Color(0xFF0D1235),
    Color(0xFF120A28), Color(0xFF080B1A),
  ];
  static const List<Color> lightAuroraGradient = [
    Color(0xFFEEF2FF), Color(0xFFF5F0FF),
    Color(0xFFEBFFF6), Color(0xFFF0F2FF),
  ];

  // Convenience getters by theme
  static Color bg(bool dark)         => dark ? darkBg         : lightBg;
  static Color surface(bool dark)    => dark ? darkSurface     : lightSurface;
  static Color surface2(bool dark)   => dark ? darkSurface2    : lightSurface2;
  static Color border(bool dark)     => dark ? darkBorder      : lightBorder;
  static Color textPrimary(bool dark)=> dark ? darkTextPrimary : lightTextPrimary;
  static Color textSecond(bool dark) => dark ? darkTextSecond  : lightTextSecond;
  static Color textHint(bool dark)   => dark ? darkTextHint    : lightTextHint;

  static Color gamesCard(bool dark)     => dark ? darkGamesCard     : lightGamesCard;
  static Color chatCard(bool dark)      => dark ? darkChatCard      : lightChatCard;
  static Color speakCard(bool dark)     => dark ? darkSpeakCard     : lightSpeakCard;
  static Color communityCard(bool dark) => dark ? darkCommunityCard : lightCommunityCard;
  static Color progressCard(bool dark)  => dark ? darkProgressCard  : lightProgressCard;
  static Color subCard(bool dark)       => dark ? darkSubCard       : lightSubCard;

  static List<Color> nebulaGradient(bool dark) =>
      dark ? darkNebulaGradient : lightAuroraGradient;
}

// ─────────────────────────────────────────────
//  TEXT STYLES
// ─────────────────────────────────────────────

class AppTextStyles {
  static const String fontFamily = 'Nunito';

  static TextStyle heading2(bool dark) => TextStyle(
    fontSize: 20, fontWeight: FontWeight.w800,
    color: GalaxyColors.textPrimary(dark),
    letterSpacing: -0.3, fontFamily: fontFamily,
  );

  static TextStyle heading3(bool dark) => TextStyle(
    fontSize: 15, fontWeight: FontWeight.w700,
    color: GalaxyColors.textPrimary(dark), fontFamily: fontFamily,
  );

  static TextStyle body1(bool dark) => TextStyle(
    fontSize: 14, color: GalaxyColors.textPrimary(dark), fontFamily: fontFamily,
  );

  static TextStyle body2(bool dark) => TextStyle(
    fontSize: 13, color: GalaxyColors.textSecond(dark), fontFamily: fontFamily,
  );

  static TextStyle caption(bool dark) => TextStyle(
    fontSize: 11, color: GalaxyColors.textSecond(dark), fontFamily: fontFamily,
  );

  static TextStyle label(bool dark) => TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500,
    color: GalaxyColors.textSecond(dark), fontFamily: fontFamily,
  );
}

// ─────────────────────────────────────────────
//  THEME DATA FACTORY
// ─────────────────────────────────────────────

class AppTheme {
  static ThemeData dark()  => _build(isDark: true);
  static ThemeData light() => _build(isDark: false);

  static ThemeData _build({required bool isDark}) {
    final bg      = GalaxyColors.bg(isDark);
    final surface = GalaxyColors.surface(isDark);
    final border  = GalaxyColors.border(isDark);
    final onText  = GalaxyColors.textPrimary(isDark);
    const primary = GalaxyColors.nebulaViolet;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bg,
      fontFamily: AppTextStyles.fontFamily,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        secondary: GalaxyColors.auroraGreen,
        onSecondary: Colors.white,
        error: GalaxyColors.supernovaRed,
        onError: Colors.white,
        surface: surface,
        onSurface: onText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: onText),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GalaxyColors.surface2(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: GalaxyColors.textHint(isDark), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary, foregroundColor: Colors.white, elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: GalaxyColors.textSecond(isDark),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerColor: border,
    );
  }
}
