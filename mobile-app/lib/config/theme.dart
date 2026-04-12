import 'package:flutter/material.dart';

/// Design tokens from DESIGN_TOKENS.md
class AfrigoColors {
  // Primary Colors
  static const Color primaryDeepGreen = Color(0xFF0B6E4F);
  static const Color primaryEmerald = Color(0xFF10B981);

  // Secondary
  static const Color secondaryNavy = Color(0xFF0F172A);

  // Semantic
  static const Color successGreen = Color(0xFF22C55E);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF3B82F6);

  // Grayscale
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Backgrounds
  static const Color bgLight = Color(0xFFFFFAF5); // Warm white
  static const Color bgDark = Color(0xFF0F1419);

  // Borders
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF374151);

  // Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
}

/// Typography
class AfrigoTypography {
  static const String fontFamilyPrimary = 'Roboto'; // System font
  static const String fontFamilyDisplay = 'Roboto'; // System font

  // Display styles
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  // Heading styles
  static const TextStyle headingLarge = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // Label
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
}

/// Spacing/Grid System (8pt grid)
class AfrigoSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Theme
class AfrigoTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AfrigoColors.primaryDeepGreen,
      scaffoldBackgroundColor: AfrigoColors.bgLight,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AfrigoColors.secondaryNavy,
        titleTextStyle: AfrigoTypography.headingMedium.copyWith(
          color: AfrigoColors.secondaryNavy,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AfrigoColors.primaryDeepGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AfrigoSpacing.lg,
            vertical: AfrigoSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AfrigoTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AfrigoColors.primaryDeepGreen,
          side: const BorderSide(color: AfrigoColors.primaryDeepGreen),
          padding: const EdgeInsets.symmetric(
            horizontal: AfrigoSpacing.lg,
            vertical: AfrigoSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AfrigoColors.gray50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AfrigoColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AfrigoColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AfrigoColors.primaryDeepGreen,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(AfrigoSpacing.md),
        labelStyle: AfrigoTypography.labelMedium,
        hintStyle: AfrigoTypography.bodyMedium.copyWith(
          color: AfrigoColors.gray400,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AfrigoTypography.displayLarge,
        displayMedium: AfrigoTypography.displayMedium,
        headlineLarge: AfrigoTypography.headingLarge,
        headlineMedium: AfrigoTypography.headingMedium,
        headlineSmall: AfrigoTypography.headingSmall,
        bodyLarge: AfrigoTypography.bodyLarge,
        bodyMedium: AfrigoTypography.bodyMedium,
        bodySmall: AfrigoTypography.bodySmall,
        labelLarge: AfrigoTypography.labelLarge,
        labelMedium: AfrigoTypography.labelMedium,
      ),
      colorScheme: ColorScheme.light(
        primary: AfrigoColors.primaryDeepGreen,
        secondary: AfrigoColors.primaryEmerald,
        error: AfrigoColors.errorRed,
        surface: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AfrigoColors.primaryEmerald,
      scaffoldBackgroundColor: AfrigoColors.bgDark,
      colorScheme: ColorScheme.dark(
        primary: AfrigoColors.primaryEmerald,
        secondary: AfrigoColors.primaryDeepGreen,
        error: AfrigoColors.errorRed,
        surface: AfrigoColors.gray900,
      ),
    );
  }
}
