import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FolderChapterShimmer extends StatelessWidget {
  const FolderChapterShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = screenWidth * (isTablet ? 0.08 : 0.05);
    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      highlightColor: colorScheme.surfaceContainerHighest.withOpacity(0.2),
      child: Container(
        margin: EdgeInsets.fromLTRB(
          horizontalPadding,
          0,
          horizontalPadding,
          isTablet ? 14 : 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 16 : 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: isTablet ? 44 : 40,
                    height: isTablet ? 44 : 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                    ),
                  ),
                  SizedBox(width: isTablet ? 12 : 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(width: 100, height: 12, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 12 : 10),
              Container(
                width: double.infinity,
                height: 14,
                color: Colors.white,
              ),
              SizedBox(height: isTablet ? 14 : 12),
              Row(
                children: [
                  Container(width: 60, height: 24, color: Colors.white),
                  const SizedBox(width: 8),
                  Container(width: 60, height: 24, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FolderChapterWebShimmer extends StatelessWidget {
  const FolderChapterWebShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      highlightColor: colorScheme.surfaceContainerHighest.withOpacity(0.2),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(child: Container(height: 20, color: Colors.white)),
                const SizedBox(width: 12),
                Container(width: 60, height: 20, color: Colors.white),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(width: 200, height: 14, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Container(height: 12, color: Colors.white)),
                const SizedBox(width: 8),
                Container(width: 60, height: 24, color: Colors.white),
                const SizedBox(width: 8),
                Container(width: 60, height: 24, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
