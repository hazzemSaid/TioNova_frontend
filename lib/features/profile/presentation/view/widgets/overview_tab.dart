import 'package:flutter/material.dart';
import 'package:tionova/features/profile/data/models/profile_model.dart';
import 'package:tionova/features/profile/presentation/view/widgets/insight_row.dart';
import 'package:tionova/features/profile/presentation/view/widgets/section_card.dart';
import 'package:tionova/features/profile/presentation/view/widgets/stat_row.dart';

class OverviewTab extends StatelessWidget {
  final double screenHeight;
  final Profile profile;
  const OverviewTab({
    super.key,
    required this.screenHeight,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionCard(
              title: 'Today',
              icon: Icons.trending_up,
              children: [
                StatRow(
                  label1: 'Chapters',
                  value1: profile.overview.today.chapters.toString(),
                  label2: 'Quizzes',
                  value2: profile.overview.today.quizzes.toString(),
                  trailing: '${10}m',
                  trailingLabel: 'Time',
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.015),
            SectionCard(
              title: 'This Month',
              icon: Icons.calendar_today,
              children: [
                StatRow(
                  label1: 'Time',
                  value1: '${10}h',
                  label2: 'Chapters',
                  value2: profile.overview.thisMonth.chapters.toString(),
                  trailing: profile.studyInsights.quizSuccessRate
                      .toStringAsFixed(0),
                  trailingLabel: '% Success',
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.015),
            SectionCard(
              title: 'Study Insights',
              icon: Icons.bar_chart,
              children: [
                InsightRow(
                  label: 'Total Folders',
                  subtitle: 'Organized materials',
                  value: profile.studyInsights.totalFolders.toString(),
                  icon: Icons.folder_outlined,
                ),
                const SizedBox(height: 2),
                InsightRow(
                  label: 'Quizzes Completed',
                  subtitle: 'Assessments',
                  value: profile.totalQuizzesTaken.toString(),
                  icon: Icons.quiz_outlined,
                ),
                const SizedBox(height: 2),
                InsightRow(
                  label: 'Quiz Success Rate',
                  subtitle: 'Average performance',
                  value:
                      '${profile.studyInsights.quizSuccessRate.toStringAsFixed(1)}%',
                  icon: Icons.pie_chart_outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
