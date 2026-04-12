import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AfrigoSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AfrigoSpacing.lg),
            Text(
              'Welcome Back',
              style: AfrigoTypography.headingLarge.copyWith(
                color: AfrigoColors.primaryDeepGreen,
              ),
            ),
            const SizedBox(height: AfrigoSpacing.md),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'you@example.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AfrigoSpacing.md),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: '••••••••',
              ),
              obscureText: true,
            ),
            const SizedBox(height: AfrigoSpacing.lg),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement login
                context.go('/dashboard/buyer');
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: AfrigoSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don\'t have an account? ',
                  style: AfrigoTypography.bodyMedium,
                ),
                GestureDetector(
                  onTap: () => context.go('/register'),
                  child: Text(
                    'Sign up',
                    style: AfrigoTypography.bodyMedium.copyWith(
                      color: AfrigoColors.primaryDeepGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
