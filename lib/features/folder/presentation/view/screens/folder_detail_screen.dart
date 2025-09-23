// features/folder/presentation/view/screens/folder_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/view/screens/EditChapterDialog.dart';
import 'package:tionova/features/folder/presentation/view/widgets/DashedBorderPainter.dart';
import 'package:tionova/features/folder/presentation/view/widgets/create_folder_card.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';
import 'package:tionova/utils/static.dart';

import 'chapter_detail_screen.dart';
import 'create_chapter_screen.dart';

class FolderDetailScreen extends StatelessWidget {
  final String folderId;
  final String title;
  final String subtitle;
  final int chapters;
  final int passed;
  final int attempted;
  final Color color;

  const FolderDetailScreen({
    super.key,
    required this.folderId,
    required this.title,
    required this.subtitle,
    required this.chapters,
    required this.passed,
    required this.attempted,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final horizontalPadding = screenWidth * (isTablet ? 0.08 : 0.05);

    return BlocProvider(
      create: (_) => getIt<ChapterCubit>(),
      child: Builder(
        builder: (context) {
          // Get auth state for token
          final authState = context.read<AuthCubit>().state;
          final token = authState is AuthSuccess ? authState.token : '';

          // Load chapters when widget builds
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (token.isNotEmpty) {
              context.read<ChapterCubit>().getChapters(
                folderId: folderId,
                token: token,
              );
            }
          });

          return Scaffold(
            backgroundColor: Colors.black,
            body: ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  // Header with back button, title, and share button
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 16,
                        left: horizontalPadding,
                        right: horizontalPadding,
                        bottom: 24,
                      ),
                      child: Row(
                        children: [
                          // Back button
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0E0E10),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF1C1C1E),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Title and subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: const TextStyle(
                                    color: Color(0xFF8E8E93),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Share button
                          GestureDetector(
                            onTap: () {
                              // Handle share action
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0E0E10),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF1C1C1E),
                                ),
                              ),
                              child: const Icon(
                                Icons.share,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Stats cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Chapters',
                              chapters.toString(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard('Passed', passed.toString()),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Attempted',
                              attempted.toString(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Add Chapter button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(horizontalPadding),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CreateChapterScreen(
                                folderTitle: title,
                                folderId: folderId,
                              ),
                            ),
                          );
                        },
                        child: CustomPaint(
                          size: Size(double.infinity, 44),
                          isComplex: true,
                          willChange: true,
                          painter: DashedBorderPainter(
                            color: color.withValues(alpha: 0.22),
                          ),
                          child: Container(
                            height: 44,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0E0E10),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: const Color(0xFF1C1C1E),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Add Chapter',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Dynamic chapter list from cubit
                  BlocBuilder<ChapterCubit, ChapterState>(
                    builder: (context, state) {
                      if (state is ChapterLoading) {
                        return const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (state is ChapterLoaded) {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate((ctx, idx) {
                            final chapter = state.chapters[idx];
                            return _buildChapterCard(context, chapter);
                          }, childCount: state.chapters.length),
                        );
                      } else if (state is ChapterError) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Text(
                              'Failed to load chapters: ${state.message}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        );
                      } else {
                        return SliverFillRemaining(
                          child: Center(
                            child: Text(
                              'No chapters found',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1C1C1E)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterCard(BuildContext context, ChapterModel chapter) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = screenWidth * (isTablet ? 0.08 : 0.05);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                ChapterDetailScreen(chapter: chapter, folderColor: color),
          ),
        );
      },
      onLongPress: () {
        ShowChapterOptionsBottomSheet(chapter: chapter).show(context);
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(
          horizontalPadding,
          0,
          horizontalPadding,
          12,
        ),
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1C1C1E)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    chapter.title ?? 'Untitled Chapter',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildStatusChip(chapter.quizStatus ?? 'Not Taken'),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              chapter.description ?? 'No description available',
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
            // Info and action buttons
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Chapter • Created ${_formatDate(chapter.createdAt)}',
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                _buildActionButton('Summary', Icons.summarize),
                const SizedBox(width: 8),
                _buildActionButton('Quiz', Icons.quiz),
                const SizedBox(width: 8),
                _buildActionButton('Chat', Icons.chat_bubble_outline),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status) {
      case 'Passed':
        chipColor = const Color(0xFF34C759);
        break;
      case 'Failed':
        chipColor = const Color(0xFFFF3B30);
        break;
      default:
        chipColor = const Color(0xFF8E8E93);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipColor),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: chipColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }
}

class ShowChapterOptionsBottomSheet {
  final ChapterModel chapter;

  ShowChapterOptionsBottomSheet({required this.chapter});

  void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E0E10),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF636366),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              chapter.title ?? 'Untitled Chapter',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildActionButton(
                  chapter: chapter,
                  context: context,
                  color: Colors.blue,
                  icon: Icons.edit,
                  label: 'Edit',
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _showEditChapterDialog(chapter, context);
                  },
                ),
                buildActionButton(
                  chapter: chapter,
                  context: context,
                  color: Colors.red,
                  icon: Icons.delete,
                  label: 'Delete',
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _showDeleteChapterDialog(chapter, context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showEditChapterDialog(ChapterModel chapter, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(
        alpha: 153,
        red: 0,
        green: 0,
        blue: 0,
      ), // 0.6 opacity
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ChapterCubit>()),
          BlocProvider.value(value: context.read<AuthCubit>()),
        ],
        child: EditChapterDialog(
          titleController: TextEditingController(text: chapter.title),
          descriptionController: TextEditingController(
            text: chapter.description,
          ),
          chapter: chapter,
          defaultcolors: Static.defaultColors,
          icons: Static.defaultIcons,
        ),
      ),
    );
  }

  void _showDeleteChapterDialog(ChapterModel chapter, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Container(child: Text('Delete Chapter')),
    );
  }

  Widget buildActionButton({
    required ChapterModel chapter,
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
