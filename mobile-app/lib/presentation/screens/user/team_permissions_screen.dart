import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
class TeamPermissionsScreen extends StatelessWidget {
  const TeamPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Team & permissions'),
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.admin_panel_settings_outlined,
                    size: 54, color: AfrigoColors.primary),
                const SizedBox(height: 16),
                Text('Business access is controlled',
                    style: AfrigoTypography.soraHeading5),
                const SizedBox(height: 8),
                Text(
                  'Team invitations and role changes require organisation-level server controls. They are unavailable in this app build so no user can grant access to private trade records without verification.',
                  textAlign: TextAlign.center,
                  style: AfrigoTypography.interBody2
                      .copyWith(color: AfrigoColors.textSecondary),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => context.push('/messages'),
                  icon: const Icon(Icons.support_agent),
                  label: const Text('Contact AfriGoOS support'),
                ),
              ]),
            ),
          ),
        ),
      );
}
