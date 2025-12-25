// Stub file for audio_waveforms on web
// This file is used when building for web platform

import 'package:flutter/material.dart';

class PlayerController {
  // Stub implementation - not used on web
  int get maxDuration => 0;
  List<double> get waveformData => [];

  Future<void> preparePlayer({
    required String path,
    bool shouldExtractWaveform = false,
    int noOfSamples = 200,
    double volume = 1.0,
  }) async {
    // Stub - not used on web
  }

  Future<void> startPlayer() async {
    // Stub - not used on web
  }

  Future<void> pausePlayer() async {
    // Stub - not used on web
  }

  Future<void> seekTo(int positionMs) async {
    // Stub - not used on web
  }

  void dispose() {
    // Stub - not used on web
  }

  Stream<PlayerState> get onPlayerStateChanged => const Stream.empty();
  Stream<int> get onCurrentDurationChanged => const Stream.empty();
}

enum PlayerState { playing, paused, stopped }

class AudioFileWaveforms extends StatelessWidget {
  final Size size;
  final PlayerController playerController;
  final WaveformType waveformType;
  final PlayerWaveStyle playerWaveStyle;

  const AudioFileWaveforms({
    super.key,
    required this.size,
    required this.playerController,
    required this.waveformType,
    required this.playerWaveStyle,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

enum WaveformType { fitWidth }

class PlayerWaveStyle {
  final Color fixedWaveColor;
  final Color liveWaveColor;
  final double spacing;
  final double waveThickness;
  final bool showSeekLine;
  final StrokeCap waveCap;

  const PlayerWaveStyle({
    required this.fixedWaveColor,
    required this.liveWaveColor,
    required this.spacing,
    required this.waveThickness,
    required this.showSeekLine,
    required this.waveCap,
  });
}
