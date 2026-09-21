import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../providers/auth_provider.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  String _selectedRole = 'buyer';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authProvider);
    if (authState is AuthAuthenticated && authState.user.roles.isNotEmpty) {
      final role = authState.user.roles.first.toLowerCase();
      if (role == 'supplier' || role == 'exporter' || role == 'buyer') {
        _selectedRole = role;
      }
    }
  }

  Future<void> _continue() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(authProvider.notifier).updateRole(_selectedRole);
    } catch (_) {
      // The authenticated Firebase session is enough to continue; the role
      // write can be retried when the profile service is available.
    }
    if (!mounted) return;
    final route = switch (_selectedRole) {
      'supplier' => '/supplier/home',
      'exporter' => '/exporter/home',
      _ => '/buyer/home',
    };
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // Android 15 can draw the navigation bar over edge-to-edge content;
          // keep the primary action comfortably above that system inset.
          padding: EdgeInsets.fromLTRB(
            24,
            28,
            24,
            32 + MediaQuery.viewPaddingOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/Afrigolg1.png',
                  width: 108,
                  height: 108,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'How will you use AfriGoOS?',
                style: AfrigoTypography.soraHeading2.copyWith(
                  color: AfrigoColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Choose the role that best describes your business. You can update this later in your profile.',
                style: AfrigoTypography.interBody1.copyWith(
                  color: AfrigoColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              _RoleOption(
                title: 'I am a buyer',
                description: 'Find trusted products and manage sourcing.',
                icon: Icons.shopping_bag_outlined,
                selected: _selectedRole == 'buyer',
                onTap: () => setState(() => _selectedRole = 'buyer'),
              ),
              const SizedBox(height: 12),
              _RoleOption(
                title: 'I am a supplier',
                description: 'List products and connect with new markets.',
                icon: Icons.inventory_2_outlined,
                selected: _selectedRole == 'supplier',
                onTap: () => setState(() => _selectedRole = 'supplier'),
              ),
              const SizedBox(height: 12),
              _RoleOption(
                title: 'I am an exporter',
                description: 'Coordinate cross-border trade and logistics.',
                icon: Icons.local_shipping_outlined,
                selected: _selectedRole == 'exporter',
                onTap: () => setState(() => _selectedRole = 'exporter'),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _isSaving ? null : _continue,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AfrigoColors.primary : AfrigoColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AfrigoColors.primary.withValues(alpha: .07)
              : Colors.white,
          border: Border.all(
            color: selected ? AfrigoColors.primary : AfrigoColors.borderLight,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(color: color)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color:
                  selected ? AfrigoColors.primary : AfrigoColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
