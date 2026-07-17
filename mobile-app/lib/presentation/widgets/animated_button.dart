import 'package:flutter/material.dart';
import '../../config/colors.dart';

/// Animated Primary Button with official AfriGo colors
/// Features smooth scale and color transitions on interaction
/// Support for large touch targets (56px height recommended)
class AnimatedPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final EdgeInsets? padding;
  final double? width;
  final double borderRadius;
  final bool isLargeTouchTarget; // 56px height for accessibility

  const AnimatedPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.padding,
    this.width,
    this.borderRadius = 12,
    this.isLargeTouchTarget = false,
    super.key,
  });

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
    if (widget.isEnabled && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onPointerUp() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.isEnabled && !widget.isLoading
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => _onPointerDown(),
      onExit: (_) => _onPointerUp(),
      child: GestureDetector(
        onTapDown: (_) => _onPointerDown(),
        onTapUp: (_) {
          _onPointerUp();
          if (widget.isEnabled && !widget.isLoading) {
            widget.onPressed();
          }
        },
        onTapCancel: _onPointerUp,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: widget.width,
            height: widget.isLargeTouchTarget ? 56 : null,
            padding: widget.isLargeTouchTarget
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 0)
                : (widget.padding ??
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            decoration: BoxDecoration(
              color: widget.isEnabled
                  ? (_colorAnimation.value ?? AppColors.primaryGreen)
                  : AppColors.disabled,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated Secondary Button with Export Gold color
class AnimatedSecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final EdgeInsets? padding;
  final double? width;

  const AnimatedSecondaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.padding,
    this.width,
    super.key,
  });

  @override
  State<AnimatedSecondaryButton> createState() =>
      _AnimatedSecondaryButtonState();
}

class _AnimatedSecondaryButtonState extends State<AnimatedSecondaryButton>
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
      begin: AppColors.secondaryGold,
      end: AppColors.secondaryGoldHover,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown() {
    if (widget.isEnabled && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onPointerUp() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.isEnabled && !widget.isLoading
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => _onPointerDown(),
      onExit: (_) => _onPointerUp(),
      child: GestureDetector(
        onTapDown: (_) => _onPointerDown(),
        onTapUp: (_) {
          _onPointerUp();
          if (widget.isEnabled && !widget.isLoading) {
            widget.onPressed();
          }
        },
        onTapCancel: _onPointerUp,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: widget.width,
            padding: widget.padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isEnabled
                  ? (_colorAnimation.value ?? AppColors.secondaryGold)
                  : AppColors.disabled,
              borderRadius: BorderRadius.circular(8),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.label,
                    style: const TextStyle(
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

/// Animated Accent Button with Ocean Blue color (for tracking/logistics)
class AnimatedAccentButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final EdgeInsets? padding;
  final double? width;

  const AnimatedAccentButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.padding,
    this.width,
    super.key,
  });

  @override
  State<AnimatedAccentButton> createState() => _AnimatedAccentButtonState();
}

class _AnimatedAccentButtonState extends State<AnimatedAccentButton>
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
      begin: AppColors.accentBlue,
      end: AppColors.accentBlueDark,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown() {
    if (widget.isEnabled && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onPointerUp() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.isEnabled && !widget.isLoading
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => _onPointerDown(),
      onExit: (_) => _onPointerUp(),
      child: GestureDetector(
        onTapDown: (_) => _onPointerDown(),
        onTapUp: (_) {
          _onPointerUp();
          if (widget.isEnabled && !widget.isLoading) {
            widget.onPressed();
          }
        },
        onTapCancel: _onPointerUp,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: widget.width,
            padding: widget.padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isEnabled
                  ? (_colorAnimation.value ?? AppColors.accentBlue)
                  : AppColors.disabled,
              borderRadius: BorderRadius.circular(8),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.label,
                    style: const TextStyle(
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

/// Animated Outlined Button - Secondary style
/// Features border, no fill, smooth animations
class AnimatedOutlinedButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? borderColor;
  final Color? textColor;
  final EdgeInsets? padding;
  final double? width;
  final double borderRadius;
  final bool isLargeTouchTarget;

  const AnimatedOutlinedButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.borderColor,
    this.textColor,
    this.padding,
    this.width,
    this.borderRadius = 12,
    this.isLargeTouchTarget = false,
    super.key,
  });

  @override
  State<AnimatedOutlinedButton> createState() => _AnimatedOutlinedButtonState();
}

class _AnimatedOutlinedButtonState extends State<AnimatedOutlinedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<Color?> _borderAnimation;

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

    _borderAnimation = ColorTween(
      begin: widget.borderColor ?? AppColors.primaryGreen,
      end: (widget.borderColor ?? AppColors.primaryGreen).withOpacity(0.6),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown() {
    if (widget.isEnabled && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onPointerUp() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.isEnabled && !widget.isLoading
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => _onPointerDown(),
      onExit: (_) => _onPointerUp(),
      child: GestureDetector(
        onTapDown: (_) => _onPointerDown(),
        onTapUp: (_) {
          _onPointerUp();
          if (widget.isEnabled && !widget.isLoading) {
            widget.onPressed();
          }
        },
        onTapCancel: _onPointerUp,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: widget.width,
            height: widget.isLargeTouchTarget ? 56 : null,
            padding: widget.isLargeTouchTarget
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 0)
                : (widget.padding ??
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: _borderAnimation.value ??
                    (widget.borderColor ?? AppColors.primaryGreen),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.textColor ?? AppColors.primaryGreen,
                        ),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.label,
                      style: TextStyle(
                        color: _colorAnimation.value ??
                            (widget.textColor ?? AppColors.primaryGreen),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated Text Button - Tertiary style (text-only)
/// Features text-only, no background, smooth fade and color animations
class AnimatedTextButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? textColor;
  final EdgeInsets? padding;
  final double? width;
  final bool isLargeTouchTarget;

  const AnimatedTextButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.textColor,
    this.padding,
    this.width,
    this.isLargeTouchTarget = false,
    super.key,
  });

  @override
  State<AnimatedTextButton> createState() => _AnimatedTextButtonState();
}

class _AnimatedTextButtonState extends State<AnimatedTextButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: widget.textColor ?? AppColors.primaryGreen,
      end: (widget.textColor ?? AppColors.primaryGreen).withOpacity(0.6),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown() {
    if (widget.isEnabled && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onPointerUp() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.isEnabled && !widget.isLoading
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => _onPointerDown(),
      onExit: (_) => _onPointerUp(),
      child: GestureDetector(
        onTapDown: (_) => _onPointerDown(),
        onTapUp: (_) {
          _onPointerUp();
          if (widget.isEnabled && !widget.isLoading) {
            widget.onPressed();
          }
        },
        onTapCancel: _onPointerUp,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: widget.width,
            height: widget.isLargeTouchTarget ? 56 : null,
            padding: widget.isLargeTouchTarget
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 0)
                : (widget.padding ??
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.textColor ?? AppColors.primaryGreen,
                        ),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.label,
                      style: TextStyle(
                        color: _colorAnimation.value ??
                            (widget.textColor ?? AppColors.primaryGreen),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
