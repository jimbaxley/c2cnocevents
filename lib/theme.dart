import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LightModeColors {
  static const lightPrimary = Color(0xFF233C7E);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightPrimaryContainer = Color.fromARGB(255, 228, 228, 228);
  static const lightOnPrimaryContainer = Color(0xFF1E1B4B);
  static const lightSecondary = Color(0xFF8B5CF6);
  static const lightOnSecondary = Color.fromARGB(255, 231, 231, 231);
  static const lightTertiary = Color(0xFFEC4899);
  static const lightOnTertiary = Color.fromARGB(255, 235, 235, 235);
  static const lightError = Color(0xFFEF4444);
  static const lightOnError = Color(0xFFFFFFFF);
  static const lightErrorContainer = Color(0xFFFFDAD6);
  static const lightOnErrorContainer = Color(0xFF410002);
  static const lightInversePrimary = Color(0xFFC6B3F7);
  static const lightShadow = Color(0xFF000000);
  static const lightSurface = Color(0xFFF5F5F5);
  static const lightOnSurface = Color(0xFF1F2937);
  static const lightAppBarBackground = Color(0xFFE0E7FF);
}

class DarkModeColors {
  static const darkPrimary = Color(0xFF982F7A);
  static const darkOnPrimary = Color(0xFFFFFFFF);
  static const darkPrimaryContainer = Color(0xFF3730A3);
  static const darkOnPrimaryContainer = Color(0xFFE0E7FF);
  static const darkSecondary = Color(0xFFA78BFA);
  static const darkOnSecondary = Color(0xFF4C1D95);
  static const darkTertiary = Color(0xFFF472B6);
  static const darkOnTertiary = Color(0xFF831843);
  static const darkError = Color(0xFFFF6B6B);
  static const darkOnError = Color(0xFF690005);
  static const darkErrorContainer = Color(0xFF93000A);
  static const darkOnErrorContainer = Color(0xFFFFDAD6);
  static const darkInversePrimary = Color(0xFF6366F1);
  static const darkShadow = Color(0xFF000000);
  static const darkSurface = Color(0xFF1F2937);
  static const darkOnSurface = Color(0xFFF9FAFB);
  static const darkAppBarBackground = Color(0xFF3730A3);
}

class FontSizes {
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 24.0;
  static const double headlineSmall = 22.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 18.0;
  static const double titleSmall = 16.0;
  static const double labelLarge = 16.0;
  static const double labelMedium = 14.0;
  static const double labelSmall = 12.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: LightModeColors.lightPrimary,
        onPrimary: LightModeColors.lightOnPrimary,
        primaryContainer: LightModeColors.lightPrimaryContainer,
        onPrimaryContainer: LightModeColors.lightOnPrimaryContainer,
        secondary: LightModeColors.lightSecondary,
        onSecondary: LightModeColors.lightOnSecondary,
        tertiary: LightModeColors.lightTertiary,
        onTertiary: LightModeColors.lightOnTertiary,
        error: LightModeColors.lightError,
        onError: LightModeColors.lightOnError,
        errorContainer: LightModeColors.lightErrorContainer,
        onErrorContainer: LightModeColors.lightOnErrorContainer,
        inversePrimary: LightModeColors.lightInversePrimary,
        shadow: LightModeColors.lightShadow,
        surface: LightModeColors.lightSurface,
        onSurface: LightModeColors.lightOnSurface,
      ),
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(
        backgroundColor: LightModeColors.lightAppBarBackground,
        foregroundColor: LightModeColors.lightOnPrimaryContainer,
        elevation: 0,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.montserrat(
          fontSize: FontSizes.displayLarge,
          fontWeight: FontWeight.normal,
        ),
        displayMedium: GoogleFonts.montserrat(
          fontSize: FontSizes.displayMedium,
          fontWeight: FontWeight.normal,
        ),
        displaySmall: GoogleFonts.montserrat(
          fontSize: FontSizes.displaySmall,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: GoogleFonts.montserrat(
          fontSize: FontSizes.headlineLarge,
          fontWeight: FontWeight.normal,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: FontSizes.headlineMedium,
          fontWeight: FontWeight.w500,
        ),
        headlineSmall: GoogleFonts.montserrat(
          fontSize: FontSizes.headlineSmall,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.montserrat(
          fontSize: FontSizes.titleLarge,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: GoogleFonts.montserrat(
          fontSize: FontSizes.titleMedium,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: GoogleFonts.montserrat(
          fontSize: FontSizes.titleSmall,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: GoogleFonts.montserrat(
          fontSize: FontSizes.labelLarge,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: GoogleFonts.montserrat(
          fontSize: FontSizes.labelMedium,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.montserrat(
          fontSize: FontSizes.labelSmall,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.montserrat(
          fontSize: FontSizes.bodyLarge,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: FontSizes.bodyMedium,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: GoogleFonts.montserrat(
          fontSize: FontSizes.bodySmall,
          fontWeight: FontWeight.normal,
        ),
      ),
    );

ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: DarkModeColors.darkPrimary,
        onPrimary: DarkModeColors.darkOnPrimary,
        primaryContainer: DarkModeColors.darkPrimaryContainer,
        onPrimaryContainer: DarkModeColors.darkOnPrimaryContainer,
        secondary: DarkModeColors.darkSecondary,
        onSecondary: DarkModeColors.darkOnSecondary,
        tertiary: DarkModeColors.darkTertiary,
        onTertiary: DarkModeColors.darkOnTertiary,
        error: DarkModeColors.darkError,
        onError: DarkModeColors.darkOnError,
        errorContainer: DarkModeColors.darkErrorContainer,
        onErrorContainer: DarkModeColors.darkOnErrorContainer,
        inversePrimary: DarkModeColors.darkInversePrimary,
        shadow: DarkModeColors.darkShadow,
        surface: DarkModeColors.darkSurface,
        onSurface: DarkModeColors.darkOnSurface,
      ),
      brightness: Brightness.dark,
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // <-- Rounded corners
        ),

        //color: const Color.fromARGB(255, 34, 19, 34), // <-- Your desired dark background
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: DarkModeColors.darkAppBarBackground,
        foregroundColor: DarkModeColors.darkOnPrimaryContainer,
        elevation: 0,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.montserrat(
          fontSize: FontSizes.displayLarge,
          fontWeight: FontWeight.normal,
        ),
        displayMedium: GoogleFonts.montserrat(
          fontSize: FontSizes.displayMedium,
          fontWeight: FontWeight.normal,
        ),
        displaySmall: GoogleFonts.montserrat(
          fontSize: FontSizes.displaySmall,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: GoogleFonts.montserrat(
          fontSize: FontSizes.headlineLarge,
          fontWeight: FontWeight.normal,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: FontSizes.headlineMedium,
          fontWeight: FontWeight.w500,
        ),
        headlineSmall: GoogleFonts.montserrat(
          fontSize: FontSizes.headlineSmall,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.montserrat(
          fontSize: FontSizes.titleLarge,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: GoogleFonts.montserrat(
          fontSize: FontSizes.titleMedium,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: GoogleFonts.montserrat(
          fontSize: FontSizes.titleSmall,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: GoogleFonts.montserrat(
          fontSize: FontSizes.labelLarge,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: GoogleFonts.montserrat(
          fontSize: FontSizes.labelMedium,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.montserrat(
          fontSize: FontSizes.labelSmall,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.montserrat(
          fontSize: FontSizes.bodyLarge,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: FontSizes.bodyMedium,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: GoogleFonts.montserrat(
          fontSize: FontSizes.bodySmall,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
