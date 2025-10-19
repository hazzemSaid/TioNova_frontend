import 'package:flutter/material.dart';

class MindMapSection extends StatefulWidget {
  final VoidCallback onOpen;
  final bool isLoading;

  const MindMapSection({
    super.key,
    required this.onOpen,
    this.isLoading = false,
  });

  @override
  State<MindMapSection> createState() => _MindMapSectionState();
}

class _MindMapSectionState extends State<MindMapSection> {
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
                ? const Color(0xFF2C2C2E)
                : const Color(0xFF1C1C1E),
            width: 1.5,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.05),
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
                    child: Icon(
                      Icons.account_tree_outlined,
                      color: Colors.white.withOpacity(0.9),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mind Map',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Visualize concepts in an interactive map',
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
                  onPressed: widget.isLoading ? null : widget.onOpen,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    backgroundColor: const Color(0xFF1C1C1E),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                      side: BorderSide(
                        color: const Color(0xFF2C2C2E),
                        width: 1,
                      ),
                    ),
                    disabledBackgroundColor: const Color(
                      0xFF1C1C1E,
                    ).withOpacity(0.5),
                  ),
                  icon: widget.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          Icons.hub_outlined,
                          color: Colors.white.withOpacity(0.9),
                          size: 22,
                        ),
                  label: Text(
                    widget.isLoading ? 'Generating...' : 'Generate Mind Map',
                    style: TextStyle(
                      color: Colors.white.withOpacity(
                        widget.isLoading ? 0.5 : 0.9,
                      ),
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
