import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class CreateFolderButton extends StatelessWidget {
  const CreateFolderButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final screenSize = MediaQuery.sizeOf(context);
    final isTablet = screenSize.width > 600;
    final double buttonHeight = isTablet ? 44.0 : 40.0;
    final double horizontalPadding = isTablet ? 24.0 : 12.0;
    final double iconSize = isTablet ? 20.0 : 18.0;
    final double fontSize = isTablet ? 14.0 : 13.0;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 8.0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Handle create folder action
          },
          borderRadius: BorderRadius.circular(30.0),
          child: DottedBorder(
            options: CustomPathDottedBorderOptions(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: colorScheme.outline.withOpacity(0.5),
              strokeWidth: 1.5,
              dashPattern: const [6, 3],
              customPath: (size) => Path()
                ..addRRect(
                  RRect.fromRectAndRadius(
                    Rect.fromLTWH(0, 0, size.width, size.height),
                    const Radius.circular(30.0),
                  ),
                ),
            ),
            child: Container(
              width: double.infinity,
              height: buttonHeight,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: colorScheme.primary, size: iconSize),
                  const SizedBox(width: 6.0),
                  Text(
                    'Create New Study Folder',
                    style:
                        textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                        ) ??
                        TextStyle(
                          color: colorScheme.primary,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
