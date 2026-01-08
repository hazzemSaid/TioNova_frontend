// features/folder/presentation/view/widgets/folder_card.dart
import 'package:flutter/material.dart';
import 'package:tionova/features/chapter/data/models/ShareWithmodel.dart';

class FolderCard extends StatelessWidget {
  final String title;
  final String description;
  final String privacy;
  final int chapters;
  final String lastAccessed;
  final Color color;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final List<ShareWithmodel>? sharedWith;

  const FolderCard({
    super.key,
    required this.title,
    required this.description,
    required this.privacy,
    required this.chapters,
    required this.lastAccessed,
    required this.color,
    this.icon,
    this.onTap,
    this.onLongPress,
    this.sharedWith,
  });

  // Responsive breakpoints
  bool _isLargeScreen(double width) => width > 900;
  bool _isTablet(double width) => width > 600;
  bool _isSmallPhone(double width) => width < 360;

  // Get category color based on category name

  // Get privacy colors and icon
  Map<String, dynamic> _getPrivacyConfig(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPrivate = privacy.toLowerCase() == 'private';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return {
      'bgColor':
          (isPrivate
                  ? colorScheme.errorContainer
                  : colorScheme.secondaryContainer)
              .withOpacity(isDark ? 0.25 : 0.55),
      'textColor': isPrivate
          ? colorScheme.onErrorContainer
          : colorScheme.onSecondaryContainer,
      'icon': isPrivate ? Icons.lock_outline : Icons.group_outlined,
    };
  }

  // Check if we should show the shared section
  bool _hasSharedSection() {
    return privacy.toLowerCase() == 'shared' &&
        sharedWith != null &&
        sharedWith!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final isLarge = _isLargeScreen(screenWidth);
    final isTablet = _isTablet(screenWidth);
    final isSmallPhone = _isSmallPhone(screenWidth);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(isTablet ? 16.0 : 12.0),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.06),
              blurRadius: isTablet ? 16.0 : 12.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 12.0 : 10.0,
          vertical: isTablet ? 12.0 : (isSmallPhone ? 6.0 : 10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, isLarge, isTablet, isSmallPhone),
            SizedBox(height: isTablet ? 10.0 : (isSmallPhone ? 4.0 : 8.0)),
            _buildContent(context, isLarge, isTablet, isSmallPhone),
            SizedBox(height: isTablet ? 10.0 : (isSmallPhone ? 4.0 : 8.0)),
            _buildFooter(context, isLarge, isTablet, isSmallPhone),
          ],
        ),
      ),
    );
  }

  // Header with icon and tags
  Widget _buildHeader(
    BuildContext context,
    bool isLarge,
    bool isTablet,
    bool isSmallPhone,
  ) {
    final iconSize = isLarge
        ? 52.0
        : (isTablet ? 48.0 : (isSmallPhone ? 40.0 : 44.0));
    final innerIconSize = isLarge
        ? 26.0
        : (isTablet ? 22.0 : (isSmallPhone ? 18.0 : 20.0));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Folder icon with gradient
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isTablet ? 12.0 : 10.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.25), color.withOpacity(0.1)],
            ),
            border: Border.all(color: color.withOpacity(0.3), width: 1.0),
          ),
          child: Icon(
            icon ?? Icons.folder_rounded,
            color: color,
            size: innerIconSize,
          ),
        ),
        SizedBox(width: isTablet ? 12.0 : 10.0),
        // Tags
        Expanded(
          child: Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (privacy.isNotEmpty) _buildPrivacyTag(context, isTablet),
            ],
          ),
        ),
      ],
    );
  }

  // Content section with title and description
  Widget _buildContent(
    BuildContext context,
    bool isLarge,
    bool isTablet,
    bool isSmallPhone,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleSize = isLarge ? 16.0 : (isTablet ? 15.0 : 14.0);
    final descSize = isLarge ? 12.0 : (isTablet ? 11.0 : 11.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: titleSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        // Description (only if no shared section)
        if (description.isNotEmpty && !_hasSharedSection()) ...[
          const SizedBox(height: 4.0),
          Text(
            description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.9),
              fontSize: descSize,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  // Footer with metadata
  Widget _buildFooter(
    BuildContext context,
    bool isLarge,
    bool isTablet,
    bool isSmallPhone,
  ) {
    final hasShared = _hasSharedSection();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chapters and last accessed
        _buildMetaRow(context, isLarge, isTablet, isSmallPhone),
        // Shared section
        if (hasShared) ...[
          SizedBox(height: isTablet ? 8.0 : (isSmallPhone ? 3.0 : 6.0)),
          Divider(
            thickness: 0.5,
            height: 0.5,
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withOpacity(0.3),
          ),
          SizedBox(height: isTablet ? 8.0 : (isSmallPhone ? 3.0 : 6.0)),
          _buildSharedSection(context, isTablet, isSmallPhone),
        ],
      ],
    );
  }

  // Meta information row
  Widget _buildMetaRow(
    BuildContext context,
    bool isLarge,
    bool isTablet,
    bool isSmallPhone,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final metaSize = isLarge
        ? 12.0
        : (isTablet ? 11.0 : (isSmallPhone ? 10.0 : 10.5));
    final iconSize = isLarge
        ? 16.0
        : (isTablet ? 15.0 : (isSmallPhone ? 13.0 : 14.0));

    return Row(
      children: [
        // Chapters count
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 8.0 : (isSmallPhone ? 6.0 : 7.0),
            vertical: isTablet ? 5.0 : (isSmallPhone ? 3.0 : 4.0),
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.7),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.library_books_outlined,
                color: colorScheme.onSurfaceVariant,
                size: iconSize,
              ),
              const SizedBox(width: 4.0),
              Text(
                '$chapters',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: metaSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8.0),
        // Last accessed
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.access_time_outlined,
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                size: iconSize,
              ),
              const SizedBox(width: 4.0),
              Expanded(
                child: Text(
                  lastAccessed,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                    fontSize: metaSize,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Shared with section
  Widget _buildSharedSection(
    BuildContext context,
    bool isTablet,
    bool isSmallPhone,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatarSize = isSmallPhone ? 22.0 : (isTablet ? 28.0 : 26.0);
    final fontSize = isSmallPhone ? 9.5 : (isTablet ? 11.0 : 10.5);

    return Row(
      children: [
        Text(
          'Shared with:',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: isSmallPhone ? 6.0 : 8.0),
        Expanded(
          child: Row(
            children: [
              // Avatar list
              ...List.generate(
                sharedWith!.length > 3 ? 3 : sharedWith!.length,
                (i) => _buildAvatar(
                  context,
                  sharedWith![i].username,
                  avatarSize,
                  i,
                  isSmallPhone,
                ),
              ),
              // More count
              if (sharedWith!.length > 3)
                _buildMoreCount(
                  context,
                  sharedWith!.length - 3,
                  avatarSize,
                  isSmallPhone,
                ),
            ],
          ),
        ),
      ],
    );
  }

  // User avatar
  Widget _buildAvatar(
    BuildContext context,
    String username,
    double size,
    int index,
    bool isSmallPhone,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradientColors = [
      [Colors.purple, Colors.deepPurple],
      [Colors.blue, Colors.indigo],
      [Colors.green, Colors.teal],
    ];

    return Container(
      margin: EdgeInsets.only(
        right: index < 2 ? (isSmallPhone ? 3.0 : 4.0) : 0,
      ),
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors[index % 3],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.surface,
          width: isSmallPhone ? 1.5 : 2.0,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        username.isNotEmpty ? username.substring(0, 1).toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: isSmallPhone ? 9.0 : 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // More users count badge
  Widget _buildMoreCount(
    BuildContext context,
    int count,
    double size,
    bool isSmallPhone,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(left: 4.0),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 6.0 : 8.0,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1.0,
        ),
      ),
      child: Text(
        '+$count',
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: isSmallPhone ? 10.0 : 11.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // Generic tag widget
  Widget _buildTag(
    BuildContext context,
    String text,
    Color bgColor,
    Color textColor,
    IconData? icon,
    bool isTablet,
  ) {
    final padding = isTablet ? 8.0 : 7.0;
    final iconSize = isTablet ? 12.0 : 11.0;
    final fontSize = isTablet ? 10.5 : 9.5;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: padding * 0.5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: textColor),
            const SizedBox(width: 4.0),
          ],
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // Privacy tag widget
  Widget _buildPrivacyTag(BuildContext context, bool isTablet) {
    final config = _getPrivacyConfig(context);
    return _buildTag(
      context,
      privacy,
      config['bgColor'],
      config['textColor'],
      config['icon'],
      isTablet,
    );
  }
}
