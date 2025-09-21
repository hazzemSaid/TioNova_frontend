import 'package:flutter/material.dart';

class ChapterCard extends StatelessWidget {
  final String title;
  final String subject;
  final String status;
  final Color statusColor;
  final String days;

  const ChapterCard({
    super.key,
    required this.title,
    required this.subject,
    required this.status,
    required this.statusColor,
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.04,
                    height: 1.3,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Row(
                children: [
                  Container(
                    width: screenWidth * 0.025,
                    height: screenWidth * 0.025,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.008,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            subject,
            style: TextStyle(
              color: const Color(0xFF8E8E93),
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                days,
                style: TextStyle(
                  color: const Color(0xFF636366),
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    color: const Color(0xFF636366),
                    size: screenWidth * 0.035,
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  Text(
                    "Chapter",
                    style: TextStyle(
                      color: const Color(0xFF636366),
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
