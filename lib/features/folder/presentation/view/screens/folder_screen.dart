import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/folder/data/models/foldermodel.dart';
import 'package:tionova/features/folder/domain/usecases/CreateFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/DeleteFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetAllFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetPublicFoldersUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/UpdateFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/getAvailableUsersForShareUseCase.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/features/folder/presentation/view/widgets/delete_confirmation_dialog.dart';
import 'package:tionova/features/folder/presentation/view/widgets/edit_folder_dialog.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_list.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_options_bottom_sheet.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_shimmer_list.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';
import 'package:tionova/utils/static.dart';
import 'package:tionova/utils/widgets/page_header.dart';

import '../widgets/create_folder_card.dart';
import '../widgets/create_folder_dialog.dart';
import '../widgets/folder_tabs.dart';
import '../widgets/study_stats.dart';
import 'folder_screen_widgets.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  String selectedCategory = 'All';
  String selectedTab = 'My Folders';
  static const defaultColors = Static.defaultColors;
  static const defaultIcons = Static.defaultIcons;
  List<Foldermodel>? _cachedFolders;
  List<Foldermodel>? _cachedPublicFolders;
  List<String> _cachedCategories = const ['All'];

  @override
  void initState() {
    super.initState();
    _fetchFolders();
    _subscribeToFolderView();
  }

  void _subscribeToFolderView() {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) return;
    final userId = authState.user.id;
    final sseUrl = '$baseUrl/sse/subscribe?userId=$userId';
    context.read<FolderCubit>().subscribeToFolderSse(sseUrl);
  }

  @override
  void dispose() {
    context.read<FolderCubit>().unsubscribeFromFolderSse();
    super.dispose();
  }

  void _fetchFolders() {
    if (selectedTab == 'My Folders') {
      context.read<FolderCubit>().fetchAllFolders();
    } else {
      context.read<FolderCubit>().fetchPublicFolders();
    }
  }

  // Helper method to get icon from stored index
  IconData _getIconFromIndex(String? iconIndex) {
    if (iconIndex == null) return Icons.folder_outlined;

    try {
      final index = int.parse(iconIndex);
      if (index >= 0 && index < defaultIcons.length) {
        return defaultIcons[index];
      }
    } catch (e) {
      // If parsing fails, return default
    }
    return Icons.folder_outlined;
  }

  // Helper method to get color from stored hex string
  Color _getColorFromHex(String? colorHex) {
    if (colorHex == null) return defaultColors[0];

    try {
      // Remove # if present and ensure it's 8 characters for ARGB
      String cleanHex = colorHex.replaceAll('#', '');
      if (cleanHex.length == 6) {
        cleanHex = 'FF$cleanHex'; // Add alpha
      }
      return Color(int.parse(cleanHex, radix: 16));
    } catch (e) {
      // If parsing fails, return default blue
    }
    return defaultColors[0];
  }

  void _deleteFolder(String folderId) {
    context.read<FolderCubit>().deletefolder(id: folderId);
  }

  void onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  void onTabSelected(String tab) {
    setState(() {
      selectedTab = tab;
    });
    // Fetch folders only if not already cached
    if (selectedTab == 'My Folders' && _cachedFolders == null) {
      context.read<FolderCubit>().fetchAllFolders();
    } else if (selectedTab == 'Public Folders' &&
        _cachedPublicFolders == null) {
      context.read<FolderCubit>().fetchPublicFolders();
    }
  }

  // Helper method to get categories from folders

  List<Foldermodel> _getFoldersFromState(FolderState state) {
    if (state is FolderLoaded) {
      return state.folders;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isTablet = screenWidth > 600;
    final horizontalPadding = screenWidth * (isTablet ? 0.08 : 0.05);
    final verticalSpacing = screenHeight * 0.02;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const NoGlowScrollBehavior(),
          child: BlocConsumer<FolderCubit, FolderState>(
            listener: (context, state) {
              // Handle folder update operations
              if (state is UpdateFolderLoading) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: isTablet ? 20 : 16,
                          height: isTablet ? 20 : 16,
                          child: CircularProgressIndicator(
                            strokeWidth: isTablet ? 2.5 : 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: isTablet ? 16 : 12),
                        Text('Updating folder...'),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: colorScheme.primary,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              if (state is UpdateFolderSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: colorScheme.onPrimary,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text('Folder updated successfully'),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              if (state is DeleteFolderSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: colorScheme.onPrimary,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text('Folder deleted successfully'),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              if (state is UpdateFolderError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error, color: colorScheme.onError, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Update failed: ${state.message}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: colorScheme.error,
                    duration: Duration(seconds: 4),
                    action: SnackBarAction(
                      label: 'Retry',
                      textColor: colorScheme.onError,
                      onPressed: () {
                        // Auto-refresh folders after error
                        _fetchFolders();
                      },
                    ),
                  ),
                );
              }
              if (state is DeleteFolderError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error, color: colorScheme.onError, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Delete failed: ${state.message}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: colorScheme.error,
                    duration: Duration(seconds: 4),
                    action: SnackBarAction(
                      label: 'Retry',
                      textColor: colorScheme.onError,
                      onPressed: () {
                        // Auto-refresh folders after error
                        _fetchFolders();
                      },
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () async {
                  _fetchFolders();
                },
                color: colorScheme.primary,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
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
                          if (selectedTab == 'My Folders')
                            CreateFolderCard(
                              onTap: () async {
                                final result = await showDialog<dynamic>(
                                  context: context,
                                  barrierDismissible: true,
                                  barrierColor: Colors.black.withOpacity(0.5),
                                  builder: (dialogContext) => BlocProvider(
                                    create: (dialogContext) => FolderCubit(
                                      getAllFolderUseCase:
                                          getIt<GetAllFolderUseCase>(),
                                      createFolderUseCase:
                                          getIt<CreateFolderUseCase>(),
                                      updateFolderUseCase:
                                          getIt<UpdateFolderUseCase>(),
                                      deleteFolderUseCase:
                                          getIt<DeleteFolderUseCase>(),
                                      getAvailableUsersForShareUseCase:
                                          getIt<
                                            GetAvailableUsersForShareUseCase
                                          >(),
                                      getPublicFoldersUseCase:
                                          getIt<GetPublicFoldersUseCase>(),
                                    ),
                                    child: const CreateFolderDialog(),
                                  ),
                                );
                                if (result != null && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Folder created'),
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(seconds: 1),
                                    ),
                                  );

                                  // No need to manually fetch - cubit handles it automatically
                                }
                              },
                            ),
                          if (selectedTab == 'My Folders')
                            SizedBox(height: verticalSpacing * 1.5),
                          if (selectedTab == 'My Folders')
                            const LongPressHint(),
                          SizedBox(height: verticalSpacing * 1.5),
                        ]),
                      ),
                    ),
                    if ((selectedTab == 'My Folders' &&
                            state is FolderLoading &&
                            _cachedFolders == null) ||
                        (selectedTab == 'Public Folders' &&
                            state is PublicFoldersLoading &&
                            _cachedPublicFolders == null))
                      const FolderShimmerList()
                    else if ((selectedTab == 'My Folders' &&
                            state is FolderError &&
                            _cachedFolders == null) ||
                        (selectedTab == 'Public Folders' &&
                            state is PublicFoldersError &&
                            _cachedPublicFolders == null))
                      SliverFillRemaining(
                        child: SingleChildScrollView(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: colorScheme.error,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Failed to load folders',
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Only retry fetch if needed
                                    _fetchFolders();
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else if ((selectedTab == 'My Folders' &&
                            _cachedFolders != null) ||
                        (selectedTab == 'Public Folders' &&
                            _cachedPublicFolders != null) ||
                        (selectedTab == 'My Folders' &&
                            (state is FolderLoaded ||
                                state is FolderLoading ||
                                state is FolderError)) ||
                        (selectedTab == 'Public Folders' &&
                            (state is PublicFoldersLoaded ||
                                state is PublicFoldersLoading ||
                                state is PublicFoldersError)))
                      Builder(
                        builder: (context) {
                          // Cache folders when loaded - independent of selected tab
                          if (state is FolderLoaded) {
                            _cachedFolders = state.folders;
                          }
                          if (state is PublicFoldersLoaded) {
                            _cachedPublicFolders = state.publicFolders;
                          }

                          // Use cached folders based on selected tab
                          final foldersToShow = selectedTab == 'My Folders'
                              ? (state is FolderLoaded
                                    ? state.folders
                                    : _cachedFolders ?? [])
                              : (state is PublicFoldersLoaded
                                    ? state.publicFolders
                                    : _cachedPublicFolders ?? []);

                          return FolderList(
                            state: FolderLoaded(foldersToShow),
                            selectedCategory: selectedCategory,
                            getIconFromIndex: _getIconFromIndex,
                            getColorFromHex: _getColorFromHex,
                            onFolderLongPress: (context, folder, color) {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor:
                                    colorScheme.surfaceContainerHighest,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                ),
                                isScrollControlled: true,
                                builder: (bottomSheetContext) =>
                                    FolderOptionsBottomSheet(
                                      folder: folder,
                                      color: color,
                                      onEdit: () => showEditFolderDialog(
                                        context,
                                        folder,
                                        defaultColors,
                                        defaultIcons,
                                        context.read<FolderCubit>(),
                                      ),
                                      onDelete: () =>
                                          showDeleteConfirmationDialog(
                                            context,
                                            folder.id,
                                            folder.title,
                                            context.read<FolderCubit>(),
                                          ),
                                      // onShare: () {},
                                      // onDuplicate: () {},
                                      // onExportPDF: () {},
                                      // onArchive: () {},
                                    ),
                              );
                            },
                          );
                        },
                      )
                    else
                      SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'No folders available',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          SizedBox(height: verticalSpacing * 1.5),
                          Builder(
                            builder: (context) {
                              final foldersForStats =
                                  selectedTab == 'My Folders'
                                  ? (state is FolderLoaded
                                        ? state.folders
                                        : (_cachedFolders ?? []))
                                  : (state is PublicFoldersLoaded
                                        ? state.publicFolders
                                        : (_cachedPublicFolders ?? []));

                              return StudyStats(
                                myFoldersCount: foldersForStats.length,
                                totalChaptersCount: foldersForStats.fold(
                                  0,
                                  (sum, folder) =>
                                      sum + (folder.chapterCount ?? 0),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: isTablet ? 24 : 16),
                        ]),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
