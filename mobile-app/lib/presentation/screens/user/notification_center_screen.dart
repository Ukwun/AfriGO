import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/colors.dart';
import '../../providers/live_market_activity_provider.dart';

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends ConsumerState<NotificationCenterScreen> {
  final Set<String> _readIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final live = ref.watch(liveMarketActivityProvider);
    final events = live.events;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text('Notifications'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          TextButton(
            onPressed: events.isEmpty
                ? null
                : () {
                    setState(() {
                      _readIds.addAll(events.map((e) => e.id));
                    });
                  },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: events.isEmpty
          ? const _EmptyNotifications()
          : RefreshIndicator(
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 450));
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 20),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final isRead = _readIds.contains(event.id);
                  return Dismissible(
                    key: ValueKey(event.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      setState(() => _readIds.add(event.id));
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 18),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.check, color: Colors.white),
                    ),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.95, end: 1),
                      duration: Duration(milliseconds: 180 + (index * 40)),
                      curve: Curves.easeOut,
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.scale(scale: value, child: child),
                      ),
                      child: _NotificationTile(
                        title: event.title,
                        subtitle: event.subtitle,
                        timestamp: event.timestamp,
                        isRead: isRead,
                        onTap: () {
                          setState(() => _readIds.add(event.id));
                          if (event.type == LiveEventType.rfqPosted) {
                            context.push('/rfqs');
                            return;
                          }
                          if (event.type == LiveEventType.shipmentBooked ||
                              event.type == LiveEventType.customsCleared) {
                            context.push('/tracking');
                            return;
                          }
                          context.push('/analytics');
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.isRead,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final DateTime timestamp;
  final bool isRead;
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
          border: Border.all(
            color: isRead ? AppColors.borderDefault : AppColors.accentBlue,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isRead
                    ? AppColors.borderDefault.withValues(alpha: 0.4)
                    : AppColors.accentBlueLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isRead ? Icons.notifications_none : Icons.notifications_active,
                size: 18,
                color: isRead ? AppColors.textSecondary : AppColors.accentBlue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 13,
                      fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(timestamp),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.notifications_none,
              size: 46, color: AppColors.textSecondary),
          SizedBox(height: 10),
          Text(
            'No notifications yet',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Live role activity updates will appear here.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
