import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  String _selectedRole = 'buyer';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
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
            Text(
              'Get Started',
              style: AfrigoTypography.headingLarge.copyWith(
                color: AfrigoColors.primaryDeepGreen,
              ),
            ),
            const SizedBox(height: AfrigoSpacing.md),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                hintText: 'John Doe',
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
              ),
              obscureText: true,
            ),
            const SizedBox(height: AfrigoSpacing.md),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: AfrigoSpacing.lg),
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
                  onSelected: (selected) {
                    setState(() => _selectedRole = 'buyer');
                  },
                ),
                FilterChip(
                  label: const Text('Seller'),
                  selected: _selectedRole == 'seller',
                  onSelected: (selected) {
                    setState(() => _selectedRole = 'seller');
                  },
                ),
              ],
            ),
            const SizedBox(height: AfrigoSpacing.lg),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement registration
                context.go('/dashboard/buyer');
              },
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
