import 'package:flutter/material.dart';

class AISummarySection extends StatefulWidget {
  final bool isSummaryAvailable;
  final bool isSummaryLoading;
  final VoidCallback onViewSummary;
  final VoidCallback onGenerateSummary;
  const AISummarySection({
    Key? key,
    required this.isSummaryAvailable,
    required this.isSummaryLoading,
    required this.onViewSummary,
    required this.onGenerateSummary,
  }) : super(key: key);

  @override
  State<AISummarySection> createState() => _AISummarySectionState();
}

class _AISummarySectionState extends State<AISummarySection> {
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
                ? const Color(0xFF5E3CFF).withOpacity(0.5)
                : const Color(0xFF1C1C1E),
            width: 1.5,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF5E3CFF).withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5E3CFF), Color(0xFFB558FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Summary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Get key points, definitions, practice questions,\nand quick reference cards',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (widget.isSummaryAvailable)
                _buildViewSummaryButton()
              else if (widget.isSummaryLoading)
                _buildLoadingButton()
              else
                _buildGenerateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewSummaryButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF5E3CFF), Color(0xFFB558FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E3CFF).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onViewSummary,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                const Text(
                  'View Full Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingButton() {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: const Color(0xFF1C1C1E),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF5E3CFF),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Generating Summary...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: const Color(0xFF1C1C1E),
        border: Border.all(color: const Color(0xFF2C2C2E), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onGenerateSummary,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome_outlined,
                  color: Colors.white.withOpacity(0.9),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  'Generate Summary',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
