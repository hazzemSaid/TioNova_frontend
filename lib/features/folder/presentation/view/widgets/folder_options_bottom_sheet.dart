import 'package:flutter/material.dart';
import 'package:tionova/features/folder/data/models/FolderModel.dart';

import 'folder_option_item.dart';

class FolderOptionsBottomSheet extends StatelessWidget {
  final Foldermodel folder;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onDuplicate;
  final VoidCallback onExportPDF;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const FolderOptionsBottomSheet({
    super.key,
    required this.folder,
    required this.color,
    required this.onEdit,
    required this.onShare,
    required this.onDuplicate,
    required this.onExportPDF,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
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
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF8E8E93),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // Folder icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.folder, color: Colors.white, size: 40),
            ),

            const SizedBox(height: 16),

            // Folder title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                folder.title,
                style: const TextStyle(
                  color: Colors.white,
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

            // Private label
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, color: Color(0xFF8E8E93), size: 14),
                SizedBox(width: 4),
                Text(
                  'Private',
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Options list
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  FolderOptionItem(
                    icon: Icons.edit_outlined,
                    label: 'Edit Folder',
                    iconColor: const Color(0xFFFFFFFF),
                    textColor: const Color(0xFFFFFFFF),
                    onTap: () {
                      Navigator.pop(context);
                      onEdit();
                    },
                  ),
                  const Divider(
                    color: Color(0xFF3A3A3C),
                    height: 1,
                    thickness: 0.5,
                    indent: 52,
                  ),
                  FolderOptionItem(
                    icon: Icons.share_outlined,
                    label: 'Share Folder',
                    iconColor: const Color(0xFF0A84FF),
                    textColor: const Color(0xFFFFFFFF),
                    onTap: () {
                      Navigator.pop(context);
                      onShare();
                    },
                  ),
                  const Divider(
                    color: Color(0xFF3A3A3C),
                    height: 1,
                    thickness: 0.5,
                    indent: 52,
                  ),
                  FolderOptionItem(
                    icon: Icons.content_copy_outlined,
                    label: 'Duplicate Folder',
                    iconColor: const Color(0xFFBF5AF2),
                    textColor: const Color(0xFFFFFFFF),
                    onTap: () {
                      Navigator.pop(context);
                      onDuplicate();
                    },
                  ),
                  const Divider(
                    color: Color(0xFF3A3A3C),
                    height: 1,
                    thickness: 0.5,
                    indent: 52,
                  ),
                  FolderOptionItem(
                    icon: Icons.picture_as_pdf_outlined,
                    label: 'Export as PDF',
                    iconColor: const Color(0xFF32D74B),
                    textColor: const Color(0xFFFFFFFF),
                    onTap: () {
                      Navigator.pop(context);
                      onExportPDF();
                    },
                  ),
                  const Divider(
                    color: Color(0xFF3A3A3C),
                    height: 1,
                    thickness: 0.5,
                    indent: 52,
                  ),
                  FolderOptionItem(
                    icon: Icons.archive_outlined,
                    label: 'Archive Folder',
                    iconColor: const Color(0xFFFF9500),
                    textColor: const Color(0xFFFFFFFF),
                    onTap: () {
                      Navigator.pop(context);
                      onArchive();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Delete option (separate)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FolderOptionItem(
                icon: Icons.delete_outline,
                label: 'Delete Folder',
                iconColor: const Color(0xFFFF3B30),
                textColor: const Color(0xFFFF3B30),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
            ),

            const SizedBox(height: 16),

            // Cancel button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
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
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}
