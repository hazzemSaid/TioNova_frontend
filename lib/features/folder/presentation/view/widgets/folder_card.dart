// features/folder/presentation/view/widgets/folder_card.dart
import 'package:flutter/material.dart';

class FolderCard extends StatelessWidget {
  final String title;
  final String description;
  final String category;
  final String privacy;
  final int chapters;
  final String lastAccessed;
  final Color color;
  final IconData? icon;
  final VoidCallback? onTap;

  const FolderCard({
    Key? key,
    required this.title,
    required this.description,
    required this.category,
    required this.privacy,
    required this.chapters,
    required this.lastAccessed,
    required this.color,
    this.icon,
    this.onTap,
  }) : super(key: key);

  Widget _buildTag(
    String text,
    Color bgColor,
    Color textColor,
    IconData? icon, {
    bool isTablet = false,
  }) {
    final double padding = isTablet ? 8.0 : 6.0; // Smaller padding on tablet
    final double iconSize = isTablet ? 12.0 : 10.0; // Smaller icon
    final double fontSize = isTablet ? 10.0 : 8.0; // Smaller font

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
      margin: EdgeInsets.only(right: isTablet ? 6.0 : 4.0), // Smaller margin
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: textColor),
            SizedBox(width: isTablet ? 6.0 : 4.0),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLargeScreen = screenSize.width > 900;

    // Responsive sizing - Keep tablet compact, make phone ultra-compact
    final double cardPadding = isTablet
        ? 16.0
        : (isLargeScreen ? 16.0 : 10.0); // Minimal padding for phone
    final double iconContainerSize = isLargeScreen
        ? 56.0
        : (isTablet ? 42.0 : 36.0); // Smaller on phone
    final double iconSize = isLargeScreen
        ? 28.0
        : (isTablet ? 20.0 : 18.0); // Compact icon for phone
    final double titleSize = isLargeScreen
        ? 20.0
        : (isTablet ? 16.0 : 13.0); // Smaller title on phone
    final double descriptionSize = isLargeScreen
        ? 14.0
        : (isTablet ? 12.0 : 9.0); // Compact text for phone
    final double metaSize = isLargeScreen
        ? 18.0
        : (isTablet ? 12.0 : 10.0); // Compact meta text for phone

    Color categoryColor;
    switch (category) {
      case 'Technology':
        categoryColor = const Color(0xFF007AFF);
        break;
      case 'Science':
        categoryColor = const Color(0xFF34C759);
        break;
      default:
        categoryColor = const Color(0xFF8E8E93);
    }

    Color privacyBgColor;
    Color privacyTextColor;
    IconData? privacyIcon;
    if (privacy.toLowerCase() == 'private') {
      privacyBgColor = const Color(0xFF1C1C1E);
      privacyTextColor = Colors.white;
      privacyIcon = Icons.lock;
    } else {
      privacyBgColor = const Color(0xFF1C1C1E);
      privacyTextColor = Colors.white;
      privacyIcon = Icons.group;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E10),
          borderRadius: BorderRadius.circular(
            isTablet ? 14.0 : (isLargeScreen ? 16.0 : 10.0),
          ), // Compact phone radius
          border: Border.all(color: const Color(0xFF1C1C1E), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: isTablet
                  ? 8.0
                  : (isLargeScreen ? 8.0 : 4.0), // Compact phone shadow
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row with icon and tags
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Folder icon with gradient
                Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(
                      isTablet ? 10.0 : (isLargeScreen ? 12.0 : 8.0),
                    ), // Compact phone radius
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: isTablet ? 8.0 : 4.0, // Smaller shadow
                        offset: const Offset(0, 2),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: isTablet ? 4.0 : 2.0, // Smaller shadow
                        offset: const Offset(0, 1),
                      ),
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color.withOpacity(0.4), color.withOpacity(0.15)],
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        isTablet ? 10.0 : (isLargeScreen ? 12.0 : 8.0),
                      ), // Compact phone inner radius
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Icon(
                      icon ?? Icons.folder,
                      color: Colors.white.withOpacity(0.9),
                      size: iconSize,
                    ),
                  ),
                ),

                SizedBox(width: isTablet ? 10.0 : 8.0), // Ultra compact spacing
                // Tags (category and privacy)
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTag(
                          category,
                          categoryColor,
                          Colors.white,
                          null,
                          isTablet: isTablet,
                        ),
                        if (privacy.isNotEmpty) ...[
                          SizedBox(
                            width: isTablet ? 6.0 : 4.0,
                          ), // Smaller spacing
                          _buildTag(
                            privacy,
                            privacyBgColor,
                            privacyTextColor,
                            privacyIcon,
                            isTablet: isTablet,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content spacing
            SizedBox(
              height: isTablet ? 8.0 : (isLargeScreen ? 8.0 : 6.0),
            ), // Compact phone spacing
            // Title
            Text(
              title,
              maxLines: 1, // Single line only
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
                height: isLargeScreen ? 1.1 : 1.2, // Tighter on smaller screens
              ),
            ),

            // Description spacing
            if (description.isNotEmpty) ...[
              SizedBox(
                height: isTablet ? 2.0 : (isLargeScreen ? 2.0 : 1.0),
              ), // Minimal phone spacing
              Text(
                description,
                maxLines: 1, // Max 1 line on all devices
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF8E8E93),
                  fontSize: descriptionSize,
                  height: 1.2, // Tight line height
                ),
              ),
            ],

            // Footer spacing
            SizedBox(
              height: isTablet ? 8.0 : (isLargeScreen ? 8.0 : 6.0),
            ), // Compact phone spacing
            // Footer with last accessed and chapter count
            Row(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  color: const Color(0xFF8E8E93),
                  size: metaSize + 2,
                ),
                SizedBox(width: isTablet ? 8.0 : 6.0),
                Expanded(
                  child: Text(
                    'Last accessed $lastAccessed',
                    style: TextStyle(
                      color: const Color(0xFF8E8E93),
                      fontSize: metaSize,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: isTablet ? 8.0 : 6.0),
                Container(
                  width: isTablet ? 20.0 : 20.0, // Ultra compact counter
                  height: isTablet ? 20.0 : 20.0, // Ultra compact counter
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 0.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$chapters',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: metaSize - 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
