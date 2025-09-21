import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.05,
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E10),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFF1C1C1E)),
      ),
      child: TextField(
        style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
        decoration: InputDecoration(
          hintText: 'Search folders and chapters...',
          hintStyle: TextStyle(
            color: const Color(0xFF8E8E93),
            fontSize: screenWidth * 0.04,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: const Color(0xFF8E8E93),
            size: screenWidth * 0.055,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
          filled: true,
          fillColor: const Color(0xFF0E0E10),
        ),
      ),
    );
  }
}
