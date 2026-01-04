import 'package:flutter/material.dart';

class FolderIconSelector extends StatelessWidget {
  final List<IconData> icons;
  final int selectedIconIndex;
  final ValueChanged<int> onIconSelected;

  const FolderIconSelector({
    super.key,
    required this.icons,
    required this.selectedIconIndex,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(icons.length, (i) {
        final selected = i == selectedIconIndex;
        return GestureDetector(
          onTap: () => onIconSelected(i),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? colorScheme.primary : colorScheme.outline,
                width: selected ? 2 : 1,
              ),
            ),
            child: Icon(icons[i], color: colorScheme.onSurface, size: 20),
          ),
        );
      }),
    );
  }
}
