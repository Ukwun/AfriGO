import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AfrigoSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome to AfriGo',
                      style: AfrigoTypography.displayMedium.copyWith(
                        color: AfrigoColors.primaryDeepGreen,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AfrigoSpacing.lg),
                    Text(
                      'Connect, Trade, Grow\nAcross Africa',
                      style: AfrigoTypography.bodyLarge.copyWith(
                        color: AfrigoColors.gray600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: AfrigoSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go('/register'),
                      child: const Text('Create Account'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
