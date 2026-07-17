import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/modern_components.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfrigoColors.bgLight,
      body: SafeArea(
        child: FadeTransition(
          opacity: _animationController,
          child: Column(
            children: [
              // Header Section with subtle gradient
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AfrigoSpacing.screenPadding,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hero Icon
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AfrigoColors.primary.withOpacity(0.15),
                              AfrigoColors.primary.withOpacity(0.05),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(AfriBorderRadius.full),
                          border: Border.all(
                            color: AfrigoColors.primary.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '📱',
                            style: AfrigoTypography.kpiLarge.copyWith(
                              fontSize: 70,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AfrigoSpacing.xxl),

                      // Main Headline
                      Text(
                        'Welcome to AfriGO',
                        style: AfrigoTypography.soraHeading2.copyWith(
                          color: AfrigoColors.textPrimary,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AfrigoSpacing.lg),

                      // Subheading
                      Text(
                        'Connect with buyers and suppliers across Africa. Trade with confidence, grow with purpose.',
                        style: AfrigoTypography.interBody1.copyWith(
                          color: AfrigoColors.textSecondary,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AfrigoSpacing.xxl),

                      // Feature Pills
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: AfrigoSpacing.md,
                        runSpacing: AfrigoSpacing.md,
                        children: [
                          ModernBadge(
                            label: 'Secure Trading',
                            backgroundColor:
                                AfrigoColors.success.withOpacity(0.1),
                            textColor: AfrigoColors.success,
                            icon: Icons.shield_outlined,
                          ),
                          ModernBadge(
                            label: 'Real-time Tracking',
                            backgroundColor:
                                AfrigoColors.accent.withOpacity(0.1),
                            textColor: AfrigoColors.accent,
                            icon: Icons.location_on_outlined,
                          ),
                          ModernBadge(
                            label: 'Fair Pricing',
                            backgroundColor:
                                AfrigoColors.warning.withOpacity(0.1),
                            textColor: AfrigoColors.warning,
                            icon: Icons.trending_up_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons Section
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AfriBorderRadius.xl),
                    topRight: Radius.circular(AfriBorderRadius.xl),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: AfrigoColors.borderLight,
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(AfrigoSpacing.screenPadding),
                child: Column(
                  children: [
                    // Login Button - Animated Primary Action with 56px touch target
                    AnimatedPrimaryButton(
                      label: 'Sign In',
                      onPressed: () => context.go('/login'),
                      isLargeTouchTarget: true,
                    ),
                    const SizedBox(height: AfrigoSpacing.md),

                    // Sign Up Button - Animated Outlined (Secondary Action) with 56px touch target
                    AnimatedOutlinedButton(
                      label: 'Create Account',
                      onPressed: () => context.go('/register'),
                      borderColor: AfrigoColors.primary,
                      textColor: AfrigoColors.primary,
                      isLargeTouchTarget: true,
                    ),

                    const SizedBox(height: AfrigoSpacing.lg),

                    // Disclaimer Text
                    Text(
                      'By signing in, you agree to our Terms of Service and Privacy Policy',
                      style: AfrigoTypography.caption.copyWith(
                        color: AfrigoColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
