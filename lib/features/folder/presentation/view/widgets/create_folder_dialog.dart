import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/features/folder/presentation/view/widgets/share_with_dialog.dart';
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

  List<String> _sharedUserIds = [];
  String? _token;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _openShareWithDialog() async {
    if (_token == null) return;
    final result = await showDialog<List<String>>(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<FolderCubit>(),
        child: ShareWithDialog(
          folderTitle: _nameCtrl.text.isEmpty ? 'Folder Name' : _nameCtrl.text,
          initialUserIds: _sharedUserIds,
          isEdit: false,
        ),
      ),
    );
    if (result != null) {
      setState(() => _sharedUserIds = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canCreate = _nameCtrl.text.trim().isNotEmpty;
    _token ??= context.read<AuthCubit>().state is AuthSuccess
        ? (context.read<AuthCubit>().state as AuthSuccess).token
        : null;

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
              backgroundColor: colorScheme.error,
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
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline, width: 1),
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
                                  if (_privacy == FolderPrivacy.shared) ...[
                                    const SizedBox(height: 10),
                                    _label('Share With'),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: _openShareWithDialog,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.surfaceContainer,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: colorScheme.outline,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.person_add,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _sharedUserIds.isEmpty
                                                    ? 'Select users to share with'
                                                    : '${_sharedUserIds.length} user(s) selected',
                                                style: TextStyle(
                                                  color: colorScheme.onSurface,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.chevron_right,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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
                                              final authState = context
                                                  .read<AuthCubit>()
                                                  .state;
                                              if (authState is AuthSuccess) {
                                                final status =
                                                    _privacy ==
                                                        FolderPrivacy.private
                                                    ? Status.private
                                                    : Status.public;
                                                context
                                                    .read<FolderCubit>()
                                                    .createfolder(
                                                      title: _nameCtrl.text
                                                          .trim(),
                                                      description: _descCtrl
                                                          .text
                                                          .trim(),
                                                      category: 'General',
                                                      token: authState.token,
                                                      status: status,
                                                      icon: _selectedIcon
                                                          .toString(),
                                                      color:
                                                          '#${_colors[_selectedColor].value.toRadixString(16).padLeft(8, '0').substring(2)}',
                                                      sharedWith:
                                                          _privacy ==
                                                              FolderPrivacy
                                                                  .shared
                                                          ? _sharedUserIds
                                                          : null,
                                                    );
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Authentication required',
                                                    ),
                                                    backgroundColor:
                                                        colorScheme.error,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
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
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _descCtrl.text.isEmpty
                      ? 'Folder description'
                      : _descCtrl.text,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
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

  Widget _label(String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _textField(
    TextEditingController ctrl, {
    required String hint,
    ValueChanged<String>? onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: ctrl,
      onChanged: onChanged,
      style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _iconGrid() {
    final colorScheme = Theme.of(context).colorScheme;
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
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? colorScheme.primary : colorScheme.outline,
                width: selected ? 1.4 : 1,
              ),
            ),
            child: Icon(_icons[i], color: colorScheme.onSurface, size: 20),
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
                color: selected ? colorScheme.primary : colorScheme.outline,
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
    final colorScheme = Theme.of(context).colorScheme;
    final selected = _privacy == value;
    return GestureDetector(
      onTap: () => setState(() => _privacy = value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outline,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colorScheme.onSurface, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle,
                color: colorScheme.onPrimaryContainer,
                size: 18,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: colorScheme.onSurfaceVariant,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton({required IconData icon, VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: colorScheme.onSurface, size: 16),
      ),
    );
  }

  Widget _outlinedButton({required String label, VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    final bg = enabled ? colorScheme.primary : colorScheme.surfaceVariant;
    final fg = enabled ? colorScheme.onPrimary : colorScheme.onSurfaceVariant;
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
