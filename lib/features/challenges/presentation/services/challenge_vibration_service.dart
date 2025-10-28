import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service for haptic feedback during challenges
/// Provides vibration feedback for user interactions
class ChallengeVibrationService {
  static final ChallengeVibrationService _instance = ChallengeVibrationService._internal();
  
  factory ChallengeVibrationService() => _instance;
  
  ChallengeVibrationService._internal();

  bool _vibrationEnabled = true;

  /// Enable or disable vibration feedback
  void setVibrationEnabled(bool enabled) {
    _vibrationEnabled = enabled;
    debugPrint('ChallengeVibrationService - Vibration ${enabled ? "enabled" : "disabled"}');
  }

  /// Check if vibration is enabled
  bool get isVibrationEnabled => _vibrationEnabled;

  /// Light vibration for button taps and selections
  Future<void> light() async {
    if (!_vibrationEnabled) return;
    
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('ChallengeVibrationService - Error with light vibration: $e');
    }
  }

  /// Medium vibration for answer submission
  Future<void> medium() async {
    if (!_vibrationEnabled) return;
    
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('ChallengeVibrationService - Error with medium vibration: $e');
    }
  }

  /// Heavy vibration for correct answers
  Future<void> heavy() async {
    if (!_vibrationEnabled) return;
    
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('ChallengeVibrationService - Error with heavy vibration: $e');
    }
  }

  /// Selection vibration for option selection
  Future<void> selection() async {
    if (!_vibrationEnabled) return;
    
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('ChallengeVibrationService - Error with selection vibration: $e');
    }
  }

  /// Success pattern: double vibration for correct answers
  Future<void> success() async {
    if (!_vibrationEnabled) return;
    
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('ChallengeVibrationService - Error with success pattern: $e');
    }
  }

  /// Error pattern: single heavy vibration for incorrect answers
  Future<void> error() async {
    if (!_vibrationEnabled) return;
    
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('ChallengeVibrationService - Error with error pattern: $e');
    }
  }

  /// Warning pattern: repeated light vibrations for timer warnings
  Future<void> warning() async {
    if (!_vibrationEnabled) return;
    
    try {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('ChallengeVibrationService - Error with warning pattern: $e');
    }
  }
}
