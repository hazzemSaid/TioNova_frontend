import 'package:flutter/material.dart';

class FolderTabs extends StatelessWidget {
  final List<String> tabs;
  final String selectedTab;
  final ValueChanged<String> onTabSelected;

  const FolderTabs({
    Key? key,
    required this.tabs,
    required this.selectedTab,
    required this.onTabSelected,
  }) : super(key: key);

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
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = tab == selectedTab;
          final isFirst = index == 0;
          final isLast = index == tabs.length - 1;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(tab),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0E0E10)
                      : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left: isFirst ? const Radius.circular(12) : Radius.zero,
                    right: isLast ? const Radius.circular(12) : Radius.zero,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getTabIcon(tab),
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF8E8E93),
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tab,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF8E8E93),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
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
