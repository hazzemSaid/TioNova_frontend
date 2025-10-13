import 'package:flutter/material.dart';
import 'package:tionova/features/folder/data/models/nodeModel.dart';

class MindmapNodeWidget extends StatefulWidget {
  final NodeModel node;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onAddChild;
  final VoidCallback onDelete;

  const MindmapNodeWidget({
    Key? key,
    required this.node,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onAddChild,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<MindmapNodeWidget> createState() => _MindmapNodeWidgetState();
}

class _MindmapNodeWidgetState extends State<MindmapNodeWidget> {
  bool _isHovered = false;

  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return const Color(0xFF4A90E2);
    }

    try {
      final hexString = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hexString', radix: 16));
    } catch (e) {
      return const Color(0xFF4A90E2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nodeColor = _parseColor(widget.node.color);
    final isRoot = widget.node.isRoot ?? false;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main node container
            Container(
              width: 170,
              height: 130,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    nodeColor.withOpacity(0.3),
                    nodeColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isSelected
                      ? nodeColor
                      : nodeColor.withOpacity(0.3),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: [
                  if (widget.isSelected || _isHovered)
                    BoxShadow(
                      color: nodeColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Stack(
                children: [
                  // AI badge for non-root nodes
                  if (!isRoot)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 10,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'AI',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Root badge for root node
                  if (isRoot)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Root',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Text(
                          widget.node.icon ?? '📝',
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 8),
                        // Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            widget.node.title ?? '',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _getTextColor(nodeColor),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons (show on hover or when selected)
            if (_isHovered || widget.isSelected)
              Positioned(
                top: -12,
                right: -12,
                child: Row(
                  children: [
                    // Add child button
                    _ActionButton(
                      icon: Icons.add,
                      color: Colors.green,
                      onTap: widget.onAddChild,
                    ),
                    const SizedBox(width: 4),
                    // Edit button
                    _ActionButton(
                      icon: Icons.edit,
                      color: Colors.blue,
                      onTap: widget.onEdit,
                    ),
                    const SizedBox(width: 4),
                    // Delete button
                    if (!isRoot)
                      _ActionButton(
                        icon: Icons.delete,
                        color: Colors.red,
                        onTap: widget.onDelete,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getTextColor(Color backgroundColor) {
    // Calculate luminance to determine if text should be light or dark
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }
}
