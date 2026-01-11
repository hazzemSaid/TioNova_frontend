import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/chapter/data/models/FileDataModel.dart';
import 'package:tionova/features/chapter/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/chapter/presentation/view/widgets/create_chapter/create_chapter_widgets.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';
import 'package:tionova/utils/widgets/custom_dialogs.dart';

/// Screen for creating a new chapter within a folder.
class CreateChapterScreen extends StatefulWidget {
  final String folderTitle;
  final String folderId;

  const CreateChapterScreen({
    super.key,
    required this.folderTitle,
    required this.folderId,
  });

  @override
  State<CreateChapterScreen> createState() => _CreateChapterScreenState();
}

class _CreateChapterScreenState extends State<CreateChapterScreen>
    with SafeContextMixin, TickerProviderStateMixin {
  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // State variables
  FileData? _selectedFile;
  String? _selectedFileName;
  late ChapterCubit _chapterCubit;
  bool _didInitCubit = false;
  bool _didShowSuccessDialog = false;
  bool _isDialogVisible = false;
  bool _isCreatingChapter = false;
  Timer? _timeoutTimer;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Validate folderId
    if (widget.folderId.isEmpty || widget.folderId == 'unknown') {
      debugPrint(
        '❌ [CreateChapterScreen] Invalid folderId: "${widget.folderId}". This will cause chapter creation to fail.',
      );
      // Schedule error dialog after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          CustomDialogs.showErrorDialog(
            context,
            title: 'Error',
            message:
                'Invalid folder ID. Cannot create chapter without a valid folder.',
          ).then((_) {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _waveController.dispose();
    _timeoutTimer?.cancel();
    _didShowSuccessDialog = false;
    _isCreatingChapter = false;
    if (_didInitCubit) {
      _chapterCubit.unsubscribeFromChapterCreationProgress();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitCubit) {
      _chapterCubit = context.read<ChapterCubit>();
      _didInitCubit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isTablet = screenWidth >= 768;
        final isDesktop = screenWidth >= 1024;

        final horizontalPadding = isDesktop
            ? 40.0
            : isTablet
            ? 24.0
            : 12.0;
        final maxContentWidth = isDesktop ? 800.0 : screenWidth;

        return BlocConsumer<ChapterCubit, ChapterState>(
          listener: _handleChapterState,
          builder: (context, state) {
            debugPrint(
              '🏗️ [Builder] Building with state: ${state.runtimeType}',
            );

            final colorScheme = Theme.of(context).colorScheme;
            final isProcessing =
                state is CreateChapterLoading || state is CreateChapterProgress;

            debugPrint('🏗️ [Builder] isProcessing=$isProcessing');

            return WillPopScope(
              onWillPop: () async {
                return !isProcessing && !_isCreatingChapter;
              },
              child: Scaffold(
                backgroundColor: colorScheme.surface,
                appBar: _buildAppBar(
                  colorScheme: colorScheme,
                  isProcessing: isProcessing,
                  isDesktop: isDesktop,
                  isTablet: isTablet,
                ),
                body: Stack(
                  children: [
                    _buildBody(
                      colorScheme: colorScheme,
                      isProcessing: isProcessing,
                      isDesktop: isDesktop,
                      isTablet: isTablet,
                      horizontalPadding: horizontalPadding,
                      maxContentWidth: maxContentWidth,
                    ),
                    _buildProgressOverlay(
                      state: state,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar({
    required ColorScheme colorScheme,
    required bool isProcessing,
    required bool isDesktop,
    required bool isTablet,
  }) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: (isProcessing || _isCreatingChapter)
              ? colorScheme.onSurface.withOpacity(0.3)
              : colorScheme.onSurface,
        ),
        onPressed: () {
          if (!(isProcessing || _isCreatingChapter || _isDialogVisible)) {
            Navigator.pop(context);
          }
        },
      ),
      title: Text(
        'New Chapter in ${widget.folderTitle}',
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: isDesktop
              ? 24
              : isTablet
              ? 22
              : 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildBody({
    required ColorScheme colorScheme,
    required bool isProcessing,
    required bool isDesktop,
    required bool isTablet,
    required double horizontalPadding,
    required double maxContentWidth,
  }) {
    return ScrollConfiguration(
      behavior: NoGlowScrollBehavior(),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isDesktop
                      ? 32
                      : isTablet
                      ? 24
                      : 12,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PDF Upload Section
                      PdfUploadSection(
                        selectedFile: _selectedFile,
                        selectedFileName: _selectedFileName,
                        onPickFile: _pickFile,
                      ),
                      SizedBox(
                        height: isDesktop
                            ? 40
                            : isTablet
                            ? 24
                            : 16,
                      ),

                      // Chapter Details Form
                      ChapterDetailsForm(
                        titleController: _titleController,
                        descriptionController: _descriptionController,
                        onFieldChanged: () => setState(() {}),
                      ),
                      SizedBox(
                        height: isDesktop
                            ? 60
                            : isTablet
                            ? 50
                            : 40,
                      ),

                      // Action Buttons
                      ChapterActionButtons(
                        isProcessing: isProcessing,
                        isDialogVisible: _isDialogVisible,
                        onCancel: () => Navigator.pop(context),
                        onCreate: _createChapter,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressOverlay({
    required ChapterState state,
    required ColorScheme colorScheme,
  }) {
    final bool isLoading = state is CreateChapterLoading;
    final bool isProgress = state is CreateChapterProgress;
    final bool isSuccess = state is CreateChapterSuccess;
    final bool isError = state is CreateChapterError;

    debugPrint(
      '🎨 [ProgressOverlay] state: ${state.runtimeType}, isProgress=$isProgress, isLoading=$isLoading',
    );

    // Hide overlay if success, error, or not processing
    if (isSuccess ||
        isError ||
        (!isLoading && !isProgress && !_isCreatingChapter)) {
      debugPrint('🎨 [ProgressOverlay] Hiding overlay');
      return const SizedBox.shrink();
    }

    final CreateChapterProgress? progressState = state is CreateChapterProgress
        ? state
        : null;
    final int progressValue = progressState != null
        ? progressState.progress.clamp(0, 100)
        : 0;
    final String statusMessage =
        progressState != null && progressState.message.isNotEmpty
        ? progressState.message
        : 'Uploading your materials...';

    debugPrint(
      '🎨 [ProgressOverlay] Showing overlay: progress=$progressValue%, message="$statusMessage"',
    );

    return Positioned.fill(
      child: ChapterCreationProgressOverlay(
        progressValue: progressValue,
        statusMessage: statusMessage,
        waveAnimation: _waveController,
        colorScheme: colorScheme,
      ),
    );
  }

  // ==================== Business Logic Methods ====================

  Future<void> _pickFile() async {
    try {
      print('Starting file picker...');

      FilePickerResult? result;

      try {
        print('Trying custom type with PDF and PPTX extensions...');
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'pptx'],
          allowMultiple: false,
        );
        print('Custom type result: $result');
      } catch (e) {
        print('Custom type failed, trying document type: $e');
        try {
          result = await FilePicker.platform.pickFiles(
            type: FileType.any,
            allowMultiple: false,
          );
          print('Document type result: $result');
        } catch (e2) {
          print('All file picker methods failed: $e2');
          _showManualFileInputDialog();
          return;
        }
      }

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final fileExtension = file.extension?.toLowerCase();
        final fileName = file.name.toLowerCase();

        // Check if file is PDF or PPTX
        if ((fileExtension == 'pdf' || fileName.endsWith('.pdf')) ||
            (fileExtension == 'pptx' || fileName.endsWith('.pptx'))) {
          Uint8List? fileBytes = file.bytes;

          if (fileBytes == null && file.path != null) {
            try {
              final fileData = await File(file.path!).readAsBytes();
              fileBytes = fileData;
            } catch (e) {
              print('Error reading file from path: $e');
            }
          }

          if (fileBytes != null) {
            // Determine MIME type based on extension
            String mimeType;
            if (fileExtension == 'pdf' || fileName.endsWith('.pdf')) {
              mimeType = 'application/pdf';
            } else {
              mimeType =
                  'application/vnd.openxmlformats-officedocument.presentationml.presentation';
            }

            setState(() {
              _selectedFile = FileData(
                bytes: fileBytes!,
                filename: file.name,
                mimeType: mimeType,
              );
              _selectedFileName = file.name;
            });

            CustomDialogs.showSuccessDialog(
              context,
              title: 'Success!',
              message: 'File "${file.name}" selected successfully!',
            );
          } else {
            CustomDialogs.showErrorDialog(
              context,
              title: 'Error!',
              message: 'File content could not be read. Please try again.',
            );
          }
        } else {
          CustomDialogs.showErrorDialog(
            context,
            title: 'Error!',
            message: 'Please select a PDF or PowerPoint (.pptx) file only.',
          );
        }
      }
    } catch (e) {
      print('File picker error: $e');
      CustomDialogs.showErrorDialog(
        context,
        title: 'Error!',
        message: 'Error picking file: ${e.toString()}',
      );
    }
  }

  void _showManualFileInputDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainerHighest,
        title: Text(
          'File Picker Not Available',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: Text(
          'The file picker is not working on this device. For now, you can create a chapter without uploading a PDF file. The PDF upload feature will be available in a future update.',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _createChapter() async {
    print('🚀 _createChapter() called');

    if (_isCreatingChapter) {
      print('⚠️ Already creating chapter, ignoring duplicate tap');
      return;
    }

    // Validation
    if (_titleController.text.trim().isEmpty) {
      print('❌ Title is empty');
      safeContext((ctx) {
        CustomDialogs.showErrorDialog(
          ctx,
          title: 'Error!',
          message: 'Please enter a title',
        );
      });
      return;
    }
    print('✅ Title validation passed: ${_titleController.text.trim()}');

    if (_descriptionController.text.trim().length < 10) {
      safeContext((ctx) {
        CustomDialogs.showErrorDialog(
          ctx,
          title: 'Error!',
          message: 'Description must be at least 10 characters',
        );
      });
      return;
    }

    if (_selectedFile == null) {
      safeContext((ctx) {
        CustomDialogs.showErrorDialog(
          ctx,
          title: 'Error!',
          message: 'Please select a PDF file',
        );
      });
      return;
    }

    // Validate folderId before attempting to create chapter
    if (widget.folderId.isEmpty || widget.folderId == 'unknown') {
      safeContext((ctx) {
        CustomDialogs.showErrorDialog(
          ctx,
          title: 'Error!',
          message:
              'Invalid folder ID. Cannot create chapter. Please go back and try again.',
        );
      });
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) {
      safeContext((ctx) {
        CustomDialogs.showErrorDialog(
          ctx,
          title: 'Error!',
          message: 'Authentication required',
        );
      });
      return;
    }

    setState(() => _isCreatingChapter = true);

    try {
      print('🔥 Subscribing to creation progress...');
      _chapterCubit.subscribeToChapterCreationProgress(
        userId: authState.user.id,
      );

      print(
        '🚀 Initiating chapter creation with folderId: ${widget.folderId}...',
      );
      _chapterCubit.createChapter(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        folderId: widget.folderId,
        file: _selectedFile!,
      );

      _timeoutTimer?.cancel();
      _timeoutTimer = Timer(const Duration(seconds: 120), () {
        if (_isCreatingChapter && mounted) {
          _handleTimeout();
        }
      });
    } catch (e, stackTrace) {
      print('❌ Error in _createChapter: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        setState(() => _isCreatingChapter = false);
      }
      _chapterCubit.unsubscribeFromChapterCreationProgress();

      safeContext((ctx) {
        String errorMessage = 'Failed to create chapter';
        if (e.toString().contains('permission-denied')) {
          errorMessage = 'Permission denied. Please check your connection.';
        } else if (e.toString().contains('network')) {
          errorMessage =
              'Network error. Please check your internet connection.';
        }

        CustomDialogs.showErrorDialog(
          ctx,
          title: 'Error!',
          message: '$errorMessage\n\nDetails: ${e.toString()}',
        );
      });
    }
  }

  void _handleTimeout() {
    print('⏱️ Request timeout - chapter creation took too long');
    _timeoutTimer?.cancel();
    if (mounted) {
      setState(() => _isCreatingChapter = false);
    }
    _chapterCubit.unsubscribeFromChapterCreationProgress();
    safeContext((ctx) {
      CustomDialogs.showErrorDialog(
        ctx,
        title: 'Timeout',
        message:
            'Chapter creation is taking too long. Please check your connection and try again.',
      );
    });
  }

  void _handleChapterState(BuildContext context, ChapterState state) {
    debugPrint('📍 _handleChapterState: ${state.runtimeType}');

    // Handle success first (most important)
    if (state is CreateChapterSuccess) {
      debugPrint('✅ CreateChapterSuccess detected in state handler');

      _timeoutTimer?.cancel();
      if (mounted) {
        setState(() => _isCreatingChapter = false);
      }

      _chapterCubit.unsubscribeFromChapterCreationProgress();

      // Show success dialog if not already shown
      if (!_didShowSuccessDialog && mounted) {
        _didShowSuccessDialog = true;
        debugPrint('📱 Showing success dialog...');

        safeContext((ctx) {
          CustomDialogs.showSuccessDialog(
            ctx,
            title: 'Success!',
            message: 'Chapter created successfully',
            onPressed: () {
              debugPrint('👈 Success dialog dismissed, navigating back');
              // Close the dialog
              Navigator.of(ctx).pop();

              // Pop the CreateChapterScreen
              if (mounted) {
                debugPrint('👈 Popping CreateChapterScreen');
                // Use Navigator.pop() which works with both Navigator and GoRouter
                Navigator.of(context).pop(true);
              }
            },
          );
        });
      }
      return; // Important: prevent other handlers from running
    }

    // Handle errors
    if (state is CreateChapterError) {
      debugPrint('❌ CreateChapterError detected in state handler');

      _timeoutTimer?.cancel();
      if (mounted) {
        setState(() => _isCreatingChapter = false);
      }

      _chapterCubit.unsubscribeFromChapterCreationProgress();

      safeContext((ctx) {
        CustomDialogs.showErrorDialog(
          ctx,
          title: 'Error!',
          message: 'Failed to create chapter: ${state.message.errMessage}',
        );
      });
      return; // Prevent other handlers from running
    }

    // Handle progress
    if (state is CreateChapterProgress) {
      debugPrint('📊 Progress: ${state.progress}% - ${state.message}');
    }
  }
}
