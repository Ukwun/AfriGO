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
          onPressed: () => context.pop(),
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
              if (_errorMessage != null)
                ModernErrorState(
                  title: 'Login Error',
                  message: _errorMessage!,
                  icon: Icons.error_outline,
                ),
              if (_errorMessage != null)
                const SizedBox(height: AfrigoSpacing.lg),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'name@example.com',
                  prefixIcon: const Icon(Icons.mail_outline),
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
              ModernButton(
                onPressed: () {},
                isLoading: isLoading,
                child: const Text('Sign In'),
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
