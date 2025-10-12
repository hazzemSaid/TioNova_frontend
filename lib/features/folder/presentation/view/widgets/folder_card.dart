// features/folder/presentation/view/widgets/folder_card.dart
import 'package:flutter/material.dart';
import 'package:tionova/features/folder/data/models/ShareWithmodel.dart';

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
  final List<ShareWithmodel>? sharedWith;

  const FolderCard({
    super.key,
    required this.title,
    required this.description,
    required this.category,
    required this.privacy,
    required this.chapters,
    required this.lastAccessed,
    required this.color,
    this.icon,
    this.onTap,
    this.sharedWith,
  });

  Widget _buildTag(
    String text,
    Color bgColor,
    Color textColor,
    IconData? icon, {
    bool isTablet = false,
  }) {
    final double padding = isTablet ? 6.0 : 5.0;
    final double iconSize = isTablet ? 10.0 : 9.0;
    final double fontSize = isTablet ? 9.0 : 7.5;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: textColor),
            SizedBox(width: isTablet ? 4.0 : 3.0),
          ],
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    final isLargeScreen = screenWidth > 900;
    final isTablet = screenWidth > 600;
    final isSmallTablet = screenWidth > 600 && screenWidth < 750;
    final isSmallPhone = screenWidth < 360;

    // Adjusted sizing for better fit
    final double cardPadding = isLargeScreen
        ? 14.0
        : (isSmallTablet ? 10.0 : (isTablet ? 12.0 : 8.0));
    final double iconContainerSize = isLargeScreen
        ? 50.0
        : (isSmallTablet ? 38.0 : (isTablet ? 44.0 : 36.0));
    final double iconSize = isLargeScreen
        ? 24.0
        : (isSmallTablet ? 16.0 : (isTablet ? 18.0 : 16.0));
    final double titleSize = isLargeScreen
        ? 16.0
        : (isSmallTablet ? 12.0 : (isTablet ? 14.0 : 14.0));
    final double descriptionSize = isLargeScreen
        ? 12.0
        : (isSmallTablet ? 9.0 : (isTablet ? 10.0 : 13));
    final double metaSize = isLargeScreen
        ? 11.0
        : (isSmallTablet ? 9.0 : (isTablet ? 10.0 : 9.0));
    final double verticalSpacing = 10;

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

    final hasSharedSection =
        privacy.toLowerCase() == 'shared' &&
        sharedWith != null &&
        sharedWith!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E10),
          borderRadius: BorderRadius.circular(isTablet ? 12.0 : 10.0),
          border: Border.all(color: const Color(0xFF1C1C1E), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: isTablet ? 6.0 : 4.0,
              offset: const Offset(0, 3),
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
                Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(isTablet ? 9.0 : 8.0),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: isTablet ? 6.0 : 4.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color.withOpacity(0.4), color.withOpacity(0.15)],
                    ),
                  ),
                  child: Icon(
                    icon ?? Icons.folder,
                    color: Colors.white.withOpacity(0.9),
                    size: iconSize,
                  ),
                ),
                SizedBox(width: isTablet ? 8.0 : 6.0),
                Expanded(
                  child: Wrap(
                    spacing: 4.0,
                    runSpacing: 3.0,
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _buildTag(
                        category,
                        categoryColor,
                        Colors.white,
                        null,
                        isTablet: isTablet,
                      ),
                      if (privacy.isNotEmpty)
                        _buildTag(
                          privacy,
                          privacyBgColor,
                          privacyTextColor,
                          privacy == 'private' ? Icons.lock : Icons.group,
                          isTablet: isTablet,
                        ),
                      Text(
                        '$chapters chapters',
                        style: TextStyle(
                          color: const Color(0xFF8E8E93),
                          fontSize: isTablet ? 9.0 : 7.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: verticalSpacing),

            // Title
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),

            // Description (only show if not empty and space allows)
            if (description.isNotEmpty && !hasSharedSection) ...[
              SizedBox(height: verticalSpacing * 0.5),
              Text(
                description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF8E8E93),
                  fontSize: descriptionSize,
                  height: 1.2,
                ),
              ),
            ],

            const Spacer(),

            // Last accessed info
            Row(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  color: const Color(0xFF8E8E93),
                  size: metaSize + 1,
                ),
                SizedBox(width: isTablet ? 6.0 : 4.0),
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
              ],
            ),

            // Shared with section
            if (hasSharedSection) ...[
              SizedBox(height: verticalSpacing),
              Divider(
                thickness: 1,
                height: 1,
                color: Colors.white.withOpacity(0.08),
              ),
              SizedBox(height: verticalSpacing),
              Row(
                children: [
                  Text(
                    'Shared with:',
                    style: TextStyle(
                      color: const Color(0xFF8E8E93),
                      fontSize: isSmallPhone ? 9.0 : 10.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Row(
                      children: [
                        ...List.generate(
                          sharedWith!.length > 3 ? 3 : sharedWith!.length,
                          (i) => Container(
                            margin: const EdgeInsets.only(right: 3),
                            width: isSmallPhone ? 18 : 20,
                            height: isSmallPhone ? 18 : 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFF232325),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              sharedWith![i].username.isNotEmpty
                                  ? sharedWith![i].username
                                        .substring(0, 2)
                                        .toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallPhone ? 8.0 : 9.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (sharedWith!.length > 3)
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(left: 2),
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallPhone ? 4 : 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF232325),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '+${sharedWith!.length - 3}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallPhone ? 8.0 : 9.0,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
