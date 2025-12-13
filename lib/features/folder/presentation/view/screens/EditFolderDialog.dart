// features/folder/presentation/view/screens/EditFolderDialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/features/folder/data/models/foldermodel.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocListener<FolderCubit, FolderState>(
      listener: (context, state) {
        if (state is UpdateFolderSuccess) {
          // Show success and close dialog
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
                  Icon(Icons.error, color: colorScheme.onError, size: 16),
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
              backgroundColor: colorScheme.error,
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
                        TextField(
                          maxLines: 2,
                          controller: _titleController,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(12),
                            labelText: 'Title',
                            labelStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: colorScheme.error),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _descriptionController,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Choose Icon',
                          style: TextStyle(
                            color: colorScheme.onSurface,
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
                            color: colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _colorRow(),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<Status>(
                          value: _selectedStatus,
                          style: TextStyle(color: colorScheme.onSurface),
                          dropdownColor: colorScheme.surfaceContainerHighest,
                          decoration: InputDecoration(
                            labelText: 'Privacy',
                            labelStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                          ),
                          items: Status.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(
                                status.name,
                                style: TextStyle(color: colorScheme.onSurface),
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
                        if (_selectedStatus == Status.share) ...[
                          const SizedBox(height: 16),
                          _buildShareWithTile(context),
                        ],
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
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                  BlocBuilder<FolderCubit, FolderState>(
                    builder: (context, state) {
                      final isLoading = state is UpdateFolderLoading;
                      return ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () => _updateFolder(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
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
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Updating...'),
                                ],
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.save, size: 16),
                                  const SizedBox(width: 4),
                                  const Text('Update'),
                                ],
                              ),
                      );
                    },
                  ),
                ],
              ),
              if (isLoading)
                Container(
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
                          CircularProgressIndicator(
                            color: Colors.blue,
                            strokeWidth: 2,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Updating folder...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
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

  void _updateFolder(BuildContext context) {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Title cannot be empty'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Get auth token

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

  Widget _iconGrid() {
    final colorScheme = Theme.of(context).colorScheme;
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
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? colorScheme.primary : colorScheme.outline,
                width: selected ? 2 : 1,
              ),
            ),
            child: Icon(
              widget.icons[i],
              color: colorScheme.onSurface,
              size: 20,
            ),
          ),
        );
      }),
    );
  }

  Widget _colorRow() {
    final colorScheme = Theme.of(context).colorScheme;
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
                color: selected ? colorScheme.primary : colorScheme.outline,
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

  Widget _buildShareWithTile(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () async {
        final selectedUsers = await showDialog<List<String>>(
          context: context,
          builder: (dialogContext) => Builder(
            builder: (innerContext) => BlocProvider.value(
              value: context.read<FolderCubit>(),
              child: ShareWithDialog(
                folderTitle: _titleController.text,
                initialUserIds:
                    widget.folder.sharedWith?.map((user) => user.id).toList() ??
                    [],
              ),
            ),
          ),
        );
        if (selectedUsers != null) {
          setState(() {
            _sharedUsers = selectedUsers;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(Icons.share, color: colorScheme.onSurface),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share With',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                  if (_sharedUsers.isNotEmpty)
                    Text(
                      '${_sharedUsers.length} users selected',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    )
                  else
                    Text(
                      'Select users to share with',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
