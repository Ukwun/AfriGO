import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/colors.dart';
import '../../providers/auth_provider.dart';
import '../../../data/services/api_client.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _countryController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await ApiClient().get('/auth/me');
      final user = response['user'] as Map<String, dynamic>? ?? const {};
      if (!mounted) return;
      setState(() {
        _phoneController.text = user['phone']?.toString() ?? '';
        _companyController.text = user['organization']?.toString() ?? '';
        _countryController.text = user['countryCode']?.toString() ?? '';
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load profile: $error')),
      );
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      await ApiClient().patch('/auth/me', body: {
        'phone': _phoneController.text.trim(),
        'organization': _companyController.text.trim(),
        'countryCode': _countryController.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save profile: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _companyController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final role = (user?.roles.isNotEmpty ?? false)
        ? user!.roles.first.toUpperCase()
        : 'BUYER';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text('Profile'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.92, end: 1),
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutBack,
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryGreenLighter,
                    child: Icon(Icons.person, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName.isNotEmpty == true
                              ? user!.fullName
                              : 'AfriGO User',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'No email available',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentBlueLight,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            role,
                            style: const TextStyle(
                              color: AppColors.accentBlueDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
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
          const SizedBox(height: 16),
          _ProfileInput(
            label: 'Phone Number',
            hint: '+234 000 000 0000',
            controller: _phoneController,
            icon: Icons.phone_outlined,
          ),
          const SizedBox(height: 12),
          _ProfileInput(
            label: 'Company',
            hint: 'Your business name',
            controller: _companyController,
            icon: Icons.business_outlined,
          ),
          const SizedBox(height: 12),
          _ProfileInput(
            label: 'Operating Country',
            hint: 'Nigeria / Ghana / Kenya ...',
            controller: _countryController,
            icon: Icons.public_outlined,
          ),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 48,
            child: FilledButton.icon(
              onPressed: _saving ? null : _saveProfile,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving...' : 'Save Profile'),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => context.push('/settings'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: const Row(
                children: [
                  Icon(Icons.settings_outlined, color: AppColors.accentBlue),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _StatRow(
            icon: Icons.verified_user_outlined,
            label: 'Trust score',
            value: '${user?.trustScore ?? 0}',
          ),
          _StatRow(
            icon: Icons.checklist_rtl_outlined,
            label: 'Completed trades',
            value: '${user?.completedTrades ?? 0}',
          ),
          _StatRow(
            icon: Icons.fact_check_outlined,
            label: 'KYC status',
            value: user?.kycStatus.toUpperCase() ?? 'PENDING',
          ),
        ],
      ),
    );
  }
}

class _ProfileInput extends StatelessWidget {
  const _ProfileInput({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: AppColors.textSecondary),
          labelText: label,
          hintText: hint,
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accentBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
