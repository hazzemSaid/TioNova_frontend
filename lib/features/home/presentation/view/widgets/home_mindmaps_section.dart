import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/home/presentation/view/widgets/MindMapCard.dart';
import 'package:tionova/features/home/presentation/view/widgets/SectionHeader.dart';

class HomeMindMapsSection extends StatelessWidget {
  final List<Map<String, dynamic>> mindMaps;
  final double horizontalPadding;
  final double verticalSpacing;
  final double screenHeight;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const HomeMindMapsSection({
    super.key,
    required this.mindMaps,
    required this.horizontalPadding,
    required this.verticalSpacing,
    required this.screenHeight,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    if (mindMaps.isEmpty)
      return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SectionHeader(
                title: "Recent Mind Maps",
                actionText: "View All",
                actionIcon: Icons.arrow_forward_ios,
              ),
              SizedBox(height: verticalSpacing),
            ]),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final mindMap = mindMaps[index];
              return Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                child: MindMapCard(
                  mindMap: mindMap,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  onTap: () {
                    final mindmapModel = mindMap['mindmapModel'];
                    if (mindmapModel != null) {
                      context.push(
                        '/mindmap-viewer',
                        extra: {'mindmap': mindmapModel},
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mind map data not found.'),
                        ),
                      );
                    }
                  },
                ),
              );
            }, childCount: mindMaps.length),
          ),
        ),
      ],
    );
  }
}
