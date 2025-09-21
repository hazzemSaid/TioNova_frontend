import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';

// Map our UI enum to the repository's Status enum
enum FolderPrivacy { private, shared, public }

class CreateFolderDialog extends StatefulWidget {
  const CreateFolderDialog({Key? key}) : super(key: key);

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final List<IconData> _icons = const [
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

  final List<Color> _colors = const [
    Color(0xFF007AFF), // blue
    Color(0xFF34C759), // green
    Color(0xFF8E44AD), // purple
    Color(0xFF7B3F00), // brown-ish
    Color(0xFFFF3B30), // red
    Color(0xFF4B4EFC), // indigo
  ];

  int _selectedIcon = 0;
  int _selectedColor = 0;
  FolderPrivacy _privacy = FolderPrivacy.private;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canCreate = _nameCtrl.text.trim().isNotEmpty;

    return BlocListener<FolderCubit, FolderState>(
      listener: (context, state) {
        if (state is CreateFolderSuccess) {
          // Close the dialog with success result
          Navigator.of(
            context,
          ).pop({'success': true, 'name': _nameCtrl.text.trim()});
        } else if (state is CreateFolderError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message.errMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 480, // keep compact on tablets
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF121214),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2C2C2E), width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: Colors.transparent,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Create New Folder',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              _iconButton(
                                icon: Icons.close,
                                onTap: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        ),

                        // Content scroll
                        Flexible(
                          child: ScrollConfiguration(
                            behavior: const NoGlowScrollBehavior(),
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _previewCard(),
                                  const SizedBox(height: 16),
                                  _label('Folder Name'),
                                  const SizedBox(height: 8),
                                  _textField(
                                    _nameCtrl,
                                    hint: 'Enter folder name...',
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  const SizedBox(height: 16),
                                  _label('Description (Optional)'),
                                  const SizedBox(height: 8),
                                  _textField(
                                    _descCtrl,
                                    hint: 'Brief description...',
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  const SizedBox(height: 20),
                                  _label('Choose Icon'),
                                  const SizedBox(height: 12),
                                  _iconGrid(),
                                  const SizedBox(height: 20),
                                  _label('Choose Color'),
                                  const SizedBox(height: 12),
                                  _colorRow(),
                                  const SizedBox(height: 20),
                                  _label('Privacy Settings'),
                                  const SizedBox(height: 12),
                                  _privacyTile(
                                    icon: Icons.lock_outline,
                                    title: 'Private',
                                    subtitle: 'Only you can access',
                                    value: FolderPrivacy.private,
                                  ),
                                  const SizedBox(height: 10),
                                  _privacyTile(
                                    icon: Icons.group_outlined,
                                    title: 'Shared',
                                    subtitle: 'Invite specific people',
                                    value: FolderPrivacy.shared,
                                  ),
                                  const SizedBox(height: 10),
                                  _privacyTile(
                                    icon: Icons.public,
                                    title: 'Public',
                                    subtitle: 'Anyone can view',
                                    value: FolderPrivacy.public,
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Actions
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: _outlinedButton(
                                  label: 'Cancel',
                                  onTap: () => Navigator.of(context).pop(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: BlocBuilder<FolderCubit, FolderState>(
                                  builder: (context, state) {
                                    final isLoading =
                                        state is CreateFolderloading;

                                    return _primaryButton(
                                      label: isLoading
                                          ? 'Creating...'
                                          : 'Create Folder',
                                      enabled: canCreate && !isLoading,
                                      onTap: canCreate && !isLoading
                                          ? () {
                                              // Get token from AuthCubit
                                              final authState = context
                                                  .read<AuthCubit>()
                                                  .state;
                                              if (authState is AuthSuccess) {
                                                // Convert FolderPrivacy to Status
                                                final status =
                                                    _privacy ==
                                                        FolderPrivacy.private
                                                    ? Status.private
                                                    : Status.public;

                                                // Use folder cubit to create folder
                                                context.read<FolderCubit>().createfolder(
                                                  title: _nameCtrl.text.trim(),
                                                  description: _descCtrl.text
                                                      .trim(),
                                                  category:
                                                      'General', // Default category
                                                  token: authState.token,
                                                  status: status,
                                                  icon: _selectedIcon
                                                      .toString(), // Store icon index as string
                                                  color:
                                                      '#${_colors[_selectedColor].value.toRadixString(16).padLeft(8, '0').substring(2)}', // Store color as hex string
                                                );
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Authentication required',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                                Navigator.of(context).pop();
                                              }
                                            }
                                          : null,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _previewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _colors[_selectedColor],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icons[_selectedIcon], color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameCtrl.text.isEmpty ? 'Folder Name' : _nameCtrl.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _descCtrl.text.isEmpty
                      ? 'Folder description'
                      : _descCtrl.text,
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _textField(
    TextEditingController ctrl, {
    required String hint,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: ctrl,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
        filled: true,
        fillColor: const Color(0xFF111113),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF2C2C2E)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF007AFF)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _iconGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_icons.length, (i) {
        final selected = i == _selectedIcon;
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = i),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF111113),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? const Color(0xFF007AFF)
                    : const Color(0xFF2C2C2E),
                width: selected ? 1.4 : 1,
              ),
            ),
            child: Icon(_icons[i], color: Colors.white, size: 20),
          ),
        );
      }),
    );
  }

  Widget _colorRow() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(_colors.length, (i) {
        final selected = i == _selectedColor;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = i),
          child: Container(
            width: 44,
            height: 32,
            decoration: BoxDecoration(
              color: _colors[i].withOpacity(0.22),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? const Color(0xFF007AFF)
                    : const Color(0xFF2C2C2E),
                width: selected ? 1.4 : 1,
              ),
            ),
            child: Center(
              child: Container(
                width: 22,
                height: 14,
                decoration: BoxDecoration(
                  color: _colors[i],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _privacyTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required FolderPrivacy value,
  }) {
    final selected = _privacy == value;
    return GestureDetector(
      onTap: () => setState(() => _privacy = value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF3A3A3C) : const Color(0xFF2C2C2E),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: Colors.white, size: 18)
            else
              const Icon(
                Icons.radio_button_unchecked,
                color: Color(0xFF6A6A6A),
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _outlinedButton({required String label, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2C2C2E)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    final bg = enabled ? Colors.white : const Color(0xFF3A3A3C);
    final fg = enabled ? Colors.black : const Color(0xFF8E8E93);
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
