import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsSection extends StatefulWidget {
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final VoidCallback? onNotificationsToggle;
  final VoidCallback? onDarkModeToggle;
  final VoidCallback? onExportData;
  final VoidCallback? onShareProgress;
  final VoidCallback? onHelpSupport;
  final VoidCallback? onSignOut;

  const SettingsSection({
    super.key,
    required this.notificationsEnabled,
    required this.darkModeEnabled,
    this.onNotificationsToggle,
    this.onDarkModeToggle,
    this.onExportData,
    this.onShareProgress,
    this.onHelpSupport,
    this.onSignOut,
  });

  @override
  State<SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<SettingsSection> {
  bool _studyReminders = true;
  bool _quizResults = true;
  bool _streakAlerts = true;
  bool _weeklyReport = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Study Preferences Section
          Row(
            children: [
              Icon(Icons.tune, color: colorScheme.onSurface, size: 18),
              const SizedBox(width: 8),
              Text(
                'Study Preferences',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildNavItem(
            context,
            'Manage Study Preferences',
            'Adjust study goals, timer',
            Icons.arrow_forward_ios,
            () {
              context.go('/preferences');
            },
          ),

          const SizedBox(height: 20),
          Divider(color: colorScheme.outline.withOpacity(0.3), height: 1),
          const SizedBox(height: 20),

          // Account Section
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: colorScheme.onSurface,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Account',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildAccountRow(context, 'Email', 'john.doe@example.edu'),
          const SizedBox(height: 8),
          _buildAccountRow(context, 'Password', '••••••••'),

          const SizedBox(height: 20),
          Divider(color: colorScheme.outline.withOpacity(0.3), height: 1),
          const SizedBox(height: 20),

          // Notifications Section
          Row(
            children: [
              Icon(
                Icons.notifications_outlined,
                color: colorScheme.onSurface,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Notifications',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildToggleItem(
            context,
            'Study Reminders',
            'Daily study time notifications',
            _studyReminders,
            (value) => setState(() => _studyReminders = value),
          ),
          const SizedBox(height: 8),
          _buildToggleItem(
            context,
            'Quiz Results',
            'Notifications on quiz results',
            _quizResults,
            (value) => setState(() => _quizResults = value),
          ),
          const SizedBox(height: 8),
          _buildToggleItem(
            context,
            'Streak Alerts',
            'Reminders to keep up study streak',
            _streakAlerts,
            (value) => setState(() => _streakAlerts = value),
          ),
          const SizedBox(height: 8),
          _buildToggleItem(
            context,
            'Weekly Report',
            'Summary of study activity',
            _weeklyReport,
            (value) => setState(() => _weeklyReport = value),
          ),

          const SizedBox(height: 20),
          Divider(color: colorScheme.outline.withOpacity(0.3), height: 1),
          const SizedBox(height: 20),

          // More Section
          Row(
            children: [
              Icon(Icons.more_horiz, color: colorScheme.onSurface, size: 18),
              const SizedBox(width: 8),
              Text(
                'More',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildActionRow(context, 'Study Preferences', Icons.tune, () {
            context.go('/preferences');
          }),
          const SizedBox(height: 8),
          _buildActionRow(
            context,
            'Help & Support',
            Icons.help_outline,
            widget.onHelpSupport,
          ),

          const SizedBox(height: 16),
          Divider(color: colorScheme.outline.withOpacity(0.3), height: 1),
          const SizedBox(height: 16),

          // Logout
          _buildActionRow(
            context,
            'Logout',
            Icons.logout_outlined,
            widget.onSignOut,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData trailingIcon,
    VoidCallback? onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.tune, color: colorScheme.onSurfaceVariant, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(trailingIcon, color: colorScheme.onSurfaceVariant, size: 16),
        ],
      ),
    );
  }

  Widget _buildAccountRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Icon(
          label == 'Email' ? Icons.email_outlined : Icons.lock_outline,
          color: colorScheme.onSurfaceVariant,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: Text(
            'Change',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleItem(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        Transform.scale(
          scale: 0.88,
          child: CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback? onTap, {
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: isDestructive
                ? colorScheme.error
                : colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: textTheme.bodyMedium?.copyWith(
                color: isDestructive
                    ? colorScheme.error
                    : colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
