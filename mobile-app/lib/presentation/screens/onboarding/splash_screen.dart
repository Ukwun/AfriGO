import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animationController.forward();

    // Navigate after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/welcome');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfrigoColors.primaryDeepGreen,
      body: Center(
        child: FadeTransition(
          opacity: _animationController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🌍 AfriGo',
                style: AfrigoTypography.displayLarge.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AfrigoSpacing.md),
              Text(
                'Pan-African Digital Trade',
                style: AfrigoTypography.bodyLarge.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
