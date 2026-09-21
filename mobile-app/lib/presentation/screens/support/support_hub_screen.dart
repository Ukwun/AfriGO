import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';

class SupportHubScreen extends StatelessWidget {
  const SupportHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('AfriGoOS'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
            icon: const Icon(Icons.notifications_none_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        children: [
          Text('Support', style: AfrigoTypography.soraHeading2),
          const SizedBox(height: 8),
          Text(
            'Get help with your trades, shipments and AfriGoOS account.',
            style: AfrigoTypography.interBody1
                .copyWith(color: AfrigoColors.textSecondary),
          ),
          const SizedBox(height: 24),
          _SupportCard(
            icon: Icons.headset_mic_outlined,
            title: 'Contact AfriGoOS support',
            subtitle: 'Open a private support conversation',
            onTap: () => context.push('/messages'),
          ),
          _SupportCard(
            icon: Icons.local_shipping_outlined,
            title: 'Logistics assistance',
            subtitle: 'Request verified provider quotes for an order',
            onTap: () => context.push('/orders'),
          ),
          _SupportCard(
            icon: Icons.public_outlined,
            title: 'Market access guidance',
            subtitle: 'Check requirements for a real product and route',
            onTap: () => context.push('/market-access'),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AfrigoColors.primary.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AfrigoColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Support responses and provider availability are recorded against your authenticated account.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({
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
  Widget build(BuildContext context) => Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AfrigoColors.borderLight),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          leading: DecoratedBox(
            decoration: BoxDecoration(
              color: AfrigoColors.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: AfrigoColors.primary),
            ),
          ),
          title: Text(title,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      );
}
