import 'package:flutter/material.dart';

class FolderEditFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const FolderEditFields({
    super.key,
    required this.titleController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        TextField(
          maxLines: 2,
          controller: titleController,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(12),
            labelText: 'Title',
            labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorScheme.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorScheme.error),
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: descriptionController,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: 'Description',
            labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorScheme.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}
