import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../providers/auth_provider.dart';

class SplashScreenModern extends ConsumerStatefulWidget {
  const SplashScreenModern({super.key});

  @override
  ConsumerState<SplashScreenModern> createState() => _SplashScreenModernState();
}

class _SplashScreenModernState extends ConsumerState<SplashScreenModern>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Check auth state and navigate
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        final authState = ref.read(authProvider);

        if (authState is AuthAuthenticated) {
          // User is logged in, go to dashboard
          final roles =
              authState.user.roles.map((r) => r.toLowerCase()).toList();
          if (roles.contains('seller') ||
              roles.contains('supplier') ||
              roles.contains('farmer')) {
            context.go('/dashboard/seller');
          } else if (roles.contains('exporter') || roles.contains('member')) {
            context.go('/dashboard/exporter');
          } else {
            context.go('/dashboard/buyer');
          }
        } else {
          // User not authenticated, go to login
          context.go('/login');
        }
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
      backgroundColor: AfrigoColors.primary,
      body: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo Circle
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(26),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Center(
                    child: Text(
                      '🌍',
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                const Text(
                  'AfriGo',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Global Trading Platform',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withAlpha(204),
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
