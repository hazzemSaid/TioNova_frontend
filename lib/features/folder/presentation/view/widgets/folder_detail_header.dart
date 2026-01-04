import 'package:flutter/material.dart';

class FolderDetailHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double horizontalPadding;

  const FolderDetailHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: 24,
      ),
      child: Row(
        children: [
          _buildActionButton(
            context,
            icon: Icons.arrow_back_ios_new,
            onTap: () => Navigator.pop(context),
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          _buildActionButton(
            context,
            icon: Icons.share,
            onTap: () {}, // Handle share
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.outline),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: colorScheme.onSurface, size: 16),
      ),
    );
  }
}

class FolderDetailWebHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double effectivePadding;

  const FolderDetailWebHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.effectivePadding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 32,
        left: effectivePadding,
        right: effectivePadding,
        bottom: 32,
      ),
      child: Row(
        children: [
          _buildActionButton(
            context,
            icon: Icons.arrow_back_ios_new,
            onTap: () => Navigator.pop(context),
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          _buildActionButton(
            context,
            icon: Icons.share,
            onTap: () {}, // Handle share
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Icon(icon, color: colorScheme.onSurface, size: 18),
      ),
    );
  }
}
