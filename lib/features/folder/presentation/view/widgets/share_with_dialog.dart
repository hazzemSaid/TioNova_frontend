import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';

class ShareWithDialog extends StatefulWidget {
  final String folderTitle;
  final List<String> initialUserIds;
  final bool isEdit;
  const ShareWithDialog({
    super.key,
    required this.folderTitle,
    required this.initialUserIds,
    this.isEdit = false,
  });

  @override
  State<ShareWithDialog> createState() => _ShareWithDialogState();
}

class _ShareWithDialogState extends State<ShareWithDialog> {
  String _search = '';
  List<String> _selectedUserIds = [];
  List<dynamic> _availableUsers = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedUserIds = List<String>.from(widget.initialUserIds);
    _fetchUsers();
  }

  void _fetchUsers() async {
    setState(() => _loading = true);

    await context.read<FolderCubit>().getAvailableUsersForShare(query: _search);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 350,
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: const Color(0xFF18181A),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              child: Column(
                children: [
                  const Icon(Icons.groups, color: Colors.white, size: 38),
                  const SizedBox(height: 8),
                  Text(
                    'Shared With',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'People who have access to "${widget.folderTitle}"',
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF8E8E93),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF232325),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 8,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (val) {
                  setState(() => _search = val);
                  _fetchUsers();
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<FolderCubit, FolderState>(
                builder: (context, state) {
                  if (_loading || state is GetAvailableUsersForShareLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is GetAvailableUsersForShareSuccess) {
                    _availableUsers = state.users;
                  }
                  return ListView(
                    shrinkWrap: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4,
                        ),
                        child: Text(
                          '${_availableUsers.length} users',
                          style: const TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      ..._availableUsers.map((user) {
                        final userId = user.id ?? user._id;
                        final userName = user.username ?? '';
                        final userEmail = user.email ?? '';
                        final alreadyShared = widget.initialUserIds.contains(
                          userId,
                        );
                        final selected = _selectedUserIds.contains(userId);
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF232325),
                            child: Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            userName,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            userEmail,
                            style: const TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 12,
                            ),
                          ),
                          trailing: Checkbox(
                            value: selected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedUserIds.add(userId);
                                } else {
                                  _selectedUserIds.remove(userId);
                                }
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              if (selected) {
                                _selectedUserIds.remove(userId);
                              } else {
                                _selectedUserIds.add(userId);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF8E8E93)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Just return the selected user IDs to the parent dialog
                        Navigator.pop(context, _selectedUserIds);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(widget.isEdit ? 'Update' : 'Share'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
