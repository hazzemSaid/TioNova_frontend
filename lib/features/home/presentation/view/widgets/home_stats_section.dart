import 'package:flutter/material.dart';
import 'package:tionova/features/home/presentation/view/widgets/StatisticsCard.dart';

class HomeStatsSection extends StatelessWidget {
  final List<Map<String, dynamic>> stats;
  final double horizontalPadding;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const HomeStatsSection({
    super.key,
    required this.stats,
    required this.horizontalPadding,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          return StatisticsCard(
            value: stats[index]['value'] as String,
            label: stats[index]['label'] as String,
            icon: stats[index]['icon'] as IconData,
            colorScheme: colorScheme,
            textTheme: textTheme,
          );
        }, childCount: stats.length),
      ),
    );
  }
}
