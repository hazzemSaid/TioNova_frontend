import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/auth/data/services/token_storage.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_detail_mobile_layout.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_detail_web_layout.dart';

class FolderDetailScreen extends StatefulWidget {
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
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  late final ChapterCubit _chapterCubit;
  late final FolderCubit _folderCubit;
  // Temporary state to hold recovered folder details if original args were missing
  String? _recoveredOwnerId;
  String? _recoveredTitle;
  String? _recoveredFolderId;
  String? _currentUserId;

  // Getter to resolve the effective folderId
  String get effectiveFolderId {
    // Priority: recovered folderId > widget folderId
    if (_recoveredFolderId != null && _recoveredFolderId!.isNotEmpty) {
      return _recoveredFolderId!;
    }
    return widget.folderId;
  }

  // Getter to resolve the effective ownerId
  String get effectiveOwnerId {
    // Priority: recovered ownerId > widget ownerId > current user ID
    if (_recoveredOwnerId != null && _recoveredOwnerId!.isNotEmpty) {
      return _recoveredOwnerId!;
    }
    if (widget.ownerId.isNotEmpty) {
      return widget.ownerId;
    }
    // Fallback to current user ID if available
    if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      return _currentUserId!;
    }
    return '';
  }

  String get effectiveTitle => _recoveredTitle ?? widget.title;

  @override
  void initState() {
    super.initState();
    _chapterCubit = getIt<ChapterCubit>();
    _folderCubit = getIt<FolderCubit>();
    _initializeData();
  }

  @override
  void dispose() {
    // Only close if you created them and they are not singletons intended to survive
    // But since getIt usually provides singletons or factory, closing might affect other parts
    // if using factory (new instance per call), we typically close it.
    // Assuming standard Cubit lifecycle:
    _chapterCubit.close();
    _folderCubit.close();
    super.dispose();
  }

  Future<void> _retrieveCurrentUserIdFromStorage() async {
    try {
      final storedId = await getIt<TokenStorage>().getUserId();
      if (storedId != null && storedId.isNotEmpty) {
        debugPrint(
          '✅ [FolderDetailScreen] Retrieved userId from storage: $storedId',
        );
        if (mounted) {
          setState(() {
            _currentUserId = storedId;
          });
        }
      }
    } catch (e) {
      debugPrint(
        '⚠️ [FolderDetailScreen] Error retrieving userId from storage: $e',
      );
    }
  }

  void _initializeData() {
    // Always retrieve current user ID from storage (for refresh scenario)
    _retrieveCurrentUserIdFromStorage();

    // Basic validation / Recovery logic
    if (widget.ownerId.isEmpty || widget.folderId == 'unknown') {
      debugPrint(
        '⚠️ [FolderDetailScreen] Invalid parameters - ownerId="${widget.ownerId}", folderId="${widget.folderId}". Attempting to fetch folders to recover...',
      );

      // Use the local instance since context.read is not available for CHILD providers yet
      final folderCubit = _folderCubit;

      // Trigger fetch if not already loaded or loading
      if (folderCubit.state is! FolderLoaded &&
          folderCubit.state is! FolderLoading) {
        folderCubit.fetchAllFolders();
      }
      // ALWAYS check the current state for recovery, even if we just started a fetch.
      // The state might already be loaded!
      _checkStateForRecovery(folderCubit.state);

      // Fallback: If we have current user ID and ownerId is empty, assume user owns this folder
      // This handles the case where user navigates away and back (route params lost)
      if (_currentUserId != null && _currentUserId!.isNotEmpty) {
        debugPrint(
          '✅ [FolderDetailScreen] Using current userId as recovered ownerId: $_currentUserId',
        );
        setState(() {
          _recoveredOwnerId = _currentUserId;
        });
      }
    }

    // Only load chapters if we have a valid folderId
    if (widget.folderId.isNotEmpty && widget.folderId != 'unknown') {
      _chapterCubit.getChapters(folderId: widget.folderId);
    } else {
      debugPrint(
        '⚠️ [FolderDetailScreen] Skipping chapter load - invalid folderId: ${widget.folderId}',
      );
    }
  }

  void _checkStateForRecovery(FolderState state) {
    if (state is FolderLoaded) {
      final folder = state.folders
          .where((f) => f.id == widget.folderId)
          .firstOrNull;
      if (folder != null) {
        if (mounted) {
          setState(() {
            _recoveredOwnerId = folder.ownerId;
            _recoveredTitle = folder.title;
            _recoveredFolderId = folder.id;
          });
          debugPrint(
            '✅ [FolderDetailScreen] Recovered folder data - ID: ${folder.id}, Owner: ${folder.ownerId}, Title: ${folder.title}',
          );
        }
      } else {
        debugPrint(
          '⚠️ [FolderDetailScreen] Folder ${widget.folderId} not found in loaded folders.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we still have a critical data failure (e.g. invalid deep link),
    // we might want to show the error screen instead of a broken UI
    // specific to the "ownerId" requirement for correct functionality (e.g. Firebase paths).
    // However, if the UI can tolerate empty ownerId (readonly), we proceed.
    // The user mentioned a crash, so we'll be safe.

    // Note: We don't block the UI here because the layouts might handle empty string fine,
    // but the crash reporter suggests otherwise.

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = screenWidth * (isTablet ? 0.08 : 0.05);
    final colorScheme = Theme.of(context).colorScheme;

    debugPrint(
      'FolderDetailScreen Debug: screenWidth=$screenWidth, kIsWeb=$kIsWeb, isTablet=$isTablet',
    );
    debugPrint('FolderDetailScreen Debug: ownerId="$effectiveOwnerId"');

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _chapterCubit),
        BlocProvider.value(value: _folderCubit),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ChapterCubit, ChapterState>(
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
          ),
          BlocListener<FolderCubit, FolderState>(
            listener: (context, state) {
              _checkStateForRecovery(state);
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: colorScheme.surface,
          body: (kIsWeb && screenWidth > 1000)
              ? FolderDetailWebLayout(
                  folderId: effectiveFolderId,
                  title: effectiveTitle,
                  subtitle: widget.subtitle,
                  chaptersCount: widget.chapters,
                  passed: widget.passed,
                  attempted: widget.attempted,
                  color: widget.color,
                  ownerId: effectiveOwnerId,
                  currentUserIdParam: _currentUserId,
                )
              : FolderDetailMobileLayout(
                  folderId: effectiveFolderId,
                  title: effectiveTitle,
                  subtitle: widget.subtitle,
                  chaptersCount: widget.chapters,
                  passed: widget.passed,
                  attempted: widget.attempted,
                  color: widget.color,
                  ownerId: effectiveOwnerId,
                  horizontalPadding: horizontalPadding,
                  currentUserIdParam: _currentUserId,
                ),
        ),
      ),
    );
  }
}
