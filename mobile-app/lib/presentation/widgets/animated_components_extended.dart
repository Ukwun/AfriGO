import 'package:flutter/material.dart';
import '../../config/colors.dart';

/// AnimatedPressButton - Interactive button with press feedback animations
/// Features: Scale transform (0.95x), color shift, ripple feedback
class AnimatedPressButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isPrimary;
  final IconData? icon;
  final double width;
  final double height;

  const AnimatedPressButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isPrimary = true,
    this.icon,
    this.width = double.infinity,
    this.height = 48,
  });

  @override
  State<AnimatedPressButton> createState() => _AnimatedPressButtonState();
}

class _AnimatedPressButtonState extends State<AnimatedPressButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.isPrimary ? AppColors.accentBlue : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border:
                !widget.isPrimary ? Border.all(color: Colors.grey[300]!) : null,
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.accentBlue.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              splashColor: Colors.white.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: widget.isPrimary ? Colors.white : Colors.black87,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: widget.isPrimary ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// AnimatedCard - Card with hover and tap animations
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _elevationAnimation = Tween<double>(begin: 2, end: 8).animate(
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
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.02).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        ),
        child: Card(
          elevation: 2,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: widget.padding,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// AnimatedCheckbox - Animated checkbox with rotation and scale
class AnimatedCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;

  const AnimatedCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (widget.value) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 0.8).animate(
            CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
          ),
          child: Checkbox(
            value: widget.value,
            onChanged: (newValue) {
              widget.onChanged(newValue);
            },
            activeColor: AppColors.accentBlue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => widget.onChanged(!widget.value),
            child: Text(
              widget.label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

/// AnimatedStatusIndicator - Pulsing status indicator with color
class AnimatedStatusIndicator extends StatefulWidget {
  final Color color;
  final String label;
  final bool isPulsing;

  const AnimatedStatusIndicator({
    super.key,
    required this.color,
    required this.label,
    this.isPulsing = true,
  });

  @override
  State<AnimatedStatusIndicator> createState() =>
      _AnimatedStatusIndicatorState();
}

class _AnimatedStatusIndicatorState extends State<AnimatedStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    if (widget.isPulsing) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: widget.color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: widget.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// RotatingIcon - Continuously rotating icon
class RotatingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;

  const RotatingIcon({
    super.key,
    required this.icon,
    this.color = Colors.black87,
    this.size = 24,
  });

  @override
  State<RotatingIcon> createState() => _RotatingIconState();
}

class _RotatingIconState extends State<RotatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _controller.repeat();
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
      child: Icon(widget.icon, color: widget.color, size: widget.size),
    );
  }
}

/// ShimmerLoading - Shimmer effect for loading states
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 16,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            Container(color: Colors.grey[200]),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: const Offset(1, 0),
              ).animate(
                CurvedAnimation(parent: _controller, curve: Curves.linear),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey[200]!,
                      Colors.grey[100]!,
                      Colors.grey[200]!,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
