import 'dart:convert';
import 'dart:io';

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
  AudioPlayer? _webAudioPlayer;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _isDownloading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.note.rawData['type'] == 'voice') {
      _initAudioPlayer();
    }
  }

  Future<String?> _downloadAudioFile(String url) async {
    try {
      if (kIsWeb) return url;
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _initAudioPlayer() async {
    final audioData = widget.note.rawData['data'] as String?;
    if (audioData == null || audioData.isEmpty) return;

    try {
      final isUrl = audioData.startsWith('http');
      String? audioPath;

      if (isUrl) {
        setState(() => _isDownloading = true);
        audioPath = await _downloadAudioFile(audioData);
        setState(() => _isDownloading = false);
        if (audioPath == null) throw Exception('Failed to download audio');
      } else {
        if (kIsWeb) {
          final cleanBase64 = audioData.contains(',') ? audioData.split(',').last : audioData;
          audioPath = 'data:audio/m4a;base64,$cleanBase64';
        } else {
          audioPath = audioData;
        }
      }

      if (kIsWeb) {
        _webAudioPlayer = AudioPlayer();
        _webAudioPlayer!.onPlayerStateChanged.listen((s) => setState(() => _isPlaying = s == PlayerState.playing));
        _webAudioPlayer!.onDurationChanged.listen((d) => setState(() => _duration = d));
        _webAudioPlayer!.onPositionChanged.listen((p) => setState(() => _position = p));
        await _webAudioPlayer!.setSource(UrlSource(audioPath));
        final d = await _webAudioPlayer!.getDuration();
        if (d != null) setState(() { _duration = d; _isInitialized = true; });
      } else {
        _playerController = waveforms.PlayerController();
        await _playerController!.preparePlayer(path: audioPath, volume: 1.0);
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {
          _duration = Duration(milliseconds: _playerController!.maxDuration);
          _isInitialized = true;
        });
        _playerController!.onPlayerStateChanged.listen((s) => setState(() => _isPlaying = s == waveforms.PlayerState.playing));
        _playerController!.onCurrentDurationChanged.listen((d) => setState(() => _position = Duration(milliseconds: d)));
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _togglePlayPause() async {
    if (!_isInitialized) return;
    if (kIsWeb) {
      _isPlaying ? await _webAudioPlayer!.pause() : await _webAudioPlayer!.resume();
    } else {
      _isPlaying ? await _playerController!.pausePlayer() : await _playerController!.startPlayer();
    }
  }

  @override
  void dispose() {
    _webAudioPlayer?.dispose();
    _playerController?.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) => DateFormat('MMMM d, yyyy').format(date);
  String _formatDuration(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  IconData _getIconForType(String type) {
    switch (type) {
      case 'text': return Icons.text_fields_rounded;
      case 'image': return Icons.image_rounded;
      case 'voice': return Icons.mic_rounded;
      default: return Icons.note_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'text': return Colors.blue;
      case 'image': return Colors.purple;
      case 'voice': return Colors.orange;
      default: return widget.accentColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final type = widget.note.rawData['type'] as String? ?? 'text';
    final typeColor = _getColorForType(type);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(colorScheme, type, typeColor),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContent(colorScheme),
                    const SizedBox(height: 24),
                    _buildInfoSection(colorScheme),
                  ],
                ),
              ),
            ),
            _buildFooter(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, String type, Color typeColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colorScheme.outline.withOpacity(0.1)))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [typeColor.withOpacity(0.8), typeColor]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_getIconForType(type), color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.note.title, style: TextStyle(color: colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.bold)),
                Text(_formatDate(widget.note.createdAt), style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
            style: IconButton.styleFrom(backgroundColor: colorScheme.surfaceContainerHighest, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ColorScheme colorScheme) {
    final type = widget.note.rawData['type'] as String? ?? 'text';
    final data = widget.note.rawData['data'] as String? ?? '';

    if (type == 'image') return _buildImageContent(data, colorScheme);
    if (type == 'voice') return _buildVoiceContent(colorScheme);
    return _buildTextContent(data, colorScheme);
  }

  Widget _buildTextContent(String text, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
      child: SelectableText(text, style: TextStyle(color: colorScheme.onSurface, fontSize: 16, height: 1.6)),
    );
  }

  Widget _buildImageContent(String data, ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: data.startsWith('http') 
          ? Image.network(data, width: double.infinity, fit: BoxFit.contain)
          : Image.memory(base64Decode(data.contains(',') ? data.split(',').last : data), width: double.infinity, fit: BoxFit.contain),
    );
  }

  Widget _buildVoiceContent(ColorScheme colorScheme) {
    final meta = widget.note.rawData['meta'] as Map<String, dynamic>?;
    final durationLabel = meta?['duration'] ?? 'Unknown';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.orange.withOpacity(0.2))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Audio Recording', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
              Text(_isInitialized ? _formatDuration(_duration) : durationLabel, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              IconButton.filled(
                onPressed: _isDownloading ? null : _togglePlayPause,
                icon: Icon(_isDownloading ? Icons.hourglass_empty_rounded : (_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded)),
                style: IconButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, fixedSize: const Size(56, 56)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Slider(
                      value: _position.inMilliseconds.toDouble().clamp(0.0, _duration.inMilliseconds.toDouble()),
                      max: _duration.inMilliseconds.toDouble() > 0 ? _duration.inMilliseconds.toDouble() : 1.0,
                      onChanged: (v) {
                        if (kIsWeb) { _webAudioPlayer?.seek(Duration(milliseconds: v.toInt())); }
                        else { _playerController?.seekTo(v.toInt()); }
                      },
                      activeColor: Colors.orange,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(_position), style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11)),
                          Text(_formatDuration(_duration), style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('INFORMATION', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.person_rounded, 'Created by', widget.note.creatorName ?? widget.note.creatorEmail ?? 'Unknown', colorScheme),
        const SizedBox(height: 8),
        _buildInfoRow(Icons.calendar_today_rounded, 'Date', _formatDate(widget.note.createdAt), colorScheme),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
        Text(value, style: TextStyle(color: colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFooter(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest.withOpacity(0.3), border: Border(top: BorderSide(color: colorScheme.outline.withOpacity(0.1))), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28))),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: () => _confirmDelete(context),
              icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
              label: Text('Delete', style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: colorScheme.errorContainer.withOpacity(0.1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
              child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () { Navigator.pop(context); widget.onDelete(); }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
