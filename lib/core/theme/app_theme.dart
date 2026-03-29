import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => buildTheme(AppColors.defaultAccent);

  static ThemeData buildTheme(Color accent) {
    final accentSoft = AppColors.accentSoftOf(accent);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: accent,
        onPrimary: AppColors.black,
        secondary: AppColors.accentPurple,
        onSecondary: AppColors.white,
        surface: AppColors.anthracite,
        onSurface: AppColors.white,
        error: AppColors.error,
        onError: AppColors.white,
        outline: AppColors.anthraciteLight,
        onSurfaceVariant: AppColors.grayLight,
        inverseSurface: AppColors.white,
        onInverseSurface: AppColors.black,
      ),
      scaffoldBackgroundColor: AppColors.black,
      fontFamily: 'Inter',

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          letterSpacing: 0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.white),
        actionsIconTheme: IconThemeData(color: AppColors.whiteAlpha70),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceBlack,
        selectedItemColor: accent,
        unselectedItemColor: AppColors.grayMid,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.anthracite.withOpacity(0.95),
        indicatorColor: accentSoft,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: accent, size: 24);
          }
          return const IconThemeData(color: AppColors.grayMid, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: AppColors.grayMid,
            fontSize: 12,
          );
        }),
      ),

      // Cards
      cardTheme: CardTheme(
        color: AppColors.anthracite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.whiteAlpha05,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.anthraciteLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.anthraciteLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: const TextStyle(color: AppColors.grayLight),
        hintStyle: const TextStyle(color: AppColors.grayMid, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIconColor: AppColors.grayLight,
        suffixIconColor: AppColors.grayLight,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: AppColors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.white,
          side: const BorderSide(color: AppColors.glassBorderStrong),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.white,
          fontSize: 57,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: AppColors.white,
          fontSize: 45,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          color: AppColors.white,
          fontSize: 36,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          color: AppColors.white,
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        headlineMedium: TextStyle(
          color: AppColors.white,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        headlineSmall: TextStyle(
          color: AppColors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AppColors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          color: AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          color: AppColors.whiteAlpha70,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          color: AppColors.whiteAlpha90,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: AppColors.whiteAlpha70,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: AppColors.grayLight,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          color: AppColors.whiteAlpha70,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          color: AppColors.grayMid,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.anthraciteLight,
        thickness: 0.5,
        space: 1,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return AppColors.grayMid;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accentSoft;
          return AppColors.anthraciteLight;
        }),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.black),
        side: const BorderSide(color: AppColors.grayMid, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        inactiveTrackColor: AppColors.anthraciteLight,
        thumbColor: accent,
        overlayColor: accentSoft,
      ),

      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.anthracite,
        elevation: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.whiteAlpha70,
          fontSize: 15,
          fontFamily: 'Inter',
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.anthraciteMid,
        contentTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: AppColors.anthraciteLight,
      ),

      // Icon
      iconTheme: const IconThemeData(
        color: AppColors.grayLight,
        size: 24,
      ),
    );
  }
}
