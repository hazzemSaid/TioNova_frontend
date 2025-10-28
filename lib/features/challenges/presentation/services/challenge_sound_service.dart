import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service for playing challenge sound effects
/// Handles correct/incorrect answers, timer warnings, and completion sounds
class ChallengeSoundService {
  static final ChallengeSoundService _instance =
      ChallengeSoundService._internal();

  factory ChallengeSoundService() => _instance;

  ChallengeSoundService._internal();

  bool _soundEnabled = true;

  /// Enable or disable sound effects
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    debugPrint(
      'ChallengeSoundService - Sound ${enabled ? "enabled" : "disabled"}',
    );
  }

  /// Check if sound is enabled
  bool get isSoundEnabled => _soundEnabled;

  /// Play sound when answer is correct
  Future<void> playCorrectSound() async {
    if (!_soundEnabled) return;

    try {
      debugPrint('ChallengeSoundService - Playing correct answer sound');
      await SystemSound.play(SystemSoundType.click);
      // In production, you would use audioplayers package:
      // await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      debugPrint('ChallengeSoundService - Error playing correct sound: $e');
    }
  }

  /// Play sound when answer is incorrect
  Future<void> playIncorrectSound() async {
    if (!_soundEnabled) return;

    try {
      debugPrint('ChallengeSoundService - Playing incorrect answer sound');
      await SystemSound.play(SystemSoundType.click);
      // In production, you would use audioplayers package:
      // await _audioPlayer.play(AssetSource('sounds/incorrect.mp3'));
    } catch (e) {
      debugPrint('ChallengeSoundService - Error playing incorrect sound: $e');
    }
  }

  /// Play sound when timer is running out (< 10 seconds)
  Future<void> playTimerWarningSound() async {
    if (!_soundEnabled) return;

    try {
      debugPrint('ChallengeSoundService - Playing timer warning sound');
      await SystemSound.play(SystemSoundType.click);
      // In production, you would use audioplayers package:
      // await _audioPlayer.play(AssetSource('sounds/timer_warning.mp3'));
    } catch (e) {
      debugPrint(
        'ChallengeSoundService - Error playing timer warning sound: $e',
      );
    }
  }

  /// Play sound when time runs out
  Future<void> playTimeoutSound() async {
    if (!_soundEnabled) return;

    try {
      debugPrint('ChallengeSoundService - Playing timeout sound');
      await SystemSound.play(SystemSoundType.click);
      // In production, you would use audioplayers package:
      // await _audioPlayer.play(AssetSource('sounds/timeout.mp3'));
    } catch (e) {
      debugPrint('ChallengeSoundService - Error playing timeout sound: $e');
    }
  }

  /// Play sound when challenge is completed
  Future<void> playCompletionSound() async {
    if (!_soundEnabled) return;

    try {
      debugPrint('ChallengeSoundService - Playing completion sound');
      await SystemSound.play(SystemSoundType.click);
      // In production, you would use audioplayers package:
      // await _audioPlayer.play(AssetSource('sounds/completion.mp3'));
    } catch (e) {
      debugPrint('ChallengeSoundService - Error playing completion sound: $e');
    }
  }

  /// Play celebration sound for winners
  Future<void> playCelebrationSound() async {
    if (!_soundEnabled) return;

    try {
      debugPrint('ChallengeSoundService - Playing celebration sound');
      await SystemSound.play(SystemSoundType.click);
      // In production, you would use audioplayers package:
      // await _audioPlayer.play(AssetSource('sounds/celebration.mp3'));
    } catch (e) {
      debugPrint('ChallengeSoundService - Error playing celebration sound: $e');
    }
  }

  /// Dispose and cleanup
  void dispose() {
    debugPrint('ChallengeSoundService - Disposing');
    // Clean up audio players if using audioplayers package
  }
}
