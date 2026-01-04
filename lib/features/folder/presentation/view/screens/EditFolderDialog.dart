// features/folder/presentation/view/screens/EditFolderDialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/features/folder/data/models/foldermodel.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_color_selector.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_edit_fields.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_icon_selector.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_privacy_widgets.dart';
import 'package:tionova/features/folder/presentation/view/widgets/share_with_dialog.dart';

class EditFolderDialog extends StatefulWidget {
  final Foldermodel folder;
  final List<Color> defaultcolors;
  final List<IconData> icons;

  const EditFolderDialog({
    super.key,
    required this.folder,
    required this.defaultcolors,
    required this.icons,
  });

  @override
  State<EditFolderDialog> createState() => _EditFolderDialogState();
}

class _EditFolderDialogState extends State<EditFolderDialog>
    with SafeContextMixin {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late Status _selectedStatus;
  late int _selectedIcon;
  late int _selectedColor;
  List<String> _sharedUsers = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.folder.title);
    _descriptionController = TextEditingController(
      text: widget.folder.description ?? '',
    );
    _selectedStatus = widget.folder.status;
    _sharedUsers =
        widget.folder.sharedWith?.map((user) => user.id).toList() ?? [];

    _initializeSelections();
  }

  void _initializeSelections() {
    _selectedIcon = 0;
    if (widget.folder.icon != null) {
      final iconIndex = int.tryParse(widget.folder.icon!);
      if (iconIndex != null &&
          iconIndex >= 0 &&
          iconIndex < widget.icons.length) {
        _selectedIcon = iconIndex;
      }
    }

    _selectedColor = 0;
    if (widget.folder.color != null) {
      try {
        final colorValue = int.parse(
          widget.folder.color!.replaceAll('#', ''),
          radix: 16,
        );
        // Add FF if needed for ARGB comparison
        final fullColorValue =
            widget.folder.color!.replaceAll('#', '').length == 6
            ? 0xFF000000 | colorValue
            : colorValue;

        final colorIndex = widget.defaultcolors.indexWhere(
          (c) => c.value == fullColorValue,
        );
        if (colorIndex != -1) {
          _selectedColor = colorIndex;
        }
      } catch (e) {
        _selectedColor = 0;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleStateListener(BuildContext context, FolderState state) {
    final colorScheme = Theme.of(context).colorScheme;
    if (state is UpdateFolderSuccess) {
      _showSnackBar(
        context,
        'Folder updated successfully!',
        Colors.green,
        Icons.check_circle,
      );
      Navigator.pop(context, true);
    }
    if (state is UpdateFolderError) {
      _showSnackBar(
        context,
        'Update failed: ${state.message.errMessage}',
        colorScheme.error,
        Icons.error,
      );
      Navigator.pop(context, false);
    }
  }

  void _showSnackBar(
    BuildContext context,
    String message,
    Color bgColor,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
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
        backgroundColor: bgColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocListener<FolderCubit, FolderState>(
      listener: _handleStateListener,
      child: BlocBuilder<FolderCubit, FolderState>(
        builder: (context, state) {
          final isLoading = state is UpdateFolderLoading;
          return Stack(
            children: [
              AlertDialog(
                backgroundColor: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outline),
                ),
                title: Text(
                  'Edit Folder',
                  style: TextStyle(
                    color: colorScheme.onSurface,
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
                        FolderEditFields(
                          titleController: _titleController,
                          descriptionController: _descriptionController,
                        ),
                        const SizedBox(height: 16),
                        _buildSectionLabel('Choose Icon', colorScheme),
                        const SizedBox(height: 12),
                        FolderIconSelector(
                          icons: widget.icons,
                          selectedIconIndex: _selectedIcon,
                          onIconSelected: (i) =>
                              setState(() => _selectedIcon = i),
                        ),
                        const SizedBox(height: 20),
                        _buildSectionLabel('Choose Color', colorScheme),
                        const SizedBox(height: 12),
                        FolderColorSelector(
                          colors: widget.defaultcolors,
                          selectedColorIndex: _selectedColor,
                          onColorSelected: (i) =>
                              setState(() => _selectedColor = i),
                        ),
                        const SizedBox(height: 16),
                        FolderPrivacyDropdown(
                          selectedStatus: _selectedStatus,
                          onChanged: (value) {
                            if (value != null)
                              setState(() => _selectedStatus = value);
                          },
                        ),
                        if (_selectedStatus == Status.share) ...[
                          const SizedBox(height: 16),
                          FolderShareTile(
                            sharedUsersCount: _sharedUsers.length,
                            onTap: _openShareDialog,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                  _buildUpdateButton(isLoading, colorScheme),
                ],
              ),
              if (isLoading) _buildLoadingOverlay(colorScheme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionLabel(String text, ColorScheme colorScheme) {
    return Text(
      text,
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildUpdateButton(bool isLoading, ColorScheme colorScheme) {
    return ElevatedButton(
      onPressed: isLoading ? null : () => _updateFolder(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? _buildLoadingButtonContent(colorScheme)
          : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.save, size: 16),
                SizedBox(width: 4),
                Text('Update'),
              ],
            ),
    );
  }

  Widget _buildLoadingButtonContent(ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.onPrimary,
          ),
        ),
        const SizedBox(width: 8),
        const Text('Updating...'),
      ],
    );
  }

  Widget _buildLoadingOverlay(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.scrim.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 2,
              ),
              const SizedBox(height: 16),
              const Text(
                'Updating folder...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openShareDialog() async {
    final selectedUsers = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => Builder(
        builder: (innerContext) => BlocProvider.value(
          value: context.read<FolderCubit>(),
          child: ShareWithDialog(
            folderTitle: _titleController.text,
            initialUserIds: _sharedUsers,
          ),
        ),
      ),
    );
    if (selectedUsers != null) {
      setState(() => _sharedUsers = selectedUsers);
    }
  }

  void _updateFolder(BuildContext context) {
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar(
        context,
        'Title cannot be empty',
        Theme.of(context).colorScheme.error,
        Icons.error,
      );
      return;
    }

    context.read<FolderCubit>().updatefolder(
      id: widget.folder.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      sharedWith: _selectedStatus == Status.share && _sharedUsers.isNotEmpty
          ? _sharedUsers
          : [],
      status: _selectedStatus,
      icon: _selectedIcon.toString(),
      color:
          '#${widget.defaultcolors[_selectedColor].value.toRadixString(16).padLeft(8, '0').substring(2)}',
    );
  }
}
