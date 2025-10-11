import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';

void showDeleteConfirmationDialog(
  BuildContext context,
  String folderId,
  String folderName,
  FolderCubit folderCubit,
) {
  showDialog(
    context: context,
      barrierColor: Colors.black.withOpacity(0.7),
    builder: (BuildContext dialogContext) {
      return BlocProvider.value(
        value: folderCubit,
        child: BlocConsumer<FolderCubit, FolderState>(
          listener: (context, state) {
            if (state is DeleteFolderSuccess) {
              // Store context reference before closing dialogs
              final scaffoldContext = context;

              // Close the dialog if it's still mounted
              if (Navigator.of(context).canPop()) {
                context.pop();
              }
              // Close the bottom sheet if it's still mounted
              if (Navigator.of(context).canPop()) {
                context.pop();
              }
              
              // Show success notification using the stored context
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (scaffoldContext.mounted) {
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    const SnackBar(
                      content: Text('Folder deleted successfully'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              });
            }
            if (state is DeleteFolderError) {
              // Show detailed error message with retry option
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message as String
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: () {
                      // Retry logic with current folder cubit
                      final authState = context.read<AuthCubit>().state as AuthSuccess;
                      final token = authState.token;
                      BlocProvider.of<FolderCubit>(context)
                          .deletefolder(id: folderId, token: token);
                    },
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            return Dialog(
              backgroundColor: const Color(0xFF1C1C1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Warning Icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Title
                    const Text(
                      'Delete Folder?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Description
                    Text(
                      'This will permanently delete the folder and all its chapters. All study materials, quizzes, and chat history will be lost.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Folder name
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '"$folderName"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // This action cannot be undone
                    Text(
                      'This action cannot be undone.',
                      style: TextStyle(
                        color: Colors.red.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Delete Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final stateauth = context.read<AuthCubit>().state as AuthSuccess;
                          final token = stateauth.token;
                          BlocProvider.of<FolderCubit>(context)
                              .deletefolder(id: folderId, token: token);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: state is DeleteFolderLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Delete Folder',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            context.pop(); // Close the dialog
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF8E8E93),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}