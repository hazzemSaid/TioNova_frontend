import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isTablet = screenSize.width > 600;

    // Responsive dimensions
    final double height = isTablet ? 56.0 : 48.0;
    final double fontSize = isTablet ? 18.0 : 16.0;
    final double iconSize = isTablet ? 24.0 : 20.0;
    final double borderRadius = isTablet ? 16.0 : 12.0;
    final EdgeInsets contentPadding = isTablet
        ? const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0)
        : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: TextField(
        style: TextStyle(color: Colors.white, fontSize: fontSize, height: 1.2),
        decoration: InputDecoration(
          hintText: 'Search folders, chapters...',
          hintStyle: TextStyle(
            color: const Color(0xFF8E8E93),
            fontSize: fontSize,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: const Color(0xFF8E8E93),
            size: iconSize,
          ),
          contentPadding: contentPadding,
          filled: true,
          fillColor: Colors.transparent,
          isDense: true,
        ),
      ),
    );
  }
}
