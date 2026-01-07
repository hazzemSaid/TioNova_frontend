import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/data/models/mindmapmodel.dart';
import 'package:tionova/features/home/data/models/analysisModel.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';

class HoverTransform extends StatefulWidget {
  final Widget child;
  const HoverTransform({super.key, required this.child});

  @override
  State<HoverTransform> createState() => _HoverTransformState();
}

class _HoverTransformState extends State<HoverTransform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.015,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            filterQuality: FilterQuality.high,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class HomeWebLayout extends StatelessWidget {
  final ThemeData theme;
  final Analysismodel analysisData;
  final List<Map<String, dynamic>> stats;
  final List<ChapterModel> chapters;
  final List<Map<String, dynamic>> folders;
  final Map<String, dynamic>? lastSummary;
  final List<Map<String, dynamic>> mindMaps;
  final Map<String, dynamic> todayProgress;
  final VoidCallback onRefresh;

  const HomeWebLayout({
    super.key,
    required this.theme,
    required this.analysisData,
    required this.stats,
    required this.chapters,
    required this.folders,
    required this.lastSummary,
    required this.mindMaps,
    required this.todayProgress,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final maxContentWidth = 1400.0;
        final horizontalPadding = availableWidth > maxContentWidth
            ? (availableWidth - maxContentWidth) / 2
            : 48.0;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: RefreshIndicator(
            onRefresh: () async => onRefresh(),
            color: colorScheme.primary,
            child: ScrollConfiguration(
              behavior: const NoGlowScrollBehavior(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Header Section
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        24,
                        horizontalPadding,
                        16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back! 👋',
                            style: textTheme.headlineLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Here\'s your learning progress',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Today's Progress Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: _buildTodayProgressCard(
                        colorScheme,
                        textTheme,
                        todayProgress,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Statistics Grid (2x2)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: _buildStatisticsSection(
                        colorScheme,
                        textTheme,
                        stats,
                        availableWidth,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Main Content: Two Columns
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: availableWidth > 1000
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Column: Chapters and Folders
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (chapters.isNotEmpty) ...[
                                        _buildSectionHeader(
                                          'Recent Chapters',
                                          colorScheme,
                                          textTheme,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildChaptersSection(
                                          chapters,
                                          colorScheme,
                                          textTheme,
                                          context,
                                        ),
                                        const SizedBox(height: 24),
                                      ],
                                      if (folders.isNotEmpty) ...[
                                        _buildSectionHeader(
                                          'Your Folders',
                                          colorScheme,
                                          textTheme,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildFoldersSection(
                                          folders,
                                          colorScheme,
                                          textTheme,
                                          context,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Right Column: Sidebar
                                SizedBox(
                                  width: 280,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (lastSummary != null) ...[
                                        _buildSectionHeader(
                                          'Latest Summary',
                                          colorScheme,
                                          textTheme,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildSummaryCard(
                                          lastSummary!,
                                          colorScheme,
                                          textTheme,
                                          context,
                                        ),
                                        const SizedBox(height: 32),
                                      ],
                                      if (mindMaps.isNotEmpty) ...[
                                        _buildSectionHeader(
                                          'Mind Maps',
                                          colorScheme,
                                          textTheme,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildMindMapsSection(
                                          mindMaps,
                                          colorScheme,
                                          textTheme,
                                          context,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (chapters.isNotEmpty) ...[
                                  _buildSectionHeader(
                                    'Recent Chapters',
                                    colorScheme,
                                    textTheme,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildChaptersSection(
                                    chapters,
                                    colorScheme,
                                    textTheme,
                                    context,
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                if (folders.isNotEmpty) ...[
                                  _buildSectionHeader(
                                    'Your Folders',
                                    colorScheme,
                                    textTheme,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFoldersSection(
                                    folders,
                                    colorScheme,
                                    textTheme,
                                    context,
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                if (lastSummary != null) ...[
                                  _buildSectionHeader(
                                    'Latest Summary',
                                    colorScheme,
                                    textTheme,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSummaryCard(
                                    lastSummary!,
                                    colorScheme,
                                    textTheme,
                                    context,
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                if (mindMaps.isNotEmpty) ...[
                                  _buildSectionHeader(
                                    'Mind Maps',
                                    colorScheme,
                                    textTheme,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildMindMapsSection(
                                    mindMaps,
                                    colorScheme,
                                    textTheme,
                                    context,
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodayProgressCard(
    ColorScheme colorScheme,
    TextTheme textTheme,
    Map<String, dynamic> data,
  ) {
    final completed = data['completed'] as int? ?? 0;
    final total = data['total'] as int? ?? 1;
    final percentage = (completed / total * 100).toStringAsFixed(0);

    return HoverTransform(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.primaryContainer.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Progress Circle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: completed / total,
                      strokeWidth: 8,
                      backgroundColor: colorScheme.surface,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$percentage%',
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        'Complete',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Progress Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Today\'s Progress',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildProgressItem(
                        '${data['chapters'] ?? 0}',
                        'Chapters',
                        Icons.book_outlined,
                        colorScheme,
                        textTheme,
                      ),
                      const SizedBox(width: 32),
                      _buildProgressItem(
                        '${data['quizzes'] ?? 0}',
                        'Quizzes',
                        Icons.quiz_outlined,
                        colorScheme,
                        textTheme,
                      ),
                      const SizedBox(width: 32),
                      _buildProgressItem(
                        '${data['studyTime'] ?? 0}m',
                        'Study Time',
                        Icons.schedule_outlined,
                        colorScheme,
                        textTheme,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(
    String value,
    String label,
    IconData icon,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection(
    ColorScheme colorScheme,
    TextTheme textTheme,
    List<Map<String, dynamic>> stats,
    double availableWidth,
  ) {
    final crossAxisCount = availableWidth > 1200
        ? 4
        : (availableWidth > 900 ? 3 : 2);
    final childAspectRatio = availableWidth > 1200
        ? 2.5
        : (availableWidth > 900 ? 2.2 : 2.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _buildStatCard(
              stat['value'] as String,
              stat['label'] as String,
              stat['icon'] as IconData,
              colorScheme,
              textTheme,
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return HoverTransform(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface,
              colorScheme.primaryContainer.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: colorScheme.primary),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                value,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Text(
      title,
      style: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildChaptersSection(
    List<ChapterModel> chapters,
    ColorScheme colorScheme,
    TextTheme textTheme,
    BuildContext context,
  ) {
    return Column(
      children: chapters.take(3).map((chapter) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildChapterCard(chapter, colorScheme, textTheme, context),
        );
      }).toList(),
    );
  }

  Widget _buildChapterCard(
    ChapterModel chapter,
    ColorScheme colorScheme,
    TextTheme textTheme,
    BuildContext context,
  ) {
    return HoverTransform(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface,
              colorScheme.primaryContainer.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chapter.title ?? 'Untitled Chapter',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Text(
              chapter.description ?? 'No description',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final folderId = chapter.folderId ?? '';
                  context.push(
                    '/folders/$folderId/chapters/${chapter.id}',
                    extra: {
                      'chapter': chapter,
                      'folderColor': colorScheme.primary,
                      'folderId': folderId,
                    },
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Read', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoldersSection(
    List<Map<String, dynamic>> folders,
    ColorScheme colorScheme,
    TextTheme textTheme,
    BuildContext context,
  ) {
    return Column(
      children: folders.take(2).map((folder) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildFolderCard(folder, colorScheme, textTheme, context),
        );
      }).toList(),
    );
  }

  Widget _buildFolderCard(
    Map<String, dynamic> folder,
    ColorScheme colorScheme,
    TextTheme textTheme,
    BuildContext context,
  ) {
    return HoverTransform(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface,
              colorScheme.primaryContainer.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  color: colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    folder['name'] as String? ?? 'Unnamed',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${folder['chapters'] ?? 0} chapters',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push(
                    '/folders/${folder['id']}',
                    extra: {
                      'title': folder['name'] as String? ?? 'Folder',
                      'subtitle': folder['subtitle'] as String? ?? '',
                      'chapters': folder['chapters'] as int? ?? 0,
                      'passed': folder['passed'] as int? ?? 0,
                      'attempted': folder['attempted'] as int? ?? 0,
                      'ownerId': folder['ownerId'] as String? ?? '',
                    },
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: const Text('View', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    Map<String, dynamic> summary,
    ColorScheme colorScheme,
    TextTheme textTheme,
    BuildContext context,
  ) {
    return HoverTransform(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface,
              colorScheme.tertiaryContainer.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary['title'] as String? ?? 'Summary',
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              summary['content'] as String? ?? 'No content',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 9,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  final summaryModel = summary['summaryModel'] as SummaryModel?;
                  final chapterTitle = summary['title'] as String? ?? 'Summary';

                  if (summaryModel != null) {
                    context.push(
                      '/summary-viewer',
                      extra: {
                        'summaryData': summaryModel,
                        'chapterTitle': chapterTitle,
                        'accentColor': colorScheme.primary,
                      },
                    );
                  }
                },
                icon: const Icon(Icons.visibility, size: 14),
                label: const Text('View', style: TextStyle(fontSize: 10)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMindMapsSection(
    List<Map<String, dynamic>> mindMaps,
    ColorScheme colorScheme,
    TextTheme textTheme,
    BuildContext context,
  ) {
    return Column(
      children: mindMaps.take(3).map((mindMap) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildMindMapCard(mindMap, colorScheme, textTheme, context),
        );
      }).toList(),
    );
  }

  Widget _buildMindMapCard(
    Map<String, dynamic> mindMap,
    ColorScheme colorScheme,
    TextTheme textTheme,
    BuildContext context,
  ) {
    return InkWell(
      onTap: () {
        final mindmapModel = mindMap['mindmapModel'] as Mindmapmodel?;
        if (mindmapModel != null) {
          context.push('/mindmap-viewer', extra: {'mindmap': mindmapModel});
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface,
              colorScheme.primaryContainer.withValues(alpha: 0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.map, size: 16, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                mindMap['title'] as String? ?? 'Mind Map',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_forward, size: 14, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
