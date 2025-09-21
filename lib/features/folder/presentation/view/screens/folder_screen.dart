// features/folder/presentation/view/screens/folder_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/folder/data/models/FolderModel.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';
import 'package:tionova/features/folder/domain/usecases/CreateFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/DeleteFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetAllFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/UpdateFolderUseCase.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
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
  const FolderScreen({Key? key}) : super(key: key);

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

  void _showEditFolderDialog(Foldermodel folder) {
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
          BlocProvider.value(value: context.read<FolderCubit>()),
          BlocProvider.value(value: context.read<AuthCubit>()),
        ],
        child: _EditFolderDialog(
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
  List<String> _getCategories(List<Foldermodel> folders) {
    final categories = ['All'];
    final categorySet = <String>{};

    for (final folder in folders) {
      if (folder.category != null && folder.category!.isNotEmpty) {
        categorySet.add(folder.category!);
      }
    }
    categories.addAll(categorySet);
    return categories;
  }

  // Helper method to extract folders from different state types
  List<Foldermodel> _getFoldersFromState(FolderState state) {
    if (state is FolderLoaded) {
      return state.folders;
    }
    return [];
  }

  // Helper method to build folder list
  Widget _buildFolderList(
    List<Foldermodel> folders,
    double screenWidth,
    String categoryFilter, [
    FolderState? currentState,
  ]) {
    // Filter folders by category
    final filteredFolders = categoryFilter == 'All'
        ? folders
        : folders.where((f) => f.category == categoryFilter).toList();

    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;
    final horizontalPadding =
        screenWidth *
        (isDesktop
            ? 0.12
            : isTablet
            ? 0.08
            : 0.05);
    final crossAxisCount = isDesktop
        ? 3
        : isTablet
        ? 2
        : 1;
    final aspectRatio = isDesktop
        ? 1.8
        : isTablet
        ? 2.0
        : 1.9;

    if (filteredFolders.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open_outlined,
                  size: 64,
                  color: Color(0xFF8E8E93),
                ),
                SizedBox(height: 16),
                Text(
                  categoryFilter == 'All'
                      ? 'No folders yet'
                      : 'No folders in "$categoryFilter" category',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  categoryFilter == 'All'
                      ? 'Create your first folder to start organizing your study materials'
                      : 'Try selecting a different category or create a new folder',
                  style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: isDesktop
              ? 20
              : isTablet
              ? 16
              : 0,
          mainAxisSpacing: isDesktop ? 20 : 16,
          childAspectRatio: aspectRatio,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;
    final horizontalPadding =
        screenWidth *
        (isDesktop
            ? 0.12
            : isTablet
            ? 0.08
            : 0.05);

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
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
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
                // Show success message
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
              if (state is UpdateFolderError) {
                // Refresh folders to ensure UI is synchronized with server state
                _fetchFolders();

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
                  ),
                );
              }
            },
            builder: (context, state) {
              return CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  // Header Section
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        SizedBox(height: screenHeight * 0.02),
                        const PageHeader(
                          title: 'Folders',
                          subtitle: 'Organize and manage your study folders',
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        const AppSearchBar(hintText: 'Search folders'),
                        SizedBox(height: screenHeight * 0.02),
                        CategoryFilter(
                          categories:
                              (state is FolderLoaded ||
                                  state is UpdateFolderSuccess ||
                                  state is UpdateFolderError)
                              ? _getCategories(_getFoldersFromState(state))
                              : const ['All', 'Technology', 'Science'],
                          selectedCategory: selectedCategory,
                          onCategorySelected: onCategorySelected,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        FolderTabs(
                          tabs: const ['My Folders', 'Public Folders'],
                          selectedTab: selectedTab,
                          onTabSelected: onTabSelected,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                      ]),
                    ),
                  ),

                  // Create Folder Section
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
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
                              _fetchFolders();
                            }
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        LongPressHint(),
                        SizedBox(height: screenHeight * 0.02),
                      ]),
                    ),
                  ),

                  // Folders List Section
                  if (state is FolderLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      ),
                    )
                  else if (state is FolderError)
                    SliverToBoxAdapter(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.6, // 60% of screen height
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Failed to load folders',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 120,
                              child: ElevatedButton(
                                onPressed: _fetchFolders,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Retry'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (state is FolderLoaded ||
                      state is UpdateFolderSuccess ||
                      state is UpdateFolderError)
                    _buildFolderList(
                      _getFoldersFromState(state),
                      screenWidth,
                      selectedCategory,
                      state,
                    )
                  else
                    const SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'No folders available',
                            style: TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),

                  // Study Stats Section - Moved to bottom
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        SizedBox(height: screenHeight * 0.02),
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
                        SizedBox(height: screenHeight * 0.02),
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

class _EditFolderDialog extends StatefulWidget {
  final Foldermodel folder;
  final List<Color> defaultcolors;
  final List<IconData> icons;

  const _EditFolderDialog({
    required this.folder,
    required this.defaultcolors,
    required this.icons,
  });

  @override
  State<_EditFolderDialog> createState() => _EditFolderDialogState();
}

class _EditFolderDialogState extends State<_EditFolderDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late Status _selectedStatus;
  late int _selectedIcon;
  late int _selectedColor;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.folder.title);
    _descriptionController = TextEditingController(
      text: widget.folder.description ?? '',
    );
    _selectedStatus = widget.folder.status;

    // Parse existing icon or default to 0
    _selectedIcon = 0;
    if (widget.folder.icon != null) {
      final iconIndex = int.tryParse(widget.folder.icon!);
      if (iconIndex != null &&
          iconIndex >= 0 &&
          iconIndex < widget.icons.length) {
        _selectedIcon = iconIndex;
      }
    }

    // Parse existing color or default to 0
    _selectedColor = 0;
    if (widget.folder.color != null) {
      try {
        final colorValue = int.parse(widget.folder.color!, radix: 16);
        final colorIndex = widget.defaultcolors.indexWhere(
          (c) => c.value == colorValue,
        );
        if (colorIndex != -1) {
          _selectedColor = colorIndex;
        }
      } catch (e) {
        // Keep default if parsing fails
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FolderCubit, FolderState>(
      listener: (context, state) {
        if (state is UpdateFolderSuccess) {
          // Show success and close dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text('Folder updated successfully!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true);
        }
        if (state is UpdateFolderError) {
          // Show error message and pop back
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
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Pop back to previous screen after showing error
          Navigator.pop(context, false);
        }
      },
      child: BlocBuilder<FolderCubit, FolderState>(
        builder: (context, state) {
          final isLoading = state is UpdateFolderLoading;
          return Stack(
            children: [
              AlertDialog(
                backgroundColor: const Color(0xFF0E0E10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFF1C1C1E)),
                ),
                title: const Text(
                  'Edit Folder',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        TextField(
                          maxLines: 2,
                          controller: _titleController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(12),
                            labelText: 'Title',
                            labelStyle: const TextStyle(
                              color: Color(0xFF8E8E93),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFF1C1C1E),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF1C1C1E),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _descriptionController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: const TextStyle(
                              color: Color(0xFF8E8E93),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFF1C1C1E),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF1C1C1E),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Choose Icon',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _iconGrid(),
                        const SizedBox(height: 20),
                        Text(
                          'Choose Color',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _colorRow(),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<Status>(
                          value: _selectedStatus,
                          style: const TextStyle(color: Colors.white),
                          dropdownColor: const Color(0xFF1C1C1E),
                          decoration: InputDecoration(
                            labelText: 'Privacy',
                            labelStyle: const TextStyle(
                              color: Color(0xFF8E8E93),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFF1C1C1E),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF1C1C1E),
                          ),
                          items: Status.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(
                                status == Status.private ? 'Private' : 'Public',
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedStatus = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFF8E8E93)),
                    ),
                  ),
                  BlocBuilder<FolderCubit, FolderState>(
                    builder: (context, state) {
                      final isLoading = state is UpdateFolderLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _updateFolder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Updating...'),
                                ],
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.save, size: 16),
                                  SizedBox(width: 4),
                                  Text('Update'),
                                ],
                              ),
                      );
                    },
                  ),
                ],
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.blue,
                            strokeWidth: 2,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Updating folder...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _updateFolder() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get auth token
    final authCubit = context.read<AuthCubit>();
    final authState = authCubit.state;

    if (authState is AuthSuccess) {
      context.read<FolderCubit>().updatefolder(
        id: widget.folder.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        sharedWith: widget.folder.sharedWith?.cast<String>(),
        status: _selectedStatus,
        icon: _selectedIcon.toString(),
        color:
            '#${widget.defaultcolors[_selectedColor].value.toRadixString(16).padLeft(8, '0').substring(2)}',
        token: authState.token,
      );
    }
  }

  Widget _iconGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(widget.icons.length, (i) {
        final selected = i == _selectedIcon;
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = i),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? Colors.blue : Colors.grey,
                width: selected ? 2 : 1,
              ),
            ),
            child: Icon(widget.icons[i], color: Colors.white, size: 20),
          ),
        );
      }),
    );
  }

  Widget _colorRow() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(widget.defaultcolors.length, (i) {
        final selected = i == _selectedColor;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = i),
          child: Container(
            width: 44,
            height: 32,
            decoration: BoxDecoration(
              color: widget.defaultcolors[i].withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? Colors.blue : Colors.grey,
                width: selected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Container(
                width: 22,
                height: 14,
                decoration: BoxDecoration(
                  color: widget.defaultcolors[i],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
