import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/folder/data/models/foldermodel.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/features/folder/presentation/view/utils/folder_view_helper.dart';
import 'package:tionova/features/folder/presentation/view/widgets/delete_confirmation_dialog.dart';
import 'package:tionova/features/folder/presentation/view/widgets/edit_folder_dialog.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_actions_section.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_header_section.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_list.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_options_bottom_sheet.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_shimmer_list.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_stats_footer.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  String selectedCategory = 'All';
  String selectedTab = 'My Folders';

  List<Foldermodel>? _cachedFolders;
  List<Foldermodel>? _cachedPublicFolders;

  @override
  void initState() {
    super.initState();
    _fetchFolders();
  }

  void _fetchFolders() {
    if (selectedTab == 'My Folders') {
      context.read<FolderCubit>().fetchAllFolders();
    } else {
      context.read<FolderCubit>().fetchPublicFolders();
    }
  }

  void onTabSelected(String tab) {
    if (selectedTab == tab) return;
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

  void _handleListener(BuildContext context, FolderState state) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state is UpdateFolderLoading) {
      _showSnackBar(
        context,
        'Updating folder...',
        colorScheme.primary,
        isProgress: true,
      );
    } else if (state is UpdateFolderSuccess) {
      _showSnackBar(
        context,
        'Folder updated successfully',
        Colors.green,
        icon: Icons.check_circle,
      );
    } else if (state is DeleteFolderSuccess) {
      _showSnackBar(
        context,
        'Folder deleted successfully',
        Colors.green,
        icon: Icons.check_circle,
      );
    } else if (state is UpdateFolderError) {
      _showErrorSnackBar(
        context,
        'Update failed: ${state.message}',
        colorScheme,
      );
    } else if (state is DeleteFolderError) {
      _showErrorSnackBar(
        context,
        'Delete failed: ${state.message}',
        colorScheme,
      );
    }
  }

  void _showSnackBar(
    BuildContext context,
    String message,
    Color bgColor, {
    bool isProgress = false,
    IconData? icon,
  }) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (isProgress)
              SizedBox(
                width: isTablet ? 20 : 16,
                height: isTablet ? 20 : 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            else if (icon != null)
              Icon(icon, color: Colors.white, size: 16),
            if (isProgress || icon != null) const SizedBox(width: 12),
            Text(message),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: bgColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(
    BuildContext context,
    String message,
    ColorScheme colorScheme,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: colorScheme.onError, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.error,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Retry',
          textColor: colorScheme.onError,
          onPressed: _fetchFolders,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = screenWidth * (isTablet ? 0.08 : 0.05);
    final verticalSpacing = MediaQuery.of(context).size.height * 0.02;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const NoGlowScrollBehavior(),
          child: BlocConsumer<FolderCubit, FolderState>(
            listener: _handleListener,
            builder: (context, state) {
              if (state is FolderLoaded) _cachedFolders = state.folders;
              if (state is PublicFoldersLoaded)
                _cachedPublicFolders = state.publicFolders;

              final foldersToShow = selectedTab == 'My Folders'
                  ? (state is FolderLoaded
                        ? state.folders
                        : _cachedFolders ?? [])
                  : (state is PublicFoldersLoaded
                        ? state.publicFolders
                        : _cachedPublicFolders ?? []);

              final isLoading =
                  (selectedTab == 'My Folders' &&
                      state is FolderLoading &&
                      _cachedFolders == null) ||
                  (selectedTab == 'Public Folders' &&
                      state is PublicFoldersLoading &&
                      _cachedPublicFolders == null);

              final isError =
                  (selectedTab == 'My Folders' &&
                      state is FolderError &&
                      _cachedFolders == null) ||
                  (selectedTab == 'Public Folders' &&
                      state is PublicFoldersError &&
                      _cachedPublicFolders == null);

              return RefreshIndicator(
                onRefresh: () async => _fetchFolders(),
                color: colorScheme.primary,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      sliver: SliverMainAxisGroup(
                        slivers: [
                          FolderHeaderSection(
                            selectedTab: selectedTab,
                            onTabSelected: onTabSelected,
                            verticalSpacing: verticalSpacing,
                          ),
                          FolderActionsSection(
                            showCreateCard: selectedTab == 'My Folders',
                            verticalSpacing: verticalSpacing,
                          ),
                        ],
                      ),
                    ),
                    if (isLoading)
                      const FolderShimmerList()
                    else if (isError)
                      _buildErrorState(colorScheme)
                    else
                      FolderList(
                        state: FolderLoaded(foldersToShow),
                        selectedCategory: selectedCategory,
                        getIconFromIndex: FolderViewHelper.getIconFromIndex,
                        getColorFromHex: FolderViewHelper.getColorFromHex,
                        onFolderLongPress: (ctx, folder, color) =>
                            _showFolderOptions(ctx, folder, color),
                      ),
                    if (!isLoading && !isError)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        sliver: FolderStatsFooter(
                          folders: foldersToShow,
                          verticalSpacing: verticalSpacing,
                          isTablet: isTablet,
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

  Widget _buildErrorState(ColorScheme colorScheme) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load folders',
              style: TextStyle(color: colorScheme.onSurface),
            ),
            TextButton(onPressed: _fetchFolders, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  void _showFolderOptions(
    BuildContext context,
    Foldermodel folder,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (bottomSheetContext) => FolderOptionsBottomSheet(
        folder: folder,
        color: color,
        onEdit: () => showEditFolderDialog(
          context,
          folder,
          FolderViewHelper.defaultColors,
          FolderViewHelper.defaultIcons,
          context.read<FolderCubit>(),
        ),
        onDelete: () => showDeleteConfirmationDialog(
          context,
          folder.id,
          folder.title,
          context.read<FolderCubit>(),
        ),
      ),
    );
  }
}
