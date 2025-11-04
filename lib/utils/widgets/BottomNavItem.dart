import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BottomNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const BottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavItem> createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<BottomNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Stop and reset animation before disposing
    _animationController.stop();
    _animationController.reset();
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (_isDisposed || !mounted) return;

    try {
      // Add haptic feedback for better touch experience
      HapticFeedback.lightImpact();

      // Play quick scale animation for visual feedback
      if (!_isDisposed && mounted) {
        await _animationController.forward();
      }

      if (!_isDisposed && mounted) {
        await _animationController.reverse();
      }
    } catch (e) {
      // Silently catch any animation errors during disposal
      debugPrint('Animation error: $e');
    }

    // Call the onTap callback
    if (!_isDisposed && mounted) {
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.currentIndex == widget.index;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(12),
            splashColor: colorScheme.surfaceVariant.withOpacity(0.5),
            highlightColor: colorScheme.surfaceVariant.withOpacity(0.3),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: isSelected
                  ? BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(
                widget.icon,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                size: 26,
              ),
            ),
          ),
        );
      },
    );
  }
}
