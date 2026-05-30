import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/modern_components.dart';

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

  bool _isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

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

  Future<void> _handleRegister() async {
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

    setState(() => _errorMessage = null);

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

    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState is AuthAuthenticated) {
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
      backgroundColor: AfrigoColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AfrigoColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'Create Account',
          style: AfrigoTypography.soraHeading6.copyWith(
            color: AfrigoColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AfrigoSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Get Started on AfriGO',
              style: AfrigoTypography.soraHeading3.copyWith(
                color: AfrigoColors.textPrimary,
              ),
            ),
            const SizedBox(height: AfrigoSpacing.md),
            Text(
              'Join thousands of traders across Africa',
              style: AfrigoTypography.interBody1.copyWith(
                color: AfrigoColors.textSecondary,
              ),
            ),
            const SizedBox(height: AfrigoSpacing.xxl),

            // Error Message
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
                    Icon(
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
              const SizedBox(height: AfrigoSpacing.xl),
            ],

            // Name Fields Row
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'First Name',
                    hint: 'John',
                    controller: _firstNameController,
                    prefixIcon: Icons.person_outline,
                    enabled: !isLoading,
                  ),
                ),
                const SizedBox(width: AfrigoSpacing.md),
                Expanded(
                  child: _buildTextField(
                    label: 'Last Name',
                    hint: 'Doe',
                    controller: _lastNameController,
                    prefixIcon: Icons.person_outline,
                    enabled: !isLoading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AfrigoSpacing.lg),

            // Email
            _buildTextField(
              label: 'Email Address',
              hint: 'you@example.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              enabled: !isLoading,
            ),
            const SizedBox(height: AfrigoSpacing.lg),

            // Password
            _buildTextField(
              label: 'Password',
              hint: '••••••••',
              controller: _passwordController,
              obscureText: !_showPassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon:
                  _showPassword ? Icons.visibility : Icons.visibility_off,
              onSuffixIconTap: () =>
                  setState(() => _showPassword = !_showPassword),
              enabled: !isLoading,
            ),
            const SizedBox(height: AfrigoSpacing.sm),
            Text(
              '⚠️  Minimum 8 characters with uppercase letters and numbers',
              style: AfrigoTypography.caption.copyWith(
                color: AfrigoColors.warning,
              ),
            ),
            const SizedBox(height: AfrigoSpacing.lg),

            // Confirm Password
            _buildTextField(
              label: 'Confirm Password',
              hint: '••••••••',
              controller: _confirmPasswordController,
              obscureText: !_showConfirmPassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: _showConfirmPassword
                  ? Icons.visibility
                  : Icons.visibility_off,
              onSuffixIconTap: () =>
                  setState(() => _showConfirmPassword = !_showConfirmPassword),
              enabled: !isLoading,
            ),
            const SizedBox(height: AfrigoSpacing.lg),

            // Optional Fields Section
            Text(
              'Optional Information',
              style: AfrigoTypography.interBody2Semi.copyWith(
                color: AfrigoColors.textSecondary,
              ),
            ),
            const SizedBox(height: AfrigoSpacing.md),

            _buildTextField(
              label: 'Phone Number',
              hint: '+254 700 000 000',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              enabled: !isLoading,
            ),
            const SizedBox(height: AfrigoSpacing.md),

            _buildTextField(
              label: 'Organization/Business',
              hint: 'Your Company Name',
              controller: _organizationController,
              prefixIcon: Icons.business_outlined,
              enabled: !isLoading,
            ),
            const SizedBox(height: AfrigoSpacing.md),

            _buildTextField(
              label: 'Country Code',
              hint: 'KE, NG, UG, etc',
              controller: _countryController,
              prefixIcon: Icons.public_outlined,
              enabled: !isLoading,
            ),
            const SizedBox(height: AfrigoSpacing.xl),

            // Role Selection
            Text(
              'What role describes you best?',
              style: AfrigoTypography.interBody2Semi.copyWith(
                color: AfrigoColors.textPrimary,
              ),
            ),
            const SizedBox(height: AfrigoSpacing.md),
            Wrap(
              spacing: AfrigoSpacing.md,
              runSpacing: AfrigoSpacing.md,
              children: [
                _buildRoleChip('Buyer', 'buyer'),
                _buildRoleChip('Seller', 'seller'),
                _buildRoleChip('Exporter', 'exporter'),
              ],
            ),
            const SizedBox(height: AfrigoSpacing.xl),

            // Terms Agreement
            Container(
              padding: const EdgeInsets.all(AfrigoSpacing.md),
              decoration: BoxDecoration(
                color: AfrigoColors.primary.withOpacity(0.05),
                border: Border.all(
                  color: AfrigoColors.primary.withOpacity(0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(AfriBorderRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: isLoading
                        ? null
                        : (value) =>
                            setState(() => _agreedToTerms = value ?? false),
                    activeColor: AfrigoColors.primary,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AfrigoSpacing.xs),
                      child: RichText(
                        text: TextSpan(
                          text: 'I agree to the ',
                          style: AfrigoTypography.interBody2.copyWith(
                            color: AfrigoColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: 'Terms of Service',
                              style: AfrigoTypography.interBody2Semi.copyWith(
                                color: AfrigoColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(
                              text: ' and ',
                              style: AfrigoTypography.interBody2.copyWith(
                                color: AfrigoColors.textSecondary,
                              ),
                            ),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: AfrigoTypography.interBody2Semi.copyWith(
                                color: AfrigoColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AfrigoSpacing.xl),

            // Register Button
            ModernButton(
              label: 'Create Account',
              onPressed: isLoading ? () {} : _handleRegister,
              isLoading: isLoading,
              height: 56,
            ),
            const SizedBox(height: AfrigoSpacing.xl),

            // Divider
            Row(
              children: [
                Expanded(
                  child: Container(
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
                    style: AfrigoTypography.labelSmall.copyWith(
                      color: AfrigoColors.textTertiary,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: AfrigoColors.borderLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AfrigoSpacing.xl),

            // Social Sign-up
            Text(
              'Sign up with',
              style: AfrigoTypography.interBody2.copyWith(
                color: AfrigoColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AfrigoSpacing.lg),

            // Social Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialButton(
                  Icons.g_translate,
                  onPressed: isLoading ? null : _handleGoogleSignUp,
                ),
                _buildSocialButton(
                  Icons.facebook,
                  onPressed: isLoading ? null : _handleFacebookSignUp,
                ),
                _buildSocialButton(
                  Icons.apple,
                  onPressed: isLoading ? null : _handleAppleSignUp,
                ),
              ],
            ),
            const SizedBox(height: AfrigoSpacing.xl),

            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: AfrigoTypography.interBody2.copyWith(
                    color: AfrigoColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Text(
                    'Sign In',
                    style: AfrigoTypography.interBody2Semi.copyWith(
                      color: AfrigoColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AfrigoSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixIconTap,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
        suffixIcon: suffixIcon != null
            ? GestureDetector(
                onTap: onSuffixIconTap,
                child: Icon(suffixIcon, size: 20),
              )
            : null,
        filled: true,
        fillColor: AfrigoColors.bgLightAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AfrigoSpacing.lg,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AfriBorderRadius.md),
          borderSide: const BorderSide(color: AfrigoColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AfriBorderRadius.md),
          borderSide: const BorderSide(color: AfrigoColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AfriBorderRadius.md),
          borderSide: const BorderSide(
            color: AfrigoColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(String label, String value) {
    final isSelected = _selectedRole == value;
    return Material(
      child: InkWell(
        onTap: () => setState(() => _selectedRole = value),
        borderRadius: BorderRadius.circular(AfriBorderRadius.full),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AfrigoSpacing.lg,
            vertical: AfrigoSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AfrigoColors.primary : AfrigoColors.bgLightAlt,
            borderRadius: BorderRadius.circular(AfriBorderRadius.full),
            border: Border.all(
              color:
                  isSelected ? AfrigoColors.primary : AfrigoColors.borderLight,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: AfrigoTypography.interBody2Semi.copyWith(
              color: isSelected ? Colors.white : AfrigoColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    IconData icon, {
    required Function()? onPressed,
  }) {
    return Material(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AfriBorderRadius.md),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AfriBorderRadius.md),
            border: Border.all(
              color: AfrigoColors.borderLight,
              width: 1,
            ),
            boxShadow: AfrigoElevation.shadow1,
          ),
          child: Icon(
            icon,
            color: AfrigoColors.textSecondary,
            size: 24,
          ),
        ),
      ),
    );
  }
}

