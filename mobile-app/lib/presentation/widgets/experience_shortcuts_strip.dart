import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/colors.dart';
import '../providers/live_market_activity_provider.dart';

class ExperienceShortcutsStrip extends ConsumerStatefulWidget {
  const ExperienceShortcutsStrip({
    super.key,
    required this.roleLabel,
  });

  final String roleLabel;

  @override
  ConsumerState<ExperienceShortcutsStrip> createState() =>
      _ExperienceShortcutsStripState();
}

class _ExperienceShortcutsStripState
    extends ConsumerState<ExperienceShortcutsStrip> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final live = ref.watch(liveMarketActivityProvider);
    final unread = live.events.length > 9 ? '9+' : '${live.events.length}';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_outlined, color: AppColors.accentBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.roleLabel} hub',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: AnimatedRotation(
                  turns: _expanded ? 0 : 0.5,
                  duration: const Duration(milliseconds: 220),
                  child: const Icon(Icons.expand_less_rounded),
                ),
              ),
            ],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 230),
            child: _expanded
                ? Column(
                    key: const ValueKey('expanded'),
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _ShortcutTile(
                              title: 'Profile',
                              subtitle: 'Identity and trust',
                              icon: Icons.person_outline,
                              accent: AppColors.primaryGreen,
                              onTap: () => context.push('/profile'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ShortcutTile(
                              title: 'Notifications',
                              subtitle: 'Live activity',
                              icon: Icons.notifications_none,
                              accent: AppColors.accentBlue,
                              badge: unread,
                              onTap: () => context.push('/notifications'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ShortcutTile(
                              title: 'Settings',
                              subtitle: 'App controls',
                              icon: Icons.tune,
                              accent: AppColors.secondaryGold,
                              onTap: () => context.push('/settings'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : const SizedBox.shrink(key: ValueKey('collapsed')),
          ),
        ],
      ),
    );
  }
}

class _ShortcutTile extends StatefulWidget {
  const _ShortcutTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String? badge;
  final VoidCallback onTap;

  @override
  State<_ShortcutTile> createState() => _ShortcutTileState();
}

class _ShortcutTileState extends State<_ShortcutTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        scale: _pressed ? 0.97 : 1,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.accent.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(widget.icon, color: widget.accent, size: 18),
                  const Spacer(),
                  if (widget.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        widget.badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
