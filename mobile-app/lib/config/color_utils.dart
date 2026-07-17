/// Color System Utility Functions and Extensions
library;

import 'dart:math' show pow;
import 'package:flutter/material.dart';
import 'colors.dart';

/// Extension methods for Color interactions
extension ColorExtension on Color {
  /// Lighten a color by a percentage (0.0 - 1.0)
  Color lighten(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness(
          (hsl.lightness + amount).clamp(0.0, 1.0),
        )
        .toColor();
  }

  /// Darken a color by a percentage (0.0 - 1.0)
  Color darken(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness(
          (hsl.lightness - amount).clamp(0.0, 1.0),
        )
        .toColor();
  }

  /// Get a color with opacity
  Color withAlphaPercent(double percent) {
    assert(percent >= 0 && percent <= 100);
    return withOpacity(percent / 100);
  }
}

/// Semantic color getter based on context
class SemanticColor {
  /// Get status color by type
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'approved':
      case 'confirmed':
        return AppColors.successGreen;
      case 'warning':
      case 'pending':
      case 'review':
        return AppColors.warningOrange;
      case 'error':
      case 'rejected':
      case 'failed':
      case 'critical':
        return AppColors.errorRed;
      case 'info':
      case 'processing':
        return AppColors.accentBlue;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Get status background color by type
  static Color getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'approved':
      case 'confirmed':
        return AppColors.successGreenLight;
      case 'warning':
      case 'pending':
      case 'review':
        return AppColors.warningOrangeLight;
      case 'error':
      case 'rejected':
      case 'failed':
      case 'critical':
        return AppColors.errorRedLight;
      case 'info':
      case 'processing':
        return AppColors.accentBlueLight;
      default:
        return AppColors.backgroundLight;
    }
  }
}

/// Color palette quick reference for consistent UI
class ColorPalette {
  /// Primary brand color (Deep Forest Green)
  static const Color primary = AppColors.primaryGreen;

  /// Secondary brand color (Export Gold)
  static const Color secondary = AppColors.secondaryGold;

  /// Accent color (Ocean Blue) - for logistics/tracking
  static const Color accent = AppColors.accentBlue;

  /// All success variations
  static const Map<String, Color> success = {
    'dark': AppColors.successGreen,
    'light': AppColors.successGreenLight,
  };

  /// All warning variations
  static const Map<String, Color> warning = {
    'dark': AppColors.warningOrange,
    'light': AppColors.warningOrangeLight,
  };

  /// All error variations
  static const Map<String, Color> error = {
    'dark': AppColors.errorRed,
    'light': AppColors.errorRedLight,
  };

  /// All neutral variations
  static const Map<String, Color> neutral = {
    'background': AppColors.backgroundLight,
    'surface': AppColors.surfaceCard,
    'textDark': AppColors.textDark,
    'textSecondary': AppColors.textSecondary,
    'border': AppColors.borderDefault,
    'divider': AppColors.divider,
    'disabled': AppColors.disabled,
  };

  /// All primary variations
  static const Map<String, Color> primaryVariations = {
    'default': AppColors.primaryGreen,
    'hover': AppColors.primaryGreenHover,
    'light': AppColors.primaryGreenLight,
    'lighter': AppColors.primaryGreenLighter,
  };

  /// All secondary variations
  static const Map<String, Color> secondaryVariations = {
    'default': AppColors.secondaryGold,
    'hover': AppColors.secondaryGoldHover,
    'light': AppColors.secondaryGoldLight,
  };

  /// All accent variations
  static const Map<String, Color> accentVariations = {
    'default': AppColors.accentBlue,
    'dark': AppColors.accentBlueDark,
    'light': AppColors.accentBlueLight,
  };
}

/// Contrast checker helper for accessibility
class ContrastHelper {
  /// Calculate relative luminance of a color
  static double _relativeLuminance(Color color) {
    final rgb = [color.red, color.green, color.blue].map((component) {
      final c = component / 255.0;
      if (c <= 0.03928) {
        return c / 12.92;
      }
      return pow((c + 0.055) / 1.055, 2.0).toDouble();
    }).toList();

    return 0.2126 * rgb[0] + 0.7152 * rgb[1] + 0.0722 * rgb[2];
  }

  /// Calculate WCAG contrast ratio between two colors
  static double getContrastRatio(Color foreground, Color background) {
    final l1 = _relativeLuminance(foreground);
    final l2 = _relativeLuminance(background);

    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if contrast meets WCAG AA standard (4.5:1)
  static bool meetsAAStandard(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= 4.5;
  }

  /// Check if contrast meets WCAG AAA standard (7:1)
  static bool meetsAAAStandard(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= 7.0;
  }

  /// Verify all official color combinations
  static Map<String, bool> verifyAllContrasts() {
    return {
      'White on Primary Green':
          meetsAAStandard(Colors.white, AppColors.primaryGreen),
      'White on Secondary Gold':
          meetsAAStandard(Colors.white, AppColors.secondaryGold),
      'White on Accent Blue':
          meetsAAStandard(Colors.white, AppColors.accentBlue),
      'Dark Text on Background':
          meetsAAAStandard(AppColors.textDark, AppColors.backgroundLight),
      'Secondary Text on Background':
          meetsAAStandard(AppColors.textSecondary, AppColors.backgroundLight),
    };
  }
}
