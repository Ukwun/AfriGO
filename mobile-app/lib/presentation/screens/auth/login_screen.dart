import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/modern_components.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _showPassword = false;
  String? _errorMessage;

  String _dashboardRouteForUser(AuthUser user) {
    final normalizedRoles = user.roles.map((r) => r.toLowerCase()).toList();
    if (normalizedRoles.contains('seller') ||
        normalizedRoles.contains('supplier')) {
      return '/dashboard/seller';
    }
    if (normalizedRoles.contains('exporter')) {
      return '/dashboard/exporter';
    }
    return '/dashboard/buyer';
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Email and password are required';
      });
      return;
    }

    setState(() => _errorMessage = null);

    await ref.read(authProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState is AuthAuthenticated) {
      context.go(_dashboardRouteForUser(authState.user));
      return;
    }

    if (authState is AuthError) {
      setState(() => _errorMessage = authState.message);
      return;
    }

    setState(() => _errorMessage = 'Unable to sign in. Please try again.');
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    return Scaffold(
      backgroundColor: AfrigoColors.bgLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/welcome'),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AfrigoSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AfrigoSpacing.xxl),
              Text('Welcome Back', style: AfrigoTypography.soraHeading2),
              const SizedBox(height: AfrigoSpacing.sm),
              Text(
                'Sign in to your AfriGO account',
                style: AfrigoTypography.interBody1.copyWith(
                  color: AfrigoColors.textSecondary,
                ),
              ),
              const SizedBox(height: AfrigoSpacing.xxl),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'name@example.com',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AfrigoSpacing.lg),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _showPassword = !_showPassword);
                    },
                  ),
                ),
                obscureText: !_showPassword,
              ),
              const SizedBox(height: AfrigoSpacing.xxl),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AfrigoSpacing.md),
                  decoration: BoxDecoration(
                    color: AfrigoColors.error.withOpacity(0.1),
                    border: Border.all(
                      color: AfrigoColors.error.withOpacity(0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(AfriBorderRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AfrigoColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: AfrigoSpacing.md),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AfrigoTypography.interBody2.copyWith(
                            color: AfrigoColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AfrigoSpacing.md),
              ],
              ModernButton(
                label: 'Sign In',
                loadingLabel: 'Signing in...',
                onPressed: _handleLogin,
                isLoading: isLoading,
              ),
              const SizedBox(height: AfrigoSpacing.xxl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Don\'t have an account? ',
                      style: AfrigoTypography.bodySmall),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: Text(
                      'Sign Up',
                      style: AfrigoTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AfrigoColors.primary,
                      ),
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
