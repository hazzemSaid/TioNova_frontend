import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Web-specific PDF viewer implementation using an iframe.
/// This file is only imported on web platforms.
class WebPdfViewer extends StatefulWidget {
  final Uint8List pdfBytes;
  final String title;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int>? onPageChanged;
  final VoidCallback? onReady;

  const WebPdfViewer({
    super.key,
    required this.pdfBytes,
    required this.title,
    this.currentPage = 0,
    this.totalPages = 0,
    this.onPageChanged,
    this.onReady,
  });

  @override
  State<WebPdfViewer> createState() => _WebPdfViewerState();
}

class _WebPdfViewerState extends State<WebPdfViewer> {
  @override
  void initState() {
    super.initState();
    // Notify parent that the viewer is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onReady?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Stub implementation - web_pdf_viewer_web.dart provides the actual implementation
    return const Center(
      child: Text(
        'PDF viewer not available on this platform',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
