import 'package:flutter/material.dart';
import 'package:tionova/features/folder/data/models/FileDataModel.dart';

/// A widget that displays the PDF upload section with file picker functionality.
class PdfUploadSection extends StatelessWidget {
  final FileData? selectedFile;
  final String? selectedFileName;
  final VoidCallback onPickFile;

  const PdfUploadSection({
    super.key,
    required this.selectedFile,
    required this.selectedFileName,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    final colorScheme = Theme.of(context).colorScheme;

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
          color: colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
          border: Border.all(
            color: colorScheme.outline,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            _buildUploadIcon(
              context: context,
              isDesktop: isDesktop,
              isTablet: isTablet,
              colorScheme: colorScheme,
            ),
            SizedBox(
              height: isDesktop
                  ? 20
                  : isTablet
                  ? 16
                  : 12,
            ),

            // Title text
            _buildTitleText(
              isDesktop: isDesktop,
              isTablet: isTablet,
              colorScheme: colorScheme,
            ),
            SizedBox(height: isDesktop ? 8 : 6),

            // Subtitle text
            _buildSubtitleText(
              isDesktop: isDesktop,
              isTablet: isTablet,
              colorScheme: colorScheme,
            ),
            SizedBox(
              height: isDesktop
                  ? 24
                  : isTablet
                  ? 20
                  : 16,
            ),

            // Choose PDF Files Button
            _buildUploadButton(
              isDesktop: isDesktop,
              isTablet: isTablet,
              colorScheme: colorScheme,
            ),
            SizedBox(
              height: isDesktop
                  ? 12
                  : isTablet
                  ? 10
                  : 8,
            ),

            // Max file size text
            _buildMaxFileSizeText(
              isDesktop: isDesktop,
              isTablet: isTablet,
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadIcon({
    required BuildContext context,
    required bool isDesktop,
    required bool isTablet,
    required ColorScheme colorScheme,
  }) {
    return Container(
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
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.description_outlined,
        color: selectedFile != null
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant,
        size: isDesktop
            ? 40
            : isTablet
            ? 35
            : 30,
      ),
    );
  }

  Widget _buildTitleText({
    required bool isDesktop,
    required bool isTablet,
    required ColorScheme colorScheme,
  }) {
    return Text(
      selectedFile != null ? 'File Selected' : 'Upload PDF Files',
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: isDesktop
            ? 20
            : isTablet
            ? 18
            : 16,
        fontWeight: selectedFile != null ? FontWeight.w500 : FontWeight.bold,
      ),
    );
  }

  Widget _buildSubtitleText({
    required bool isDesktop,
    required bool isTablet,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        selectedFile != null
            ? selectedFileName ?? ''
            : 'Click to browse or drag and drop\nPDF files here',
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: isDesktop
              ? 14
              : isTablet
              ? 13
              : 12,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildUploadButton({
    required bool isDesktop,
    required bool isTablet,
    required ColorScheme colorScheme,
  }) {
    return ElevatedButton.icon(
      onPressed: onPickFile,
      icon: Icon(
        Icons.upload_file,
        color: selectedFile != null
            ? colorScheme.onPrimary
            : colorScheme.onSurfaceVariant,
        size: isDesktop ? 20 : 18,
      ),
      label: Text(
        selectedFile == null ? 'Choose PDF Files' : 'Rechange PDF Files',
        style: TextStyle(
          fontSize: isDesktop
              ? 16
              : isTablet
              ? 15
              : 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }

  Widget _buildMaxFileSizeText({
    required bool isDesktop,
    required bool isTablet,
    required ColorScheme colorScheme,
  }) {
    return Text(
      'Max file size: 50MB per file',
      style: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: isDesktop
            ? 13
            : isTablet
            ? 12
            : 11,
      ),
    );
  }
}
