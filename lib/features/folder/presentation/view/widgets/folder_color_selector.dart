import 'package:flutter/material.dart';

class FolderColorSelector extends StatelessWidget {
  final List<Color> colors;
  final int selectedColorIndex;
  final ValueChanged<int> onColorSelected;

  const FolderColorSelector({
    super.key,
    required this.colors,
    required this.selectedColorIndex,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(colors.length, (i) {
        final selected = i == selectedColorIndex;
        return GestureDetector(
          onTap: () => onColorSelected(i),
          child: Container(
            width: 44,
            height: 32,
            decoration: BoxDecoration(
              color: colors[i].withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? colorScheme.primary : colorScheme.outline,
                width: selected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Container(
                width: 22,
                height: 14,
                decoration: BoxDecoration(
                  color: colors[i],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
