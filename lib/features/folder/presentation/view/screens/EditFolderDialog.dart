// features/folder/presentation/view/screens/EditFolderDialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/folder/data/models/FolderModel.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';

class EditFolderDialog extends StatefulWidget {
  final Foldermodel folder;
  final List<Color> defaultcolors;
  final List<IconData> icons;

  const EditFolderDialog({
    required this.folder,
    required this.defaultcolors,
    required this.icons,
  });

  @override
  State<EditFolderDialog> createState() => _EditFolderDialogState();
}

class _EditFolderDialogState extends State<EditFolderDialog> {
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
