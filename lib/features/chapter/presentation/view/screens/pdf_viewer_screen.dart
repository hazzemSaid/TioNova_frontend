import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/features/chapter/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/chapter/presentation/view/widgets/pdf_viewer/file_helper.dart';
import 'package:tionova/features/chapter/presentation/view/widgets/pdf_viewer/web_pdf_viewer.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';

class PDFViewerScreen extends StatefulWidget {
  final String chapterId;
  final String? folderId;
  final String chapterTitle;

  const PDFViewerScreen({
    super.key,
    required this.chapterId,
    this.folderId,
    required this.chapterTitle,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen>
    with SafeContextMixin {
  String? localPath;
  PDFViewController? controller;
  int currentPage = 0;
  int totalPages = 0;
  bool isReady = false;
  bool _isInitialized = false;
  bool _showNoPdfView = false;
  Uint8List? pdfBytes; // Store PDF bytes for download

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to ensure widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _downloadPDFFromAPIForViewing();
      }
    });
  }

  // void _loadPDF() async {
  //   try {
  //     setState(() {
  //       isReady = false;
  //     });

  //     // On web, skip file-based caching and load directly from API
  //     if (kIsWeb) {
  //       print('Web platform: fetching PDF from API for viewing');
  //       await _downloadPDFFromAPIForViewing();
  //       return;
  //     }

  //     // Check if PDF is already cached and show it first (non-web only)
  //     // if (DownloadService.isPDFCached(widget.chapterId)) {
  //     //   print('Loading PDF from cache for chapter: ${widget.chapterId}');
  //     //   final cachedPdfBytes = DownloadService.getCachedPDF(widget.chapterId);

  //     //   if (cachedPdfBytes != null) {
  //     //     pdfBytes = cachedPdfBytes;
  //     //     final path = await _createFileFromBytes(cachedPdfBytes);
  //     //     if (mounted) {
  //     //       setState(() {
  //     //         localPath = path;
  //     //         _showNoPdfView = false;
  //     //       });
  //     //     }
  //     //     // View from cache only; do not make a network request
  //     //     return;
  //     //   }
  //     // }

  //     // Not cached: fetch from API for viewing (without caching)
  //     print(
  //       'PDF not cached, fetching from API for viewing: ${widget.chapterId}',
  //     );
  //     await _downloadPDFFromAPIForViewing();
  //   } catch (e) {
  //     if (mounted && context.mounted && _isInitialized) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error loading PDF: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  Future<void> _downloadPDFFromAPIForViewing() async {
    try {
      print(
        'Fetching PDF from API for viewing (no caching): ${widget.chapterId}',
      );

      context.read<ChapterCubit>().getChapterContentPdf(
        chapterId: widget.chapterId,
        forDownload: false, // For viewing only
      );
    } catch (e) {
      if (mounted && context.mounted && _isInitialized) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadPDFFromAPI() async {
    try {
      print(
        'Fetching PDF from API for download (will cache): ${widget.chapterId}',
      );

      context.read<ChapterCubit>().getChapterContentPdf(
        chapterId: widget.chapterId,
        forDownload: true, // For download (will cache)
      );
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String> _createFileFromBytes(Uint8List bytes) async {
    // Web doesn't support file system - we use pdfBytes directly
    if (kIsWeb) {
      throw UnsupportedError('File creation not supported on web');
    }

    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/chapter_${widget.chapterId}.pdf';
      await writeFileBytes(path, bytes);
      return path;
    } catch (e) {
      throw Exception('Failed to create PDF file: $e');
    }
  }

  /// Check if the file bytes represent a valid PDF file
  /// PDF files start with the signature "%PDF-" (0x25 0x50 0x44 0x46 0x2D)
  bool _isValidPDF(Uint8List bytes) {
    if (bytes.length < 5) {
      return false;
    }

    // Check for PDF signature: %PDF-
    return bytes[0] == 0x25 && // %
        bytes[1] == 0x50 && // P
        bytes[2] == 0x44 && // D
        bytes[3] == 0x46 && // F
        bytes[4] == 0x2D; // -
  }

  /// Show alert dialog for non-PDF files
  void _showNotPdfAlert() {
    if (!mounted || !_isInitialized) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text(
              'Not a PDF File',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Text(
          'The uploaded file is not a valid PDF document. Only PDF files can be displayed in the PDF viewer.\n\nPlease upload a PDF file to view the content.',
          style: TextStyle(color: Color(0xFF8E8E93), fontSize: 16, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close dialog
              if (context.mounted) {
                Navigator.of(context).pop(); // Go back
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Go Back',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Future<void> _downloadPDF() async {
  //   // On web, download directly using pdfBytes
  //   if (kIsWeb && pdfBytes != null) {
  //     final fileName = DownloadService.sanitizeFileName(widget.chapterTitle);
  //     await DownloadService.downloadPDF(
  //       pdfBytes: pdfBytes!,
  //       fileName: fileName,
  //       context: context,
  //     );
  //     return;
  //   }

  //   // First check if PDF is already cached
  //   if (DownloadService.isPDFCached(widget.chapterId)) {
  //     final cachedPDF = DownloadService.getCachedPDF(widget.chapterId);
  //     if (cachedPDF != null) {
  //       print('Downloading cached PDF for chapter: ${widget.chapterId}');
  //       final fileName = DownloadService.sanitizeFileName(widget.chapterTitle);
  //       await DownloadService.downloadPDF(
  //         pdfBytes: cachedPDF,
  //         fileName: fileName,
  //         context: context,
  //       );
  //       return;
  //     }
  //   }

  //   // If not cached and not currently loaded, download from API first
  //   if (pdfBytes == null) {
  //     if (mounted && context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: const Text('Downloading PDF from server...'),
  //           backgroundColor: Colors.blue,
  //           action: SnackBarAction(
  //             label: 'Cancel',
  //             onPressed: () {
  //               ScaffoldMessenger.of(context).hideCurrentSnackBar();
  //             },
  //           ),
  //         ),
  //       );
  //     }

  //     // Download from API (this will cache since it's forDownload=true)
  //     await _downloadPDFFromAPI();
  //     return;
  //   }

  //   // If PDF is loaded in memory, download it
  //   final fileName = DownloadService.sanitizeFileName(widget.chapterTitle);
  //   await DownloadService.downloadPDF(
  //     pdfBytes: pdfBytes!,
  //     fileName: fileName,
  //     context: context,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;

    return BlocListener<ChapterCubit, ChapterState>(
      listener: (context, state) {
        if (state is GetChapterContentPdfSuccess) {
          // Store PDF bytes
          pdfBytes = state.pdfData;

          print('BlocListener: forDownload = ${state.forDownload}');

          // Validate that the file is actually a PDF
          if (!_isValidPDF(state.pdfData)) {
            print('⚠️ File is not a valid PDF! Showing alert...');

            // Reset state
            if (mounted) {
              setState(() {
                pdfBytes = null;
                localPath = null;
                isReady = false;
                _showNoPdfView = true;
              });
            }

            // Show alert dialog
            _showNotPdfAlert();
            return; // Don't proceed with loading
          }

          print('✅ File is a valid PDF, proceeding with loading...');

          // Only cache if this is a download operation
          if (state.forDownload) {
            // DownloadService.cachePDF(
            //   widget.chapterId,
            //   state.pdfData,
            //   fileName:
            //       DownloadService.sanitizeFileName(widget.chapterTitle) +
            //       '.pdf',
            //   chapterTitle: widget.chapterTitle,
            // );
            print(
              'PDF cached for chapter: ${widget.chapterId}, size: ${state.pdfData.length} bytes',
            );
          } else {
            print(
              'PDF loaded for viewing only (not cached): ${widget.chapterId}, size: ${state.pdfData.length} bytes',
            );
          }

          // On web, we use pdfBytes directly with WebPdfViewer, no file needed
          if (kIsWeb) {
            if (mounted) {
              setState(() {
                _showNoPdfView = false;
                isReady = true;
              });
              print('Web PDF ready, pdfBytes length: ${pdfBytes?.length}');
            }
          } else {
            // On non-web platforms, create a file from bytes
            print('Creating PDF file from bytes on mobile...');
            _createFileFromBytes(state.pdfData)
                .then((path) {
                  print('PDF file created successfully at: $path');
                  if (mounted) {
                    setState(() {
                      localPath = path;
                      _showNoPdfView = false;
                    });
                    print('localPath set, triggering UI rebuild');
                  }
                })
                .catchError((error) {
                  print('Error creating PDF file: $error');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error loading PDF: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                });
          }
        } else if (state is GetChapterContentPdfError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message.errMessage}'),
              backgroundColor: Colors.red,
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
            onPressed: () {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.chapterTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (totalPages > 0)
                Text(
                  'Page ${currentPage + 1} of $totalPages',
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
          centerTitle: false,
          actions: [
            if ((kIsWeb && pdfBytes != null && isReady) ||
                (!kIsWeb && localPath != null && isReady))
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: const Color(0xFF1C1C1E),
                onSelected: (value) {
                  switch (value) {
                    case 'download':
                      // _downloadPDF();
                      break;
                    case 'refresh':
                      // Clear cache and force reload from API
                      // DownloadService.clearCachedPDF(widget.chapterId);
                      // setState(() {
                      //   localPath = null;
                      //   pdfBytes = null;
                      //   isReady = false;
                      //   _showNoPdfView = false;
                      // });
                      // Force download from API for viewing (without caching)
                      _downloadPDFFromAPIForViewing();
                      break;
                    case 'first':
                      if (!kIsWeb) {
                        controller?.setPage(0);
                      }
                      break;
                    case 'last':
                      if (!kIsWeb && totalPages > 0) {
                        controller?.setPage(totalPages - 1);
                      }
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(Icons.download, color: Colors.white, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Download PDF',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, color: Colors.white, size: 20),
                        SizedBox(width: 12),
                        Text('Refresh', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  if (!kIsWeb) ...[
                    const PopupMenuItem(
                      value: 'first',
                      child: Row(
                        children: [
                          Icon(Icons.first_page, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'First Page',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'last',
                      child: Row(
                        children: [
                          Icon(Icons.last_page, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'Last Page',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
        body: BlocBuilder<ChapterCubit, ChapterState>(
          builder: (context, state) {
            print(
              'BlocBuilder state: ${state.runtimeType}, localPath: $localPath, pdfBytes: ${pdfBytes?.length}, isWeb: $kIsWeb',
            );

            if (state is GetChapterContentPdfLoading) {
              print('Showing loading view');
              return _buildLoadingView(isTablet);
            }

            if (state is GetChapterContentPdfError) {
              print('Showing error view');
              return _buildErrorView(state.message.errMessage, isTablet);
            }

            if (_showNoPdfView) {
              print('Showing no PDF view');
              return _buildNoPdfView(isTablet);
            }

            // On web, check pdfBytes; on other platforms, check localPath
            if (kIsWeb) {
              if (pdfBytes == null) {
                print('Web: pdfBytes is null, showing loading view');
                return _buildLoadingView(isTablet);
              }
              print('Web: Showing web PDF view');
              return _buildWebPDFView(isTablet);
            }

            if (localPath == null) {
              print('Mobile: localPath is null, showing loading view');
              return _buildLoadingView(isTablet);
            }

            print('Mobile: Showing native PDF view');
            return _buildPDFView(isTablet);
          },
        ),
        bottomNavigationBar:
            !kIsWeb && localPath != null && isReady && totalPages > 1
            ? _buildNavigationBar(isTablet)
            : null,
      ),
    );
  }

  Widget _buildLoadingView(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isTablet ? 80 : 60,
            height: isTablet ? 80 : 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(isTablet ? 40 : 30),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'Loading PDF...',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Please wait while we prepare your document',
            style: TextStyle(
              color: const Color(0xFF8E8E93),
              fontSize: isTablet ? 16 : 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String errorMessage, bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isTablet ? 80 : 60,
              height: isTablet ? 80 : 60,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isTablet ? 40 : 30),
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red,
                size: isTablet ? 40 : 30,
              ),
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              'Failed to Load PDF',
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              errorMessage,
              style: TextStyle(
                color: const Color(0xFF8E8E93),
                fontSize: isTablet ? 16 : 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 32 : 24),
            SizedBox(
              width: isTablet ? 200 : 160,
              child: GestureDetector(
                onTap: _downloadPDFFromAPIForViewing,
                child: Container(
                  height: isTablet ? 50 : 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isTablet ? 25 : 22),
                  ),
                  child: Center(
                    child: Text(
                      'Try Again',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPdfView(bool isTablet) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF1C1C1E)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: isTablet ? 80 : 64,
              color: Colors.white.withOpacity(0.3),
            ),
            SizedBox(height: isTablet ? 24 : 20),
            Text(
              'PDF Not Downloaded',
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 64 : 48),
              child: Text(
                'This PDF is not downloaded yet. Click the download button to get it from the server.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isTablet ? 16 : 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: isTablet ? 32 : 24),
            SizedBox(
              width: isTablet ? 200 : 160,
              child: GestureDetector(
                onTap: () {
                  _downloadPDFFromAPI();
                },
                child: Container(
                  height: isTablet ? 50 : 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isTablet ? 25 : 22),
                  ),
                  child: Center(
                    child: Text(
                      'Download PDF',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Web-specific PDF viewer using iframe with Blob URL.
  Widget _buildWebPDFView(bool isTablet) {
    if (pdfBytes == null) {
      return _buildLoadingView(isTablet);
    }

    return WebPdfViewer(
      pdfBytes: pdfBytes!,
      title: widget.chapterTitle,
      currentPage: currentPage,
      totalPages: totalPages,
      onReady: () {
        if (mounted) {
          setState(() {
            isReady = true;
          });
        }
      },
    );
  }

  Widget _buildPDFView(bool isTablet) {
    print('Building PDFView with localPath: $localPath');
    return ScrollConfiguration(
      behavior: NoGlowScrollBehavior(),
      child: Container(
        decoration: const BoxDecoration(color: Color(0xFF1C1C1E)),
        child: PDFView(
          filePath: localPath!,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: false,
          pageFling: true,
          pageSnap: true,
          defaultPage: currentPage,
          fitPolicy: FitPolicy.BOTH,
          preventLinkNavigation: false,
          onRender: (pages) {
            print('PDF rendered successfully! Total pages: $pages');
            setState(() {
              totalPages = pages ?? 0;
              isReady = true;
            });
          },
          onError: (error) {
            print('PDF Error: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF Error: $error'),
                backgroundColor: Colors.red,
              ),
            );
          },
          onPageError: (page, error) {
            print('Page $page Error: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Page $page Error: $error'),
                backgroundColor: Colors.red,
              ),
            );
          },
          onViewCreated: (PDFViewController pdfViewController) {
            print('PDF View Created');
            controller = pdfViewController;
          },
          onLinkHandler: (uri) {
            // Handle PDF links if needed
          },
          onPageChanged: (int? page, int? total) {
            if (page != null) {
              setState(() {
                currentPage = page;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildNavigationBar(bool isTablet) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        border: Border(top: BorderSide(color: Color(0xFF2C2C2E), width: 0.5)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 16 : 12,
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous page
            GestureDetector(
              onTap: currentPage > 0
                  ? () => controller?.setPage(currentPage - 1)
                  : null,
              child: Container(
                width: isTablet ? 50 : 44,
                height: isTablet ? 50 : 44,
                decoration: BoxDecoration(
                  color: currentPage > 0
                      ? const Color(0xFF2C2C2E)
                      : const Color(0xFF2C2C2E).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(isTablet ? 25 : 22),
                ),
                child: Icon(
                  Icons.chevron_left,
                  color: currentPage > 0
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                  size: isTablet ? 28 : 24,
                ),
              ),
            ),

            // Page info
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 16,
                vertical: isTablet ? 12 : 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(isTablet ? 20 : 18),
              ),
              child: Text(
                '${currentPage + 1} / $totalPages',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Next page
            GestureDetector(
              onTap: currentPage < totalPages - 1
                  ? () => controller?.setPage(currentPage + 1)
                  : null,
              child: Container(
                width: isTablet ? 50 : 44,
                height: isTablet ? 50 : 44,
                decoration: BoxDecoration(
                  color: currentPage < totalPages - 1
                      ? const Color(0xFF2C2C2E)
                      : const Color(0xFF2C2C2E).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(isTablet ? 25 : 22),
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: currentPage < totalPages - 1
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                  size: isTablet ? 28 : 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up temporary file (non-web only)
    if (!kIsWeb && localPath != null) {
      try {
        deleteFile(localPath!);
      } catch (e) {
        // Ignore errors on platforms where File is not available
      }
    }
    super.dispose();
  }
}
