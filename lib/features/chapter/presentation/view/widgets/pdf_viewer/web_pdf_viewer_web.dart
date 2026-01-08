// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Web-specific PDF viewer implementation that works on all browsers including iOS Safari.
/// Uses PDF.js for universal compatibility.
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
  bool _isReady = false;
  bool _hasError = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 0;
  web.HTMLIFrameElement? _iframe;
  String? _iframeId;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.currentPage + 1; // Convert to 1-indexed
    _iframeId = 'pdf-iframe-${DateTime.now().millisecondsSinceEpoch}';
    _initPdfViewer();
  }

  void _initPdfViewer() {
    try {
      print('WebPdfViewer: Initializing with ${widget.pdfBytes.length} bytes');

      // Create PDF viewer HTML with embedded PDF.js
      final base64Pdf = base64Encode(widget.pdfBytes);
      final htmlContent = _createPdfViewerHtml(base64Pdf);

      // Create a Blob from HTML content
      final blob = web.Blob(
        [htmlContent.toJS].toJS,
        web.BlobPropertyBag(type: 'text/html'),
      );
      final blobUrl = web.URL.createObjectURL(blob);

      // Create iframe and add it to the document
      _createAndInsertIframe(blobUrl);

      setState(() {
        _isReady = true;
      });

      // Notify parent that the viewer is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onReady?.call();
      });
    } catch (e) {
      print('Error initializing PDF viewer: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _createAndInsertIframe(String blobUrl) {
    // Remove existing iframe if any
    final existingIframe = web.document.getElementById(_iframeId!);
    existingIframe?.remove();

    // Create new iframe
    _iframe = web.document.createElement('iframe') as web.HTMLIFrameElement;
    _iframe!.id = _iframeId!;
    _iframe!.src = blobUrl;
    _iframe!.style.border = 'none';
    _iframe!.style.width = '100%';
    _iframe!.style.height = '100%';
    _iframe!.style.position = 'absolute';
    _iframe!.style.top = '0';
    _iframe!.style.left = '0';
    _iframe!.setAttribute('allow', 'fullscreen');

    // Create a container div for the iframe if it doesn't exist
    final containerId = 'pdf-container-$_iframeId';
    var container = web.document.getElementById(containerId);
    if (container == null) {
      container = web.document.createElement('div');
      container.id = containerId;
      (container as web.HTMLElement).style.position = 'fixed';
      container.style.width = '0';
      container.style.height = '0';
      container.style.overflow = 'hidden';
      container.style.visibility = 'hidden';
      web.document.body?.appendChild(container);
    }

    container.appendChild(_iframe!);
  }

  String _createPdfViewerHtml(String base64Pdf) {
    // Using PDF.js from CDN for universal browser support including iOS Safari
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>PDF Viewer</title>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/4.0.379/pdf.min.mjs" type="module"></script>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    
    html, body {
      width: 100%;
      height: 100%;
      background-color: #1C1C1E;
      overflow: hidden;
      -webkit-overflow-scrolling: touch;
    }
    
    #pdf-container {
      width: 100%;
      height: 100%;
      overflow-y: auto;
      overflow-x: hidden;
      -webkit-overflow-scrolling: touch;
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: 10px 0;
    }
    
    .pdf-page {
      margin-bottom: 10px;
      box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
      background: white;
    }
    
    #loading {
      position: fixed;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      color: white;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      text-align: center;
    }
    
    .spinner {
      width: 40px;
      height: 40px;
      border: 3px solid rgba(255, 255, 255, 0.3);
      border-radius: 50%;
      border-top-color: white;
      animation: spin 1s ease-in-out infinite;
      margin: 0 auto 16px;
    }
    
    @keyframes spin {
      to { transform: rotate(360deg); }
    }
    
    #error {
      display: none;
      position: fixed;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      color: #ff6b6b;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      text-align: center;
      padding: 20px;
    }
    
    /* Touch-friendly scrolling for iOS */
    @supports (-webkit-touch-callout: none) {
      #pdf-container {
        -webkit-overflow-scrolling: touch;
      }
    }
  </style>
</head>
<body>
  <div id="loading">
    <div class="spinner"></div>
    <p>Loading PDF...</p>
  </div>
  <div id="error">
    <p>Error loading PDF</p>
  </div>
  <div id="pdf-container"></div>
  
  <script type="module">
    const pdfjsLib = await import('https://cdnjs.cloudflare.com/ajax/libs/pdf.js/4.0.379/pdf.min.mjs');
    
    // Configure worker
    pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/4.0.379/pdf.worker.min.mjs';
    
    async function loadPdf() {
      try {
        const pdfData = atob('$base64Pdf');
        const pdfArray = new Uint8Array(pdfData.length);
        for (let i = 0; i < pdfData.length; i++) {
          pdfArray[i] = pdfData.charCodeAt(i);
        }
        
        const loadingTask = pdfjsLib.getDocument({ data: pdfArray });
        const pdf = await loadingTask.promise;
        
        document.getElementById('loading').style.display = 'none';
        
        const container = document.getElementById('pdf-container');
        const totalPages = pdf.numPages;
        
        // Calculate optimal scale based on device width
        const deviceWidth = window.innerWidth;
        const isMobile = deviceWidth < 768;
        
        for (let pageNum = 1; pageNum <= totalPages; pageNum++) {
          const page = await pdf.getPage(pageNum);
          
          // Get the viewport at scale 1 to determine natural dimensions
          const baseViewport = page.getViewport({ scale: 1 });
          
          // Calculate scale to fit width with some padding
          const padding = isMobile ? 20 : 40;
          const scale = (deviceWidth - padding) / baseViewport.width;
          const viewport = page.getViewport({ scale: Math.min(scale, 2) }); // Cap at 2x scale
          
          const canvas = document.createElement('canvas');
          canvas.className = 'pdf-page';
          const context = canvas.getContext('2d');
          
          // Handle high DPI displays
          const dpr = window.devicePixelRatio || 1;
          canvas.width = viewport.width * dpr;
          canvas.height = viewport.height * dpr;
          canvas.style.width = viewport.width + 'px';
          canvas.style.height = viewport.height + 'px';
          context.scale(dpr, dpr);
          
          container.appendChild(canvas);
          
          await page.render({
            canvasContext: context,
            viewport: viewport
          }).promise;
        }
        
        // Handle window resize
        let resizeTimeout;
        window.addEventListener('resize', () => {
          clearTimeout(resizeTimeout);
          resizeTimeout = setTimeout(() => {
            // Reload PDF on resize for better quality
            container.innerHTML = '';
            document.getElementById('loading').style.display = 'block';
            loadPdf();
          }, 500);
        });
        
      } catch (error) {
        console.error('Error loading PDF:', error);
        document.getElementById('loading').style.display = 'none';
        document.getElementById('error').style.display = 'block';
        document.getElementById('error').querySelector('p').textContent = 'Error: ' + error.message;
      }
    }
    
    loadPdf();
  </script>
</body>
</html>
''';
  }

  @override
  void dispose() {
    // Remove the iframe from DOM
    final containerId = 'pdf-container-$_iframeId';
    web.document.getElementById(containerId)?.remove();
    super.dispose();
  }

  @override
  void didUpdateWidget(WebPdfViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If PDF bytes changed, reinitialize
    if (widget.pdfBytes != oldWidget.pdfBytes) {
      _iframeId = 'pdf-iframe-${DateTime.now().millisecondsSinceEpoch}';
      setState(() {
        _isReady = false;
        _hasError = false;
      });
      _initPdfViewer();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading PDF',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _errorMessage = null;
                });
                _initPdfViewer();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!_isReady) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            SizedBox(height: 16),
            Text('Loading PDF...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    // Use HtmlElementView to display the iframe
    return LayoutBuilder(
      builder: (context, constraints) {
        // Update iframe dimensions and move it to the visible area
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateIframePosition(constraints);
        });

        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Container(
            color: const Color(0xFF1C1C1E),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }

  void _updateIframePosition(BoxConstraints constraints) {
    if (_iframe == null) return;

    final containerId = 'pdf-container-$_iframeId';
    final container =
        web.document.getElementById(containerId) as web.HTMLElement?;
    if (container == null) return;

    // Get the Flutter widget's position on screen
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);

    // Update container to be visible and positioned correctly
    container.style.position = 'fixed';
    container.style.left = '${position.dx}px';
    container.style.top = '${position.dy}px';
    container.style.width = '${constraints.maxWidth}px';
    container.style.height = '${constraints.maxHeight}px';
    container.style.overflow = 'hidden';
    container.style.visibility = 'visible';
    container.style.zIndex = '1000';

    // Update iframe dimensions
    _iframe!.style.width = '100%';
    _iframe!.style.height = '100%';
  }
}
