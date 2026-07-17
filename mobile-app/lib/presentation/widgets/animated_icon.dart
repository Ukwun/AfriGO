import 'package:flutter/material.dart';
import '../../config/colors.dart';

/// Animated Icon with Label using Fade and Slide transitions
class AnimatedIconWithLabel extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;
  final double iconSize;
  final TextStyle? labelStyle;

  const AnimatedIconWithLabel({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
    this.iconSize = 24,
    this.labelStyle,
    super.key,
  });

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
      begin: const Offset(0.2, 0),
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
                size: widget.iconSize,
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: widget.labelStyle ??
                    TextStyle(
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

/// Animated Icon Button with hover effects
class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final Color? hoverColor;
  final double size;
  final String? tooltip;

  const AnimatedIconButton({
    required this.icon,
    required this.onPressed,
    this.color,
    this.hoverColor,
    this.size = 24,
    this.tooltip,
    super.key,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
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

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _colorAnimation = ColorTween(
      begin: widget.color ?? AppColors.primaryGreen,
      end: widget.hoverColor ?? AppColors.primaryGreenHover,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover() {
    _controller.forward();
  }

  void _onHoverExit() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _onHover(),
      onExit: (_) => _onHoverExit(),
      child: GestureDetector(
        onTap: widget.onPressed,
        onTapDown: (_) => _onHover(),
        onTapUp: (_) => _onHoverExit(),
        onTapCancel: _onHoverExit,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Tooltip(
            message: widget.tooltip ?? '',
            child: Icon(
              widget.icon,
              color: _colorAnimation.value ?? AppColors.primaryGreen,
              size: widget.size,
            ),
          ),
        ),
      ),
    );
  }
}

/// Status Badge with semantic color (success, warning, error)
class StatusBadge extends StatelessWidget {
  final String label;
  final String status; // 'success', 'warning', 'error'
  final EdgeInsets padding;
  final double borderRadius;

  const StatusBadge({
    required this.label,
    required this.status,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.borderRadius = 20,
    super.key,
  });

  Color get _backgroundColor {
    switch (status) {
      case 'success':
        return AppColors.successGreenLight;
      case 'warning':
        return AppColors.warningOrangeLight;
      case 'error':
        return AppColors.errorRedLight;
      default:
        return AppColors.backgroundLight;
    }
  }

  Color get _textColor {
    switch (status) {
      case 'success':
        return AppColors.successGreen;
      case 'warning':
        return AppColors.warningOrange;
      case 'error':
        return AppColors.errorRed;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

/// Animated Loader with primary green color
class AnimatedLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const AnimatedLoader({
    this.size = 40,
    this.color,
    super.key,
  });

  @override
  State<AnimatedLoader> createState() => _AnimatedLoaderState();
}

class _AnimatedLoaderState extends State<AnimatedLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.color ?? AppColors.primaryGreen,
        ),
        strokeWidth: 3,
      ),
    );
  }
}
