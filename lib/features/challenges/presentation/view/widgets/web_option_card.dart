import 'package:flutter/material.dart';

class WebOptionCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final String actionLabel;
  final VoidCallback onTap;
  final bool outlined;

  const WebOptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.actionLabel,
    required this.onTap,
    this.outlined = false,
  });

  @override
  State<WebOptionCard> createState() => _WebOptionCardState();
}

class _WebOptionCardState extends State<WebOptionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(20);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: borderRadius,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: colorScheme.surface,
              border: Border.all(
                width: widget.outlined ? 2 : 1,
                color: widget.outlined
                    ? widget.gradientColors.last
                    : colorScheme.outlineVariant.withOpacity(0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? widget.gradientColors.first.withOpacity(0.15)
                      : theme.shadowColor.withOpacity(0.08),
                  blurRadius: _isHovered ? 24 : 12,
                  offset: _isHovered ? const Offset(0, 12) : const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background gradient overlay
                if (!widget.outlined)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      gradient: LinearGradient(
                        colors: widget.gradientColors
                            .map((c) => c.withOpacity(_isHovered ? 0.1 : 0.05))
                            .toList(),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                // Content
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: widget.gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: _isHovered
                              ? [
                                  BoxShadow(
                                    color: widget.gradientColors.first
                                        .withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(widget.icon, color: Colors.white, size: 32),
                      ),
                      SizedBox(height: 16),
                      // Title and Description
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6),
                          Text(
                            widget.description,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.1,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Action Button
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: _isHovered
                                ? widget.gradientColors
                                : [
                                    widget.gradientColors.first.withOpacity(
                                      0.3,
                                    ),
                                    widget.gradientColors.last.withOpacity(0.3),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: _isHovered
                              ? [
                                  BoxShadow(
                                    color: widget.gradientColors.first
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.actionLabel,
                              style: TextStyle(
                                color: _isHovered
                                    ? Colors.white
                                    : colorScheme.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(width: 6),
                            AnimatedTransform(
                              offset: _isHovered ? Offset(4, 0) : Offset.zero,
                              child: Icon(
                                Icons.arrow_forward,
                                color: _isHovered
                                    ? Colors.white
                                    : colorScheme.primary,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class AnimatedTransform extends StatelessWidget {
  final Offset offset;
  final Widget child;

  const AnimatedTransform({
    super.key,
    required this.offset,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: offset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: child,
    );
  }
}
