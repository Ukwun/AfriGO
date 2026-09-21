import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/modern_components.dart';

class _SignupBrandLockup extends StatelessWidget {
  const _SignupBrandLockup();

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/Afrigolg1.png', width: 66, height: 66),
          const SizedBox(width: 12),
          Container(width: 1, height: 56, color: AfrigoColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AfriGoOS',
                  style: AfrigoTypography.soraHeading2.copyWith(
                    color: AfrigoColors.primary,
                    fontSize: 30,
                    height: 1,
                  )),
              Text('Africa Trades Together',
                  style: AfrigoTypography.interBody2Semi.copyWith(
                    color: AfrigoColors.primary,
                    fontSize: 12,
                  )),
            ],
          ),
        ],
      );
}

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

  String _dashboardRouteForSelectedRole(String role) {
    switch (role.toLowerCase()) {
      case 'supplier':
        return '/supplier/home';
      case 'exporter':
        return '/exporter/home';
      default:
        return '/buyer/home';
    }
  }

  String _dashboardRouteForAuthUser(AuthUser user) {
    final normalizedRoles = user.roles.map((r) => r.toLowerCase()).toList();
    if (normalizedRoles.contains('supplier')) {
      return '/supplier/home';
    }
    if (normalizedRoles.contains('exporter')) {
      return '/exporter/home';
    }
    return '/buyer/home';
  }

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
      await ref
          .read(authProvider.notifier)
          .loginWithGoogle(role: _selectedRole);
      if (!mounted) return;

      final authState = ref.read(authProvider);
      if (authState is AuthAuthenticated) {
        context.go('/role-selection');
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
      await ref
          .read(authProvider.notifier)
          .loginWithFacebook(role: _selectedRole);
      if (!mounted) return;

      final authState = ref.read(authProvider);
      if (authState is AuthAuthenticated) {
        context.go('/role-selection');
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
      await ref.read(authProvider.notifier).loginWithApple(role: _selectedRole);
      if (!mounted) return;

      final authState = ref.read(authProvider);
      if (authState is AuthAuthenticated) {
        context.go('/role-selection');
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
    final fullName = _firstNameController.text.trim();
    final nameParts = fullName.split(RegExp(r'\s+'));
    if (fullName.isEmpty) {
      setState(() => _errorMessage = 'Full name is required');
      return;
    }

    if (nameParts.length < 2) {
      setState(() => _errorMessage = 'Enter your first and last name');
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
          firstName: nameParts.first,
          lastName: nameParts.skip(1).join(' '),
          role: _selectedRole,
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
      // Registration already submitted the selected role. Going through a
      // fresh role-selection screen reset the UI default to buyer and could
      // silently send suppliers/exporters to the buyer dashboard.
      context.go(_dashboardRouteForAuthUser(authState.user));
    } else if (authState is AuthError) {
      setState(() => _errorMessage = authState.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(44, 18, 44, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.arrow_back,
                      color: AfrigoColors.primary, size: 30),
                  onPressed: () => context.pop(),
                ),
              ),
              const SizedBox(height: 12),
              const _SignupBrandLockup(),
              const SizedBox(height: 48),
              Text(
                'Create your account',
                style: AfrigoTypography.soraHeading1.copyWith(
                  color: AfrigoColors.textPrimary,
                  fontSize: 38,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Join AfriGoOS to access new markets,\nconnect with trusted partners and grow\nyour business across Africa.',
                style: AfrigoTypography.interBody1.copyWith(
                  color: AfrigoColors.textSecondary,
                  fontSize: 18,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 42),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AfrigoSpacing.md),
                  decoration: BoxDecoration(
                    color: AfrigoColors.error.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AfrigoColors.error.withValues(alpha: 0.3),
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
                const SizedBox(height: AfrigoSpacing.xl),
              ],
              _buildTextField(
                label: 'Full name',
                hint: 'Enter your full name',
                controller: _firstNameController,
                prefixIcon: Icons.person_outline,
                enabled: !isLoading,
              ),
              const SizedBox(height: AfrigoSpacing.lg),
              _buildTextField(
                label: 'Work email',
                hint: 'name@company.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                enabled: !isLoading,
              ),
              const SizedBox(height: AfrigoSpacing.lg),
              _buildTextField(
                label: 'Password',
                hint: 'Create a password',
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
                'Use at least 8 characters with a mix of letters, numbers and symbols.',
                style: AfrigoTypography.caption.copyWith(
                  color: AfrigoColors.warning,
                ),
              ),
              const SizedBox(height: AfrigoSpacing.lg),
              _buildTextField(
                label: 'Confirm Password',
                hint: 'Confirm your password',
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                prefixIcon: Icons.lock_outline,
                suffixIcon: _showConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
                onSuffixIconTap: () => setState(
                    () => _showConfirmPassword = !_showConfirmPassword),
                enabled: !isLoading,
              ),
              const SizedBox(height: 26),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    label: 'Agree to Terms of Service and Privacy Policy',
                    checked: _agreedToTerms,
                    child: Checkbox(
                      value: _agreedToTerms,
                      onChanged: isLoading
                          ? null
                          : (value) => setState(
                                () => _agreedToTerms = value ?? false,
                              ),
                      activeColor: AfrigoColors.primary,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
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
              const SizedBox(height: 26),
              ModernButton(
                label: 'Create account',
                onPressed: isLoading ? () {} : _handleRegister,
                isLoading: isLoading,
                height: 56,
              ),
              const SizedBox(height: 34),
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
                      'or',
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
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already registered? ',
                    style: AfrigoTypography.interBody2.copyWith(
                      color: AfrigoColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      'Sign in.',
                      style: AfrigoTypography.interBody2Semi.copyWith(
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
    return Semantics(
      label: label,
      textField: true,
      enabled: enabled,
      child: TextField(
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
      ),
    );
  }

  Widget _buildRoleChip(String label, String value) {
    final isSelected = _selectedRole == value;
    return Semantics(
      label: '$label role',
      button: true,
      selected: isSelected,
      child: Material(
        child: InkWell(
          onTap: () => setState(() => _selectedRole = value),
          borderRadius: BorderRadius.circular(AfriBorderRadius.full),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AfrigoSpacing.lg,
              vertical: AfrigoSpacing.md,
            ),
            decoration: BoxDecoration(
              color:
                  isSelected ? AfrigoColors.primary : AfrigoColors.bgLightAlt,
              borderRadius: BorderRadius.circular(AfriBorderRadius.full),
              border: Border.all(
                color: isSelected
                    ? AfrigoColors.primary
                    : AfrigoColors.borderLight,
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
