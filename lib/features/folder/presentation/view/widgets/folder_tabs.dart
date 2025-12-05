import 'package:flutter/material.dart';

class FolderTabs extends StatelessWidget {
  final List<String> tabs;
  final String selectedTab;
  final ValueChanged<String> onTabSelected;

  const FolderTabs({
    super.key,
    required this.tabs,
    required this.selectedTab,
    required this.onTabSelected,
  });

  IconData _getTabIcon(String tab) {
    switch (tab) {
      case 'My Folders':
        return Icons.lock_outline;
      case 'Public Folders':
        return Icons.public;
      default:
        return Icons.folder_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final tab = entry.value;
          final isActive = tab == selectedTab;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.primaryContainer.withOpacity(0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isActive ? null : colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isActive
                        ? Colors.transparent
                        : colorScheme.outlineVariant.withOpacity(0.6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isActive
                          ? colorScheme.primary.withOpacity(0.25)
                          : theme.shadowColor.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      scale: isActive ? 1.1 : 1.0,
                      child: Icon(
                        _getTabIcon(tab),
                        color: isActive
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: isActive
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                      child: Text(tab),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
