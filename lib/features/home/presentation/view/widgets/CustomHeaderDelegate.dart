// Custom Header Delegate for Sliver
import 'package:flutter/material.dart';

class CustomHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final double screenWidth;

  CustomHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.screenWidth,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    return SizedBox(
      height: maxHeight,
      child: Container(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  !isDarkMode
                      ? 'assets/images/logo1.png'
                      : 'assets/images/logo2.png',
                  width: screenWidth * 0.25,
                  fit: BoxFit.contain,
                ),
                Container(
                  width: screenWidth * 0.11,
                  height: screenWidth * 0.11,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(screenWidth * 0.025),
                  ),
                  child: Icon(
                    Icons.wb_sunny_outlined,
                    color: colorScheme.onSurface,
                    size: screenWidth * 0.055,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Text(
          'Challenges Screen',
          style:
              theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onBackground,
              ) ??
              TextStyle(
                color: colorScheme.onBackground,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
