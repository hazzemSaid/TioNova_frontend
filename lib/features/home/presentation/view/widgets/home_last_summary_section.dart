import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/home/presentation/view/widgets/SectionHeader.dart';
import 'package:tionova/features/home/presentation/view/widgets/SummaryCard.dart';

class HomeLastSummarySection extends StatelessWidget {
  final Map<String, dynamic>? lastSummary;
  final double horizontalPadding;
  final double verticalSpacing;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const HomeLastSummarySection({
    super.key,
    required this.lastSummary,
    required this.horizontalPadding,
    required this.verticalSpacing,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    if (lastSummary == null)
      return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          SizedBox(height: verticalSpacing * 2),
          SectionHeader(
            title: "Last Summary",
            actionText: "",
            actionIcon: Icons.description,
          ),
          SizedBox(height: verticalSpacing),
          SummaryCard(
            summary: lastSummary!,
            colorScheme: colorScheme,
            textTheme: textTheme,
            onTap: () {
              // Navigate to summary viewer
              // The passed summaryModel should be valid as checked by caller or this null check
              // We need to access model which is in the map
              final summaryModel =
                  lastSummary!['summaryModel']; // This logic was inside onTap in home_screen.dart
              context.push(
                '/summary-viewer',
                extra: {
                  'summaryData': summaryModel,
                  'chapterTitle': lastSummary!['title'],
                  'accentColor': colorScheme.primary,
                },
              );
            },
          ),
          SizedBox(height: verticalSpacing * 2),
        ]),
      ),
    );
  }
}
