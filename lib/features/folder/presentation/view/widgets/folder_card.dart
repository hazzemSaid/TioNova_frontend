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
    this.sharedWith,
  }) : super(key: key);

  Widget _buildTag(
    String text,
    Color bgColor,
    Color textColor,
    IconData? icon, {
    bool isTablet = false,
  }) {
    final double padding = isTablet ? 8.0 : 6.0;
    final double iconSize = isTablet ? 12.0 : 10.0;
    final double fontSize = isTablet ? 10.0 : 8.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
      margin: EdgeInsets.only(right: isTablet ? 6.0 : 4.0),
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

    final double cardPadding = isTablet ? 16.0 : (isLargeScreen ? 16.0 : 10.0);
    final double iconContainerSize = isLargeScreen
        ? 56.0
        : (isTablet ? 42.0 : 36.0);
    final double iconSize = isLargeScreen ? 28.0 : (isTablet ? 20.0 : 18.0);
    final double titleSize = isLargeScreen ? 20.0 : (isTablet ? 16.0 : 13.0);
    final double descriptionSize = isLargeScreen
        ? 14.0
        : (isTablet ? 12.0 : 9.0);
    final double metaSize = isLargeScreen ? 18.0 : (isTablet ? 12.0 : 10.0);

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
          ),
          border: Border.all(color: const Color(0xFF1C1C1E), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: isTablet ? 8.0 : (isLargeScreen ? 8.0 : 4.0),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(
                      isTablet ? 10.0 : (isLargeScreen ? 12.0 : 8.0),
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: isTablet ? 8.0 : 4.0,
                        offset: const Offset(0, 2),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: isTablet ? 4.0 : 2.0,
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
                      ),
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
                SizedBox(width: isTablet ? 10.0 : 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTag(
                            category,
                            categoryColor,
                            Colors.white,
                            null,
                            isTablet: isTablet,
                          ),
                          if (privacy.isNotEmpty) ...[
                            SizedBox(width: isTablet ? 6.0 : 4.0),
                            _buildTag(
                              privacy,
                              privacyBgColor,
                              privacyTextColor,
                              privacy == 'private' ? Icons.lock : Icons.group,
                              isTablet: isTablet,
                            ),
                          ],
                          if (privacy.toLowerCase() == 'shared') ...[
                            SizedBox(width: isTablet ? 6.0 : 4.0),
                            Text(
                              '$chapters chapters',
                              style: TextStyle(
                                color: const Color(0xFF8E8E93),
                                fontSize: isTablet ? 10.0 : 8.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: isTablet ? 6.0 : 4.0),
                            const Icon(
                              Icons.more_vert,
                              color: Color(0xFF8E8E93),
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 8.0 : (isLargeScreen ? 8.0 : 6.0)),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
                height: isLargeScreen ? 1.1 : 1.2,
              ),
            ),
            if (description.isNotEmpty) ...[
              SizedBox(height: isTablet ? 2.0 : (isLargeScreen ? 2.0 : 1.0)),
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
            SizedBox(height: isTablet ? 8.0 : (isLargeScreen ? 8.0 : 6.0)),
            if (privacy.toLowerCase() != 'shared')
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
                    width: isTablet ? 20.0 : 20.0,
                    height: isTablet ? 20.0 : 20.0,
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
            if (privacy.toLowerCase() == 'shared' &&
                sharedWith != null &&
                sharedWith!.isNotEmpty) ...[
              SizedBox(height: isTablet ? 8.0 : 6.0),
              Row(
                children: [
                  const Text(
                    'Shared with:',
                    style: TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Avatar list logic, showing up to 3 avatars + 'more' if applicable
                  ...List.generate(
                    sharedWith!.length > 3 ? 3 : sharedWith!.length,
                    (i) => Container(
                      margin: const EdgeInsets.only(right: 4),
                      width: 20,
                      height: 20,
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Display the '+X more' tag only if there are more than 3 users
                  if (sharedWith!.length > 3)
                    Container(
                      margin: const EdgeInsets.only(left: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF232325),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${sharedWith!.length - 3} more',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
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
