import 'package:flutter/material.dart';

class FolderCard extends StatelessWidget {
  final String title;
  final String chapters;
  final String days;

  const FolderCard({
    super.key,
    required this.title,
    required this.chapters,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.045),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E10),
        borderRadius: BorderRadius.circular(screenWidth * 0.035),
        border: Border.all(color: const Color(0xFF1C1C1E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: screenWidth * 0.12,
            height: screenWidth * 0.12,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
            child: Icon(
              Icons.folder_outlined,
              color: Colors.white,
              size: screenWidth * 0.06,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.04,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  chapters,
                  style: TextStyle(
                    color: const Color(0xFF8E8E93),
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: screenHeight * 0.002),
                Text(
                  days,
                  style: TextStyle(
                    color: const Color(0xFF636366),
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
