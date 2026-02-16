import 'package:flutter/material.dart';

class ChapterDetailActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? iconContainerColor;
  final Color? textColor;
  final Color? subtitleColor;
  final bool isLarge;

  const ChapterDetailActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
    this.isLoading = false,
    this.backgroundColor,
    this.iconColor,
    this.iconContainerColor,
    this.textColor,
    this.subtitleColor,
    this.isLarge = false,
  });

  @override
  State<ChapterDetailActionCard> createState() =>
      _ChapterDetailActionCardState();
}

class _ChapterDetailActionCardState extends State<ChapterDetailActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(widget.isLarge ? 32 : 28),
        transform: _isHovered
            ? (Matrix4.identity()..translate(0, -4, 0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? colorScheme.primary.withOpacity(0.5)
                : colorScheme.outline.withOpacity(0.5),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.isLarge ? 64 : 56,
              height: widget.isLarge ? 64 : 56,
              decoration: BoxDecoration(
                color: _isHovered
                    ? (widget.iconContainerColor ??
                          colorScheme.primaryContainer)
                    : (widget.iconContainerColor ?? colorScheme.surfaceVariant),
                borderRadius: BorderRadius.circular(16),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                widget.icon,
                color: _isHovered
                    ? (widget.iconColor ?? colorScheme.primary)
                    : (widget.iconColor ?? colorScheme.onSurface),
                size: widget.isLarge ? 32 : 28,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: TextStyle(
                color: widget.textColor ?? colorScheme.onSurface,
                fontSize: widget.isLarge ? 22 : 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.description,
              style: TextStyle(
                color: widget.subtitleColor ?? colorScheme.onSurfaceVariant,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: OutlinedButton(
                  onPressed: widget.isLoading ? null : widget.onAction,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _isHovered
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                    side: BorderSide(
                      color: _isHovered
                          ? colorScheme.primary
                          : colorScheme.outline,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: _isHovered
                        ? colorScheme.primary.withOpacity(0.05)
                        : Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.isLoading
                            ? Icons.hourglass_empty
                            : widget.actionIcon,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.actionLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
