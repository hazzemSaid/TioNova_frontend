// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

/// Web-specific PDF viewer implementation using an iframe with Blob URL.
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
  String? _blobUrl;
  late String _viewId;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _viewId = 'pdf-viewer-${DateTime.now().millisecondsSinceEpoch}';
    _initPdfViewer();
  }

  void _initPdfViewer() {
    try {
      print('WebPdfViewer: Initializing with ${widget.pdfBytes.length} bytes');

      // Create a Blob from PDF bytes
      final blob = html.Blob([widget.pdfBytes], 'application/pdf');
      _blobUrl = html.Url.createObjectUrlFromBlob(blob);
      print('WebPdfViewer: Created blob URL: $_blobUrl');

      // Register the view factory for the HTML element
      // ignore: undefined_prefixed_name
      ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
        print('WebPdfViewer: Creating iframe for viewId: $viewId');
        final iframe = html.IFrameElement()
          ..src = _blobUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow = 'fullscreen';

        return iframe;
      });

      setState(() {
        _isReady = true;
      });
      print('WebPdfViewer: Ready');

      // Notify parent that the viewer is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onReady?.call();
      });
    } catch (e) {
      print('Error initializing PDF viewer: $e');
    }
  }

  @override
  void dispose() {
    // Revoke the Blob URL to free memory
    if (_blobUrl != null) {
      html.Url.revokeObjectUrl(_blobUrl!);
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(WebPdfViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If PDF bytes changed, reinitialize
    if (widget.pdfBytes != oldWidget.pdfBytes) {
      if (_blobUrl != null) {
        html.Url.revokeObjectUrl(_blobUrl!);
      }
      _viewId = 'pdf-viewer-${DateTime.now().millisecondsSinceEpoch}';
      _initPdfViewer();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Container(
            color: const Color(0xFF1C1C1E),
            child: HtmlElementView(viewType: _viewId),
          ),
        );
      },
    );
  }
}
