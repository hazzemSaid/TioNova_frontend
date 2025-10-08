import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/folder/data/models/FolderModel.dart';
import 'package:tionova/features/folder/domain/usecases/CreateFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/DeleteFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetAllFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/UpdateFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/getAvailableUsersForShareUseCase.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/features/folder/presentation/view/screens/EditFolderDialog.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';
import 'package:tionova/utils/widgets/app_search_bar.dart';
import 'package:tionova/utils/widgets/page_header.dart';

import '../widgets/category_filter.dart';
import '../widgets/create_folder_card.dart';
import '../widgets/create_folder_dialog.dart';
import '../widgets/folder_tabs.dart';
import '../widgets/study_stats.dart';
import 'folder_detail_screen.dart';
import 'folder_screen_widgets.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  String selectedCategory = 'All';
  String selectedTab = 'My Folders';
  static const defaultColors = [
    Color(0xFF007AFF), // blue
    Color(0xFF34C759), // green
    Color(0xFF8E44AD), // purple
    Color(0xFF7B3F00), // brown-ish
    Color(0xFFFF3B30), // red
    Color(0xFF4B4EFC), // indigo
    Color(0xFFFFD700), // gold
    Color(0xFFE91E63), // pink
    Color(0xFF00C853), // teal
    Color(0xFFFF9800), // orange
    Color(0xFF673AB7), // deep purple
    Color(0xFF009688), // cyan
  ];
  static const defaultIcons = [
    Icons.folder_outlined,
    Icons.book_outlined,
    Icons.code,
    Icons.calculate_outlined,
    Icons.science_outlined,
    Icons.music_note_outlined,
    Icons.language_outlined,
    Icons.auto_awesome_outlined,
    Icons.sports_esports_outlined,
    Icons.school_outlined,
  ];
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
    final sseUrl = 'http://192.168.1.12:3000/api/v1/subscribe?userId=$userId';
    context.read<FolderCubit>().subscribeToFolderSse(sseUrl);
  }

  void dispose() {
    context.read<FolderCubit>().unsubscribeFromFolderSse();
    super.dispose();
  }

  void _fetchFolders() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      context.read<FolderCubit>().fetchAllFolders(authState.token);
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

  void _showFolderOptionsBottomSheet(
    BuildContext context,
    Foldermodel folder,
    Color color,
  ) {
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
              folder.title,
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
                _buildActionButton(
                  icon: Icons.edit,
                  label: 'Edit',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _showEditFolderDialog(folder);
                  },
                ),
                _buildActionButton(
                  icon: Icons.delete,
                  label: 'Delete',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _showDeleteConfirmationDialog(folder);
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 16 : 12,
          horizontal: isTablet ? 32 : 24,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: isTablet ? 28 : 24),
            SizedBox(height: isTablet ? 6 : 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditFolderDialog(Foldermodel folder) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(
        alpha: 153,
        red: 0,
        green: 0,
        blue: 0,
      ),
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<FolderCubit>()),
          BlocProvider.value(value: context.read<AuthCubit>()),
        ],
        child: EditFolderDialog(
          folder: folder,
          defaultcolors: defaultColors,
          icons: defaultIcons,
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(Foldermodel folder) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Folder',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${folder.title}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteFolder(folder.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteFolder(String folderId) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      context.read<FolderCubit>().deletefolder(
        id: folderId,
        token: authState.token,
      );
      // No need to manually refresh, UI will update from FolderLoaded
    }
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
  }

  // Helper method to get categories from folders
  List<String> _getCategories(FolderState state) {
    final categories = ['All'];
    final categorySet = <String>{};

    if (state is FolderLoaded) {
      for (final folder in state.folders) {
        if (folder.category != null && folder.category!.isNotEmpty) {
          categorySet.add(folder.category!);
        }
      }
    }
    categories.addAll(categorySet);
    return categories;
  }

  List<Foldermodel> _getFoldersFromState(FolderState state) {
    if (state is FolderLoaded) {
      return state.folders;
    }
    return [];
  }

  Widget _buildFolderList(FolderState state) {
    final folders = _getFoldersFromState(state);
    final filteredFolders = folders.where((folder) {
      if (selectedCategory == 'All') {
        return true;
      }
      return folder.category == selectedCategory;
    }).toList();

    final isTablet = MediaQuery.of(context).size.width > 600;
    final horizontalPadding =
        MediaQuery.of(context).size.width * (isTablet ? 0.08 : 0.05);
    final crossAxisCount = isTablet ? 2 : 1;

    if (filteredFolders.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'No folders found',
            style: TextStyle(color: Color(0xFF8E8E93), fontSize: 16),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: isTablet ? 16 : 0,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final folder = filteredFolders[index];
          final color = _getColorFromHex(folder.color);
          final icon = _getIconFromIndex(folder.icon);
          return FolderGridItem(
            folder: folder,
            color: color,
            icon: icon,
            onLongPress: () =>
                _showFolderOptionsBottomSheet(context, folder, color),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FolderDetailScreen(
                    folderId: folder.id,
                    title: folder.title,
                    subtitle: folder.description ?? 'No description',
                    chapters: folder.chapterCount ?? 0,
                    passed: 0,
                    attempted: 0,
                    color: color,
                  ),
                ),
              );
            },
          );
        }, childCount: filteredFolders.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isTablet = screenWidth > 600;
    final horizontalPadding = screenWidth * (isTablet ? 0.08 : 0.05);
    final verticalSpacing = screenHeight * 0.02;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const NoGlowScrollBehavior(),
          child: BlocConsumer<FolderCubit, FolderState>(
            listener: (context, state) {
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
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: isTablet ? 16 : 12),
                        Text('Updating folder...'),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.blue,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              if (state is UpdateFolderSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 16),
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
                        Icon(Icons.check_circle, color: Colors.white, size: 16),
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
                        Icon(Icons.error, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Update failed: ${state.message.errMessage}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 4),
                    action: SnackBarAction(
                      label: 'Retry',
                      textColor: Colors.white,
                      onPressed: () {
                        // Optionally implement retry logic here
                      },
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              return CustomScrollView(
                physics: const ClampingScrollPhysics(),
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
                        const AppSearchBar(hintText: 'Search folders'),
                        SizedBox(height: verticalSpacing * 1.5),
                        CategoryFilter(
                          categories: (state is FolderLoaded)
                              ? _getCategories(state)
                              : const ['All', 'Technology', 'Science'],
                          selectedCategory: selectedCategory,
                          onCategorySelected: onCategorySelected,
                        ),
                        SizedBox(height: verticalSpacing),
                        FolderTabs(
                          tabs: const ['My Folders', 'Public Folders'],
                          selectedTab: selectedTab,
                          onTabSelected: onTabSelected,
                        ),
                        SizedBox(height: verticalSpacing),
                        CreateFolderCard(
                          onTap: () async {
                            final result = await showDialog<dynamic>(
                              context: context,
                              barrierDismissible: true,
                              barrierColor: Colors.black.withValues(
                                alpha: 153,
                                red: 0,
                                green: 0,
                                blue: 0,
                              ),
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
                                      getIt<GetAvailableUsersForShareUseCase>(),
                                ),
                                child: const CreateFolderDialog(),
                              ),
                            );
                            if (result != null && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Folder created'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              final authState = context.read<AuthCubit>().state;
                              String token = '';
                              if (authState is AuthSuccess) {
                                token = authState.token;
                              }
                              if (token == '') return;
                              context.read<FolderCubit>().fetchAllFolders(
                                token,
                              );

                              // No need to call _fetchFolders(); UI will update from FolderLoaded
                            }
                          },
                        ),
                        SizedBox(height: verticalSpacing * 1.5),
                        const LongPressHint(),
                        SizedBox(height: verticalSpacing * 1.5),
                      ]),
                    ),
                  ),
                  if (state is FolderLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      ),
                    )
                  else if (state is FolderError)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Failed to load folders',
                              style: TextStyle(color: Colors.white),
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
                    )
                  else if (state is FolderLoaded)
                    _buildFolderList(state)
                  else
                    const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No folders available',
                          style: TextStyle(color: Colors.white70),
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
                        if (state is FolderLoaded ||
                            state is UpdateFolderSuccess ||
                            state is UpdateFolderError)
                          StudyStats(
                            myFoldersCount: _getFoldersFromState(state).length,
                            totalChaptersCount: _getFoldersFromState(state)
                                .fold(
                                  0,
                                  (sum, folder) =>
                                      sum + (folder.chapterCount ?? 0),
                                ),
                          )
                        else
                          const StudyStats(
                            myFoldersCount: 0,
                            totalChaptersCount: 0,
                          ),
                        SizedBox(height: isTablet ? 24 : 16),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
