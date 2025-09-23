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
    final screenSize = MediaQuery.sizeOf(context);
    final isTablet = screenSize.width > 600;
    final double padding = isTablet
        ? 16.0
        : 14.0; // Slightly reduced padding on tablet
    final double iconSize = isTablet
        ? 60.0
        : 56.0; // Slightly reduced for tablet
    final double titleSize = isTablet
        ? 15.0
        : 14.0; // Slightly reduced title size
    final double metaSize = isTablet
        ? 12.0
        : 11.0; // Slightly reduced meta size
    final double spacing = isTablet ? 8.0 : 6.0; // Reduced spacing on tablet
    final double? cardWidth = isTablet ? null : screenSize.width * 0.45;

    return Container(
      width: cardWidth,
      constraints: BoxConstraints(
        minWidth: isTablet ? 140.0 : 120.0, // Slightly wider on tablet
        maxHeight: isTablet
            ? 220.0
            : double.infinity, // Limit max height on tablet
      ),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E10),
        borderRadius: BorderRadius.circular(isTablet ? 16.0 : 14.0),
        border: Border.all(color: const Color(0xFF1C1C1E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(
                  16.0,
                ), // More rounded corners for larger icon
              ),
              child: Icon(
                Icons.folder_outlined,
                color: Colors.white,
                size:
                    iconSize *
                    0.7, // Slightly larger icon relative to container
              ),
            ),
          ),
          SizedBox(height: spacing * 1.5), // Slightly reduced space after icon
          if (!isTablet)
            const Spacer(), // Remove Spacer on tablet to prevent overflow
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: titleSize,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: spacing / 2),
          Text(
            chapters,
            style: TextStyle(
              color: const Color(0xFF8E8E93),
              fontSize: metaSize,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            days,
            style: TextStyle(
              color: const Color(0xFF636366),
              fontSize: metaSize - 1,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
