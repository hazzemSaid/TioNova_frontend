import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FolderShimmerList extends StatelessWidget {
  const FolderShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Better breakpoints for different device sizes
    final isLargeScreen = screenWidth > 900;
    final isTablet = screenWidth > 600;
    final isSmallPhone = screenWidth < 360;

    // Dynamic cross axis count based on screen width
    int crossAxisCount;
    double horizontalPadding;
    double crossAxisSpacing;
    double mainAxisSpacing;
    double childAspectRatio;

    if (isLargeScreen || isTablet) {
      // Tablets (2 columns)
      crossAxisCount = 2;
      horizontalPadding = screenWidth * 0.06;
      crossAxisSpacing = 16;
      mainAxisSpacing = 16;
      childAspectRatio = 2;
    } else if (isSmallPhone) {
      // Small phones (1 column)
      crossAxisCount = 1;
      horizontalPadding = screenWidth * 0.04;
      crossAxisSpacing = 0;
      mainAxisSpacing = 12;
      childAspectRatio = 2.4;
    } else {
      // Regular phones (1 column)
      crossAxisCount = 1;
      horizontalPadding = screenWidth * 0.05;
      crossAxisSpacing = 0;
      mainAxisSpacing = 14;
      childAspectRatio = 2.5;
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isTablet ? 15 : 12,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return const ShimmerFolderCard();
          },
          childCount: 6, // Show 6 shimmer items
        ),
      ),
    );
  }
}

class ShimmerFolderCard extends StatelessWidget {
  const ShimmerFolderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 200,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
