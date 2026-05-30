import 'package:flutter/material.dart';
import '../../config/colors.dart';

/// Modern Card component with layered design and subtle shadows
/// Supports floating panels, elevation levels, and elegant styling
class ModernCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final double elevation;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool isFloating;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const ModernCard({
    required this.child,
    this.padding,
    this.borderRadius = 16, // 16-24px as specified
    this.elevation = 1,
    this.backgroundColor,
    this.borderColor,
    this.isFloating = false,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 200),
    Key? key,
  }) : super(key: key);

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  late Animation<Offset> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _elevationAnimation =
        Tween<double>(begin: widget.elevation, end: widget.elevation + 4)
            .animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _floatAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -4),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover() {
    if (widget.isFloating || widget.onTap != null) {
      _controller.forward();
    }
  }

  void _onHoverExit() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => _onHover(),
      onExit: (_) => _onHoverExit(),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _onHover(),
        onTapUp: (_) => _onHoverExit(),
        onTapCancel: _onHoverExit,
        child: SlideTransition(
          position: _floatAnimation,
          child: AnimatedBuilder(
            animation: _elevationAnimation,
            builder: (context, child) {
              return Material(
                elevation: _elevationAnimation.value,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                shadowColor: Colors.black.withOpacity(0.08),
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: widget.borderColor != null
                        ? Border.all(
                            color: widget.borderColor!,
                            width: 1,
                          )
                        : Border.all(
                            color: AppColors.borderDefault,
                            width: 1,
                          ),
                  ),
                  padding: widget.padding ?? const EdgeInsets.all(16),
                  child: child,
                ),
              );
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Layered Card - creates visual depth with multiple card levels
class LayeredCard extends StatelessWidget {
  final Widget child;
  final int layers;
  final double layerOffset;
  final EdgeInsets? padding;
  final double borderRadius;

  const LayeredCard({
    required this.child,
    this.layers = 2,
    this.layerOffset = 4,
    this.padding,
    this.borderRadius = 16,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background layers for depth
        ...List.generate(
          layers,
          (index) => Positioned(
            top: (index + 1) * layerOffset.toDouble(),
            left: (index + 1) * layerOffset.toDouble(),
            right: -(index + 1) * layerOffset.toDouble(),
            bottom: -(index + 1) * layerOffset.toDouble(),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: AppColors.borderDefault.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
        // Main card
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppColors.borderDefault,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ],
    );
  }
}

/// Floating Panel - elevated card with enhanced shadow for floating effect
class FloatingPanel extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final double? width;
  final double? height;

  const FloatingPanel({
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.width,
    this.height,
    Key? key,
  }) : super(key: key);

  @override
  State<FloatingPanel> createState() => _FloatingPanelState();
}

class _FloatingPanelState extends State<FloatingPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_floatAnimation.value),
          child: Material(
            elevation: 12 + _floatAnimation.value,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            shadowColor: AppColors.primaryGreen.withOpacity(0.15),
            color: Colors.transparent,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: AppColors.borderDefault,
                  width: 1,
                ),
              ),
              padding: widget.padding ?? const EdgeInsets.all(20),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Subtle shadow mixin for consistent shadow styling across the app
class ShadowStyles {
  /// Subtle shadow - light elevation for cards
  static List<BoxShadow> get subtle => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  /// Medium shadow - standard card elevation
  static List<BoxShadow> get medium => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// Elevated shadow - for floating panels
  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// Deep shadow - for highest elevation (modals, dialogs)
  static List<BoxShadow> get deep => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];
}
