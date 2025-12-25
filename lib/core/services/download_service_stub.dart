// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Get download path - Web stub (not applicable on web)
Future<String?> getDownloadPath() async {
  // On web, we don't have a traditional file system path
  return null;
}

/// Download PDF - Web implementation using browser download
Future<bool> downloadPDF({
  required Uint8List pdfBytes,
  required String fileName,
  required BuildContext context,
}) async {
  try {
    // Ensure fileName has .pdf extension
    String finalFileName = fileName;
    if (!fileName.toLowerCase().endsWith('.pdf')) {
      finalFileName = '$fileName.pdf';
    }

    // Create a Blob from the PDF bytes
    final blob = web.Blob(
      [pdfBytes.toJS].toJS,
      web.BlobPropertyBag(type: 'application/pdf'),
    );

    // Create object URL
    final url = web.URL.createObjectURL(blob);

    // Create download link
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = finalFileName;
    anchor.style.display = 'none';

    // Add to document, click, and remove
    web.document.body?.appendChild(anchor);
    anchor.click();
    web.document.body?.removeChild(anchor);

    // Cleanup URL after a delay
    Future.delayed(const Duration(seconds: 1), () {
      web.URL.revokeObjectURL(url);
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF download started: $finalFileName'),
        backgroundColor: Colors.green,
      ),
    );

    return true;
  } catch (e) {
    print('Error downloading PDF on web: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Download failed: $e'),
        backgroundColor: Colors.red,
      ),
    );
    return false;
  }
}
