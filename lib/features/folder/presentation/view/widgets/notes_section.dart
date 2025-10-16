import 'package:flutter/material.dart';
import 'package:tionova/features/folder/presentation/view/screens/notes_screen.dart';

class NotesSection extends StatelessWidget {
  final String chapterId;
  final String chapterTitle;
  final Color? accentColor;

  const NotesSection({
    super.key,
    required this.chapterId,
    required this.chapterTitle,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1B4D3E), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: const Color(0xFF00D9A0),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add text, voice, or image notes',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NotesScreen(
                      chapterId: chapterId,
                      chapterTitle: chapterTitle,
                      accentColor: accentColor ?? const Color(0xFF00D9A0),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: const Color(0xFF1C1C1E),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: Icon(
                Icons.description_outlined,
                color: Colors.white.withOpacity(0.9),
                size: 18,
              ),
              label: const Text(
                'Open',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
