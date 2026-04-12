# AfriGo Design Tokens & Theme System

## 🎨 COLOR PALETTE (PRODUCTION-LOCKED)

### **Primary Colors**
```dart
// Primary green - trust, growth, trade
const Color primaryGreen = Color(0xFF0B6E4F);      // Deep green
const Color primaryGreenHover = Color(0xFF09543D); // Darker for hover
const Color accentGreen = Color(0xFF10B981);       // Emerald/bright green
```

### **Secondary Colors**
```dart
// Enterprise look
const Color darkNavy = Color(0xFF0F172A);          // Secondary dark
const Color slate = Color(0xFF334155);             // Slate gray
```

### **Functional Colors**
```dart
const Color infoBlue = Color(0xFF3B82F6);          // Information
const Color warningAmber = Color(0xFFF59E0B);      // Warning/pending
const Color successGreen = Color(0xFF22C55E);      // Success
const Color errorRed = Color(0xFFEF4444);          // Error/destructive

// Additional functional
const Color border = Color(0xFFE2E8F0);            // Light borders
const Color divider = Color(0xFFCBD5F5);           // Soft divider
const Color disabled = Color(0xFF94A3B8);          // Disabled state
```

### **Neutral Scale**
```dart
const Color white = Color(0xFFFFFFFF);
const Color lightBackground = Color(0xFFF8FAFC);   // Light mode BG
const Color softBackground = Color(0xFFF1F5F9);    // Softer light
const Color darkBackground = Color(0xFF020617);    // Dark mode BG
const Color surfaceLight = Color(0xFFFFFFFF);
const Color surfaceDark = Color(0xFF0F172A);
```

### **Gradients**
```dart
const LinearGradient primaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF0B6E4F), Color(0xFF10B981)],
);

const LinearGradient actionGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
);

const LinearGradient eventTimelineGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF0B6E4F), Color(0xFF10B98133)], // Fade to light
);
```

---

## 🔤 TYPOGRAPHY SYSTEM

### **Font Families**
```dart
// Primary (UI text, body)
const String fontFamilyDefault = 'Inter';

// Display/Headings (premium feel)
const String fontFamilyDisplay = 'Sora';
```

### **Text Scales**
```dart
class TextScales {
  // Headings (use Sora)
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Sora',
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.2, // Tighter line height for headings
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'Sora',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.25,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: 'Sora',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // Body text (use Inter)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5, // 1.5x line height for readability
    letterSpacing: 0,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // Captions
  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
  );

  static const TextStyle caption2 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0.5,
  );

  // Labels (for buttons, tags)
  static const TextStyle label = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0.5,
  );
}
```

### **Line Height Rules**
```
Body text: 1.4 - 1.5x (comfortable reading)
Headings: 1.2x (tight, impactful)
Captions: 1.33x (compact but readable)
```

---

## 🔘 BUTTON SYSTEM (PRODUCTION-READY)

### **Button Sizes**
```dart
class ButtonSizes {
  // Small: Form inputs, compact layout
  static const double smallHeight = 36;
  static const EdgeInsets smallPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  
  // Medium: Default, most common
  static const double mediumHeight = 44;
  static const EdgeInsets mediumPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 10);
  
  // Large: Primary CTAs, high emphasis
  static const double largeHeight = 52;
  static const EdgeInsets largePadding = EdgeInsets.symmetric(horizontal: 20, vertical: 12);
}
```

### **Border Radius**
```dart
// Standard (most buttons)
static const BorderRadius standardRadius = BorderRadius.all(Radius.circular(12));

// Large CTAs (more prominent)
static const BorderRadius largeRadius = BorderRadius.all(Radius.circular(16));

// Small/compact
static const BorderRadius smallRadius = BorderRadius.all(Radius.circular(8));
```

### **Button Types**

#### **1. Primary (Main CTA)**
```dart
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: ScaleTransition(
        scale: Tween(begin: 1.0, end: 0.97).animate(
          // Scale down on press (haptic feedback)
          CurvedAnimation(parent: _pressAnimation, curve: Curves.easeOut),
        ),
        child: Container(
          height: 44, // Medium
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0B6E4F), Color(0xFF10B981)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B6E4F).withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
```

**Visual Behavior:**
- Gradient fill: #0B6E4F → #10B981
- White text
- Soft shadow (color: 0B6E4F, opacity: 0.2, blur: 12)
- Hover: shadow increases
- Press: scale 1.0 → 0.97

#### **2. Secondary (Outline)**
```dart
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF10B981),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF10B981),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

**Visual Behavior:**
- Transparent background
- Green border (1.5px)
- Green text
- No shadow

#### **3. Ghost (No border)**
```dart
class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        splashColor: const Color(0xFF10B981).withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF10B981),
            ),
          ),
        ),
      ),
    );
  }
}
```

#### **4. Destructive (Danger)**
```dart
class DestructiveButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444), // Error red
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### **Interaction States**

```dart
class ButtonInteractions {
  // Press feedback
  static const Duration pressDuration = Duration(milliseconds: 120);
  static const double pressScale = 0.97;
  static const Curve pressCurve = Curves.easeOut;
  
  // Hover feedback (desktop)
  static const Duration hoverDuration = Duration(milliseconds: 150);
  
  // Disabled state
  static const double disabledOpacity = 0.4;
  
  // Loading animation
  static const Duration loadingSpinDuration = Duration(seconds: 1);
}
```

---

## 📏 SPACING SYSTEM (8pt Grid)

```dart
class Spacing {
  // Base unit: 8px
  static const double xs = 4;   // 0.5×
  static const double sm = 8;   // 1×
  static const double md = 16;  // 2×
  static const double lg = 24;  // 3×
  static const double xl = 32;  // 4×
  static const double xxl = 48; // 6×
  static const double xxxl = 64; // 8×
}
```

---

## 🎯 COMPONENT SPECS

### **Card Component**
```dart
class CardSpec {
  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(12));
  static const EdgeInsets padding = EdgeInsets.all(16);
  static const Color backgroundColor = Color(0xFFFFFFFF); // White
  
  static final BoxShadow shadow = BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
}
```

### **Input Field**
```dart
class InputFieldSpec {
  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(12));
  static const double height = 48;
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 12, vertical: 12);
  
  static const Color borderColor = Color(0xFFE2E8F0); // Light border
  static const Color borderFocusedColor = Color(0xFF10B981); // Green when focused
  static const Color backgroundColor = Color(0xFFFAFAFA); // Slightly off-white
}
```

### **Timeline Node**
```dart
class TimelineNodeSpec {
  static const double nodeRadius = 20; // 40px diameter
  static const double connectorWidth = 2;
  static const Color connectorColor = Color(0xFF0B6E4F);
  
  static const double nodeSpacing = 80; // Vertical spacing between nodes
}
```

---

## 🌓 DARK MODE SUPPORT

```dart
// Light Theme
class LightTheme {
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A); // Dark navy
  static const Color textSecondary = Color(0xFF64748B); // Medium gray
}

// Dark Theme (Phase 2)
class DarkTheme {
  static const Color background = Color(0xFF020617);
  static const Color surface = Color(0xFF0F172A);
  static const Color textPrimary = Color(0xFFF1F5F9); // Light
  static const Color textSecondary = Color(0xFF94A3B8); // Medium gray
}
```

---

## 🎬 STATUS COLORS (TIMELINE CRITICAL)

```dart
class StatusColors {
  // Lot/Shipment/Payment status colors
  static const Color pending = Color(0xFFF59E0B);     // Amber - awaiting action
  static const Color approved = Color(0xFF22C55E);    // Green - confirmed
  static const Color rejected = Color(0xFFEF4444);    // Red - failed/denied
  static const Color inProgress = Color(0xFF3B82F6);  // Blue - active
  static const Color archived = Color(0xFF94A3B8);    // Gray - completed/old
}
```

---

## 📱 RESPONSIVE BREAKPOINTS

```dart
class ResponsiveBreakpoints {
  static const double mobile = 0;      // 0 - 599px
  static const double tablet = 600;    // 600 - 1199px
  static const double desktop = 1200;  // 1200px+
}
```

---

## 🔗 USAGE IN FLUTTER

```dart
// In your main theme file:
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF0B6E4F),
      secondary: const Color(0xFF10B981),
      error: const Color(0xFFEF4444),
      surface: const Color(0xFFFFFFFF),
      background: const Color(0xFFF8FAFC),
    ),
    # Typography
    textTheme: const TextTheme(
      displayLarge: TextScales.h1,
      displayMedium: TextScales.h2,
      displaySmall: TextScales.h3,
      bodyLarge: TextScales.bodyLarge,
      bodyMedium: TextScales.body,
      bodySmall: TextScales.bodySmall,
      labelMedium: TextScales.label,
      labelSmall: TextScales.caption,
    ),
    # Components
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      prefixIconColor: const Color(0xFF10B981),
    ),
  );
}
```

---

## ✅ DESIGN TOKENS CHECKLIST

- [ ] Colors: All 25+ colors defined
- [ ] Typography: 4 font scales (heading, body, label, caption)
- [ ] Buttons: 4 types × 3 sizes = 12 variants
- [ ] Spacing: 8-point grid system
- [ ] Components: Card, Input, Timeline, etc.
- [ ] Dark mode: Full palette defined (Phase 2)
- [ ] Status colors: Timeline-specific
- [ ] Animations: Timing + easing centralized
- [ ] Shadows: Consistent elevation system
- [ ] Responsive: Mobile/tablet/desktop breakpoints

