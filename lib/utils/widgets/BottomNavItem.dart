import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BottomNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const BottomNavItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<BottomNavItem> createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<BottomNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSelected = widget.currentIndex == widget.index;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: InkWell(
            onTap: () {
              // Add haptic feedback for better touch experience
              HapticFeedback.lightImpact();

              // Play quick scale animation for visual feedback
              _animationController.forward().then((_) {
                _animationController.reverse();
              });

              widget.onTap();
            },
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
            splashColor: const Color(0xFF3C3C3E),
            highlightColor: const Color(0xFF3C3C3E).withOpacity(0.3),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.015, // Increased tap area height
              ),
              margin: EdgeInsets.all(
                screenWidth * 0.01,
              ), // Added margin for better tap separation
              decoration: isSelected
                  ? BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    )
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: isSelected ? Colors.white : const Color(0xFF8E8E93),
                    size: screenWidth * 0.05,
                  ),
                  SizedBox(width: screenWidth * 0.015),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF8E8E93),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
