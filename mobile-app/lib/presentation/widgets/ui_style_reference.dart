import 'package:flutter/material.dart';
import '../../config/colors.dart';
import 'animated_button.dart';
import 'modern_card.dart';

/// Complete UI Style Reference & Implementation Guide
/// Shows all available button and card components with usage examples

class UIStyleGuide {
  /// Button Style Reference
  ///
  /// Primary Button (Filled - Deep Forest Green)
  /// Usage: Main actions, primary calls-to-action
  /// Height: Default 44px, or 56px for large touch targets
  ///
  /// ```dart
  /// AnimatedPrimaryButton(
  ///   label: 'Submit Order',
  ///   onPressed: () { /* action */ },
  ///   isLargeTouchTarget: true, // 56px height
  /// )
  /// ```
  static const String primaryButtonDocs = '''
  Primary Button - Filled Style
  - Color: Deep Forest Green (#0F5B46)
  - Animation: 200ms scale (1.0 → 0.96)
  - Hover: Color transitions to primaryGreenHover
  - Shadow: Subtle elevation (0.1 opacity)
  - States: Normal, Pressed, Loading, Disabled
  - Touch Target: 56px height (isLargeTouchTarget: true)
  - Usage: Main actions, form submissions, primary CTAs
  ''';

  /// Secondary Button (Outlined - No Fill, Bordered)
  /// Usage: Secondary actions, alternatives to primary action
  /// Height: Default 44px, or 56px for large touch targets
  ///
  /// ```dart
  /// AnimatedOutlinedButton(
  ///   label: 'Cancel',
  ///   onPressed: () { /* action */ },
  ///   borderColor: AppColors.primaryGreen,
  ///   textColor: AppColors.primaryGreen,
  ///   isLargeTouchTarget: true,
  /// )
  /// ```
  static const String secondaryButtonDocs = '''
  Secondary Button - Outlined Style
  - Border: 2px solid border (customizable color)
  - Background: Transparent
  - Animation: 200ms scale (1.0 → 0.96)
  - Color Animation: Smooth text color transition on press
  - Border Animation: Border opacity changes on press
  - Touch Target: 56px height (isLargeTouchTarget: true)
  - Usage: Secondary actions, cancel buttons, alternatives
  ''';

  /// Tertiary Button (Text Only - No Background, No Border)
  /// Usage: Minimal actions, links, tertiary alternatives
  /// Height: Default 28px, or 56px for large touch targets
  ///
  /// ```dart
  /// AnimatedTextButton(
  ///   label: 'Learn More',
  ///   onPressed: () { /* action */ },
  ///   textColor: AppColors.accentBlue,
  ///   isLargeTouchTarget: false,
  /// )
  /// ```
  static const String tertiaryButtonDocs = '''
  Tertiary Button - Text Only Style
  - Style: Text-only, no background or border
  - Animation: 200ms fade (1.0 → 0.7)
  - Color Animation: Smooth color transition on press
  - Minimal padding: 8px by default
  - Touch Target: 56px height optional (isLargeTouchTarget: true)
  - Usage: Links, minimal actions, tertiary CTAs, help/info
  ''';

  /// Card Style Reference
  ///
  /// Modern Card - Base Card Component
  /// Features: Floating effect, elevation, customizable styling
  ///
  /// ```dart
  /// ModernCard(
  ///   borderRadius: 16, // 16-24px standard
  ///   elevation: 1,
  ///   isFloating: true,
  ///   onTap: () { /* action */ },
  ///   child: Column(
  ///     children: [
  ///       Text('Card Content'),
  ///     ],
  ///   ),
  /// )
  /// ```
  static const String modernCardDocs = '''
  Modern Card - Primary Card Component
  - Border Radius: 16-24px (default 16)
  - Elevation: Configurable (default 1)
  - Shadow: Subtle (0.08 opacity)
  - Floating Effect: On hover/tap elevation increases to +4
  - Float Animation: 4px upward slide on hover (300ms)
  - Background: AppColors.surfaceCard
  - Border: AppColors.borderDefault (1px)
  - Interactive: onTap callback support
  - States: Normal, Hover (with float effect)
  ''';

  /// Layered Card - Creates Visual Depth
  /// Features: Multiple background layers for visual hierarchy
  ///
  /// ```dart
  /// LayeredCard(
  ///   layers: 3,
  ///   layerOffset: 4,
  ///   child: Text('Layered Content'),
  /// )
  /// ```
  static const String layeredCardDocs = '''
  Layered Card - Visual Depth Component
  - Layers: Number of background layers (default 2)
  - Layer Offset: Pixel offset between layers (default 4)
  - Background Colors: backgroundLight with decreasing opacity
  - Main Layer: surfaceCard with subtle border
  - Shadow: Dual shadow system (0.05 and 0.03 opacity)
  - Use Case: Premium content, featured items, highlight sections
  ''';

  /// Floating Panel - Always Floating Effect
  /// Features: Continuous floating animation, enhanced shadows
  ///
  /// ```dart
  /// FloatingPanel(
  ///   borderRadius: 20,
  ///   child: Column(
  ///     children: [
  ///       Text('Floating Content'),
  ///     ],
  ///   ),
  /// )
  /// ```
  static const String floatingPanelDocs = '''
  Floating Panel - Continuous Floating Animation
  - Elevation: Base 12 + animated +8 (total 20px max)
  - Float Animation: Continuous 0-8px vertical movement
  - Animation Duration: 2000ms (slow, continuous)
  - Easing: easeInOut for smooth oscillation
  - Shadow Color: primaryGreen tinted (0.15 opacity)
  - Use Case: Featured content, special sections, emphasis
  ''';

  /// Shadow Styles - Consistent Shadow System
  /// Use ShadowStyles class for consistent elevation shadows
  ///
  /// ```dart
  /// Container(
  ///   decoration: BoxDecoration(
  ///     boxShadow: ShadowStyles.medium,
  ///   ),
  ///   child: Text('Content'),
  /// )
  /// ```
  static const String shadowStylesDocs = '''
  Shadow Styles - Elevation System
  - Subtle: Light elevation (0.04-0.06 opacity) - cards, small components
  - Medium: Standard elevation (0.06-0.02 opacity) - card hover, active states
  - Elevated: High elevation (0.08-0.04 opacity) - floating panels, modals
  - Deep: Maximum elevation (0.12-0.08 opacity) - dialogs, overlays
  - All use layered shadows for natural depth
  ''';
}

/// Example Screen Showing All Button Styles
class ButtonStylesExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Button Styles'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Primary Buttons Section
          const SectionHeader('Primary Buttons'),
          const SizedBox(height: 12),
          AnimatedPrimaryButton(
            label: 'Primary Button (Normal)',
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          AnimatedPrimaryButton(
            label: 'Large Touch Target (56px)',
            onPressed: () {},
            isLargeTouchTarget: true,
          ),
          const SizedBox(height: 12),
          AnimatedPrimaryButton(
            label: 'Disabled Button',
            onPressed: () {},
            isEnabled: false,
          ),
          const SizedBox(height: 24),

          // Secondary (Outlined) Buttons Section
          const SectionHeader('Secondary Buttons (Outlined)'),
          const SizedBox(height: 12),
          AnimatedOutlinedButton(
            label: 'Secondary Outlined',
            onPressed: () {},
            borderColor: AppColors.primaryGreen,
            textColor: AppColors.primaryGreen,
          ),
          const SizedBox(height: 12),
          AnimatedOutlinedButton(
            label: 'Large Touch Target (56px)',
            onPressed: () {},
            borderColor: AppColors.primaryGreen,
            textColor: AppColors.primaryGreen,
            isLargeTouchTarget: true,
          ),
          const SizedBox(height: 12),
          AnimatedOutlinedButton(
            label: 'Gold Variant',
            onPressed: () {},
            borderColor: AppColors.secondaryGold,
            textColor: AppColors.secondaryGold,
          ),
          const SizedBox(height: 24),

          // Tertiary (Text Only) Buttons Section
          const SectionHeader('Tertiary Buttons (Text Only)'),
          const SizedBox(height: 12),
          AnimatedTextButton(
            label: 'Text Button',
            onPressed: () {},
            textColor: AppColors.primaryGreen,
          ),
          const SizedBox(height: 12),
          AnimatedTextButton(
            label: 'Large Touch Target (56px)',
            onPressed: () {},
            textColor: AppColors.primaryGreen,
            isLargeTouchTarget: true,
          ),
          const SizedBox(height: 12),
          AnimatedTextButton(
            label: 'Blue Variant',
            onPressed: () {},
            textColor: AppColors.accentBlue,
          ),
          const SizedBox(height: 24),

          // Card Styles Section
          const SectionHeader('Card Styles'),
          const SizedBox(height: 12),
          ModernCard(
            borderRadius: 16,
            child: const Text('Modern Card (16px radius)'),
          ),
          const SizedBox(height: 12),
          ModernCard(
            borderRadius: 20,
            isFloating: true,
            onTap: () {},
            child: const Text('Floating Card (Interactive)'),
          ),
          const SizedBox(height: 12),
          LayeredCard(
            layers: 2,
            child: const Text('Layered Card (Visual Depth)'),
          ),
          const SizedBox(height: 12),
          FloatingPanel(
            child: const Text('Floating Panel (Continuous Animation)'),
          ),
        ],
      ),
    );
  }
}

/// Section header for organizing examples
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'Sora',
      ),
    );
  }
}

/// Button Size Guidelines
class ButtonSizeGuidelines {
  // Standard touch target sizes for accessibility
  static const double smallTouchTarget = 40; // Compact buttons
  static const double standardTouchTarget = 48; // Standard buttons
  static const double largeTouchTarget = 56; // Large touch target (recommended)
  static const double extraLargeTouchTarget = 64; // Extra large (premium CTAs)

  // Padding guidelines for button content
  static const EdgeInsets compactPadding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  static const EdgeInsets standardPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const EdgeInsets largePadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 14);
}

/// Card Size Guidelines
class CardSizeGuidelines {
  // Border radius recommendations
  static const double smallRadius = 8; // Subtle rounding
  static const double standardRadius = 16; // Standard card radius
  static const double largeRadius = 20; // Premium feel
  static const double extraLargeRadius = 24; // Featured content

  // Elevation/shadow recommendations
  static const double subtleElevation = 1; // Minimal elevation
  static const double standardElevation = 4; // Standard card
  static const double prominentElevation = 8; // Featured content
  static const double floatingElevation = 12; // Floating panels

  // Padding recommendations for card content
  static const EdgeInsets compactPadding = EdgeInsets.all(12);
  static const EdgeInsets standardPadding = EdgeInsets.all(16);
  static const EdgeInsets spaciousPadding = EdgeInsets.all(20);
}

/// Animation Timing Guidelines
class AnimationTimings {
  static const Duration fastPress = Duration(milliseconds: 200); // Button press
  static const Duration standardHover =
      Duration(milliseconds: 300); // Card hover
  static const Duration slowEntry =
      Duration(milliseconds: 400); // Entry animation
  static const Duration continuousFloat =
      Duration(milliseconds: 2000); // Floating panel
}
