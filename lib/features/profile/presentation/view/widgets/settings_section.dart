import 'package:flutter/material.dart';

class SettingsSection extends StatelessWidget {
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final VoidCallback? onNotificationsToggle;
  final VoidCallback? onDarkModeToggle;
  final VoidCallback? onExportData;
  final VoidCallback? onShareProgress;
  final VoidCallback? onHelpSupport;
  final VoidCallback? onSignOut;

  const SettingsSection({
    Key? key,
    required this.notificationsEnabled,
    required this.darkModeEnabled,
    this.onNotificationsToggle,
    this.onDarkModeToggle,
    this.onExportData,
    this.onShareProgress,
    this.onHelpSupport,
    this.onSignOut,
  }) : super(key: key);

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
          // Header
          Row(
            children: [
              Icon(
                Icons.settings_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Settings',
                style:
                    textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ) ??
                    TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Notifications Toggle
          _buildToggleItem(
            context,
            'Notifications',
            Icons.notifications_outlined,
            notificationsEnabled,
            onNotificationsToggle,
          ),

          const SizedBox(height: 12),

          // Dark Mode Toggle
          _buildToggleItem(
            context,
            'Dark Mode',
            Icons.dark_mode_outlined,
            darkModeEnabled,
            onDarkModeToggle,
          ),

          const SizedBox(height: 12),

          // Export Data Button
          _buildActionButton(
            context,
            'Export Study Data',
            Icons.download_outlined,
            onExportData,
          ),

          const SizedBox(height: 12),

          // Share Progress Button
          _buildActionButton(
            context,
            'Share Progress',
            Icons.share_outlined,
            onShareProgress,
          ),

          const SizedBox(height: 12),

          // Help & Support Button
          _buildActionButton(
            context,
            'Help & Support',
            Icons.help_outline,
            onHelpSupport,
          ),

          const SizedBox(height: 12),

          // Sign Out Button
          _buildActionButton(
            context,
            'Sign Out',
            Icons.logout_outlined,
            onSignOut,
            isDestructive: true,
          ),

          const SizedBox(height: 16),

          // App Version
          Center(
            child: Column(
              children: [
                Text(
                  'TioNova v1.0.0',
                  style:
                      textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ) ??
                      TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI-powered study assistant',
                  style:
                      textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ) ??
                      TextStyle(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(
    BuildContext context,
    String title,
    IconData icon,
    bool value,
    VoidCallback? onToggle,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Icon(icon, color: colorScheme.onSurfaceVariant, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style:
                textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface) ??
                TextStyle(color: colorScheme.onSurface, fontSize: 16),
          ),
        ),
        Switch(
          value: value,
          onChanged: (_) => onToggle?.call(),
          activeColor: colorScheme.primary,
          inactiveThumbColor: colorScheme.outline,
          inactiveTrackColor: colorScheme.surfaceVariant,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback? onTap, {
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final actionColor = isDestructive ? colorScheme.error : colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: actionColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style:
                    textTheme.bodyLarge?.copyWith(
                      color: isDestructive
                          ? colorScheme.error
                          : colorScheme.onSurface,
                    ) ??
                    TextStyle(
                      color: isDestructive
                          ? colorScheme.error
                          : colorScheme.onSurface,
                      fontSize: 16,
                    ),
              ),
            ),
            if (!isDestructive)
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
