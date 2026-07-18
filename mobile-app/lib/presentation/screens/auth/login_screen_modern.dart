import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../animations/micro_animations.dart';

class LoginScreenModern extends ConsumerStatefulWidget {
  const LoginScreenModern({super.key});

  @override
  ConsumerState<LoginScreenModern> createState() => _LoginScreenModernState();
}

class _LoginScreenModernState extends ConsumerState<LoginScreenModern>
    with TickerProviderStateMixin {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  bool _showPassword = false;
  String? _errorMessage;
  bool _isProcessing = false;

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

  String _getDashboardRoute(AuthUser user) {
    final roles = user.roles.map((r) => r.toLowerCase()).toList();
    if (roles.contains('supplier')) {
      return '/dashboard/seller';
    }
    if (roles.contains('exporter')) {
      return '/dashboard/exporter';
    }
    return '/dashboard/buyer';
  }

  Future<void> _handleLogin(String? email, String? password) async {
    if (_isProcessing) return;

    // Use provided credentials or from text fields
    final finalEmail = email ?? _emailController.text.trim();
    final finalPassword = password ?? _passwordController.text.trim();

    if (finalEmail.isEmpty || finalPassword.isEmpty) {
      setState(() => _errorMessage = 'Email and password are required');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isProcessing = true;
    });

    try {
      await ref.read(authProvider.notifier).login(
            email: finalEmail,
            password: finalPassword,
          );

      if (!mounted) return;

      final authState = ref.read(authProvider);
      if (authState is AuthAuthenticated) {
        if (mounted) {
          context.go(_getDashboardRoute(authState.user));
        }
        return;
      }

      if (authState is AuthError) {
        setState(() => _errorMessage = authState.message);
      }
    } catch (e) {
      setState(() => _errorMessage = 'An error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleSocialLogin(Future<void> Function() authenticate) async {
    if (_isProcessing) return;
    setState(() {
      _errorMessage = null;
      _isProcessing = true;
    });
    try {
      await authenticate();
      if (!mounted) return;
      final state = ref.read(authProvider);
      if (state is AuthAuthenticated) {
        context.go(_getDashboardRoute(state.user));
      } else if (state is AuthError) {
        setState(() => _errorMessage = state.message);
      }
    } catch (error) {
      if (mounted) setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authProvider);
    final fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    return Scaffold(
      backgroundColor: AfrigoColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Logo/Title
                  const SlideInAnimation(
                    delay: Duration(milliseconds: 100),
                    child: Text(
                      'AfriGo Trading',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AfrigoColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const SlideInAnimation(
                    delay: Duration(milliseconds: 150),
                    child: Text(
                      'Connect with traders worldwide',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Email Field
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 200),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email address',
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AfrigoColors.primary,
                          ),
                        ),
                      ),
                      enabled: !_isProcessing,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 250),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: AnimatedPressButton(
                          onPressed: () {
                            setState(() => _showPassword = !_showPassword);
                          },
                          child: Icon(
                            _showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AfrigoColors.primary,
                          ),
                        ),
                      ),
                      enabled: !_isProcessing,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Error Message
                  if (_errorMessage != null)
                    SlideInAnimation(
                      delay: Duration.zero,
                      beginOffset: const Offset(0, -0.1),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withAlpha(128),
                          ),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Login Button
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 300),
                    child: AnimatedPressButton(
                      onPressed: () => _handleLogin(null, null),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AfrigoColors.primary,
                              Color(0xFF27A855),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AfrigoColors.primary.withAlpha(102),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                height: 24,
                                child: RotatingLoader(
                                  size: 24,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Sign In',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or continue with'),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _SocialLoginButton(
                          icon: Icons.g_mobiledata,
                          label: 'Google',
                          onPressed: _isProcessing
                              ? null
                              : () => _handleSocialLogin(
                                    () => ref
                                        .read(authProvider.notifier)
                                        .loginWithGoogle(),
                                  ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SocialLoginButton(
                          icon: Icons.facebook,
                          label: 'Facebook',
                          onPressed: _isProcessing
                              ? null
                              : () => _handleSocialLogin(
                                    () => ref
                                        .read(authProvider.notifier)
                                        .loginWithFacebook(),
                                  ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SocialLoginButton(
                          icon: Icons.apple,
                          label: 'Apple',
                          onPressed: _isProcessing
                              ? null
                              : () => _handleSocialLogin(
                                    () => ref
                                        .read(authProvider.notifier)
                                        .loginWithApple(),
                                  ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const SizedBox(height: 40),

                  // Sign Up Link
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 400),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Don\'t have an account? ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        AnimatedPressButton(
                          onPressed: () => context.push('/register'),
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              color: AfrigoColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Sign in with $label',
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 4),
            FittedBox(child: Text(label)),
          ],
        ),
      ),
    );
  }
}
