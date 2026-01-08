import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_waveforms/audio_waveforms.dart' as waveforms if (dart.library.html) 'package:tionova/features/folder/presentation/view/widgets/audio_waveforms_stub.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tionova/features/chapter/data/models/NoteModel.dart';

class NoteDetailDialog extends StatefulWidget {
  final Notemodel note;
  final Color accentColor;
  final VoidCallback onDelete;

  const NoteDetailDialog({
    super.key,
    required this.note,
    required this.accentColor,
    required this.onDelete,
  });

  @override
  State<NoteDetailDialog> createState() => _NoteDetailDialogState();
}

class _NoteDetailDialogState extends State<NoteDetailDialog> {
  waveforms.PlayerController? _playerController;
  AudioPlayer? _webAudioPlayer; // For web platform
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _isDownloading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _hasWaveform = false; // Track if waveform is available

  @override
  void initState() {
    super.initState();
    if (widget.note.rawData['type'] == 'voice') {
      _initAudioPlayer();
    }
  }

  Future<String?> _downloadAudioFile(String url) async {
    try {
      print('⬇️ Downloading audio file from: $url');

      if (kIsWeb) {
        // On web, we can use the URL directly
        return url;
      }

      // Get temporary directory for mobile/desktop
      final tempDir = await getTemporaryDirectory();
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final filePath = '${tempDir.path}/$fileName';

      // Download the file
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Write to file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        print('✅ Audio file downloaded to: $filePath');
        return filePath;
      } else {
        print('❌ Failed to download audio: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error downloading audio: $e');
      return null;
    }
  }

  Future<void> _initAudioPlayer() async {
    final audioData = widget.note.rawData['data'] as String?;
    if (audioData == null || audioData.isEmpty) {
      print('❌ Audio data is null or empty');
      return;
    }

    print('🎵 Initializing audio player...');
    print('📍 Audio source: $audioData');
    print('🌐 Platform: ${kIsWeb ? "Web" : "Mobile/Desktop"}');

    try {
      // Check if it's a URL (Cloudinary) or local path
      final isUrl =
          audioData.startsWith('http://') || audioData.startsWith('https://');

      String? audioPath;

      if (isUrl) {
        print('🌐 Processing audio from URL...');

        if (mounted) {
          setState(() {
            _isDownloading = true;
          });
        }

        audioPath = await _downloadAudioFile(audioData);

        if (mounted) {
          setState(() {
            _isDownloading = false;
          });
        }

        if (audioPath == null) {
          throw Exception('Failed to download audio file');
        }
      } else {
        // For base64 data, we need to handle it differently
        if (kIsWeb) {
          // On web, convert base64 to data URL
          try {
            final cleanBase64 = audioData.contains(',')
                ? audioData.split(',').last
                : audioData;
            audioPath = 'data:audio/m4a;base64,$cleanBase64';
          } catch (e) {
            print('❌ Error processing base64 audio: $e');
            throw Exception('Failed to process audio data');
          }
        } else {
          audioPath = audioData;
        }
      }

      if (kIsWeb) {
        // Use audioplayers for web
        _webAudioPlayer = AudioPlayer();
        
        // Set up event listeners
        _webAudioPlayer!.onPlayerStateChanged.listen((state) {
          if (mounted) {
            setState(() {
              _isPlaying = state == PlayerState.playing;
            });
          }
        });

        _webAudioPlayer!.onDurationChanged.listen((duration) {
          if (mounted) {
            setState(() {
              _duration = duration;
              _isInitialized = true;
            });
          }
        });

        _webAudioPlayer!.onPositionChanged.listen((position) {
          if (mounted) {
            setState(() {
              _position = position;
            });
          }
        });

        // Load and play the audio source
        await _webAudioPlayer!.setSource(UrlSource(audioPath));
        
        // Get duration
        final duration = await _webAudioPlayer!.getDuration();
        if (duration != null && mounted) {
          setState(() {
            _duration = duration;
            _isInitialized = true;
            _hasWaveform = false; // No waveform on web
          });
        }

        print('✅ Web audio player initialized successfully');
        print('📊 Duration: ${_duration.inSeconds}s');
      } else {
        // Use audio_waveforms for mobile/desktop
        _playerController = waveforms.PlayerController();

        print('🔄 Preparing player...');

        // Prepare player with local file path
        // audioPath is guaranteed to be non-null at this point
        await _playerController!.preparePlayer(
          path: audioPath,
          shouldExtractWaveform: true,
          noOfSamples: 200,
          volume: 1.0,
        );

        // Give it time to load and extract waveform
        await Future.delayed(const Duration(milliseconds: 800));

        // Update duration
        if (mounted) {
          setState(() {
            _duration = Duration(milliseconds: _playerController!.maxDuration);
            _isInitialized = true;
            _hasWaveform = _playerController!.waveformData.isNotEmpty;
          });
          print('✅ Audio player initialized successfully');
          print('📊 Duration: ${_duration.inSeconds}s');
          print(
            '🎵 Waveform data points: ${_playerController!.waveformData.length}',
          );
        }

        // Listen to player state
        _playerController!.onPlayerStateChanged.listen((state) {
          print('🎵 Player state changed: $state');
          if (mounted) {
            setState(() {
              _isPlaying = state == waveforms.PlayerState.playing;
            });
          }
        });

        // Listen to current position
        _playerController!.onCurrentDurationChanged.listen((duration) {
          if (mounted) {
            setState(() {
              _position = Duration(milliseconds: duration);
            });

            // Check if playback finished
            if (duration >= _playerController!.maxDuration && _isPlaying) {
              setState(() {
                _isPlaying = false;
                _position = Duration.zero;
              });
            }
          }
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error initializing audio player: $e');
      print('📚 Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _seekToPosition(double dx, double waveformWidth) {
    if (!_isInitialized) {
      print('⚠️ Cannot seek: player not ready');
      return;
    }

    if (_duration.inMilliseconds == 0) {
      print('⚠️ Cannot seek: duration is zero');
      return;
    }

    try {
      // Calculate the percentage of the tap position
      final percentage = (dx / waveformWidth).clamp(0.0, 1.0);

      // Calculate the target position in milliseconds
      final targetPositionMs = (_duration.inMilliseconds * percentage).toInt();

      print(
        '🎯 Seeking to: ${(percentage * 100).toStringAsFixed(1)}% (${targetPositionMs}ms / ${_duration.inMilliseconds}ms)',
      );
      print(
        '📏 Tap position: ${dx.toStringAsFixed(1)}px / ${waveformWidth.toStringAsFixed(1)}px',
      );

      // Seek to the position
      if (kIsWeb) {
        _webAudioPlayer?.seek(Duration(milliseconds: targetPositionMs));
      } else {
        _playerController?.seekTo(targetPositionMs);
      }

      // Update the position state immediately for visual feedback
      if (mounted) {
        setState(() {
          _position = Duration(milliseconds: targetPositionMs);
        });
      }

      print('✅ Seek completed');
    } catch (e, stackTrace) {
      print('❌ Error seeking: $e');
      print('📚 Stack trace: $stackTrace');
    }
  }

  Future<void> _togglePlayPause() async {
    if (!_isInitialized) {
      print('⚠️ Player not initialized yet');
      return;
    }

    try {
      if (kIsWeb) {
        if (_webAudioPlayer == null) {
          print('⚠️ Web audio player is null');
          return;
        }

        if (_isPlaying) {
          print('⏸️ Pausing player...');
          await _webAudioPlayer!.pause();
          if (mounted) {
            setState(() {
              _isPlaying = false;
            });
          }
          print('✅ Paused successfully');
        } else {
          print('▶️ Starting player...');
          await _webAudioPlayer!.resume();
          if (mounted) {
            setState(() {
              _isPlaying = true;
            });
          }
          print('✅ Playing successfully');
        }
      } else {
        if (_playerController == null) {
          print('⚠️ Player controller is null');
          return;
        }

        if (_isPlaying) {
          print('⏸️ Pausing player...');
          await _playerController!.pausePlayer();
          if (mounted) {
            setState(() {
              _isPlaying = false;
            });
          }
          print('✅ Paused successfully');
        } else {
          print('▶️ Starting player...');
          await _playerController!.startPlayer();
          if (mounted) {
            setState(() {
              _isPlaying = true;
            });
          }
          print('✅ Playing successfully');
        }
      }
    } catch (e) {
      print('❌ Error toggling play/pause: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playback error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      _webAudioPlayer?.dispose();
    } else {
      _playerController?.dispose();
    }
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM d, yyyy at h:mm a').format(date);
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'text':
        return Icons.text_fields;
      case 'image':
        return Icons.image;
      case 'voice':
        return Icons.mic;
      default:
        return Icons.note;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'text':
        return Colors.blue;
      case 'image':
        return Colors.purple;
      case 'voice':
        return Colors.orange;
      default:
        return widget.accentColor;
    }
  }

  Widget _buildContent(BuildContext context) {
    final type = widget.note.rawData['type'] as String? ?? 'text';
    final data = widget.note.rawData['data'] as String? ?? '';

    switch (type) {
      case 'image':
        return _buildImageContent(data);
      case 'voice':
        return _buildVoiceContent();
      case 'text':
      default:
        return _buildTextContent(data);
    }
  }

  Widget _buildTextContent(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SelectableText(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
      ),
    );
  }

  Widget _buildImageContent(String imageData) {
    try {
      if (imageData.isEmpty) {
        return _buildErrorWidget('No image data available');
      }

      // Check if it's a URL (Cloudinary) or base64 data
      if (imageData.startsWith('http://') || imageData.startsWith('https://')) {
        // It's a Cloudinary URL, use Image.network
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageData,
            width: double.infinity,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading image...',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget('Failed to load image from server');
            },
          ),
        );
      } else {
        // It's base64 data, decode it
        final cleanBase64 = imageData.contains(',')
            ? imageData.split(',').last
            : imageData;
        final Uint8List bytes = base64Decode(cleanBase64);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            bytes,
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget('Failed to load image');
            },
          ),
        );
      }
    } catch (e) {
      return _buildErrorWidget('Error loading image: $e');
    }
  }

  Widget _buildVoiceContent() {
    final meta = widget.note.rawData['meta'] as Map<String, dynamic>?;
    final duration = meta?['duration'] ?? 'Unknown';
    final sizeInKB = meta?['size'] != null
        ? ((meta!['size'] as num) / 1024).toStringAsFixed(1)
        : 'Unknown';

    String _formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return '$minutes:$seconds';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header with title and duration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Voice Recording',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _playerController != null && _duration.inSeconds > 0
                    ? _formatDuration(_duration)
                    : duration.toString(),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Waveform with integrated play button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Play/Pause Button
                GestureDetector(
                  onTap: _isDownloading ? null : _togglePlayPause,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange,
                    ),
                    child: _isDownloading
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 28,
                          ),
                  ),
                ),

                const SizedBox(width: 16),

                // Waveform or Progress Bar
                Expanded(
                  child: _isInitialized && _duration.inSeconds > 0
                      ? (_hasWaveform && !kIsWeb && _playerController != null
                            ? LayoutBuilder(
                                builder: (context, constraints) {
                                  return GestureDetector(
                                    onTapDown: (details) => _seekToPosition(
                                      details.localPosition.dx,
                                      constraints.maxWidth,
                                    ),
                                    onHorizontalDragUpdate: (details) =>
                                        _seekToPosition(
                                          details.localPosition.dx,
                                          constraints.maxWidth,
                                        ),
                                    child: waveforms.AudioFileWaveforms(
                                      size: Size(constraints.maxWidth, 50),
                                      playerController: _playerController!,
                                      waveformType: waveforms.WaveformType.fitWidth,
                                      playerWaveStyle: waveforms.PlayerWaveStyle(
                                        fixedWaveColor: const Color(0xFF4A4A4A),
                                        liveWaveColor: Colors.orange,
                                        spacing: 6,
                                        waveThickness: 3,
                                        showSeekLine: false,
                                        waveCap: StrokeCap.round,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                height: 50,
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTapDown: (details) {
                                    if (!kIsWeb) {
                                      _seekToPosition(
                                        details.localPosition.dx,
                                        50,
                                      );
                                    }
                                  },
                                  onHorizontalDragUpdate: (details) {
                                    if (!kIsWeb) {
                                      _seekToPosition(
                                        details.localPosition.dx,
                                        50,
                                      );
                                    }
                                  },
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      trackHeight: 3,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 6,
                                      ),
                                      overlayShape: const RoundSliderOverlayShape(
                                        overlayRadius: 12,
                                      ),
                                      trackShape:
                                          const RoundedRectSliderTrackShape(),
                                    ),
                                    child: Slider(
                                      value: _position.inSeconds.toDouble().clamp(
                                        0.0,
                                        _duration.inSeconds.toDouble(),
                                      ),
                                      max: _duration.inSeconds.toDouble(),
                                      activeColor: Colors.orange,
                                      inactiveColor: const Color(0xFF4A4A4A),
                                      onChanged: (value) async {
                                        final positionMs = (value * 1000).toInt();
                                        if (kIsWeb) {
                                          await _webAudioPlayer?.seek(
                                            Duration(milliseconds: positionMs),
                                          );
                                        } else {
                                          await _playerController?.seekTo(
                                            positionMs,
                                          );
                                        }
                                        if (mounted) {
                                          setState(() {
                                            _position = Duration(milliseconds: positionMs);
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ))
                      : Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: Text(
                            'Loading...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Time progress
          if (_isInitialized && _duration.inSeconds > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_position),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatDuration(_duration - _position),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // File Size
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Size: $sizeInKB KB',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Error message if audio player failed
          if (!_isInitialized &&
              widget.note.rawData['data'] != null &&
              !_isDownloading) ...[
            const SizedBox(height: 16),
            Text(
              'Unable to load audio. Please check your connection.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.grey[600], size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.note.rawData['type'] as String? ?? 'text';
    final typeColor = _getColorForType(type);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: typeColor.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: typeColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForType(type),
                      color: typeColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.note.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(widget.note.createdAt),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildContent(context),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: typeColor.withOpacity(0.2), width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Type Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: typeColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getIconForType(type), color: typeColor, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          type.toUpperCase(),
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Delete Button
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF1C1C1E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text(
                            'Delete Note',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            'Are you sure you want to delete this note? This action cannot be undone.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pop(); // Close confirmation
                                widget.onDelete();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
