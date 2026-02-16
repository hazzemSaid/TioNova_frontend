import 'dart:async';
import 'dart:html' as html;

/// Web Audio Recorder using MediaRecorder API
/// Works on Chrome, Firefox, Safari (iOS 14.3+)
class WebAudioRecorder {
  html.MediaRecorder? _mediaRecorder;
  html.MediaStream? _mediaStream;
  final List<html.Blob> _audioChunks = [];
  StreamController<Duration>? _durationController;
  DateTime? _startTime;
  Timer? _durationTimer;
  bool _isRecording = false;

  /// Check if audio recording is supported
  static bool get isSupported {
    return html.window.navigator.mediaDevices != null;
  }

  /// Request microphone permission and start recording
  Future<void> startRecording() async {
    if (_isRecording) return;

    try {
      // Request microphone access
      _mediaStream = await html.window.navigator.mediaDevices!.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'sampleRate': 44100,
        },
      });

      // Determine the best MIME type for this browser
      final String mimeType = _getBestMimeType();

      // Create MediaRecorder
      _mediaRecorder = html.MediaRecorder(_mediaStream!, {
        'mimeType': mimeType,
      });

      _audioChunks.clear();

      // Listen for data available
      _mediaRecorder!.addEventListener('dataavailable', (event) {
        final html.Blob blob = (event as html.BlobEvent).data!;
        if (blob.size > 0) {
          _audioChunks.add(blob);
        }
      });

      // Start recording
      _mediaRecorder!.start();
      _isRecording = true;
      _startTime = DateTime.now();

      // Start duration timer
      _durationController = StreamController<Duration>.broadcast();
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_startTime != null && _isRecording) {
          final duration = DateTime.now().difference(_startTime!);
          _durationController?.add(duration);
        }
      });
    } catch (e) {
      throw Exception('Failed to access microphone: $e');
    }
  }

  /// Get the best MIME type supported by the browser
  String _getBestMimeType() {
    // Try different MIME types in order of preference
    final List<String> mimeTypes = [
      'audio/webm;codecs=opus',
      'audio/webm',
      'audio/ogg;codecs=opus',
      'audio/mp4',
      'audio/mpeg',
    ];

    for (final mimeType in mimeTypes) {
      if (html.MediaRecorder.isTypeSupported(mimeType)) {
        return mimeType;
      }
    }

    // Fallback to default (should work on most browsers)
    return 'audio/webm';
  }

  /// Stop recording and return the audio data as base64
  Future<RecordingResult> stopRecording() async {
    if (!_isRecording || _mediaRecorder == null) {
      throw Exception('Recording not started');
    }

    final completer = Completer<RecordingResult>();

    // Listen for stop event
    _mediaRecorder!.addEventListener('stop', (event) async {
      try {
        // Create blob from chunks
        final blob = html.Blob(_audioChunks, _mediaRecorder!.mimeType);

        // Read blob as base64
        final reader = html.FileReader();
        reader.readAsDataUrl(blob);

        await reader.onLoadEnd.first;

        final String dataUrl = reader.result as String;
        final String base64Data = dataUrl.split(',').last;

        // Calculate duration
        final duration = _startTime != null
            ? DateTime.now().difference(_startTime!)
            : Duration.zero;

        // Get MIME type
        final mimeType = _mediaRecorder!.mimeType ?? 'audio/webm';

        completer.complete(
          RecordingResult(
            base64Data: base64Data,
            duration: duration,
            mimeType: mimeType,
            sizeBytes: blob.size,
          ),
        );
      } catch (e) {
        completer.completeError(e);
      }
    });

    // Stop recording
    _mediaRecorder!.stop();
    _isRecording = false;

    // Stop all tracks
    _mediaStream?.getTracks().forEach((track) => track.stop());

    // Clean up
    _durationTimer?.cancel();
    await _durationController?.close();

    return completer.future;
  }

  /// Get stream of recording duration updates
  Stream<Duration>? get onDurationChanged => _durationController?.stream;

  /// Check if currently recording
  bool get isRecording => _isRecording;

  /// Dispose resources
  void dispose() {
    _mediaRecorder?.stop();
    _mediaStream?.getTracks().forEach((track) => track.stop());
    _durationTimer?.cancel();
    _durationController?.close();
  }
}

/// Result of a recording
class RecordingResult {
  final String base64Data;
  final Duration duration;
  final String mimeType;
  final int sizeBytes;

  RecordingResult({
    required this.base64Data,
    required this.duration,
    required this.mimeType,
    required this.sizeBytes,
  });

  /// Get data URL for playback
  String get dataUrl => 'data:$mimeType;base64,$base64Data';
}
