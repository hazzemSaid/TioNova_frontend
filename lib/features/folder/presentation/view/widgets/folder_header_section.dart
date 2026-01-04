import 'package:flutter/material.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_tabs.dart';
import 'package:tionova/utils/widgets/page_header.dart';

class FolderHeaderSection extends StatelessWidget {
  final String selectedTab;
  final ValueChanged<String> onTabSelected;
  final double verticalSpacing;

  const FolderHeaderSection({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    required this.verticalSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(height: verticalSpacing * 1.5),
          const PageHeader(
            title: 'Folders',
            subtitle: 'Organize and manage your study folders',
          ),
          SizedBox(height: verticalSpacing * 1.5),
          FolderTabs(
            tabs: const ['My Folders', 'Public Folders'],
            selectedTab: selectedTab,
            onTabSelected: onTabSelected,
          ),
          SizedBox(height: verticalSpacing),
        ],
      ),
    );
  }
}
