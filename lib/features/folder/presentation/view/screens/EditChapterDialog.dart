// features/folder/presentation/view/screens/EditChapterDialog.dart
import 'package:flutter/material.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';

class EditChapterDialog extends StatelessWidget {
  final ChapterModel chapter;
  final List<Color> defaultcolors;
  final List<IconData> icons;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  const EditChapterDialog({
    required this.chapter,
    required this.defaultcolors,
    required this.icons,
    required this.titleController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    // Make a dialog with the chapter title, description, and dropdown for the status
    return AlertDialog(
      backgroundColor: const Color(0xFF0E0E10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF1C1C1E)),
      ),
      title: Text('Edit Chapter', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(12),
                labelText: 'Title',
                labelStyle: const TextStyle(color: Color(0xFF8E8E93)),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF1C1C1E)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(12),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFF1C1C1E),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: const TextStyle(color: Color(0xFF8E8E93)),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF1C1C1E)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFF1C1C1E),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: () {
            // Save logic here
            //logic to update the chapter
            Navigator.of(context).pop();
          },
          child: Text('Save', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
