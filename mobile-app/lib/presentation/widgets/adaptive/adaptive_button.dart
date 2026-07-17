import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/role_provider.dart';

/// Adaptive button that adjusts size based on user role
/// Suppliers get larger buttons (64px), others get standard (48px)
class AdaptiveButton extends ConsumerWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final Color? color;
  final double? customHeight;

  const AdaptiveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.color,
    this.customHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolePreferences = ref.watch(rolePreferencesProvider);
    final buttonHeight = customHeight ?? rolePreferences.buttonHeight;

    return SizedBox(
      height: buttonHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Adaptive outlined button variant
class AdaptiveOutlinedButton extends ConsumerWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isEnabled;
  final IconData? icon;
  final Color? color;
  final double? customHeight;

  const AdaptiveOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.icon,
    this.color,
    this.customHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolePreferences = ref.watch(rolePreferencesProvider);
    final buttonHeight = customHeight ?? rolePreferences.buttonHeight;

    return SizedBox(
      height: buttonHeight,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color ?? Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Adaptive text button for secondary actions
class AdaptiveTextButton extends ConsumerWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isEnabled;
  final Color? color;

  const AdaptiveTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: isEnabled ? onPressed : null,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

/// Adaptive large icon button (for suppliers and logistics)
/// Good for quick mobile actions
class AdaptiveIconButton extends ConsumerWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double? customSize;

  const AdaptiveIconButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
    this.customSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolePreferences = ref.watch(rolePreferencesProvider);
    final size = customSize ?? (rolePreferences.buttonHeight * 0.8);

    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: size * 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
