import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/colors.dart';
import '../../providers/auth_provider.dart';

class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  bool _pushEnabled = true;
  bool _biometricEnabled = false;
  bool _priceAlertsEnabled = true;
  double _syncInterval = 15;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _pushEnabled = prefs.getBool('settings_push') ?? true;
      _biometricEnabled = prefs.getBool('settings_bio') ?? false;
      _priceAlertsEnabled = prefs.getBool('settings_price_alerts') ?? true;
      _syncInterval = (prefs.getInt('settings_sync_interval') ?? 15).toDouble();
    });
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_push', _pushEnabled);
    await prefs.setBool('settings_bio', _biometricEnabled);
    await prefs.setBool('settings_price_alerts', _priceAlertsEnabled);
    await prefs.setInt('settings_sync_interval', _syncInterval.toInt());
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text('Settings'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Experience',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          _SwitchTile(
            icon: Icons.notifications_active_outlined,
            title: 'Push notifications',
            subtitle: 'Receive immediate trade and shipment updates',
            value: _pushEnabled,
            onChanged: (value) async {
              setState(() => _pushEnabled = value);
              await _persist();
            },
          ),
          _SwitchTile(
            icon: Icons.fingerprint,
            title: 'Biometric unlock',
            subtitle: 'Use fingerprint/face to unlock sensitive actions',
            value: _biometricEnabled,
            onChanged: (value) async {
              setState(() => _biometricEnabled = value);
              await _persist();
            },
          ),
          _SwitchTile(
            icon: Icons.show_chart,
            title: 'Price alerts',
            subtitle: 'Notify when commodity prices move beyond threshold',
            value: _priceAlertsEnabled,
            onChanged: (value) async {
              setState(() => _priceAlertsEnabled = value);
              await _persist();
            },
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Real-time sync interval',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${_syncInterval.toInt()} sec',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Slider(
                  min: 5,
                  max: 60,
                  divisions: 11,
                  value: _syncInterval,
                  activeColor: AppColors.accentBlue,
                  onChanged: (value) => setState(() => _syncInterval = value),
                  onChangeEnd: (_) async => _persist(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Utilities',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.vibration,
            title: 'Test haptic feedback',
            subtitle: 'Preview micro-interaction vibration',
            onTap: () {
              HapticFeedback.selectionClick();
              HapticFeedback.lightImpact();
            },
          ),
          _ActionTile(
            icon: Icons.cleaning_services_outlined,
            title: 'Clear local preferences',
            subtitle: 'Reset saved profile and settings fields',
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('profile_phone');
              await prefs.remove('profile_company');
              await prefs.remove('profile_country');
              await prefs.remove('settings_push');
              await prefs.remove('settings_bio');
              await prefs.remove('settings_price_alerts');
              await prefs.remove('settings_sync_interval');
              if (!mounted) return;
              messenger.showSnackBar(
                const SnackBar(content: Text('Local preferences cleared.')),
              );
              await _loadSettings();
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _logout,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondaryGold),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
