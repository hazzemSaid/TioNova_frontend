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

  // final List<String> categories = [
  //   'Select a category',
  //   'Technology',
  //   'Science',
  //   'Mathematics',
  //   'Physics',
  //   'Literature',
  //   'History',
  // ];

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

    // Get auth token
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
          token: authState.token,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;

    // Responsive padding and sizing
    final horizontalPadding = isDesktop
        ? 40.0
        : isTablet
        ? 24.0
        : 16.0;
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
                  Navigator.pop(context);
                }
              },
            ),
            title: Text(
              'New Chapter in ${widget.folderTitle}',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 20,
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
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: 16,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Upload PDF section
                                Align(
                                  alignment: Alignment.center,
                                  child: Builder(
                                    builder: (context) {
                                      final colorScheme = Theme.of(
                                        context,
                                      ).colorScheme;
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: colorScheme.outline,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.upload_file,
                                                    color:
                                                        colorScheme.onSurface,
                                                    size: isTablet ? 24 : 22,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Upload PDF Document',
                                                    style: TextStyle(
                                                      color:
                                                          colorScheme.onSurface,
                                                      fontSize: isTablet
                                                          ? 22
                                                          : 20,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Upload your study material as a PDF file (max 10MB)",
                                                style: TextStyle(
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                  fontSize: isTablet ? 16 : 14,
                                                ),
                                              ),
                                              const SizedBox(height: 16),

                                              // Drop zone
                                              Align(
                                                alignment: Alignment.center,
                                                child: GestureDetector(
                                                  onTap: _pickFile,
                                                  child: Container(
                                                    margin: EdgeInsets.all(
                                                      isTablet ? 20 : 16,
                                                    ),
                                                    height: isTablet
                                                        ? 160
                                                        : 140,
                                                    decoration: BoxDecoration(
                                                      color: colorScheme
                                                          .surfaceVariant,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      border: Border.all(
                                                        color:
                                                            colorScheme.outline,
                                                        style:
                                                            BorderStyle.solid,
                                                      ),
                                                    ),
                                                    child: SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          SizedBox(
                                                            height: isTablet
                                                                ? 12
                                                                : 8,
                                                          ),
                                                          if (_selectedFile !=
                                                              null) ...[
                                                            Container(
                                                              width: 48,
                                                              height: 48,
                                                              decoration: BoxDecoration(
                                                                color: colorScheme
                                                                    .tertiary
                                                                    .withOpacity(
                                                                      0.2,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                                border: Border.all(
                                                                  color: colorScheme
                                                                      .tertiary,
                                                                  width: 2,
                                                                ),
                                                              ),
                                                              child: Icon(
                                                                Icons
                                                                    .check_circle,
                                                                color: colorScheme
                                                                    .tertiary,
                                                                size: 24,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: isTablet
                                                                  ? 10
                                                                  : 6,
                                                            ),
                                                            Text(
                                                              'File Selected',
                                                              style: TextStyle(
                                                                color: colorScheme
                                                                    .tertiary,
                                                                fontSize:
                                                                    isTablet
                                                                    ? 16
                                                                    : 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: isTablet
                                                                  ? 4
                                                                  : 2,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        12,
                                                                  ),
                                                              child: Text(
                                                                _selectedFileName ??
                                                                    'Unknown file',
                                                                style: TextStyle(
                                                                  color: colorScheme
                                                                      .onSurface,
                                                                  fontSize:
                                                                      isTablet
                                                                      ? 12
                                                                      : 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: isTablet
                                                                  ? 6
                                                                  : 4,
                                                            ),
                                                            Container(
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        isTablet
                                                                        ? 14
                                                                        : 12,
                                                                    vertical:
                                                                        isTablet
                                                                        ? 6
                                                                        : 4,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: colorScheme
                                                                    .tertiary
                                                                    .withOpacity(
                                                                      0.1,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                              ),
                                                              child: Text(
                                                                'Tap to change file',
                                                                style: TextStyle(
                                                                  color: colorScheme
                                                                      .tertiary,
                                                                  fontSize:
                                                                      isTablet
                                                                      ? 10
                                                                      : 9,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ),
                                                          ] else ...[
                                                            Container(
                                                              width: 48,
                                                              height: 48,
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    colorScheme
                                                                        .surface,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                              ),
                                                              child: Icon(
                                                                Icons
                                                                    .description_outlined,
                                                                color: colorScheme
                                                                    .onSurface,
                                                                size: 24,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: isTablet
                                                                  ? 10
                                                                  : 6,
                                                            ),
                                                            Text(
                                                              'Choose PDF file',
                                                              style: TextStyle(
                                                                color: colorScheme
                                                                    .onSurface,
                                                                fontSize:
                                                                    isTablet
                                                                    ? 16
                                                                    : 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: isTablet
                                                                  ? 4
                                                                  : 2,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        12,
                                                                  ),
                                                              child: Text(
                                                                'Click to browse or drag and drop your PDF here',
                                                                style: TextStyle(
                                                                  color: colorScheme
                                                                      .onSurfaceVariant,
                                                                  fontSize:
                                                                      isTablet
                                                                      ? 12
                                                                      : 10,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: isTablet
                                                                  ? 6
                                                                  : 4,
                                                            ),
                                                            Container(
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        isTablet
                                                                        ? 14
                                                                        : 12,
                                                                    vertical:
                                                                        isTablet
                                                                        ? 6
                                                                        : 4,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: colorScheme
                                                                    .surfaceContainerHighest,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                              ),
                                                              child: Text(
                                                                'PDF files only',
                                                                style: TextStyle(
                                                                  color: colorScheme
                                                                      .onSurfaceVariant,
                                                                  fontSize:
                                                                      isTablet
                                                                      ? 10
                                                                      : 9,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                          SizedBox(
                                                            height: isTablet
                                                                ? 12
                                                                : 8,
                                                          ),
                                                        ],
                                                      ),
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
                                ),

                                const SizedBox(height: 24),

                                // Chapter Details Section
                                Builder(
                                  builder: (context) {
                                    final colorScheme = Theme.of(
                                      context,
                                    ).colorScheme;
                                    return Container(
                                      decoration: BoxDecoration(
                                        color:
                                            colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: colorScheme.outline,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Chapter Details',
                                              style: TextStyle(
                                                color: colorScheme.onSurface,
                                                fontSize: isTablet ? 22 : 20,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            _buildFormField(
                                              label: 'Title',
                                              hint: 'Enter chapter title',
                                              controller: _titleController,
                                              isRequired: true,
                                            ),
                                            const SizedBox(height: 16),
                                            _buildFormField(
                                              label: 'Description',
                                              hint:
                                                  'Enter chapter description (at least 10 characters)',
                                              controller:
                                                  _descriptionController,
                                              isRequired: true,
                                              maxLines: 3,
                                              showCharCount: true,
                                            ),
                                            const SizedBox(height: 16),
                                            // _buildDropdown(),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                SizedBox(height: isTablet ? 50 : 40),

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
                                              // Cancel button
                                              SizedBox(
                                                width: 180,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    if (!(isProcessing || _isDialogVisible)) {
                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                  child: Container(
                                                    height: isTablet ? 54 : 48,
                                                    decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            isTablet ? 27 : 24,
                                                          ),
                                                      border: Border.all(
                                                        color:
                                                            colorScheme.outline,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                          color: colorScheme
                                                              .onSurface,
                                                          fontSize: isTablet
                                                              ? 18
                                                              : 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              SizedBox(
                                                width: isTablet ? 20 : 12,
                                              ),

                                              // Create Chapter button
                                              SizedBox(
                                                width: 180,
                                                child: GestureDetector(
                                                  onTap: isProcessing
                                                      ? null
                                                      : _createChapter,
                                                  child: Container(
                                                    height: isTablet ? 54 : 48,
                                                    decoration: BoxDecoration(
                                                      color: isProcessing
                                                          ? colorScheme
                                                                .surfaceVariant
                                                          : colorScheme.primary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            isTablet ? 27 : 24,
                                                          ),
                                                    ),
                                                    child: Center(
                                                      child:
                                                          _buildCreateButtonChild(
                                                            isProcessing:
                                                                isProcessing,
                                                            isTablet: isTablet,
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
                                              // Cancel button
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    if (!(isProcessing || _isDialogVisible)) {
                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                  child: Container(
                                                    height: isTablet ? 54 : 48,
                                                    decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            isTablet ? 27 : 24,
                                                          ),
                                                      border: Border.all(
                                                        color:
                                                            colorScheme.outline,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                          color: colorScheme
                                                              .onSurface,
                                                          fontSize: isTablet
                                                              ? 18
                                                              : 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              SizedBox(
                                                width: isTablet ? 20 : 12,
                                              ),

                                              // Create Chapter button
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: isProcessing
                                                      ? null
                                                      : _createChapter,
                                                  child: Container(
                                                    height: isTablet ? 54 : 48,
                                                    decoration: BoxDecoration(
                                                      color: isProcessing
                                                          ? colorScheme
                                                                .surfaceVariant
                                                          : colorScheme.primary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            isTablet ? 27 : 24,
                                                          ),
                                                    ),
                                                    child: Center(
                                                      child:
                                                          _buildCreateButtonChild(
                                                            isProcessing:
                                                                isProcessing,
                                                            isTablet: isTablet,
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
                isTablet: isTablet,
              ),
            ],
          ),
        ),
      );
      },
    );
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
          final authState = context.read<AuthCubit>().state;
          if (authState is AuthSuccess) {
            _chapterCubit.getChapters(
              folderId: widget.folderId,
              token: authState.token,
            );
          }
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
    required bool isTablet,
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
      child: Container(
        color: colorScheme.scrim.withOpacity(0.55),
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: isTablet ? 440 : 360),
            margin: EdgeInsets.symmetric(horizontal: isTablet ? 0 : 24),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Creating Your Chapter',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: isTablet ? 24 : 22,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "We're processing your materials and generating AI-powered content",
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: isTablet ? 16 : 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Container(
                  width: isTablet ? 220 : 200,
                  height: isTablet ? 260 : 230,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 14),
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
                              fontSize: isTablet ? 36 : 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Processing',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: isTablet ? 14 : 13,
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
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(28),
                            bottomRight: Radius.circular(28),
                          ),
                          child: AnimatedBuilder(
                            animation: _waveController,
                            builder: (context, child) {
                              return SizedBox(
                                width: isTablet ? 220 : 200,
                                height: isTablet ? 260 : 230,
                                child: CustomPaint(
                                painter: WavyProgressPainter(
                                  progress: progressValue / 100.0,
                                  waveOffset: _waveController.value * 2 * math.pi,
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
                const SizedBox(height: 24),
                Text(
                  statusMessage,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: isTablet ? 16 : 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tips_and_updates,
                        color: colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Tip: You can add multiple PDFs and videos to each chapter',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: isTablet ? 13 : 12,
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

  // Widget _buildDropdown() {
  //   final screenWidth = MediaQuery.of(context).size.width;
  //   final isTablet = screenWidth >= 768;

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       RichText(
  //         text: TextSpan(
  //           text: 'Category',
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontSize: isTablet ? 18 : 16,
  //             fontWeight: FontWeight.w500,
  //           ),
  //           children: [
  //             TextSpan(
  //               text: ' *',
  //               style: TextStyle(
  //                 color: Colors.red,
  //                 fontSize: isTablet ? 18 : 16,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       SizedBox(height: isTablet ? 10 : 8),
  //       GestureDetector(
  //         onTap: () {
  //           showModalBottomSheet(
  //             context: context,
  //             backgroundColor: const Color(0xFF1C1C1E),
  //             shape: const RoundedRectangleBorder(
  //               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //             ),
  //             builder: (context) {
  //               return Container(
  //                 padding: EdgeInsets.all(isTablet ? 24 : 16),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Text(
  //                       'Select Category',
  //                       style: TextStyle(
  //                         color: Colors.white,
  //                         fontSize: isTablet ? 20 : 18,
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                     SizedBox(height: isTablet ? 20 : 16),
  //                     ...categories.map((category) {
  //                       return GestureDetector(
  //                         onTap: () {
  //                           setState(() {
  //                             _selectedCategory = category;
  //                           });
  //                           Navigator.pop(context);
  //                         },
  //                         child: Container(
  //                           width: double.infinity,
  //                           padding: EdgeInsets.symmetric(
  //                             vertical: isTablet ? 16 : 12,
  //                           ),
  //                           decoration: const BoxDecoration(
  //                             border: Border(
  //                               bottom: BorderSide(
  //                                 color: Color(0xFF2C2C2E),
  //                                 width: 0.5,
  //                               ),
  //                             ),
  //                           ),
  //                           child: Text(
  //                             category,
  //                             style: TextStyle(
  //                               color: Colors.white,
  //                               fontSize: isTablet ? 18 : 16,
  //                             ),
  //                           ),
  //                         ),
  //                       );
  //                     }).toList(),
  //                   ],
  //                 ),
  //               );
  //             },
  //           );
  //         },
  //         child: Container(
  //           width: double.infinity,
  //           padding: EdgeInsets.all(isTablet ? 16 : 12),
  //           decoration: BoxDecoration(
  //             color: const Color(0xFF1C1C1E),
  //             borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
  //             border: Border.all(color: const Color(0xFF2C2C2E)),
  //           ),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 _selectedCategory,
  //                 style: TextStyle(
  //                   color: _selectedCategory == 'Select a category'
  //                       ? const Color(0xFF8E8E93)
  //                       : Colors.white,
  //                   fontSize: isTablet ? 16 : 14,
  //                 ),
  //               ),
  //               Icon(
  //                 Icons.keyboard_arrow_down,
  //                 color: const Color(0xFF8E8E93),
  //                 size: isTablet ? 24 : 20,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}

class WavyProgressPainter extends CustomPainter {
  final double progress;
  final double waveOffset;
  final Color color;

  WavyProgressPainter({
    required this.progress,
    required this.waveOffset,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final waveHeight = 12.0;
    final waveLength = size.width / 1.5;
    // Calculate the height of the filled area from bottom
    final progressHeight = size.height * progress.clamp(0.0, 1.0);

    if (progressHeight <= 0) return;

    // Create gradient paint for the liquid effect
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.6),
          color.withOpacity(0.9),
          color,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, size.height - progressHeight, size.width, progressHeight));

    final path = Path();

    // Start from bottom left
    path.moveTo(0, size.height);

    // Create wavy pattern along the top edge of the progress
    for (double x = 0; x <= size.width; x += 1) {
      final normalizedX = x / waveLength;
      // Create smooth wave using sine function
      final waveY = waveHeight * math.sin(normalizedX * 2 * math.pi + waveOffset);
      final y = size.height - progressHeight + waveY;
      path.lineTo(x, y);
    }

    // Close the path to bottom right, then back to bottom left
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, gradientPaint);

    // Add a subtle highlight on top of the wave for depth
    final highlightPath = Path();
    highlightPath.moveTo(0, size.height - progressHeight);
    for (double x = 0; x <= size.width; x += 1) {
      final normalizedX = x / waveLength;
      final waveY = waveHeight * math.sin(normalizedX * 2 * math.pi + waveOffset);
      final y = size.height - progressHeight + waveY;
      highlightPath.lineTo(x, y);
    }

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(WavyProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.waveOffset != waveOffset ||
        oldDelegate.color != color;
  }
}
