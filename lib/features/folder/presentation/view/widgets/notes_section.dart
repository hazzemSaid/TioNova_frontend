import 'package:flutter/material.dart';
import 'package:tionova/features/folder/presentation/view/screens/notes_screen.dart';

class NotesSection extends StatefulWidget {
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
  State<NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends State<NotesSection> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (mounted) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() => _isHovered = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFF00D9A0).withOpacity(0.5)
                : const Color(0xFF1B4D3E),
            width: 1.5,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF00D9A0).withOpacity(0.15),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Color(0xFF00D9A0),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Add text, voice, or image notes',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NotesScreen(
                          chapterId: widget.chapterId,
                          chapterTitle: widget.chapterTitle,
                          accentColor:
                              widget.accentColor ?? const Color(0xFF00D9A0),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    backgroundColor: const Color(0xFF1C1C1E),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                      side: const BorderSide(
                        color: Color(0xFF2C2C2E),
                        width: 1,
                      ),
                    ),
                  ),
                  icon: Icon(
                    Icons.description_outlined,
                    color: Colors.white.withOpacity(0.9),
                    size: 22,
                  ),
                  label: Text(
                    'Open',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
