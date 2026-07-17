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

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  bool _showPassword = false;
  String? _errorMessage;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Start animations when screen loads
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  String _dashboardRouteForUser(AuthUser user) {
    final normalizedRoles = user.roles.map((r) => r.toLowerCase()).toList();
    if (normalizedRoles.contains('seller') ||
        normalizedRoles.contains('supplier') ||
        normalizedRoles.contains('farmer')) {
      return '/dashboard/seller';
    }
    if (normalizedRoles.contains('exporter') ||
        normalizedRoles.contains('member')) {
      return '/dashboard/exporter';
    }
    return '/dashboard/buyer';
  }

  Future<void> _handleLogin() async {
    print('[LoginScreen] Login button pressed');
    print('[LoginScreen] Email: ${_emailController.text.trim()}');

    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      print('[LoginScreen] Validation failed: missing email or password');
      setState(() {
        _errorMessage = 'Email and password are required';
      });
      return;
    }

    setState(() => _errorMessage = null);

    print('[LoginScreen] Calling auth provider login...');

    await ref.read(authProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    print('[LoginScreen] Login request completed');

    if (!mounted) {
      print('[LoginScreen] Widget disposed, returning');
      return;
    }

    final authState = ref.read(authProvider);
    print('[LoginScreen] Auth state after login: $authState');

    if (authState is AuthAuthenticated) {
      print('[LoginScreen] Login successful, navigating to dashboard');
      context.go(_dashboardRouteForUser(authState.user));
      return;
    }

    if (authState is AuthError) {
      print('[LoginScreen] Auth error: ${authState.message}');
      setState(() => _errorMessage = authState.message);
      return;
    }

    print('[LoginScreen] Unknown auth state');
    setState(() => _errorMessage = 'Unable to sign in. Please try again.');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    final slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    return Scaffold(
      backgroundColor: AfrigoColors.bgLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: 'Go Back',
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AfrigoSpacing.screenPadding,
            vertical: AfrigoSpacing.md,
          ),
          child: SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome Back', style: AfrigoTypography.soraHeading2),
                  const SizedBox(height: AfrigoSpacing.sm),
                  Text(
                    'Sign in to your AfriGO account',
                    style: AfrigoTypography.interBody1.copyWith(
                      color: AfrigoColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AfrigoSpacing.lg),

                  // Error message with animation
                  if (_errorMessage != null)
                    AnimatedOpacity(
                      opacity: 1,
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        children: [
                          ModernErrorState(
                            title: 'Login Error',
                            message: _errorMessage!,
                            icon: Icons.error_outline,
                          ),
                          const SizedBox(height: AfrigoSpacing.lg),
                        ],
                      ),
                    ),

                  // Test credentials box with hover effect
                  _buildTestCredentialsBox(),
                  const SizedBox(height: AfrigoSpacing.lg),

                  // Email field with focus animation
                  _buildEmailField(),
                  const SizedBox(height: AfrigoSpacing.lg),

                  // Password field with focus animation
                  _buildPasswordField(),
                  const SizedBox(height: AfrigoSpacing.xxl),

                  // Login button
                  ModernButton(
                    onPressed: isLoading ? () {} : _handleLogin,
                    isLoading: isLoading,
                    child: const Text('Sign In'),
                  ),
                  const SizedBox(height: AfrigoSpacing.lg),

                  // Sign up link
                  Center(
                    child: Row(
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
                  ),
                  const SizedBox(height: AfrigoSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestCredentialsBox() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(AfrigoSpacing.md),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade300),
        borderRadius: BorderRadius.circular(AfriBorderRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '📝',
                style: AfrigoTypography.interBody1,
              ),
              const SizedBox(width: 8),
              Text(
                'Test Accounts',
                style: AfrigoTypography.interBody2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCredentialRow(
            'Farmer',
            'samuel.okoye@afrigo.test',
            'FarmerPass@123',
          ),
          const SizedBox(height: 8),
          _buildCredentialRow(
            'Buyer',
            'olawale.adeyemi@afrigo.test',
            'BuyerPass@123',
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(String role, String email, String password) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AfriBorderRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role,
            style: AfrigoTypography.interBody2.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
              fontSize: 12,
            ),
          ),
          Text(
            email,
            style: AfrigoTypography.interBody2.copyWith(
              color: Colors.blue.shade800,
              fontFamily: 'monospace',
              fontSize: 10,
            ),
          ),
          Text(
            password,
            style: AfrigoTypography.interBody2.copyWith(
              color: Colors.blue.shade800,
              fontFamily: 'monospace',
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() => _isEmailFocused = hasFocus);
        },
        child: AnimatedScale(
          scale: _isEmailFocused ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'name@example.com',
              prefixIcon: Icon(
                Icons.mail_outline,
                color: _isEmailFocused
                    ? AfrigoColors.primary
                    : Colors.grey.shade400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AfriBorderRadius.lg),
                borderSide: BorderSide(
                  color: _isEmailFocused
                      ? AfrigoColors.primary
                      : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AfriBorderRadius.lg),
                borderSide: const BorderSide(
                  color: AfrigoColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() => _isPasswordFocused = hasFocus);
        },
        child: AnimatedScale(
          scale: _isPasswordFocused ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: TextField(
            controller: _passwordController,
            obscureText: !_showPassword,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(
                Icons.lock_outline,
                color: _isPasswordFocused
                    ? AfrigoColors.primary
                    : Colors.grey.shade400,
              ),
              suffixIcon: AnimatedIconButton(
                icon: _showPassword ? Icons.visibility : Icons.visibility_off,
                onPressed: () {
                  setState(() => _showPassword = !_showPassword);
                },
                tooltip: _showPassword ? 'Hide password' : 'Show password',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AfriBorderRadius.lg),
                borderSide: BorderSide(
                  color: _isPasswordFocused
                      ? AfrigoColors.primary
                      : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AfriBorderRadius.lg),
                borderSide: const BorderSide(
                  color: AfrigoColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated icon button with scale and color transition
class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.85).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Tooltip(
            message: widget.tooltip ?? '',
            child: Icon(
              widget.icon,
              color: AfrigoColors.primary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
