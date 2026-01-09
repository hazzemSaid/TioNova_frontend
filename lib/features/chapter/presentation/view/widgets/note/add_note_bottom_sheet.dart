import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tionova/core/utils/platform_utils.dart';
import 'package:tionova/features/chapter/presentation/bloc/chapter/chapter_cubit.dart';

import 'voice_file_stub.dart'
    if (dart.library.io) 'voice_file_io.dart'
    as voice_fs;

class AddNoteBottomSheet extends StatefulWidget {
  final String chapterId;
  final Color accentColor;
  final VoidCallback onNoteAdded;
  final String? initialNoteType;

  const AddNoteBottomSheet({
    super.key,
    required this.chapterId,
    required this.accentColor,
    required this.onNoteAdded,
    this.initialNoteType,
  });

  @override
  State<AddNoteBottomSheet> createState() => _AddNoteBottomSheetState();
}

class _AddNoteBottomSheetState extends State<AddNoteBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  String _selectedType = 'text';
  Uint8List? _imageData;
  String? _imageName;
  int? _imageSize;
  bool _isRecording = false;
  FlutterSoundRecorder? _audioRecorder;
  String? _audioPath;
  Duration _recordingDuration = Duration.zero;
  DateTime? _recordingStartTime;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialNoteType ?? 'text';
    _initAudioRecorder();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    _stopRecording();
    _audioRecorder?.closeRecorder();
    super.dispose();
  }

  Future<void> _initAudioRecorder() async {
    if (isWeb) return;
    _audioRecorder = FlutterSoundRecorder();
    await _audioRecorder!.openRecorder();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageData = bytes;
        _imageName = image.name;
        _imageSize = bytes.length;
      });
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (photo != null) {
      final bytes = await photo.readAsBytes();
      setState(() {
        _imageData = bytes;
        _imageName = photo.name;
        _imageSize = bytes.length;
      });
    }
  }

  Future<void> _startRecording() async {
    if (isWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice recording is not supported on Web yet'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _audioRecorder!.startRecorder(toFile: path, codec: Codec.aacADTS);

      setState(() {
        _isRecording = true;
        _audioPath = path;
        _recordingStartTime = DateTime.now();
        _recordingDuration = Duration.zero;
      });

      _updateRecordingDuration();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start recording: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateRecordingDuration() {
    if (_isRecording && _recordingStartTime != null) {
      Future.delayed(const Duration(seconds: 1), () {
        if (_isRecording && mounted) {
          setState(() {
            _recordingDuration = DateTime.now().difference(
              _recordingStartTime!,
            );
          });
          _updateRecordingDuration();
        }
      });
    }
  }

  Future<void> _stopRecording() async {
    if (isWeb) return;
    if (_isRecording && _audioRecorder != null) {
      await _audioRecorder!.stopRecorder();
      setState(() => _isRecording = false);
    }
  }

  Future<void> _deleteRecording() async {
    if (_audioPath != null) {
      try {
        if (!isWeb) await voice_fs.deleteFile(_audioPath!);
      } catch (e) {
        debugPrint('Error deleting recording: $e');
      }
      setState(() {
        _audioPath = null;
        _recordingDuration = Duration.zero;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Map<String, dynamic> rawData = {'type': _selectedType};

    if (_selectedType == 'text') {
      if (_textController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter some text'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      rawData['data'] = _textController.text.trim();
    } else if (_selectedType == 'image') {
      if (_imageData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an image'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      rawData['data'] = base64Encode(_imageData!);
      rawData['meta'] = {'fileName': _imageName, 'size': _imageSize};
    } else if (_selectedType == 'voice') {
      if (_audioPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please record some audio'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final bytes = await voice_fs.readFileBytes(_audioPath!);
      rawData['data'] = base64Encode(bytes);
      rawData['meta'] = {
        'duration': _formatDuration(_recordingDuration),
        'size': bytes.length,
      };
    }

    if (mounted) {
      context.read<ChapterCubit>().addNote(
        title: _titleController.text.trim(),
        chapterId: widget.chapterId,
        rawData: rawData,
      );
      Navigator.of(context).pop();
      widget.onNoteAdded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(colorScheme),
                _buildTypeSelector(colorScheme),
                _buildTitleInput(colorScheme),
                _buildContentSection(colorScheme),
                _buildActionButtons(colorScheme),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.add_circle_outline_rounded,
              color: widget.accentColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Add New Note',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Note Type',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTypeChip(
                'text',
                'Text',
                Icons.text_fields_rounded,
                colorScheme,
              ),
              const SizedBox(width: 12),
              _buildTypeChip(
                'image',
                'Image',
                Icons.image_rounded,
                colorScheme,
              ),
              const SizedBox(width: 12),
              _buildTypeChip('voice', 'Voice', Icons.mic_rounded, colorScheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(
    String type,
    String label,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? widget.accentColor.withOpacity(0.1)
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? widget.accentColor
                  : colorScheme.outline.withOpacity(0.1),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? widget.accentColor
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? widget.accentColor
                      : colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleInput(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Title',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Enter note title',
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(ColorScheme colorScheme) {
    switch (_selectedType) {
      case 'image':
        return _buildImageSection(colorScheme);
      case 'voice':
        return _buildVoiceSection(colorScheme);
      default:
        return _buildTextSection(colorScheme);
    }
  }

  Widget _buildTextSection(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Content',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            maxLines: 6,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Write your note here...',
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Image',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          if (_imageData != null)
            Container(
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.accentColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.memory(_imageData!, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: IconButton(
                      onPressed: () => setState(() {
                        _imageData = null;
                        _imageName = null;
                        _imageSize = null;
                      }),
                      icon: const Icon(
                        Icons.delete_rounded,
                        color: Colors.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                _buildImageButton(
                  'Gallery',
                  Icons.photo_library_rounded,
                  _pickImage,
                  colorScheme,
                ),
                const SizedBox(width: 12),
                _buildImageButton(
                  'Camera',
                  Icons.camera_alt_rounded,
                  _takePhoto,
                  colorScheme,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildImageButton(
    String label,
    IconData icon,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Icon(icon, color: widget.accentColor),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceSection(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Voice Recording',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isRecording
                    ? Colors.red.withOpacity(0.3)
                    : colorScheme.outline.withOpacity(0.1),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                if (_isRecording) ...[
                  _buildPulseIcon(Colors.red),
                  const SizedBox(height: 24),
                  Text(
                    _formatDuration(_recordingDuration),
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else if (_audioPath != null) ...[
                  _buildPulseIcon(
                    widget.accentColor,
                    icon: Icons.check_circle_rounded,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _formatDuration(_recordingDuration),
                    style: TextStyle(
                      color: widget.accentColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else ...[
                  _buildPulseIcon(
                    colorScheme.onSurfaceVariant,
                    icon: Icons.mic_none_rounded,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ready to record',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 18,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_audioPath != null && !_isRecording)
                      IconButton.filledTonal(
                        onPressed: _deleteRecording,
                        icon: const Icon(Icons.delete_rounded),
                        padding: const EdgeInsets.all(16),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.errorContainer,
                          foregroundColor: colorScheme.error,
                        ),
                      ),
                    if (_audioPath != null && !_isRecording)
                      const SizedBox(width: 16),
                    FloatingActionButton.extended(
                      onPressed: _isRecording
                          ? _stopRecording
                          : _startRecording,
                      backgroundColor: _isRecording
                          ? Colors.red
                          : widget.accentColor,
                      foregroundColor: _isRecording
                          ? Colors.white
                          : Colors.black,
                      icon: Icon(
                        _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      ),
                      label: Text(_isRecording ? 'Stop' : 'Start Recording'),
                      elevation: 0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseIcon(Color color, {IconData icon = Icons.mic_rounded}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 48),
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ElevatedButton(
        onPressed: _saveNote,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.accentColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Save Note',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
