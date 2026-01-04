import 'package:flutter/material.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';

class FolderPrivacyDropdown extends StatelessWidget {
  final Status selectedStatus;
  final ValueChanged<Status?> onChanged;

  const FolderPrivacyDropdown({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DropdownButtonFormField<Status>(
      value: selectedStatus,
      style: TextStyle(color: colorScheme.onSurface),
      dropdownColor: colorScheme.surfaceContainerHighest,
      decoration: InputDecoration(
        labelText: 'Privacy',
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary),
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
      onChanged: onChanged,
    );
  }
}

class FolderShareTile extends StatelessWidget {
  final int sharedUsersCount;
  final VoidCallback onTap;

  const FolderShareTile({
    super.key,
    required this.sharedUsersCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
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
                  Text(
                    sharedUsersCount > 0
                        ? '$sharedUsersCount users selected'
                        : 'Select users to share with',
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
