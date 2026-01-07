import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_detail_mobile_layout.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_detail_web_layout.dart';

class FolderDetailScreen extends StatelessWidget {
  final String folderId;
  final String title;
  final String subtitle;
  final int chapters;
  final int passed;
  final int attempted;
  final Color color;
  final String ownerId;

  const FolderDetailScreen({
    super.key,
    required this.folderId,
    required this.title,
    required this.subtitle,
    required this.chapters,
    required this.passed,
    required this.attempted,
    required this.color,
    required this.ownerId,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = screenWidth * (isTablet ? 0.08 : 0.05);
    final colorScheme = Theme.of(context).colorScheme;

    debugPrint(
      'FolderDetailScreen Debug: screenWidth=$screenWidth, kIsWeb=$kIsWeb, isTablet=$isTablet',
    );
    debugPrint('FolderDetailScreen Debug: ownerId="$ownerId"');

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<ChapterCubit>()..getChapters(folderId: folderId),
        ),
        BlocProvider(create: (_) => getIt<FolderCubit>()),
      ],
      child: BlocListener<ChapterCubit, ChapterState>(
        listener: (context, state) {
          if (state is DeleteChapterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Chapter deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is DeleteChapterError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to delete chapter: ${state.message.errMessage}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: colorScheme.surface,
          body: (kIsWeb && screenWidth > 1000)
              ? FolderDetailWebLayout(
                  folderId: folderId,
                  title: title,
                  subtitle: subtitle,
                  chaptersCount: chapters,
                  passed: passed,
                  attempted: attempted,
                  color: color,
                  ownerId: ownerId,
                )
              : FolderDetailMobileLayout(
                  folderId: folderId,
                  title: title,
                  subtitle: subtitle,
                  chaptersCount: chapters,
                  passed: passed,
                  attempted: attempted,
                  color: color,
                  ownerId: ownerId,
                  horizontalPadding: horizontalPadding,
                ),
        ),
      ),
    );
  }
}
