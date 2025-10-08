// Remove this line, it's not needed for DottedBorder

import 'package:flutter/material.dart';
import 'package:tionova/features/home/presentation/view/widgets/ChapterCard.dart';
import 'package:tionova/features/home/presentation/view/widgets/CreateFolderButton.dart';
import 'package:tionova/features/home/presentation/view/widgets/CustomHeaderDelegate.dart';
import 'package:tionova/features/home/presentation/view/widgets/FolderCard.dart';
import 'package:tionova/features/home/presentation/view/widgets/SearchBar.dart';
import 'package:tionova/features/home/presentation/view/widgets/SectionHeader.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';

// Home Screen with Slivers
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final topPadding = MediaQuery.of(context).padding.top;
    final bool isTablet = screenWidth > 600;
    final double horizontalPadding = screenWidth * (isTablet ? 0.08 : 0.05);
    final double verticalSpacing = screenHeight * 0.02;

    return Scaffold(
      backgroundColor: Colors.black,
      body: ScrollConfiguration(
        behavior: const NoGlowScrollBehavior(),
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            // Custom Header using SliverPersistentHeader
            SliverPersistentHeader(
              delegate: CustomHeaderDelegate(
                minHeight:
                    topPadding +
                    (isTablet
                        ? 60
                        : 80), // Further reduced min height for tablet
                maxHeight:
                    topPadding +
                    (isTablet
                        ? 70
                        : 100), // Further reduced max height for tablet
                screenWidth: screenWidth,
              ),
            ),

            // Main Content
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(height: verticalSpacing * 1.5),

                  // Search Bar
                  CustomSearchBar(),
                  SizedBox(height: verticalSpacing * 1.5),

                  // Create Folder Button
                  CreateFolderButton(),
                  SizedBox(height: verticalSpacing * 2),

                  // Recent Chapters Section
                  SectionHeader(
                    title: "Recent Chapters",
                    actionText: "Continue studying",
                    actionIcon: Icons.access_time,
                  ),
                  SizedBox(height: verticalSpacing),
                ]),
              ),
            ),

            // Chapter Cards using SliverList for better performance
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final chapters = [
                    {
                      'title': 'Binary Search Trees',
                      'subject': 'Computer Science',
                      'status': 'Passed',
                      'color': const Color(0xFF34C759),
                      'days': 'Last opened 606 days ago',
                    },
                    {
                      'title': 'Matrix Operations',
                      'subject': 'Mathematics',
                      'status': 'Failed',
                      'color': const Color(0xFFFF3B30),
                      'days': 'Last opened 607 days ago',
                    },
                    {
                      'title': 'Wave Functions',
                      'subject': 'Physics',
                      'status': 'Not Taken',
                      'color': const Color(0xFF8E8E93),
                      'days': 'Last opened 608 days ago',
                    },
                  ];

                  return Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                    child: ChapterCard(
                      title: chapters[index]['title'] as String,
                      subject: chapters[index]['subject'] as String,
                      status: chapters[index]['status'] as String,
                      statusColor: chapters[index]['color'] as Color,
                      days: chapters[index]['days'] as String,
                    ),
                  );
                }, childCount: 3),
              ),
            ),

            // Recent Folders Section
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(height: verticalSpacing * 2),
                  SectionHeader(
                    title: "Recent Folders",
                    actionText: "View All",
                    actionIcon: Icons.arrow_forward_ios,
                  ),
                  SizedBox(height: verticalSpacing),
                ]),
              ),
            ),

            // Folder Grid using SliverGrid for better performance
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = isTablet ? 3 : 2;
                  final childAspectRatio = isTablet ? 1.2 : 1.0;

                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: screenWidth * (isTablet ? 0.03 : 0.04),
                      mainAxisSpacing: screenHeight * 0.02,
                      childAspectRatio: childAspectRatio,
                      mainAxisExtent: isTablet ? 180 : 160,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final folders = [
                        {
                          'title': 'Computer Science',
                          'chapters': '12 chapters',
                          'days': '606 days ago',
                        },
                        {
                          'title': 'Mathematics',
                          'chapters': '8 chapters',
                          'days': '607 days ago',
                        },
                        {
                          'title': 'Physics',
                          'chapters': '15 chapters',
                          'days': '608 days ago',
                        },
                      ];
                      return FolderCardHome(
                        title: folders[index]['title']!,
                        chapters: folders[index]['chapters']!,
                        days: folders[index]['days']!,
                      );
                    }, childCount: 3),
                  );
                },
              ),
            ),

            // Minimal bottom spacing to avoid cramping
            SliverToBoxAdapter(child: SizedBox(height: 8)),
          ],
        ),
      ),
    );
  }
}
