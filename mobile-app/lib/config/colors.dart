import 'package:flutter/material.dart';

/// Official AfriGo Brand Colors (May 2026)
/// Communicates: Trust + Agriculture + Export + Global Trade
class AppColors {
  // ============================================================================
  // PRIMARY BRAND COLORS
  // ============================================================================

  /// Deep Forest Green - Trust, agriculture, export, global trade
  static const Color primaryGreen = Color(0xFF0F5B46);
  static const Color primaryGreenHover =
      Color(0xFF0A4335); // Hover state (20% darker)
  static const Color primaryGreenLight = Color(0xFF1A8A67); // Lighter variant
  static const Color primaryGreenLighter = Color(0xFFE8F5F1); // Background tint

  /// Export Gold - Commerce, premium, quality
  static const Color secondaryGold = Color(0xFFC89B3C);
  static const Color secondaryGoldHover = Color(0xFFB68927); // Hover state
  static const Color secondaryGoldLight = Color(0xFFE8D9B8); // Background tint

  /// Ocean Blue - Logistics, tracking, shipping, real-time updates
  static const Color accentBlue = Color(0xFF1E88E5);
  static const Color accentBlueDark = Color(0xFF1565C0); // Darker variant
  static const Color accentBlueLight = Color(0xFFE3F2FD); // Background tint

  // ============================================================================
  // SEMANTIC COLORS
  // ============================================================================

  /// Success state - Confirmations, approved states, positive feedback
  static const Color successGreen = Color(0xFF12B76A);
  static const Color successGreenLight = Color(0xFFD1FAE5); // Background tint

  /// Warning state - Pending states, caution alerts, requires attention
  static const Color warningOrange = Color(0xFFF79009);
  static const Color warningOrangeLight = Color(0xFFFEF3C7); // Background tint

  /// Error state - Errors, destructive actions, critical alerts
  static const Color errorRed = Color(0xFFF04438);
  static const Color errorRedLight = Color(0xFFFEE4E2); // Background tint

  // ============================================================================
  // NEUTRAL PALETTE
  // ============================================================================

  /// Background - Main app background, light surfaces
  static const Color backgroundLight = Color(0xFFF7F8FA);

  /// Cards/Surfaces - Cards, modals, dropdowns, overlays
  static const Color surfaceCard = Color(0xFFFFFFFF);

  /// Text - Dark (Primary) - Main body text, headings, primary content
  static const Color textDark = Color(0xFF111827);

  /// Text - Secondary - Secondary text, placeholders, disabled states
  static const Color textSecondary = Color(0xFF667085);

  /// Borders & Dividers - Card borders, input borders, divider lines
  static const Color borderDefault = Color(0xFFE4E7EC);

  /// Soft divider - For lighter visual separation
  static const Color divider = Color(0xFFD0D5DD);

  /// Disabled state - For disabled interactive elements
  static const Color disabled = Color(0xFFA0AEC0);

  // ============================================================================
  // GRADIENTS
  // ============================================================================

  /// Primary brand gradient - Deep green to lighter green
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F5B46), Color(0xFF1A8A67)],
  );

  /// Gold accent gradient - Export gold to lighter gold
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC89B3C), Color(0xFFE8D9B8)],
  );

  /// Logistics blue gradient - Ocean blue to lighter blue
  static const LinearGradient logisticsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
  );

  /// Timeline/event gradient - Green fading to transparent
  static const LinearGradient eventTimelineGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F5B46), Color(0xFF0F5B4622)],
  );

  // ============================================================================
  // BACKWARDS COMPATIBILITY ALIASES
  // ============================================================================
  // (For transitioning from old color names)

  static const Color primary = primaryGreen;
  static const Color secondary = secondaryGold;
  static const Color accent = accentBlue;
  static const Color success = successGreen;
  static const Color warning = warningOrange;
  static const Color error = errorRed;
  static const Color background = backgroundLight;
  static const Color surface = surfaceCard;
  static const Color border = borderDefault;
}
