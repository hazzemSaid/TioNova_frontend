import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service to track app usage time
class AppUsageTrackerService with WidgetsBindingObserver {
  static final AppUsageTrackerService _instance =
      AppUsageTrackerService._internal();
  factory AppUsageTrackerService() => _instance;
  AppUsageTrackerService._internal();

  // Tracking state
  DateTime? _sessionStartTime;
  DateTime? _lastResumeTime;
  Timer? _updateTimer;
  bool _isTracking = false;

  // Hive box for storing usage data
  static const String _boxName = 'app_usage';
  Box<dynamic>? _usageBox;

  // Current session time in seconds
  int _currentSessionSeconds = 0;

  // Stream controller for usage updates
  final StreamController<int> _usageStreamController =
      StreamController<int>.broadcast();

  /// Initialize the tracker
  Future<void> initialize() async {
    if (_isTracking) return;

    try {
      // Open Hive box
      _usageBox = await Hive.openBox(_boxName);

      // Register as lifecycle observer
      WidgetsBinding.instance.addObserver(this);

      // Start tracking
      _startSession();
      _isTracking = true;

      debugPrint('AppUsageTracker: Initialized successfully');
    } catch (e) {
      debugPrint('AppUsageTracker: Error initializing - $e');
    }
  }

  /// Dispose the tracker
  void dispose() {
    _updateTimer?.cancel();
    _usageStreamController.close();
    WidgetsBinding.instance.removeObserver(this);
    _saveCurrentSession();
    _isTracking = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _onAppPaused();
        break;
    }
  }

  /// Start tracking session
  void _startSession() {
    _sessionStartTime = DateTime.now();
    _lastResumeTime = DateTime.now();
    _currentSessionSeconds = 0;

    // Update every second
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lastResumeTime != null) {
        _currentSessionSeconds++;
        _updateTodayUsage();
      }
    });
  }

  /// Handle app resumed
  void _onAppResumed() {
    _lastResumeTime = DateTime.now();
    debugPrint('AppUsageTracker: App resumed');
  }

  /// Handle app paused
  void _onAppPaused() {
    if (_lastResumeTime != null) {
      final pauseTime = DateTime.now();
      final sessionDuration = pauseTime.difference(_lastResumeTime!).inSeconds;
      _currentSessionSeconds += sessionDuration;
      _lastResumeTime = null;
      _saveCurrentSession();
      debugPrint('AppUsageTracker: App paused, session: ${sessionDuration}s');
    }
  }

  /// Update today's usage in real-time
  void _updateTodayUsage() {
    if (_usageBox == null) return;

    final today = _getTodayKey();
    final existingData =
        _usageBox!.get(today, defaultValue: <String, dynamic>{}) as Map;

    final updatedData = Map<String, dynamic>.from(existingData);
    updatedData['totalSeconds'] = (updatedData['totalSeconds'] ?? 0) + 1;
    updatedData['lastUpdated'] = DateTime.now().toIso8601String();

    _usageBox!.put(today, updatedData);

    // Emit the updated value to stream
    if (!_usageStreamController.isClosed) {
      _usageStreamController.add(getTodayUsageMinutes());
    }
  }

  /// Save current session
  void _saveCurrentSession() {
    if (_usageBox == null || _sessionStartTime == null) return;

    final today = _getTodayKey();
    final existingData =
        _usageBox!.get(today, defaultValue: <String, dynamic>{}) as Map;

    final updatedData = Map<String, dynamic>.from(existingData);
    updatedData['totalSeconds'] =
        (updatedData['totalSeconds'] ?? 0) + _currentSessionSeconds;
    updatedData['sessions'] = (updatedData['sessions'] ?? 0) + 1;
    updatedData['lastSession'] = DateTime.now().toIso8601String();

    _usageBox!.put(today, updatedData);
    _currentSessionSeconds = 0;
  }

  /// Get today's key (format: yyyy-MM-dd)
  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Get today's usage in minutes
  int getTodayUsageMinutes() {
    if (_usageBox == null) return 0;

    final today = _getTodayKey();
    final data =
        _usageBox!.get(today, defaultValue: <String, dynamic>{}) as Map;
    final totalSeconds = data['totalSeconds'] ?? 0;

    return (totalSeconds / 60).round();
  }

  /// Get today's usage in seconds
  int getTodayUsageSeconds() {
    if (_usageBox == null) return 0;

    final today = _getTodayKey();
    final data =
        _usageBox!.get(today, defaultValue: <String, dynamic>{}) as Map;

    return data['totalSeconds'] ?? 0;
  }

  /// Get formatted today's usage (e.g., "1h 30m" or "45m")
  String getTodayUsageFormatted() {
    final totalMinutes = getTodayUsageMinutes();

    if (totalMinutes < 60) {
      return '${totalMinutes}m';
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (minutes == 0) {
      return '${hours}h';
    }

    return '${hours}h ${minutes}m';
  }

  /// Get usage data for a specific date
  Map<String, dynamic>? getUsageForDate(DateTime date) {
    if (_usageBox == null) return null;

    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final data = _usageBox!.get(key);

    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  /// Get last 7 days usage
  List<Map<String, dynamic>> getLast7DaysUsage() {
    final usage = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final data = _usageBox?.get(key);

      usage.add({
        'date': key,
        'totalSeconds': data != null ? (data as Map)['totalSeconds'] ?? 0 : 0,
        'sessions': data != null ? (data as Map)['sessions'] ?? 0 : 0,
      });
    }

    return usage;
  }

  /// Get current streak (consecutive days with usage)
  int getCurrentStreak() {
    if (_usageBox == null) return 0;

    int streak = 0;
    final now = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final data = getUsageForDate(date);

      if (data != null && (data['totalSeconds'] ?? 0) > 0) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Get total usage this week (in minutes)
  int getWeekUsageMinutes() {
    final last7Days = getLast7DaysUsage();
    final totalSeconds = last7Days.fold<int>(
      0,
      (sum, day) => sum + (day['totalSeconds'] as int),
    );
    return (totalSeconds / 60).round();
  }

  /// Get total usage this month (in minutes)
  int getMonthUsageMinutes() {
    if (_usageBox == null) return 0;

    final now = DateTime.now();
    int totalSeconds = 0;

    for (int i = 0; i < now.day; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final data = getUsageForDate(date);
      if (data != null) {
        totalSeconds += (data['totalSeconds'] ?? 0) as int;
      }
    }

    return (totalSeconds / 60).round();
  }

  /// Clear all usage data (for testing)
  Future<void> clearAllData() async {
    await _usageBox?.clear();
    _currentSessionSeconds = 0;
  }

  /// Get live stream of today's usage (updates every second)
  Stream<int> getTodayUsageStream() {
    return _usageStreamController.stream;
  }
}
