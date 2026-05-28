import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _phoneController;
  late TextEditingController _organizationController;
  late TextEditingController _countryController;

  late FocusNode _firstNameFocus;
  late FocusNode _lastNameFocus;
  late FocusNode _emailFocus;
  late FocusNode _passwordFocus;
  late FocusNode _confirmPasswordFocus;
  late FocusNode _phoneFocus;
  late FocusNode _organizationFocus;
  late FocusNode _countryFocus;

  String _selectedRole = 'buyer';
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _agreedToTerms = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _phoneController = TextEditingController();
    _organizationController = TextEditingController();
    _countryController = TextEditingController();

    _firstNameFocus = FocusNode();
    _lastNameFocus = FocusNode();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
    _confirmPasswordFocus = FocusNode();
    _phoneFocus = FocusNode();
    _organizationFocus = FocusNode();
    _countryFocus = FocusNode();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _organizationController.dispose();
    _countryController.dispose();

    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _phoneFocus.dispose();
    _organizationFocus.dispose();
    _countryFocus.dispose();
    super.dispose();
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  /// Validate password strength (minimum 8 chars, mixed case & numbers)
  bool _isValidPassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  /// Handle Google Sign-Up
  Future<void> _handleGoogleSignUp() async {
    setState(() => _errorMessage = null);
    try {
      await ref.read(authProvider.notifier).loginWithGoogle();
      if (!mounted) return;

      final authState = ref.read(authProvider);
      if (authState is AuthAuthenticated) {
        context.go('/dashboard/buyer');
      } else if (authState is AuthError) {
        setState(() => _errorMessage = authState.message);
      }
    } catch (e) {
      if (mounted) {
        setState(
            () => _errorMessage = 'Google sign-up failed: ${e.toString()}');
      }
    }
  }

  /// Handle Facebook Sign-Up
  Future<void> _handleFacebookSignUp() async {
    setState(() => _errorMessage = null);
    try {
      await ref.read(authProvider.notifier).loginWithFacebook();
      if (!mounted) return;

      final authState = ref.read(authProvider);
      if (authState is AuthAuthenticated) {
        context.go('/dashboard/buyer');
      } else if (authState is AuthError) {
        setState(() => _errorMessage = authState.message);
      }
    } catch (e) {
      if (mounted) {
        setState(
            () => _errorMessage = 'Facebook sign-up failed: ${e.toString()}');
      }
    }
  }

  /// Handle Apple Sign-Up
  Future<void> _handleAppleSignUp() async {
    setState(() => _errorMessage = null);
    try {
      await ref.read(authProvider.notifier).loginWithApple();
      if (!mounted) return;

      final authState = ref.read(authProvider);
      if (authState is AuthAuthenticated) {
        context.go('/dashboard/buyer');
      } else if (authState is AuthError) {
        setState(() => _errorMessage = authState.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Apple sign-up failed: ${e.toString()}');
      }
    }
  }

  /// Handle registration
  Future<void> _handleRegister() async {
    // Validate input
    if (_firstNameController.text.isEmpty) {
      setState(() => _errorMessage = 'First name is required');
      return;
    }

    if (_lastNameController.text.isEmpty) {
      setState(() => _errorMessage = 'Last name is required');
      return;
    }

    if (_emailController.text.isEmpty) {
      setState(() => _errorMessage = 'Email is required');
      return;
    }

    if (!_isValidEmail(_emailController.text)) {
      setState(() => _errorMessage = 'Invalid email format');
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Password is required');
      return;
    }

    if (!_isValidPassword(_passwordController.text)) {
      setState(
        () => _errorMessage =
            'Password must be 8+ characters with uppercase and numbers',
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    if (!_agreedToTerms) {
      setState(() => _errorMessage = 'Please agree to terms and conditions');
      return;
    }

    // Clear error
    setState(() => _errorMessage = null);

    // Attempt registration
    await ref.read(authProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: _phoneController.text.isEmpty
              ? null
              : _phoneController.text.trim(),
          organizationName: _organizationController.text.isEmpty
              ? null
              : _organizationController.text.trim(),
          countryCode: _countryController.text.isEmpty
              ? null
              : _countryController.text.trim(),
        );

    // Check result and navigate
    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState is AuthAuthenticated) {
      // Navigate to buyer dashboard (email verification can be added later)
      context.go('/dashboard/buyer');
    } else if (authState is AuthError) {
      setState(() => _errorMessage = authState.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
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
            Text(
              'Get Started on AfriGo',
              style: AfrigoTypography.headingLarge.copyWith(
                color: AfrigoColors.primaryDeepGreen,
              ),
            ),
            const SizedBox(height: AfrigoSpacing.sm),
            Text(
              'Join thousands of traders across Africa',
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

            // First Name
            TextField(
              controller: _firstNameController,
              focusNode: _firstNameFocus,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'First Name',
                hintText: 'John',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _lastNameFocus.requestFocus(),
            ),
            const SizedBox(height: AfrigoSpacing.md),

            // Last Name
            TextField(
              controller: _lastNameController,
              focusNode: _lastNameFocus,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                hintText: 'Doe',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _emailFocus.requestFocus(),
            ),
            const SizedBox(height: AfrigoSpacing.md),

            // Email
            TextField(
              controller: _emailController,
              focusNode: _emailFocus,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'you@example.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            const SizedBox(height: AfrigoSpacing.md),

            // Password
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
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
            ),
            const SizedBox(height: AfrigoSpacing.sm),
            Text(
              'Min 8 characters, must include uppercase and numbers',
              style: AfrigoTypography.bodySmall.copyWith(
                color: AfrigoColors.textSecondary,
              ),
            ),
            const SizedBox(height: AfrigoSpacing.md),

            // Confirm Password
            TextField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocus,
              enabled: !isLoading,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () => setState(
                      () => _showConfirmPassword = !_showConfirmPassword),
                ),
              ),
              obscureText: !_showConfirmPassword,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _phoneFocus.requestFocus(),
            ),
            const SizedBox(height: AfrigoSpacing.md),

            // Phone (Optional)
            TextField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'Phone Number (Optional)',
                hintText: '+254700000000',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _organizationFocus.requestFocus(),
            ),
            const SizedBox(height: AfrigoSpacing.md),

            // Organization (Optional)
            TextField(
              controller: _organizationController,
              focusNode: _organizationFocus,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'Organization/Business (Optional)',
                hintText: 'Your Company Name',
                prefixIcon: Icon(Icons.business_outlined),
              ),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _countryFocus.requestFocus(),
            ),
            const SizedBox(height: AfrigoSpacing.md),

            // Country Code (Optional)
            TextField(
              controller: _countryController,
              focusNode: _countryFocus,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'Country Code (Optional)',
                hintText: 'KE, NG, UG, etc',
                prefixIcon: Icon(Icons.public_outlined),
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AfrigoSpacing.lg),

            // User Role Selection
            Text(
              'I am a',
              style: AfrigoTypography.labelLarge.copyWith(
                color: AfrigoColors.secondaryNavy,
              ),
            ),
            const SizedBox(height: AfrigoSpacing.sm),
            Wrap(
              spacing: AfrigoSpacing.sm,
              children: [
                FilterChip(
                  label: const Text('Buyer'),
                  selected: _selectedRole == 'buyer',
                  onSelected: isLoading
                      ? null
                      : (selected) {
                          setState(() => _selectedRole = 'buyer');
                        },
                ),
                FilterChip(
                  label: const Text('Seller'),
                  selected: _selectedRole == 'seller',
                  onSelected: isLoading
                      ? null
                      : (selected) {
                          setState(() => _selectedRole = 'seller');
                        },
                ),
                FilterChip(
                  label: const Text('Exporter'),
                  selected: _selectedRole == 'exporter',
                  onSelected: isLoading
                      ? null
                      : (selected) {
                          setState(() => _selectedRole = 'exporter');
                        },
                ),
              ],
            ),
            const SizedBox(height: AfrigoSpacing.lg),

            // Terms Agreement
            CheckboxListTile(
              value: _agreedToTerms,
              onChanged: isLoading
                  ? null
                  : (value) => setState(() => _agreedToTerms = value ?? false),
              title: const Text(
                'I agree to the Terms of Service and Privacy Policy',
                style: AfrigoTypography.bodySmall,
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AfrigoSpacing.lg),

            // Register Button
            ElevatedButton(
              onPressed: isLoading ? null : _handleRegister,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Create Account'),
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

            // Social Login Buttons
            Text(
              'Sign up with',
              style: AfrigoTypography.bodySmall.copyWith(
                color: AfrigoColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AfrigoSpacing.md),

            // Google Button
            OutlinedButton.icon(
              onPressed: isLoading ? null : _handleGoogleSignUp,
              icon: const Icon(Icons.g_translate),
              label: const Text('Google'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: AfrigoSpacing.sm),

            // Facebook Button
            OutlinedButton.icon(
              onPressed: isLoading ? null : _handleFacebookSignUp,
              icon: const Icon(Icons.facebook),
              label: const Text('Facebook'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: AfrigoSpacing.sm),

            // Apple Button
            OutlinedButton.icon(
              onPressed: isLoading ? null : _handleAppleSignUp,
              icon: const Icon(Icons.apple),
              label: const Text('Apple'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: AfrigoSpacing.lg),

            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account? ',
                  style: AfrigoTypography.bodyMedium,
                ),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Text(
                    'Sign In',
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
