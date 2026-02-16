import 'package:flutter/material.dart';

/// A widget that displays the chapter action buttons (Cancel and Create).
class ChapterActionButtons extends StatelessWidget {
  final bool isProcessing;
  final bool isDialogVisible;
  final VoidCallback onCancel;
  final VoidCallback onCreate;

  const ChapterActionButtons({
    super.key,
    required this.isProcessing,
    required this.isDialogVisible,
    required this.onCancel,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    final colorScheme = Theme.of(context).colorScheme;

    if (isDesktop) {
      return _buildDesktopLayout(
        colorScheme: colorScheme,
        isDesktop: isDesktop,
        isTablet: isTablet,
      );
    }

    return _buildMobileLayout(colorScheme: colorScheme, isTablet: isTablet);
  }

  Widget _buildDesktopLayout({
    required ColorScheme colorScheme,
    required bool isDesktop,
    required bool isTablet,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 180,
          child: _buildCancelButton(
            colorScheme: colorScheme,
            isDesktop: isDesktop,
            isTablet: isTablet,
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
          child: _buildCreateButton(
            colorScheme: colorScheme,
            isDesktop: isDesktop,
            isTablet: isTablet,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout({
    required ColorScheme colorScheme,
    required bool isTablet,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildCancelButton(
            colorScheme: colorScheme,
            isDesktop: false,
            isTablet: isTablet,
          ),
        ),
        SizedBox(width: isTablet ? 20 : 12),
        Expanded(
          child: _buildCreateButton(
            colorScheme: colorScheme,
            isDesktop: false,
            isTablet: isTablet,
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton({
    required ColorScheme colorScheme,
    required bool isDesktop,
    required bool isTablet,
  }) {
    return GestureDetector(
      onTap: () {
        if (!(isProcessing || isDialogVisible)) {
          onCancel();
        }
      },
      child: Container(
        height: isDesktop
            ? 60
            : isTablet
            ? 54
            : 48,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(
            isDesktop
                ? 30
                : isTablet
                ? 27
                : 24,
          ),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Center(
          child: Text(
            'Cancel',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: isDesktop
                  ? 20
                  : isTablet
                  ? 18
                  : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton({
    required ColorScheme colorScheme,
    required bool isDesktop,
    required bool isTablet,
  }) {
    return GestureDetector(
      onTap: isProcessing ? null : onCreate,
      child: Container(
        height: isDesktop
            ? 60
            : isTablet
            ? 54
            : 48,
        decoration: BoxDecoration(
          color: isProcessing
              ? colorScheme.surfaceVariant
              : colorScheme.primary,
          borderRadius: BorderRadius.circular(
            isDesktop
                ? 30
                : isTablet
                ? 27
                : 24,
          ),
        ),
        child: Center(
          child: _buildCreateButtonChild(
            colorScheme: colorScheme,
            isTablet: isTablet,
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButtonChild({
    required ColorScheme colorScheme,
    required bool isTablet,
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
}
