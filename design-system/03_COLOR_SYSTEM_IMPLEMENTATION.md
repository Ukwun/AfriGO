# AfriGo Color System Implementation Guide

**Version:** May 2026  
**Status:** Production-Ready  
**Last Updated:** May 30, 2026

---

## 📋 Quick Reference - Color Codes

### Brand Colors
| Usage | Color | HEX | Dart Const |
|-------|-------|-----|-----------|
| Primary (Trust/Trade) | Deep Forest Green | #0F5B46 | `primaryGreen` |
| Secondary (Commerce) | Export Gold | #C89B3C | `secondaryGold` |
| Accent (Logistics) | Ocean Blue | #1E88E5 | `accentBlue` |

### Semantic Colors
| State | Color | HEX | Dart Const |
|-------|-------|-----|-----------|
| Success | Green | #12B76A | `successGreen` |
| Warning | Orange | #F79009 | `warningOrange` |
| Error | Red | #F04438 | `errorRed` |

### Neutral Palette
| Element | Color | HEX | Dart Const |
|---------|-------|-----|-----------|
| Background | Light Gray | #F7F8FA | `backgroundLight` |
| Cards | White | #FFFFFF | `surfaceCard` |
| Text (Dark) | Dark Gray | #111827 | `textDark` |
| Text (Secondary) | Medium Gray | #667085 | `textSecondary` |
| Borders | Light Gray | #E4E7EC | `borderDefault` |

---

## 🎨 Flutter Implementation (Mobile App)

### Step 1: Create Theme Constants File

**File:** `lib/config/colors.dart`

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primaryGreen = Color(0xFF0F5B46);
  static const Color primaryGreenHover = Color(0xFF0A4335);
  static const Color primaryGreenLight = Color(0xFF1A8A67);
  static const Color primaryGreenLighter = Color(0xFFE8F5F1);

  // Secondary Brand Colors
  static const Color secondaryGold = Color(0xFFC89B3C);
  static const Color secondaryGoldHover = Color(0xFFB68927);
  static const Color secondaryGoldLight = Color(0xFFE8D9B8);

  // Accent Blue (Logistics/Tracking)
  static const Color accentBlue = Color(0xFF1E88E5);
  static const Color accentBlueDark = Color(0xFF1565C0);
  static const Color accentBlueLight = Color(0xFFE3F2FD);

  // Semantic Colors
  static const Color successGreen = Color(0xFF12B76A);
  static const Color successGreenLight = Color(0xFFD1FAE5);
  
  static const Color warningOrange = Color(0xFFF79009);
  static const Color warningOrangeLight = Color(0xFFFEF3C7);
  
  static const Color errorRed = Color(0xFFF04438);
  static const Color errorRedLight = Color(0xFFFEE4E2);

  // Neutral Palette
  static const Color backgroundLight = Color(0xFFF7F8FA);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF667085);
  static const Color borderDefault = Color(0xFFE4E7EC);
  static const Color divider = Color(0xFFD0D5DD);
  static const Color disabled = Color(0xFFA0AEC0);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F5B46), Color(0xFF1A8A67)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC89B3C), Color(0xFFE8D9B8)],
  );

  static const LinearGradient logisticsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
  );

  static const LinearGradient eventTimelineGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F5B46), Color(0xFF0F5B4622)],
  );
}
```

### Step 2: Create Theme Data

**File:** `lib/config/theme.dart`

```dart
import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Primary brand colors
    primaryColor: AppColors.primaryGreen,
    primaryColorDark: AppColors.primaryGreenHover,
    
    // Scaffold and background
    scaffoldBackgroundColor: AppColors.backgroundLight,
    canvasColor: AppColors.backgroundLight,
    
    // Color scheme (Material 3)
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryGreen,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryGreenLight,
      onPrimaryContainer: AppColors.textDark,
      
      secondary: AppColors.secondaryGold,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryGoldLight,
      
      tertiary: AppColors.accentBlue,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.accentBlueLight,
      
      error: AppColors.errorRed,
      errorContainer: AppColors.errorRedLight,
      
      surface: AppColors.surfaceCard,
      onSurface: AppColors.textDark,
      outline: AppColors.borderDefault,
    ),
    
    // AppBar styling
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Sora',
      ),
    ),
    
    // Button styling
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    ),
    
    // Card styling
    cardTheme: CardTheme(
      color: AppColors.surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.borderDefault, width: 1),
      ),
    ),
    
    // Input decoration styling
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundLight,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.borderDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.errorRed),
      ),
      hintStyle: TextStyle(
        color: AppColors.textSecondary,
        fontFamily: 'Inter',
      ),
    ),
  );
}
```

### Step 3: Apply Theme in Main.dart

```dart
import 'package:flutter/material.dart';
import 'config/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AfriGo',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
```

---

## 🎬 Animation & Micro-Interactions Implementation

### Button Hover & Press States

```dart
import 'package:flutter/material.dart';
import '../config/colors.dart';

class AnimatedPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const AnimatedPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedPrimaryButton> createState() => _AnimatedPrimaryButtonState();
}

class _AnimatedPrimaryButtonState extends State<AnimatedPrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _colorAnimation = ColorTween(
      begin: AppColors.primaryGreen,
      end: AppColors.primaryGreenHover,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown() {
    _controller.forward();
  }

  void _onPointerUp() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _onPointerDown(),
      onExit: (_) => _onPointerUp(),
      child: GestureDetector(
        onTapDown: (_) => _onPointerDown(),
        onTapUp: (_) {
          _onPointerUp();
          if (!widget.isLoading) widget.onPressed();
        },
        onTapCancel: _onPointerUp,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: _colorAnimation.value ?? AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: widget.isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
```

### Icon Fade & Slide Transitions

```dart
class AnimatedIconWithLabel extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const AnimatedIconWithLabel({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedIconWithLabel> createState() => _AnimatedIconWithLabelState();
}

class _AnimatedIconWithLabelState extends State<AnimatedIconWithLabel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0.2, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.color ?? AppColors.primaryGreen,
                size: 24,
              ),
              SizedBox(height: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 🌐 Web/Backend Implementation (Next.js/Tailwind)

### Step 1: Tailwind Configuration

**File:** `tailwind.config.ts` (Backend)

```typescript
import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './src/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        // Brand colors
        'afrigo-green': {
          50: '#E8F5F1',
          100: '#D1EBE3',
          200: '#A3D7C7',
          300: '#1A8A67',
          400: '#157D5A',
          500: '#0F5B46', // Primary
          600: '#0A4335',
          700: '#082D2B',
          800: '#061A18',
          900: '#030D0A',
        },
        'afrigo-gold': {
          50: '#FEF9E7',
          100: '#FDF1C8',
          200: '#F0D999',
          300: '#E8D9B8', // Light
          400: '#D0A73A',
          500: '#C89B3C', // Primary
          600: '#B68927',
          700: '#9D6B1F',
          800: '#6D4A13',
          900: '#3D2A09',
        },
        'afrigo-blue': {
          50: '#E3F2FD',
          100: '#BBDEFB',
          200: '#90CAF9',
          300: '#64B5F6',
          400: '#42A5F5',
          500: '#1E88E5', // Primary
          600: '#1565C0',
          700: '#0D47A1',
          800: '#082B6F',
          900: '#051347',
        },
        // Semantic colors
        'success': {
          50: '#D1FAE5',
          100: '#A7F3D0',
          500: '#12B76A',
        },
        'warning': {
          50: '#FEF3C7',
          100: '#FDE68A',
          500: '#F79009',
        },
        'error': {
          50: '#FEE4E2',
          100: '#FEC9C4',
          500: '#F04438',
        },
        // Neutral palette
        'neutral': {
          0: '#FFFFFF',
          50: '#F7F8FA',
          100: '#F2F3F5',
          200: '#E4E7EC',
          300: '#D0D5DD',
          500: '#667085',
          700: '#344054',
          900: '#111827',
        },
      },
      boxShadow: {
        'sm': '0 1px 2px 0 rgba(17, 24, 39, 0.05)',
        'md': '0 4px 6px -1px rgba(17, 24, 39, 0.1)',
        'lg': '0 10px 15px -3px rgba(17, 24, 39, 0.1)',
        'xl': '0 20px 25px -5px rgba(17, 24, 39, 0.1)',
      },
      borderRadius: {
        'xs': '4px',
        'sm': '6px',
        'md': '8px',
        'lg': '12px',
        'xl': '16px',
      },
    },
  },
  plugins: [],
};

export default config;
```

### Step 2: CSS Custom Properties

**File:** `styles/variables.css` (Backend)

```css
:root {
  /* Primary Brand Colors */
  --color-primary-green: #0F5B46;
  --color-primary-green-hover: #0A4335;
  --color-primary-green-light: #1A8A67;
  --color-primary-green-lighter: #E8F5F1;

  /* Secondary Brand Colors */
  --color-secondary-gold: #C89B3C;
  --color-secondary-gold-hover: #B68927;
  --color-secondary-gold-light: #E8D9B8;

  /* Accent Colors */
  --color-accent-blue: #1E88E5;
  --color-accent-blue-dark: #1565C0;
  --color-accent-blue-light: #E3F2FD;

  /* Semantic Colors */
  --color-success: #12B76A;
  --color-success-light: #D1FAE5;
  --color-warning: #F79009;
  --color-warning-light: #FEF3C7;
  --color-error: #F04438;
  --color-error-light: #FEE4E2;

  /* Neutral Palette */
  --color-bg-light: #F7F8FA;
  --color-surface-card: #FFFFFF;
  --color-text-dark: #111827;
  --color-text-secondary: #667085;
  --color-border: #E4E7EC;
  --color-divider: #D0D5DD;

  /* Transitions */
  --transition-fast: 200ms cubic-bezier(0.4, 0, 0.2, 1);
  --transition-base: 300ms cubic-bezier(0.4, 0, 0.2, 1);
  --transition-slow: 500ms cubic-bezier(0.4, 0, 0.2, 1);
}
```

### Step 3: Reusable Button Component (React)

```typescript
// components/Button.tsx
import React from 'react';
import clsx from 'clsx';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'tertiary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  isLoading?: boolean;
  fullWidth?: boolean;
}

export const Button: React.FC<ButtonProps> = ({
  variant = 'primary',
  size = 'md',
  isLoading = false,
  fullWidth = false,
  children,
  className,
  disabled,
  ...props
}) => {
  const baseStyles = 'inline-flex items-center justify-center rounded-md font-medium transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed focus:outline-none focus:ring-2 focus:ring-offset-2';

  const variantStyles = {
    primary: 'bg-afrigo-green-500 text-white hover:bg-afrigo-green-600 active:scale-95 focus:ring-afrigo-green-500',
    secondary: 'bg-afrigo-gold-500 text-white hover:bg-afrigo-gold-600 active:scale-95 focus:ring-afrigo-gold-500',
    tertiary: 'bg-afrigo-blue-500 text-white hover:bg-afrigo-blue-600 active:scale-95 focus:ring-afrigo-blue-500',
    danger: 'bg-error-500 text-white hover:bg-error-600 active:scale-95 focus:ring-error-500',
  };

  const sizeStyles = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2 text-base',
    lg: 'px-6 py-3 text-lg',
  };

  return (
    <button
      className={clsx(
        baseStyles,
        variantStyles[variant],
        sizeStyles[size],
        fullWidth && 'w-full',
        className
      )}
      disabled={disabled || isLoading}
      {...props}
    >
      {isLoading ? (
        <span className="animate-spin mr-2">⌛</span>
      ) : null}
      {children}
    </button>
  );
};
```

---

## ✅ Implementation Checklist

### Mobile (Flutter)
- [ ] Create `lib/config/colors.dart` with all color constants
- [ ] Create `lib/config/theme.dart` with Material3 theme
- [ ] Update `main.dart` to use `AppTheme.lightTheme`
- [ ] Update all buttons to use `AnimatedPrimaryButton`
- [ ] Test color consistency across all screens
- [ ] Verify accessibility contrast ratios

### Web/Backend
- [ ] Update `tailwind.config.ts` with color theme
- [ ] Create `styles/variables.css` with CSS variables
- [ ] Update all button components to use new color system
- [ ] Test responsive button states
- [ ] Verify color consistency in dark mode (if needed)

### Cross-Platform
- [ ] Test all interactive elements respond correctly
- [ ] Verify micro-animations feel natural and responsive
- [ ] Test on different screen sizes
- [ ] Accessibility testing with color contrast tools

---

## 🎯 Color Usage Guidelines

### When to Use Each Color

| Color | Primary Use | Secondary Use |
|-------|------------|---------------|
| **Deep Forest Green** | Primary buttons, navigation, headers | Trust-building sections |
| **Export Gold** | Secondary actions, premium features | Highlights, badges |
| **Ocean Blue** | Tracking info, logistics, shipping | Links, alerts, real-time updates |
| **Green Success** | Confirmations, approved states | Positive feedback |
| **Orange Warning** | Pending states, caution alerts | Requires attention |
| **Red Error** | Errors, destructive actions | Critical alerts |

### Accessibility Notes
- Minimum contrast ratio: 4.5:1 for text on backgrounds
- All interactive elements must be clearly visible
- Test with color blindness simulators

---

## 📱 Live Examples

### Button States
```
Default: #0F5B46 (Deep Forest Green)
Hover:   #0A4335 (20% darker)
Active:  Scale 0.96, shadow increase
Disabled: Opacity 0.5
Loading:  Spinner + label
```

### Card Styling
```
Background: #FFFFFF
Border:     #E4E7EC (1px)
Shadow:     Subtle (0 1px 2px rgba(17,24,39,0.05))
Hover:      Border color → #0F5B46, shadow increase
```

### Form Inputs
```
Default Border:   #E4E7EC
Focus Border:     #0F5B46 (2px)
Success Border:   #12B76A
Error Border:     #F04438
Placeholder:      #667085
```

---

Last Updated: **May 30, 2026**
