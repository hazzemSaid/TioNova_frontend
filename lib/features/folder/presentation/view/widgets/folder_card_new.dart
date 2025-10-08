/*import 'package:flutter/material.dart';
import 'package:tionova/features/folder/data/models/ShareWithmodel.dart';

class FolderCard extends StatelessWidget {
  final String title;
  final String description;
  final String category;
  final String privacy;
  final int chapters;
  final String lastAccessed;
  final Color color;
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
    this.sharedWith,
  }) : super(key: key);

  Widget _buildTag(
    String text,
    Color bgColor,
    Color textColor,
    IconData? icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      privacyBgColor = const Color(0xFF2C2C2E);
      privacyTextColor = Colors.white;
      privacyIcon = Icons.lock;
    } else {
      privacyBgColor = const Color(0xFF2C2C2E);
      privacyTextColor = Colors.white;
      privacyIcon = Icons.group;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.folder, color: Colors.white, size: 24),
              ),
              const Spacer(),
              Row(
                children: [
                  _buildTag(category, categoryColor, Colors.white, null),
                  _buildTag(
                    privacy,
                    privacyBgColor,
                    privacyTextColor,
                    privacyIcon,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$chapters chapters',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.access_time_outlined,
                color: Color(0xFF8E8E93),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'Last accessed $lastAccessed',
                style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
              ),
              const Spacer(),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$chapters',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (privacy.toLowerCase() == 'shared' &&
              sharedWith != null &&
              sharedWith!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'Shared with:',
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                ...List.generate(
                  sharedWith!.length > 4 ? 4 : sharedWith!.length,
                  (i) => Container(
                    margin: const EdgeInsets.only(right: 4),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF232325),
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
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (sharedWith!.length > 4)
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
                      '+${sharedWith!.length - 4} more',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
*/
