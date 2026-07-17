import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BuyerMoreScreen extends ConsumerWidget {
  const BuyerMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('More Options'), elevation: 0),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  theme,
                  'Buying',
                  [
                    {
                      'label': 'My RFQs',
                      'icon': Icons.request_quote,
                      'route': '/rfqs'
                    },
                    {
                      'label': 'My Orders',
                      'icon': Icons.shopping_cart,
                      'route': '/rfqs'
                    },
                    {
                      'label': 'Saved Suppliers',
                      'icon': Icons.favorite,
                      'route': '/rfqs'
                    },
                  ],
                  context,
                ),
                const SizedBox(height: 24),
                _buildSection(
                  theme,
                  'Account',
                  [
                    {
                      'label': 'Notifications',
                      'icon': Icons.notifications,
                      'route': '/notifications'
                    },
                    {
                      'label': 'Settings',
                      'icon': Icons.settings,
                      'route': '/settings'
                    },
                    {
                      'label': 'Help & Support',
                      'icon': Icons.help_center,
                      'route': '/settings'
                    },
                  ],
                  context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title,
      List<Map<String, dynamic>> items, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Column(
          children: List.generate(
            items.length,
            (index) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => context.push(items[index]['route']),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(items[index]['icon'],
                            color: theme.colorScheme.primary, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                          child: Text(items[index]['label'],
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600))),
                      Icon(Icons.arrow_forward_ios,
                          size: 14, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
