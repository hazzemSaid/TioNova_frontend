import 'package:flutter/material.dart';
import 'package:tionova/features/folder/data/models/FolderModel.dart';

import 'folder_option_item.dart';

class FolderOptionsBottomSheet extends StatelessWidget {
  final Foldermodel folder;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FolderOptionsBottomSheet({
    super.key,
    required this.folder,
    required this.color,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.close,
                  color: Color(0xFF8E8E93),
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.folder, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            folder.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
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
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          FolderOptionItem(
            icon: Icons.edit_outlined,
            label: 'Edit Folder',
            iconColor: Colors.white,
            onTap: () => {Navigator.pop(context), onEdit()},
          ),
          const Divider(color: Color(0xFF3A3A3C), height: 1, thickness: 0.5),
          FolderOptionItem(
            icon: Icons.delete_outline,
            label: 'Delete Folder',
            iconColor: const Color(0xFFFF3B30),
            textColor: const Color(0xFFFF3B30),
            onTap: () => {Navigator.pop(context), onDelete()},
          ),
          // Add other options here
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
