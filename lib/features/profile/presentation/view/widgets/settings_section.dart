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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1C1C1E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Notifications Toggle
          _buildToggleItem(
            'Notifications',
            Icons.notifications_outlined,
            notificationsEnabled,
            onNotificationsToggle,
          ),

          const SizedBox(height: 12),

          // Dark Mode Toggle
          _buildToggleItem(
            'Dark Mode',
            Icons.dark_mode_outlined,
            darkModeEnabled,
            onDarkModeToggle,
          ),

          const SizedBox(height: 12),

          // Export Data Button
          _buildActionButton(
            'Export Study Data',
            Icons.download_outlined,
            onExportData,
          ),

          const SizedBox(height: 12),

          // Share Progress Button
          _buildActionButton(
            'Share Progress',
            Icons.share_outlined,
            onShareProgress,
          ),

          const SizedBox(height: 12),

          // Help & Support Button
          _buildActionButton(
            'Help & Support',
            Icons.help_outline,
            onHelpSupport,
          ),

          const SizedBox(height: 12),

          // Sign Out Button
          _buildActionButton(
            'Sign Out',
            Icons.logout_outlined,
            onSignOut,
            isDestructive: true,
          ),

          const SizedBox(height: 16),

          // App Version
          const Center(
            child: Column(
              children: [
                Text(
                  'TioNova v1.0.0',
                  style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  'AI-powered study assistant',
                  style: TextStyle(color: Color(0xFF6A6A6A), fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(
    String title,
    IconData icon,
    bool value,
    VoidCallback? onToggle,
  ) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF8E8E93), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        Switch(
          value: value,
          onChanged: (_) => onToggle?.call(),
          activeColor: const Color(0xFF007AFF),
          inactiveThumbColor: const Color(0xFF8E8E93),
          inactiveTrackColor: const Color(0xFF2C2C2E),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    VoidCallback? onTap, {
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? const Color(0xFFFF3B30)
                  : const Color(0xFF8E8E93),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDestructive ? const Color(0xFFFF3B30) : Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            if (!isDestructive)
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF8E8E93),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
