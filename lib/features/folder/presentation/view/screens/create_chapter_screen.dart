// features/folder/presentation/view/screens/create_chapter_screen.dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/folder/data/models/FileDataModel.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/view/widgets/WavyProgressPainter.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';
import 'package:tionova/utils/widgets/custom_dialogs.dart';

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
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  FileData? _selectedFile;
  String? _selectedFileName;
  late ChapterCubit _chapterCubit;
  bool _didInitCubit = false;
  bool _didShowSuccessDialog = false;
  bool _isDialogVisible = false;
  late AnimationController _waveController;
  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _waveController.dispose();
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

  Future<void> _pickFile() async {
    try {
      print('Starting file picker...');

      // Try different file picker methods based on platform
      FilePickerResult? result;

      // First try the custom type with PDF extension
      try {
        print('Trying custom type with PDF extension...');
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          allowMultiple: false,
        );
        print('Custom type result: $result');
      } catch (e) {
        // If custom type fails, try with document type
        print('Custom type failed, trying document type: $e');
        try {
          result = await FilePicker.platform.pickFiles(
            type: FileType.any,
            allowMultiple: false,
          );
          print('Document type result: $result');
        } catch (e2) {
          // If all file picker methods fail, show a dialog for manual file name input
          print('All file picker methods failed: $e2');
          _showManualFileInputDialog();
          return;
        }
      }

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Validate that it's a PDF file
        if (file.extension?.toLowerCase() == 'pdf' ||
            file.name.toLowerCase().endsWith('.pdf')) {
          // Try to get file bytes, either from memory or by reading the file
          Uint8List? fileBytes = file.bytes;

          if (fileBytes == null && file.path != null) {
            // If bytes are null but path exists, try to read the file
            try {
              final fileData = await File(file.path!).readAsBytes();
              fileBytes = fileData;
            } catch (e) {
              print('Error reading file from path: $e');
            }
          }

          if (fileBytes != null) {
            setState(() {
              _selectedFile = FileData(
                bytes: fileBytes!,
                filename: file.name,
                mimeType: 'application/pdf',
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
            message: 'Please select a PDF file only.',
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

    if (_titleController.text.trim().isEmpty) {
      print('❌ Title is empty');
      CustomDialogs.showErrorDialog(
        context,
        title: 'Error!',
        message: 'Please enter a title',
      );
      return;
    }
    print('✅ Title validation passed: ${_titleController.text.trim()}');

    if (_descriptionController.text.trim().length < 10) {
      CustomDialogs.showErrorDialog(
        context,
        title: 'Error!',
        message: 'Description must be at least 10 characters',
      );
      return;
    }

    if (_selectedFile == null) {
      CustomDialogs.showErrorDialog(
        context,
        title: 'Error!',
        message: 'Please select a PDF file',
      );
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      try {
        _chapterCubit.subscribeToChapterCreationProgress(
          userId: authState.user.id,
        );
        _chapterCubit.createChapter(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          folderId: widget.folderId,
          file: _selectedFile!,
        );
      } catch (e) {
        if (mounted) {
          CustomDialogs.showErrorDialog(
            context,
            title: 'Error!',
            message: 'Failed to create chapter: ${e.toString()}',
          );
        }
      }
    } else {
      CustomDialogs.showErrorDialog(
        context,
        title: 'Error!',
        message: 'Authentication required',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isTablet = screenWidth >= 768;
        final isDesktop = screenWidth >= 1024;

        // Responsive padding and sizing
        final horizontalPadding = isDesktop
            ? 40.0
            : isTablet
            ? 24.0
            : 12.0;
        final maxContentWidth = isDesktop ? 800.0 : screenWidth;

        return BlocConsumer<ChapterCubit, ChapterState>(
          listener: _handleChapterState,
          builder: (context, state) {
            final colorScheme = Theme.of(context).colorScheme;
            final isProcessing =
                state is CreateChapterLoading || state is CreateChapterProgress;
            return WillPopScope(
              onWillPop: () async => !(isProcessing || _isDialogVisible),
              child: Scaffold(
                backgroundColor: colorScheme.surface,
                appBar: AppBar(
                  backgroundColor: colorScheme.surface,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                    onPressed: () {
                      if (!(isProcessing || _isDialogVisible)) {
                        // Properly close the IconButton and continue the widget tree
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
                ),
                body: Stack(
                  children: [
                    ScrollConfiguration(
                      behavior: NoGlowScrollBehavior(),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: maxContentWidth,
                          ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Upload PDF section
                                      Builder(
                                        builder: (context) {
                                          final screenWidth = MediaQuery.of(
                                            context,
                                          ).size.width;
                                          final isTablet = screenWidth >= 768;
                                          final isDesktop = screenWidth >= 1024;
                                          final colorScheme = Theme.of(
                                            context,
                                          ).colorScheme;

                                          return Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              margin: EdgeInsets.all(
                                                isDesktop
                                                    ? 40
                                                    : isTablet
                                                    ? 30
                                                    : 20,
                                              ),
                                              height: isDesktop
                                                  ? 380
                                                  : isTablet
                                                  ? 340
                                                  : 300,
                                              decoration: BoxDecoration(
                                                color:
                                                    colorScheme.surfaceVariant,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      isDesktop ? 16 : 12,
                                                    ),
                                                border: Border.all(
                                                  color: colorScheme.outline,
                                                  width: 2,
                                                  style: BorderStyle.solid,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  // Icon
                                                  Container(
                                                    width: isDesktop
                                                        ? 80
                                                        : isTablet
                                                        ? 70
                                                        : 60,
                                                    height: isDesktop
                                                        ? 80
                                                        : isTablet
                                                        ? 70
                                                        : 60,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          colorScheme.surface,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .description_outlined,
                                                      color:
                                                          _selectedFile != null
                                                          ? colorScheme.primary
                                                          : colorScheme
                                                                .onSurfaceVariant,
                                                      size: isDesktop
                                                          ? 40
                                                          : isTablet
                                                          ? 35
                                                          : 30,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: isDesktop
                                                        ? 20
                                                        : isTablet
                                                        ? 16
                                                        : 12,
                                                  ),

                                                  // Title text
                                                  Text(
                                                    _selectedFile != null
                                                        ? 'File Selected'
                                                        : 'Upload PDF Files',
                                                    style: TextStyle(
                                                      color:
                                                          colorScheme.onSurface,
                                                      fontSize: isDesktop
                                                          ? 20
                                                          : isTablet
                                                          ? 18
                                                          : 16,
                                                      fontWeight:
                                                          _selectedFile != null
                                                          ? FontWeight.w500
                                                          : FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: isDesktop ? 8 : 6,
                                                  ),

                                                  // Subtitle text
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 24,
                                                        ),
                                                    child: Text(
                                                      _selectedFile != null
                                                          ? _selectedFileName ??
                                                                ''
                                                          : 'Click to browse or drag and drop\nPDF files here',
                                                      style: TextStyle(
                                                        color: colorScheme
                                                            .onSurfaceVariant,
                                                        fontSize: isDesktop
                                                            ? 14
                                                            : isTablet
                                                            ? 13
                                                            : 12,
                                                        height: 1.4,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: isDesktop
                                                        ? 24
                                                        : isTablet
                                                        ? 20
                                                        : 16,
                                                  ),

                                                  // Choose PDF Files Button
                                                  ElevatedButton.icon(
                                                    onPressed: _pickFile,
                                                    icon: Icon(
                                                      Icons.upload_file,
                                                      color:
                                                          _selectedFile != null
                                                          ? colorScheme
                                                                .onPrimary
                                                          : colorScheme
                                                                .onSurfaceVariant,
                                                      size: isDesktop ? 20 : 18,
                                                    ),
                                                    label: Text(
                                                      _selectedFile == null
                                                          ? 'Choose PDF Files'
                                                          : 'Rechange PDF Files',
                                                      style: TextStyle(
                                                        fontSize: isDesktop
                                                            ? 16
                                                            : isTablet
                                                            ? 15
                                                            : 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          colorScheme.primary,
                                                      foregroundColor:
                                                          colorScheme.onPrimary,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal:
                                                                isDesktop
                                                                ? 28
                                                                : isTablet
                                                                ? 24
                                                                : 20,
                                                            vertical: isDesktop
                                                                ? 16
                                                                : isTablet
                                                                ? 14
                                                                : 12,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      elevation: 0,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: isDesktop
                                                        ? 12
                                                        : isTablet
                                                        ? 10
                                                        : 8,
                                                  ),

                                                  // Max file size text
                                                  Text(
                                                    'Max file size: 50MB per file',
                                                    style: TextStyle(
                                                      color: colorScheme
                                                          .onSurfaceVariant,
                                                      fontSize: isDesktop
                                                          ? 13
                                                          : isTablet
                                                          ? 12
                                                          : 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(
                                        height: isDesktop
                                            ? 40
                                            : isTablet
                                            ? 24
                                            : 16,
                                      ),
                                      // Chapter Details Section
                                      Builder(
                                        builder: (context) {
                                          final colorScheme = Theme.of(
                                            context,
                                          ).colorScheme;
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: colorScheme
                                                  .surfaceContainerHighest,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    isDesktop ? 24 : 16,
                                                  ),
                                              border: Border.all(
                                                color: colorScheme.outline,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                isDesktop ? 24 : 16,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Chapter Details',
                                                    style: TextStyle(
                                                      color:
                                                          colorScheme.onSurface,
                                                      fontSize: isDesktop
                                                          ? 24
                                                          : isTablet
                                                          ? 22
                                                          : 20,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: isDesktop ? 24 : 16,
                                                  ),
                                                  _buildFormField(
                                                    label: 'Title',
                                                    hint: 'Enter chapter title',
                                                    controller:
                                                        _titleController,
                                                    isRequired: true,
                                                    // ...existing code...
                                                  ),
                                                  SizedBox(
                                                    height: isDesktop ? 24 : 16,
                                                  ),
                                                  _buildFormField(
                                                    label: 'Description',
                                                    hint:
                                                        'Enter chapter description (at least 10 characters)',
                                                    controller:
                                                        _descriptionController,
                                                    isRequired: true,
                                                    maxLines: 3,
                                                    showCharCount: true,
                                                    // ...existing code...
                                                  ),
                                                  SizedBox(
                                                    height: isDesktop ? 24 : 16,
                                                  ),
                                                  // _buildDropdown(),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      SizedBox(
                                        height: isDesktop
                                            ? 60
                                            : isTablet
                                            ? 50
                                            : 40,
                                      ),

                                      // Bottom buttons
                                      Builder(
                                        builder: (context) {
                                          final colorScheme = Theme.of(
                                            context,
                                          ).colorScheme;
                                          return isDesktop
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 180,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if (!(isProcessing ||
                                                              _isDialogVisible)) {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                          height: isDesktop
                                                              ? 60
                                                              : isTablet
                                                              ? 54
                                                              : 48,
                                                          decoration: BoxDecoration(
                                                            color: Colors
                                                                .transparent,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  isDesktop
                                                                      ? 30
                                                                      : isTablet
                                                                      ? 27
                                                                      : 24,
                                                                ),
                                                            border: Border.all(
                                                              color: colorScheme
                                                                  .outline,
                                                            ),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              'Cancel',
                                                              style: TextStyle(
                                                                color: colorScheme
                                                                    .onSurface,
                                                                fontSize:
                                                                    isDesktop
                                                                    ? 20
                                                                    : isTablet
                                                                    ? 18
                                                                    : 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: isDesktop
                                                          ? 32
                                                          : isTablet
                                                          ? 20
                                                          : 12,
                                                    ),
                                                    SizedBox(
                                                      width: 180,
                                                      child: GestureDetector(
                                                        onTap: isProcessing
                                                            ? null
                                                            : _createChapter,
                                                        child: Container(
                                                          height: isDesktop
                                                              ? 60
                                                              : isTablet
                                                              ? 54
                                                              : 48,
                                                          decoration: BoxDecoration(
                                                            color: isProcessing
                                                                ? colorScheme
                                                                      .surfaceVariant
                                                                : colorScheme
                                                                      .primary,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  isDesktop
                                                                      ? 30
                                                                      : isTablet
                                                                      ? 27
                                                                      : 24,
                                                                ),
                                                          ),
                                                          child: Center(
                                                            child: _buildCreateButtonChild(
                                                              isProcessing:
                                                                  isProcessing,
                                                              isTablet:
                                                                  isTablet,
                                                              colorScheme:
                                                                  colorScheme,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Row(
                                                  children: [
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if (!(isProcessing ||
                                                              _isDialogVisible)) {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                          height: isTablet
                                                              ? 54
                                                              : 48,
                                                          decoration: BoxDecoration(
                                                            color: Colors
                                                                .transparent,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  isTablet
                                                                      ? 27
                                                                      : 24,
                                                                ),
                                                            border: Border.all(
                                                              color: colorScheme
                                                                  .outline,
                                                            ),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              'Cancel',
                                                              style: TextStyle(
                                                                color: colorScheme
                                                                    .onSurface,
                                                                fontSize:
                                                                    isTablet
                                                                    ? 18
                                                                    : 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: isTablet ? 20 : 12,
                                                    ),
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: isProcessing
                                                            ? null
                                                            : _createChapter,
                                                        child: Container(
                                                          height: isTablet
                                                              ? 54
                                                              : 48,
                                                          decoration: BoxDecoration(
                                                            color: isProcessing
                                                                ? colorScheme
                                                                      .surfaceVariant
                                                                : colorScheme
                                                                      .primary,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  isTablet
                                                                      ? 27
                                                                      : 24,
                                                                ),
                                                          ),
                                                          child: Center(
                                                            child: _buildCreateButtonChild(
                                                              isProcessing:
                                                                  isProcessing,
                                                              isTablet:
                                                                  isTablet,
                                                              colorScheme:
                                                                  colorScheme,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildCreationProgressOverlay(
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
    // End of build method
  }

  Widget _buildCreateButtonChild({
    required bool isProcessing,
    required bool isTablet,
    required ColorScheme colorScheme,
  }) {
    if (!isProcessing) {
      return Text(
        'Create Chapter',
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: isTablet ? 18 : 16,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onSurface),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Processing...',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _handleChapterState(BuildContext context, ChapterState state) {
    if (state is CreateChapterError) {
      _chapterCubit.unsubscribeFromChapterCreationProgress();
      _isDialogVisible = true;
      CustomDialogs.showErrorDialog(
        context,
        title: 'Error!',
        message: 'Failed to create chapter: ${state.message.errMessage}',
        onPressed: () {
          _isDialogVisible = false;
        },
      );
      return;
    }

    if (state is CreateChapterSuccess && !_didShowSuccessDialog) {
      _chapterCubit.unsubscribeFromChapterCreationProgress();
      _didShowSuccessDialog = true;
      _isDialogVisible = true;
      CustomDialogs.showSuccessDialog(
        context,
        title: 'Success!',
        message: 'Chapter created successfully!',
        onPressed: () {
          // Refresh chapters after dialog closes
          _chapterCubit.getChapters(folderId: widget.folderId);
          _isDialogVisible = false;
          safeContext((ctx) {
            if (ctx.canPop()) Navigator.of(ctx).pop();
          });
        },
      );
    }
  }

  Widget _buildCreationProgressOverlay({
    required ChapterState state,
    required ColorScheme colorScheme,
  }) {
    final bool isLoading = state is CreateChapterLoading;
    final bool isProgress = state is CreateChapterProgress;

    if (!isLoading && !isProgress) {
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

    return Positioned.fill(
      child: Builder(
        builder: (context) {
          final screenWidth = MediaQuery.of(context).size.width;
          final isTablet = screenWidth >= 768;
          final isDesktop = screenWidth >= 1024;

          return Container(
            color: colorScheme.scrim.withOpacity(0.55),
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop
                      ? 500
                      : isTablet
                      ? 440
                      : 360,
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: isDesktop
                      ? 0
                      : isTablet
                      ? 0
                      : 24,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop
                      ? 32
                      : isTablet
                      ? 28
                      : 24,
                  vertical: isDesktop
                      ? 36
                      : isTablet
                      ? 32
                      : 28,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(
                    isDesktop
                        ? 36
                        : isTablet
                        ? 32
                        : 28,
                  ),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
                      blurRadius: isDesktop ? 40 : 30,
                      offset: Offset(0, isDesktop ? 24 : 20),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Creating Your Chapter',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: isDesktop
                              ? 26
                              : isTablet
                              ? 24
                              : 20,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: isDesktop
                            ? 8
                            : isTablet
                            ? 6
                            : 6,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop
                              ? 16
                              : isTablet
                              ? 8
                              : 4,
                        ),
                        child: Text(
                          "We're processing your materials and generating AI-powered content",
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: isDesktop
                                ? 17
                                : isTablet
                                ? 16
                                : 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: isDesktop
                            ? 28
                            : isTablet
                            ? 24
                            : 20,
                      ),
                      Container(
                        width: isDesktop
                            ? 240
                            : isTablet
                            ? 220
                            : 200,
                        height: isDesktop
                            ? 280
                            : isTablet
                            ? 260
                            : 230,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(
                            isDesktop ? 32 : 28,
                          ),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withOpacity(0.08),
                              blurRadius: isDesktop ? 20 : 18,
                              offset: Offset(0, isDesktop ? 16 : 14),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Percentage and Processing text
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$progressValue%',
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: isDesktop
                                        ? 40
                                        : isTablet
                                        ? 36
                                        : 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: isDesktop ? 8 : 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: isDesktop ? 18 : 16,
                                      height: isDesktop ? 18 : 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: isDesktop ? 8 : 6),
                                    Text(
                                      'Processing',
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: isDesktop
                                            ? 15
                                            : isTablet
                                            ? 14
                                            : 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Animated wavy progress bar at the bottom
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(
                                    isDesktop ? 32 : 28,
                                  ),
                                  bottomRight: Radius.circular(
                                    isDesktop ? 32 : 28,
                                  ),
                                ),
                                child: AnimatedBuilder(
                                  animation: _waveController,
                                  builder: (context, child) {
                                    return SizedBox(
                                      width: isDesktop
                                          ? 220
                                          : isTablet
                                          ? 200
                                          : 180,
                                      height: isDesktop
                                          ? 260
                                          : isTablet
                                          ? 240
                                          : 210,
                                      child: CustomPaint(
                                        painter: WavyProgressPainter(
                                          progress: progressValue / 100.0,
                                          waveOffset:
                                              _waveController.value *
                                              2 *
                                              math.pi,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: isDesktop
                            ? 28
                            : isTablet
                            ? 24
                            : 20,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop
                              ? 16
                              : isTablet
                              ? 8
                              : 0,
                        ),
                        child: Text(
                          statusMessage,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: isDesktop
                                ? 17
                                : isTablet
                                ? 16
                                : 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 20 : 18),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop
                              ? 20
                              : isTablet
                              ? 16
                              : 14,
                          vertical: isDesktop ? 14 : 12,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(
                            isDesktop ? 18 : 16,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.tips_and_updates,
                              color: colorScheme.primary,
                              size: isDesktop ? 20 : 18,
                            ),
                            SizedBox(width: isDesktop ? 10 : 8),
                            Flexible(
                              child: Text(
                                'Tip: You can add multiple PDFs and videos to each chapter',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: isDesktop
                                      ? 14
                                      : isTablet
                                      ? 13
                                      : 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isRequired = false,
    int maxLines = 1,
    bool showCharCount = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w500,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: colorScheme.error,
                    fontSize: isTablet ? 18 : 16,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 10 : 8),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Stack(
            children: [
              TextField(
                controller: controller,
                maxLines: maxLines,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: isTablet ? 16 : 14,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: isTablet ? 16 : 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(isTablet ? 16 : 12),
                ),
                onChanged: (text) {
                  setState(() {});
                },
              ),
              if (showCharCount)
                Positioned(
                  bottom: isTablet ? 12 : 8,
                  right: isTablet ? 16 : 12,
                  child: Text(
                    '${_descriptionController.text.length}/200',
                    style: TextStyle(
                      color: _descriptionController.text.length < 10
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
