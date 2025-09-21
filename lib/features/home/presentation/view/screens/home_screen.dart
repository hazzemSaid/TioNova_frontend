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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

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
                minHeight: topPadding + 80,
                maxHeight: topPadding + 80,
                screenWidth: screenWidth,
              ),
            ),

            // Main Content
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(height: screenHeight * 0.025),

                  // Search Bar
                  CustomSearchBar(),
                  SizedBox(height: screenHeight * 0.025),

                  // Create Folder Button
                  CreateFolderButton(),
                  SizedBox(height: screenHeight * 0.04),

                  // Recent Chapters Section
                  SectionHeader(
                    title: "Recent Chapters",
                    actionText: "Continue studying",
                    actionIcon: Icons.access_time,
                  ),
                  SizedBox(height: screenHeight * 0.02),
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
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(height: screenHeight * 0.04),
                  SectionHeader(
                    title: "Recent Folders",
                    actionText: "View All",
                    actionIcon: Icons.arrow_forward_ios,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ]),
              ),
            ),

            // Folder Grid using SliverGrid for better performance
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.crossAxisExtent > 600
                      ? 3
                      : 2;
                  final childAspectRatio = constraints.crossAxisExtent > 600
                      ? 1.2
                      : 1.0;

                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: screenWidth * 0.04,
                      mainAxisSpacing: screenHeight * 0.02,
                      childAspectRatio: childAspectRatio,
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
                      return FolderCard(
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
