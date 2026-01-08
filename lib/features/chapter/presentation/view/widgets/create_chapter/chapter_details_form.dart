import 'package:flutter/material.dart';
import 'package:tionova/features/chapter/presentation/view/widgets/create_chapter/chapter_form_field.dart';

/// A widget that displays the chapter details form section.
class ChapterDetailsForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final VoidCallback onFieldChanged;

  const ChapterDetailsForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(isDesktop ? 24 : 16),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chapter Details',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: isDesktop
                    ? 24
                    : isTablet
                    ? 22
                    : 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: isDesktop ? 24 : 16),
            ChapterFormField(
              label: 'Title',
              hint: 'Enter chapter title',
              controller: titleController,
              isRequired: true,
              onChanged: onFieldChanged,
            ),
            SizedBox(height: isDesktop ? 24 : 16),
            ChapterFormField(
              label: 'Description',
              hint: 'Enter chapter description (at least 10 characters)',
              controller: descriptionController,
              isRequired: true,
              maxLines: 3,
              showCharCount: true,
              maxCharCount: 200,
              minCharCount: 10,
              onChanged: onFieldChanged,
            ),
            SizedBox(height: isDesktop ? 24 : 16),
          ],
        ),
      ),
    );
  }
}
