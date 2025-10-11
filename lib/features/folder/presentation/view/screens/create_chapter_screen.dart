// features/folder/presentation/view/screens/create_chapter_screen.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/folder/data/models/FileDataModel.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';

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

class _CreateChapterScreenState extends State<CreateChapterScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  FileData? _selectedFile;
  String? _selectedFileName;

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
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File "${file.name}" selected successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'File content could not be read. Please try again.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a PDF file only.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('File picker error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showManualFileInputDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0E0E10),
        title: const Text(
          'File Picker Not Available',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'The file picker is not working on this device. For now, you can create a chapter without uploading a PDF file. The PDF upload feature will be available in a future update.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Future<void> _createChapter() async {
    print('🚀 _createChapter() called');

    if (_titleController.text.trim().isEmpty) {
      print('❌ Title is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    print('✅ Title validation passed: ${_titleController.text.trim()}');

    if (_descriptionController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Description must be at least 10 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a PDF file'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Get auth token
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      try {
        context.read<ChapterCubit>().createChapter(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          folderId: widget.folderId,
          token: authState.token,
          file: _selectedFile!,
        );

        // Close the loading dialog
        if (mounted) Navigator.of(context).pop();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chapter created successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate back to previous screen after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(
                context,
              ).pop(true); // Return true to indicate success
            }
          });
        }
      } catch (e) {
        // Close the loading dialog
        if (mounted) Navigator.of(context).pop();

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create chapter: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } else {
      // Close the loading dialog
      if (mounted) Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication required'),
          backgroundColor: Colors.red,
        ),
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

    return BlocProvider(
      create: (context) => getIt<ChapterCubit>(),
      child: BlocListener<ChapterCubit, ChapterState>(
        listener: (context, state) {
          if (state is CreateChapterLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Creating chapter...'),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 2),
              ),
            );
          }
          if (state is CreateChapterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text('Chapter created successfully!'),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            final authState = context.read<AuthCubit>().state;
            if (authState is AuthSuccess) {
              context.read<ChapterCubit>().getChapters(
                folderId: widget.folderId,
                token: authState.token,
              );
            }
            Navigator.pop(context, true); // Return true to indicate success
          }
          if (state is CreateChapterError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Failed to create chapter: ${state.message.errMessage}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'New Chapter in ${widget.folderTitle}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: false,
          ),
          body: ScrollConfiguration(
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
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0E0E10),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF1C1C1E),
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
                                            color: Colors.white,
                                            size: isTablet ? 24 : 22,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Upload PDF Document',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isTablet ? 22 : 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Upload your study material as a PDF file (max 10MB)",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(.5),
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
                                            height: isTablet ? 160 : 140,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1C1C1E),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFF2C2C2E),
                                                style: BorderStyle.solid,
                                              ),
                                            ),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    height: isTablet ? 12 : 8,
                                                  ),
                                                  if (_selectedFile !=
                                                      null) ...[
                                                    Container(
                                                      width: 48,
                                                      height: 48,
                                                      decoration: BoxDecoration(
                                                        color: Colors.green
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors.green,
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.check_circle,
                                                        color: Colors.green,
                                                        size: 24,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: isTablet ? 10 : 6,
                                                    ),
                                                    Text(
                                                      'File Selected',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: isTablet
                                                            ? 16
                                                            : 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: isTablet ? 4 : 2,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                          ),
                                                      child: Text(
                                                        _selectedFileName ??
                                                            'Unknown file',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: isTablet
                                                              ? 12
                                                              : 10,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: isTablet ? 6 : 4,
                                                    ),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: isTablet
                                                                ? 14
                                                                : 12,
                                                            vertical: isTablet
                                                                ? 6
                                                                : 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        'Tap to change file',
                                                        style: TextStyle(
                                                          color: Colors.green,
                                                          fontSize: isTablet
                                                              ? 10
                                                              : 9,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ] else ...[
                                                    Container(
                                                      width: 48,
                                                      height: 48,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFF2C2C2E,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      child: const Icon(
                                                        Icons
                                                            .description_outlined,
                                                        color: Colors.white,
                                                        size: 24,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: isTablet ? 10 : 6,
                                                    ),
                                                    Text(
                                                      'Choose PDF file',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: isTablet
                                                            ? 16
                                                            : 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: isTablet ? 4 : 2,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                          ),
                                                      child: Text(
                                                        'Click to browse or drag and drop your PDF here',
                                                        style: TextStyle(
                                                          color: const Color(
                                                            0xFF8E8E93,
                                                          ),
                                                          fontSize: isTablet
                                                              ? 12
                                                              : 10,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: isTablet ? 6 : 4,
                                                    ),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: isTablet
                                                                ? 14
                                                                : 12,
                                                            vertical: isTablet
                                                                ? 6
                                                                : 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFF0E0E10,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        'PDF files only',
                                                        style: TextStyle(
                                                          color: const Color(
                                                            0xFF8E8E93,
                                                          ),
                                                          fontSize: isTablet
                                                              ? 10
                                                              : 9,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  SizedBox(
                                                    height: isTablet ? 12 : 8,
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
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Chapter Details Section
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF0E0E10),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF1C1C1E),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Chapter Details',
                                      style: TextStyle(
                                        color: Colors.white,
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
                                      controller: _descriptionController,
                                      isRequired: true,
                                      maxLines: 3,
                                      showCharCount: true,
                                    ),
                                    const SizedBox(height: 16),
                                    // _buildDropdown(),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: isTablet ? 50 : 40),

                            // Bottom buttons
                            isDesktop
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Cancel button
                                      SizedBox(
                                        width: 180,
                                        child: GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: Container(
                                            height: isTablet ? 54 : 48,
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    isTablet ? 27 : 24,
                                                  ),
                                              border: Border.all(
                                                color: const Color(0xFF1C1C1E),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: isTablet ? 18 : 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(width: isTablet ? 20 : 12),

                                      // Create Chapter button
                                      SizedBox(
                                        width: 180,
                                        child: BlocBuilder<ChapterCubit, ChapterState>(
                                          builder: (context, state) {
                                            final isLoading =
                                                state is CreateChapterLoading;
                                            return GestureDetector(
                                              onTap: isLoading
                                                  ? null
                                                  : _createChapter,
                                              child: Container(
                                                height: isTablet ? 54 : 48,
                                                decoration: BoxDecoration(
                                                  color: isLoading
                                                      ? Colors.grey
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        isTablet ? 27 : 24,
                                                      ),
                                                ),
                                                child: Center(
                                                  child: isLoading
                                                      ? Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            SizedBox(
                                                              width: 16,
                                                              height: 16,
                                                              child: CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                      Color
                                                                    >(
                                                                      Colors
                                                                          .black,
                                                                    ),
                                                              ),
                                                            ),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              'Creating...',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize:
                                                                    isTablet
                                                                    ? 18
                                                                    : 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : Text(
                                                          'Create Chapter',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: isTablet
                                                                ? 18
                                                                : 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      // Cancel button
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: Container(
                                            height: isTablet ? 54 : 48,
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    isTablet ? 27 : 24,
                                                  ),
                                              border: Border.all(
                                                color: const Color(0xFF1C1C1E),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: isTablet ? 18 : 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(width: isTablet ? 20 : 12),

                                      // Create Chapter button
                                      Expanded(
                                        child: BlocBuilder<ChapterCubit, ChapterState>(
                                          builder: (context, state) {
                                            final isLoading =
                                                state is CreateChapterLoading;
                                            return GestureDetector(
                                              onTap: isLoading
                                                  ? null
                                                  : _createChapter,
                                              child: Container(
                                                height: isTablet ? 54 : 48,
                                                decoration: BoxDecoration(
                                                  color: isLoading
                                                      ? Colors.grey
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        isTablet ? 27 : 24,
                                                      ),
                                                ),
                                                child: Center(
                                                  child: isLoading
                                                      ? Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            SizedBox(
                                                              width: 16,
                                                              height: 16,
                                                              child: CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                      Color
                                                                    >(
                                                                      Colors
                                                                          .black,
                                                                    ),
                                                              ),
                                                            ),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              'Creating...',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize:
                                                                    isTablet
                                                                    ? 18
                                                                    : 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : Text(
                                                          'Create Chapter',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: isTablet
                                                                ? 18
                                                                : 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w500,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: isTablet ? 18 : 16,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 10 : 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
            border: Border.all(color: const Color(0xFF2C2C2E)),
          ),
          child: Stack(
            children: [
              TextField(
                controller: controller,
                maxLines: maxLines,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 16 : 14,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: const Color(0xFF8E8E93),
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
                          ? Colors.red
                          : const Color(0xFF8E8E93),
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
