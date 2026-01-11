// Stub file for web audio recorder on non-web platforms
// This file is not used on mobile platforms

/// Stub class - not used on mobile
class WebAudioRecorder {
  static bool get isSupported => false;

  Future<void> startRecording() async {
    throw UnsupportedError('Web audio recording not supported on mobile');
  }

  Future<RecordingResult> stopRecording() async {
    throw UnsupportedError('Web audio recording not supported on mobile');
  }

  Stream<Duration>? get onDurationChanged => null;
  bool get isRecording => false;
  void dispose() {}
}

/// Stub class - not used on mobile
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

  String get dataUrl => '';
}
