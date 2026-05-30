import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Official AfriGo Brand Colors (May 2026)
/// Maps new color system with backwards compatibility
class AfrigoColors {
  // ============================================================================
  // PRIMARY BRAND COLORS
  // ============================================================================
  static const Color primary = AppColors.primaryGreen;
  static const Color primaryLight = AppColors.primaryGreenLight;
  static const Color primaryDark = AppColors.primaryGreenHover;

  // ============================================================================
  // ACCENT COLORS
  // ============================================================================
  static const Color accent = AppColors.accentBlue;
  static const Color accentLight = AppColors.accentBlueLight;

  // ============================================================================
  // SEMANTIC COLORS
  // ============================================================================
  static const Color success = AppColors.successGreen;
  static const Color warning = AppColors.warningOrange;
  static const Color error = AppColors.errorRed;
  static const Color info = AppColors.accentBlue;

  // ============================================================================
  // NEUTRAL PALETTE
  // ============================================================================
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE3E3E3);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);

  // ============================================================================
  // BACKGROUNDS & SURFACES (OFFICIAL COLORS)
  // ============================================================================
  static const Color bgLight = AppColors.backgroundLight;
  static const Color bgLightAlt = AppColors.backgroundLight;
  static const Color bgDark = Color(0xFF121212);
  static const Color surface = AppColors.surfaceCard;
  static const Color surfaceVariant = AppColors.backgroundLight;

  // ============================================================================
  // BORDERS & DIVIDERS (OFFICIAL COLORS)
  // ============================================================================
  static const Color borderLight = AppColors.borderDefault;
  static const Color borderDefault = AppColors.borderDefault;
  static const Color borderDark = AppColors.divider;

  // ============================================================================
  // TEXT COLORS (OFFICIAL COLORS)
  // ============================================================================
  static const Color textPrimary = AppColors.textDark;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textTertiary = AppColors.textSecondary;

  // ============================================================================
  // BACKWARDS COMPATIBILITY ALIASES
  // ============================================================================
  static const Color primaryDeepGreen = primary;
  static const Color primaryEmerald = primaryLight;
  static const Color secondaryNavy = neutral900;
  static const Color successGreen = success;
  static const Color warningAmber = warning;
  static const Color errorRed = error;
  static const Color infoBlue = info;
  static const Color gray50 = neutral50;
  static const Color gray100 = neutral100;
  static const Color gray200 = neutral200;
  static const Color gray300 = neutral300;
  static const Color gray400 = neutral400;
  static const Color gray500 = neutral500;
  static const Color gray600 = neutral600;
  static const Color gray700 = neutral700;
  static const Color gray800 = neutral800;
  static const Color gray900 = neutral900;
}

/// Modern Typography System
/// Headings: Sora (Modern, premium, technological)
/// Body: Inter (Readable, enterprise-friendly, data-friendly)
class AfrigoTypography {
  // SORA HEADINGS - Modern, premium feel
  static TextStyle soraHeading1 = GoogleFonts.sora(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static TextStyle soraHeading2 = GoogleFonts.sora(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.3,
  );

  static TextStyle soraHeading3 = GoogleFonts.sora(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
  );

  static TextStyle soraHeading4 = GoogleFonts.sora(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle soraHeading5 = GoogleFonts.sora(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle soraHeading6 = GoogleFonts.sora(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // INTER BODY - Readable, professional, data-optimized
  static TextStyle interBody1 = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.2,
  );

  static TextStyle interBody1Semi = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.6,
    letterSpacing: 0.2,
  );

  static TextStyle interBody2 = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.2,
  );

  static TextStyle interBody2Semi = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.6,
    letterSpacing: 0.2,
  );

  static TextStyle interBody3 = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.3,
  );

  static TextStyle interBody3Semi = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.3,
  );

  // Button & Label Text
  static TextStyle buttonLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.2,
  );

  static TextStyle buttonMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.2,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.5,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.3,
  );

  // KPI/Numbers
  static TextStyle kpiLarge = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle kpiMedium = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.3,
  );

  // Backwards compatibility
  static TextStyle displayLarge = soraHeading1;
  static TextStyle displayMedium = soraHeading2;
  static TextStyle headingLarge = soraHeading3;
  static TextStyle headingMedium = soraHeading4;
  static TextStyle headingSmall = soraHeading5;
  static TextStyle bodyLarge = interBody1;
  static TextStyle bodyMedium = interBody2;
  static TextStyle bodySmall = interBody3;
  static TextStyle labelLarge = buttonLarge;
  static TextStyle labelMedium = buttonMedium;
}

/// Modern Spacing System (8pt grid base)
class AfrigoSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double screenPadding = 20;
}

/// Modern Border Radius System
class AfriBorderRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 9999;
}

/// Elevation/Shadow System
class AfrigoElevation {
  static List<BoxShadow> shadow0 = [];

  static List<BoxShadow> shadow1 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> shadow2 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadow3 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadow4 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}

/// Modern Theme System
class AfrigoTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.backgroundLight,

      // App Bar
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        titleTextStyle: AfrigoTypography.soraHeading5.copyWith(
          color: AppColors.textDark,
        ),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.5,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AfriBorderRadius.lg),
          side: const BorderSide(
            color: AppColors.borderDefault,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // Primary Button (Elevated) - Deep Forest Green
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AfrigoSpacing.xl,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AfriBorderRadius.lg),
          ),
          textStyle: AfrigoTypography.buttonLarge,
        ),
      ),

      // Secondary Button (Outlined) - Deep Forest Green
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          side: const BorderSide(
            color: AppColors.primaryGreen,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AfrigoSpacing.xl,
            vertical: 13,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AfriBorderRadius.lg),
          ),
          textStyle: AfrigoTypography.buttonLarge,
        ),
      ),

      // Text Button - Deep Forest Green
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          textStyle: AfrigoTypography.buttonMedium,
          padding: const EdgeInsets.symmetric(
            horizontal: AfrigoSpacing.md,
            vertical: AfrigoSpacing.sm,
          ),
        ),
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AfrigoSpacing.lg,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AfriBorderRadius.md),
          borderSide: const BorderSide(
            color: AppColors.borderDefault,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AfriBorderRadius.md),
          borderSide: const BorderSide(
            color: AppColors.borderDefault,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AfriBorderRadius.md),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AfriBorderRadius.md),
          borderSide: const BorderSide(
            color: AppColors.errorRed,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AfriBorderRadius.md),
          borderSide: const BorderSide(
            color: AppColors.errorRed,
            width: 2,
          ),
        ),
        hintStyle: AfrigoTypography.interBody2.copyWith(
          color: AppColors.textSecondary,
        ),
        labelStyle: AfrigoTypography.interBody2Semi.copyWith(
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: AfrigoTypography.interBody3Semi.copyWith(
          color: AppColors.primaryGreen,
        ),
      ),

      // Color Scheme - Official AfriGo Colors
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.secondaryGold,
        tertiary: AppColors.accentBlue,
        error: AppColors.errorRed,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
      ),

      // List & Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDefault,
        thickness: 1,
        space: 0,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AfriBorderRadius.xl),
            topRight: Radius.circular(AfriBorderRadius.xl),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryGreenLight,
      scaffoldBackgroundColor: AfrigoColors.bgDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryGreenLight,
        secondary: AppColors.secondaryGold,
        tertiary: AppColors.accentBlue,
        error: AppColors.errorRed,
        surface: AfrigoColors.neutral900,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
      ),
    );
  }
}

/// Backwards Compatibility - Maps old AppTheme to new color system
class AppTheme {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color primaryGreenLight = AppColors.primaryGreenLight;
  static const Color primaryGreenHover = AppColors.primaryGreenHover;

  static const Color secondaryGold = AppColors.secondaryGold;
  static const Color accentBlue = AppColors.accentBlue;

  static const Color successGreen = AppColors.successGreen;
  static const Color warningOrange = AppColors.warningOrange;
  static const Color errorRed = AppColors.errorRed;

  static const Color textPrimary = AppColors.textDark;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color backgroundLight = AppColors.backgroundLight;
  static const Color surfaceCard = AppColors.surfaceCard;
}
