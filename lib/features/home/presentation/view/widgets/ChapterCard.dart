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
    final screenSize = MediaQuery.sizeOf(context);
    final isTablet = screenSize.width > 600;
    
    // Responsive dimensions
    final double padding = isTablet ? 20.0 : 16.0;
    final double titleSize = isTablet ? 18.0 : 16.0;
    final double subjectSize = isTablet ? 15.0 : 13.0;
    final double metaSize = isTablet ? 13.0 : 11.0;
    final double spacing = isTablet ? 12.0 : 8.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E10),
        borderRadius: BorderRadius.circular(isTablet ? 16.0 : 14.0),
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
                    fontSize: titleSize,
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(width: spacing),
              Row(
                children: [
                  Container(
                    width: isTablet ? 10.0 : 8.0,
                    height: isTablet ? 10.0 : 8.0,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: spacing / 2),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 12.0 : 10.0,
                      vertical: isTablet ? 6.0 : 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: isTablet ? 12.0 : 10.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: spacing / 2),
          Text(
            subject,
            style: TextStyle(
              color: const Color(0xFF8E8E93),
              fontSize: subjectSize,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: spacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                days,
                style: TextStyle(
                  color: const Color(0xFF636366),
                  fontSize: metaSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    color: const Color(0xFF636366),
                    size: isTablet ? 16.0 : 14.0,
                  ),
                  SizedBox(width: spacing / 2),
                  Text(
                    "Chapter",
                    style: TextStyle(
                      color: const Color(0xFF636366),
                      fontSize: metaSize,
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
