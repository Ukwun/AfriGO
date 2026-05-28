import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late FocusNode _emailFocus;
  late FocusNode _passwordFocus;

  bool _showPassword = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  /// Handle login button press
  Future<void> _handleLogin() async {
    // Validate input
    if (_emailController.text.isEmpty) {
      setState(() => _errorMessage = 'Email is required');
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Password is required');
      return;
    }

    if (!_isValidEmail(_emailController.text)) {
      setState(() => _errorMessage = 'Invalid email format');
      return;
    }

    // Clear error
    setState(() => _errorMessage = null);

    // Attempt login
    await ref.read(authProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    // Check result and navigate
    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState is AuthAuthenticated) {
      // Determine dashboard based on role
      final role = authState.user.roles.isNotEmpty
          ? authState.user.roles.first
          : 'buyer';
      context.go('/dashboard/$role');
    } else if (authState is AuthError) {
      setState(() => _errorMessage = authState.message);
    }
  }

  /// Handle Google Sign-In
  Future<void> _handleGoogleLogin() async {
    setState(() => _errorMessage = null);
    try {
      await ref.read(authProvider.notifier).loginWithGoogle();
      if (!mounted) return;

      final authState = ref.read(authProvider);
      if (authState is AuthAuthenticated) {
        final role = authState.user.roles.isNotEmpty
            ? authState.user.roles.first
            : 'buyer';
        context.go('/dashboard/$role');
      } else if (authState is AuthError) {
        setState(() => _errorMessage = authState.message);
      }
    } catch (e) {
      if (mounted) {
        setState(
            () => _errorMessage = 'Google sign-in failed: ${e.toString()}');
      }
    }
  }

  /// Handle Facebook Sign-In
  Future<void> _handleFacebookLogin() async {
    setState(() => _errorMessage = null);
    try {
      await ref.read(authProvider.notifier).loginWithFacebook();
      if (!mounted) return;

      final authState = ref.read(authProvider);
      if (authState is AuthAuthenticated) {
        final role = authState.user.roles.isNotEmpty
            ? authState.user.roles.first
            : 'buyer';
        context.go('/dashboard/$role');
      } else if (authState is AuthError) {
        setState(() => _errorMessage = authState.message);
      }
    } catch (e) {
      if (mounted) {
        setState(
            () => _errorMessage = 'Facebook sign-in failed: ${e.toString()}');
      }
    }
  }

  /// Handle Apple Sign-In
  Future<void> _handleAppleLogin() async {
    setState(() => _errorMessage = null);
    try {
      await ref.read(authProvider.notifier).loginWithApple();
      if (!mounted) return;

      final authState = ref.read(authProvider);
      if (authState is AuthAuthenticated) {
        final role = authState.user.roles.isNotEmpty
            ? authState.user.roles.first
            : 'buyer';
        context.go('/dashboard/$role');
      } else if (authState is AuthError) {
        setState(() => _errorMessage = authState.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Apple sign-in failed: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login to AfriGo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AfrigoSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AfrigoSpacing.lg),

            // Heading
            Text(
              'Welcome Back',
              style: AfrigoTypography.headingLarge.copyWith(
                color: AfrigoColors.primaryDeepGreen,
              ),
            ),
            const SizedBox(height: AfrigoSpacing.sm),
            Text(
              'Sign in to your account to trade now',
              style: AfrigoTypography.bodyMedium.copyWith(
                color: AfrigoColors.textSecondary,
              ),
            ),
            const SizedBox(height: AfrigoSpacing.xl),

            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(AfrigoSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: AfrigoTypography.bodySmall.copyWith(
                    color: Colors.red.shade700,
                  ),
                ),
              ),
              const SizedBox(height: AfrigoSpacing.lg),
            ],

            // Email field
            TextField(
              controller: _emailController,
              focusNode: _emailFocus,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'your@example.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            const SizedBox(height: AfrigoSpacing.md),

            // Password field
            TextField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              enabled: !isLoading,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
              ),
              obscureText: !_showPassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleLogin(),
            ),
            const SizedBox(height: AfrigoSpacing.sm),

            // Forgot password link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go('/forgot-password'),
                child: Text(
                  'Forgot password?',
                  style: AfrigoTypography.bodySmall.copyWith(
                    color: AfrigoColors.primaryDeepGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AfrigoSpacing.lg),

            // Login button
            ElevatedButton(
              onPressed: isLoading ? null : _handleLogin,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Sign In'),
            ),
            const SizedBox(height: AfrigoSpacing.lg),

            // Divider
            Row(
              children: [
                const Expanded(
                  child: Divider(
                    height: 1,
                    color: AfrigoColors.borderLight,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AfrigoSpacing.md,
                  ),
                  child: Text(
                    'OR',
                    style: AfrigoTypography.bodySmall.copyWith(
                      color: AfrigoColors.textSecondary,
                    ),
                  ),
                ),
                const Expanded(
                  child: Divider(
                    height: 1,
                    color: AfrigoColors.borderLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AfrigoSpacing.lg),

            // Social Login Text
            Text(
              'Sign in with',
              style: AfrigoTypography.bodySmall.copyWith(
                color: AfrigoColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AfrigoSpacing.md),

            // Google Button
            OutlinedButton.icon(
              onPressed: isLoading ? null : _handleGoogleLogin,
              icon: const Icon(Icons.g_translate),
              label: const Text('Google'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: AfrigoSpacing.sm),

            // Facebook Button
            OutlinedButton.icon(
              onPressed: isLoading ? null : _handleFacebookLogin,
              icon: const Icon(Icons.facebook),
              label: const Text('Facebook'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: AfrigoSpacing.sm),

            // Apple Button
            OutlinedButton.icon(
              onPressed: isLoading ? null : _handleAppleLogin,
              icon: const Icon(Icons.apple),
              label: const Text('Apple'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: AfrigoSpacing.lg),

            // Sign up link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don\'t have an account? ',
                  style: AfrigoTypography.bodyMedium.copyWith(
                    color: AfrigoColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/register'),
                  child: Text(
                    'Create Account',
                    style: AfrigoTypography.bodyMedium.copyWith(
                      color: AfrigoColors.primaryDeepGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AfrigoSpacing.lg),
          ],
        ),
      ),
    );
  }
}
