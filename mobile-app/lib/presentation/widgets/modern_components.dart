import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Modern Primary Button with ripple effect and animation
class ModernButton extends StatefulWidget {
  final String? label;
  final String? loadingLabel;
  final Widget? child;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final IconData? icon;
  final bool isSecondary;

  const ModernButton({
    super.key,
    this.label,
    this.loadingLabel,
    this.child,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.icon,
    this.isSecondary = false,
  }) : assert(label != null || child != null,
            'Either label or child must be provided');

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
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
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: Tween(begin: 1.0, end: 0.98).animate(_controller),
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.isSecondary ? Colors.white : AfrigoColors.primary,
            border: widget.isSecondary
                ? Border.all(color: AfrigoColors.primary, width: 1.5)
                : null,
            borderRadius: BorderRadius.circular(AfriBorderRadius.lg),
            boxShadow: widget.isLoading || !widget.isSecondary
                ? AfrigoElevation.shadow2
                : [],
          ),
          child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: widget.isLoading
                  ? Row(
                      key: const ValueKey('loading'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              widget.isSecondary
                                  ? AfrigoColors.primary
                                  : Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: AfrigoSpacing.sm),
                        Text(
                          widget.loadingLabel ?? widget.label ?? '',
                          style: AfrigoTypography.buttonLarge.copyWith(
                            color: widget.isSecondary
                                ? AfrigoColors.primary
                                : Colors.white,
                          ),
                        ),
                      ],
                    )
                  : widget.child != null
                      ? Center(
                          key: const ValueKey('child'),
                          child: widget.child!,
                        )
                      : Row(
                          key: const ValueKey('label'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color: widget.isSecondary
                                    ? AfrigoColors.primary
                                    : Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: AfrigoSpacing.sm),
                            ],
                            Text(
                              widget.label ?? '',
                              style: AfrigoTypography.buttonLarge.copyWith(
                                color: widget.isSecondary
                                    ? AfrigoColors.primary
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
            ),
        ),
      ),
    );
  }
}

/// Modern Text Input with floating label and validation
class ModernTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final int? maxLines;
  final int? minLines;

  const ModernTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.maxLines = 1,
    this.minLines,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  late FocusNode _focusNode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_validateOnFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_validateOnFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _validateOnFocusChange() {
    if (!_focusNode.hasFocus) {
      _validate();
    }
  }

  void _validate() {
    final result = widget.validator?.call(widget.controller.text);
    setState(() => _errorText = result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          onChanged: (_) {
            if (_errorText != null) _validate();
          },
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 20)
                : null,
            suffixIcon: widget.suffixIcon != null
                ? GestureDetector(
                    onTap: widget.onSuffixIconTap,
                    child: Icon(widget.suffixIcon, size: 20),
                  )
                : null,
            errorText: _errorText,
            filled: true,
            fillColor: AfrigoColors.bgLightAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AfriBorderRadius.md),
              borderSide: const BorderSide(color: AfrigoColors.borderLight),
            ),
          ),
        ),
      ],
    );
  }
}

/// Modern Card with hover effect
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final void Function()? onTap;
  final bool elevated;
  final Color? backgroundColor;

  const ModernCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AfrigoSpacing.lg),
    this.onTap,
    this.elevated = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.white,
      borderRadius: BorderRadius.circular(AfriBorderRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AfriBorderRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AfrigoColors.borderLight,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(AfriBorderRadius.lg),
            boxShadow: elevated ? AfrigoElevation.shadow2 : [],
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Modern Section Header
class ModernSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsets padding;

  const ModernSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AfrigoSpacing.screenPadding,
      vertical: AfrigoSpacing.lg,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AfrigoTypography.soraHeading5.copyWith(
                    color: AfrigoColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AfrigoSpacing.xs),
                  Text(
                    subtitle!,
                    style: AfrigoTypography.interBody2.copyWith(
                      color: AfrigoColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Modern Loading Indicator
class ModernLoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;

  const ModernLoadingIndicator({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(
                color ?? AfrigoColors.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AfrigoSpacing.lg),
            Text(
              message!,
              style: AfrigoTypography.interBody2.copyWith(
                color: AfrigoColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Modern Error State
class ModernErrorState extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ModernErrorState({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AfrigoSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AfrigoColors.error,
            ),
            const SizedBox(height: AfrigoSpacing.lg),
            Text(
              title,
              style: AfrigoTypography.soraHeading5.copyWith(
                color: AfrigoColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AfrigoSpacing.sm),
              Text(
                message!,
                style: AfrigoTypography.interBody2.copyWith(
                  color: AfrigoColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AfrigoSpacing.xl),
              ModernButton(
                label: 'Try Again',
                onPressed: onRetry!,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Modern Badge
class ModernBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const ModernBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AfrigoSpacing.md,
        vertical: AfrigoSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AfrigoColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AfriBorderRadius.full),
        border: Border.all(
          color: backgroundColor ?? AfrigoColors.primary,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: textColor ?? AfrigoColors.primary,
            ),
            const SizedBox(width: AfrigoSpacing.xs),
          ],
          Text(
            label,
            style: AfrigoTypography.caption.copyWith(
              color: textColor ?? AfrigoColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
