import 'package:flutter/material.dart';

/// A reusable form field widget for chapter creation.
class ChapterFormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isRequired;
  final int maxLines;
  final bool showCharCount;
  final int? maxCharCount;
  final int? minCharCount;
  final VoidCallback? onChanged;

  const ChapterFormField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isRequired = false,
    this.maxLines = 1,
    this.showCharCount = false,
    this.maxCharCount,
    this.minCharCount,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w500,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: colorScheme.error,
                    fontSize: isTablet ? 18 : 16,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 10 : 8),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Stack(
            children: [
              TextField(
                controller: controller,
                maxLines: maxLines,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: isTablet ? 16 : 14,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: isTablet ? 16 : 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(isTablet ? 16 : 12),
                ),
                onChanged: (text) {
                  onChanged?.call();
                },
              ),
              if (showCharCount && maxCharCount != null)
                Positioned(
                  bottom: isTablet ? 12 : 8,
                  right: isTablet ? 16 : 12,
                  child: Text(
                    '${controller.text.length}/$maxCharCount',
                    style: TextStyle(
                      color: (minCharCount != null &&
                              controller.text.length < minCharCount!)
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
