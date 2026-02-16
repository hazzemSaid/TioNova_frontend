import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/folder/data/models/foldermodel.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';

import 'folder_option_item.dart';

class FolderOptionsBottomSheet extends StatelessWidget {
  final Foldermodel folder;
  final Color color;
  final VoidCallback onEdit;
  // final VoidCallback onShare;
  // final VoidCallback onDuplicate;
  // final VoidCallback onExportPDF;
  // final VoidCallback onArchive;
  final VoidCallback onDelete;

  const FolderOptionsBottomSheet({
    super.key,
    required this.folder,
    required this.color,
    required this.onEdit,
    // required this.onShare,
    // required this.onDuplicate,
    // required this.onExportPDF,
    // required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final currentUserId =
            authState is AuthSuccess ? authState.user.id : null;
        final isOwner =
            currentUserId != null && currentUserId.toString() == folder.ownerId.toString();
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, right: 20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.close,
                          color: colorScheme.onSurfaceVariant,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:
                      Icon(Icons.folder, color: colorScheme.onSurface, size: 40),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    folder.title,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      folder.status == Status.public
                          ? Icons.public
                          : folder.status == Status.share
                              ? Icons.people
                              : Icons.lock,
                      color: colorScheme.onSurfaceVariant,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      folder.status == Status.public
                          ? 'Public'
                          : folder.status == Status.share
                              ? 'Shared'
                              : 'Private',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.1,
                      ),
                    ),
                    if (!isOwner) ...[
                      SizedBox(width: 8),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'View Only',
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 28),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      if (isOwner) ...[
                        FolderOptionItem(
                          icon: Icons.edit_outlined,
                          label: 'Edit Folder',
                          iconColor: colorScheme.onSurface,
                          textColor: colorScheme.onSurface,
                          onTap: () {
                            Navigator.pop(context);
                            onEdit();
                          },
                        ),
                        Divider(
                          color: colorScheme.outline,
                          height: 1,
                          thickness: 0.5,
                          indent: 52,
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (isOwner)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: FolderOptionItem(
                            icon: Icons.delete_outline,
                            label: 'Delete Folder',
                            iconColor: colorScheme.error,
                            textColor: colorScheme.error,
                            onTap: () {
                              Navigator.pop(context);
                              onDelete();
                            },
                          ),
                        ),
                      const SizedBox(height: 16),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
