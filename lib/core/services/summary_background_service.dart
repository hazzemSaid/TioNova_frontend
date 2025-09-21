import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tionova/core/services/notification/notification_service.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/domain/usecases/GenerateSummaryUseCase.dart';

// Mock RemoteMessage for local notifications
class MockRemoteMessage extends RemoteMessage {
  final String _title;
  final String _body;
  final Map<String, dynamic> _data;

  MockRemoteMessage({
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
  }) : _title = title,
       _body = body,
       _data = data;

  @override
  RemoteNotification? get notification =>
      MockRemoteNotification(title: _title, body: _body);

  @override
  Map<String, dynamic> get data => _data;
}

class MockRemoteNotification extends RemoteNotification {
  @override
  final String? title;
  @override
  final String? body;

  MockRemoteNotification({required this.title, required this.body});
}

class SummaryBackgroundService {
  static final SummaryBackgroundService _instance =
      SummaryBackgroundService._internal();
  factory SummaryBackgroundService() => _instance;
  SummaryBackgroundService._internal();

  final NotificationService _notificationService = NotificationService();
  Timer? _processingTimer;
  GenerateSummaryUseCase? _generateSummaryUseCase;

  // Keys for SharedPreferences
  static const String _pendingRequestsKey = 'pending_summary_requests';
  static const String _completedSummariesKey = 'completed_summaries';

  // Initialize the service
  Future<void> initialize({
    GenerateSummaryUseCase? generateSummaryUseCase,
  }) async {
    print('🚀 DEBUG: Initializing SummaryBackgroundService');
    _generateSummaryUseCase = generateSummaryUseCase;
    await _notificationService.initialize();
    await _startProcessingQueue();
    print('✅ DEBUG: SummaryBackgroundService initialized');
  }

  // Add a summary request to the background queue
  Future<void> requestSummaryGeneration({
    required String chapterId,
    required String chapterTitle,
    required String token,
  }) async {
    print('📝 DEBUG: Adding summary request to queue');
    print('📄 Chapter ID: $chapterId');
    print('📖 Chapter Title: $chapterTitle');

    final prefs = await SharedPreferences.getInstance();
    final pendingRequestsJson = prefs.getStringList(_pendingRequestsKey) ?? [];

    final request = {
      'chapterId': chapterId,
      'chapterTitle': chapterTitle,
      'token': token,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'pending',
    };

    // Add to pending requests if not already exists
    final requestJson = jsonEncode(request);
    if (!pendingRequestsJson.any((r) {
      final existing = jsonDecode(r);
      return existing['chapterId'] == chapterId;
    })) {
      print('✅ DEBUG: Request added to queue');
      pendingRequestsJson.add(requestJson);
      await prefs.setStringList(_pendingRequestsKey, pendingRequestsJson);

      // Show immediate feedback notification
      print('🔔 DEBUG: Showing start notification');
      await _showNotification(
        title: 'Summary Generation Started',
        body:
            'Generating summary for "$chapterTitle". You\'ll be notified when it\'s ready.',
        chapterId: chapterId,
      );
    } else {
      print('⚠️ DEBUG: Request already exists in queue');
    }
  }

  // Start the background processing queue
  Future<void> _startProcessingQueue() async {
    print('⏰ DEBUG: Starting processing queue timer');
    _processingTimer?.cancel();
    _processingTimer = Timer.periodic(const Duration(seconds: 10), (
      timer,
    ) async {
      await _processNextRequest();
    });
  }

  // Process the next pending request
  Future<void> _processNextRequest() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingRequestsJson =
          prefs.getStringList(_pendingRequestsKey) ?? [];

      if (pendingRequestsJson.isEmpty) return;

      print('🔄 DEBUG: Processing next request from queue');

      // Get the first pending request
      final firstRequestJson = pendingRequestsJson.first;
      final request = jsonDecode(firstRequestJson);

      if (request['status'] == 'pending') {
        print(
          '📊 DEBUG: Processing request for chapter: ${request['chapterId']}',
        );

        // Mark as processing
        request['status'] = 'processing';
        pendingRequestsJson[0] = jsonEncode(request);
        await prefs.setStringList(_pendingRequestsKey, pendingRequestsJson);

        // Process the request
        await _generateSummary(
          chapterId: request['chapterId'],
          chapterTitle: request['chapterTitle'],
          token: request['token'],
        );

        // Remove from pending requests
        pendingRequestsJson.removeAt(0);
        await prefs.setStringList(_pendingRequestsKey, pendingRequestsJson);
        print('✅ DEBUG: Request completed and removed from queue');
      }
    } catch (e) {
      print('💥 DEBUG: Error processing summary request: $e');
    }
  }

  // Generate summary using the use case
  Future<void> _generateSummary({
    required String chapterId,
    required String chapterTitle,
    required String token,
  }) async {
    print('🤖 DEBUG: Starting AI summary generation');
    try {
      // Check if use case is available
      if (_generateSummaryUseCase == null) {
        print('❌ DEBUG: GenerateSummaryUseCase is null!');
        await _showNotification(
          title: 'Summary Generation Error',
          body: 'Service not properly initialized for "$chapterTitle"',
          chapterId: chapterId,
        );
        return;
      }

      print('📡 DEBUG: Calling GenerateSummaryUseCase...');
      final result = await _generateSummaryUseCase!(
        token: token,
        chapterId: chapterId,
      );

      await result.fold(
        (failure) async {
          print('❌ DEBUG: UseCase failed: ${failure.errMessage}');
          await _showNotification(
            title: 'Summary Generation Failed',
            body:
                'Failed to generate summary for "$chapterTitle": ${failure.errMessage}',
            chapterId: chapterId,
          );
        },
        (summaryResponse) async {
          print('✅ DEBUG: UseCase success - SummaryResponse received');
          print(
            '📊 Summary structure: ${summaryResponse.success ? "Valid" : "Invalid"}',
          );
          print('💬 API Message: ${summaryResponse.message}');
          print(
            '🔢 Key concepts count: ${summaryResponse.summary.keyConcepts.length}',
          );

          // Extract the summary data
          final summaryData = summaryResponse.summary;
          print('✅ DEBUG: Using parsed SummaryModel from API');

          // Store the completed summary
          print('💾 DEBUG: Storing completed summary');
          await _storeCompletedSummary(
            chapterId: chapterId,
            chapterTitle: chapterTitle,
            summaryData: summaryData,
            rawSummary: jsonEncode(summaryResponse.toJson()),
          );

          // Show success notification
          print('🔔 DEBUG: Showing success notification');
          await _showNotification(
            title: 'Summary Ready!',
            body:
                'AI summary for "$chapterTitle" has been generated successfully.',
            chapterId: chapterId,
          );
        },
      );
    } catch (e) {
      print('💥 DEBUG: Exception in _generateSummary: $e');
      await _showNotification(
        title: 'Summary Generation Error',
        body: 'An error occurred while generating summary for "$chapterTitle"',
        chapterId: chapterId,
      );
    }
  }

  // Store completed summary
  Future<void> _storeCompletedSummary({
    required String chapterId,
    required String chapterTitle,
    SummaryModel? summaryData,
    required String rawSummary,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final completedSummariesJson =
        prefs.getStringList(_completedSummariesKey) ?? [];

    final completedSummary = {
      'chapterId': chapterId,
      'chapterTitle': chapterTitle,
      'summaryData': summaryData?.toJson(),
      'rawSummary': rawSummary,
      'completedAt': DateTime.now().toIso8601String(),
    };

    // Remove any existing summary for this chapter
    completedSummariesJson.removeWhere((s) {
      final existing = jsonDecode(s);
      return existing['chapterId'] == chapterId;
    });

    // Add the new completed summary
    completedSummariesJson.add(jsonEncode(completedSummary));
    await prefs.setStringList(_completedSummariesKey, completedSummariesJson);
    print('💾 DEBUG: Summary stored successfully');
  }

  // Get completed summary for a chapter
  Future<Map<String, dynamic>?> getCompletedSummary(String chapterId) async {
    final prefs = await SharedPreferences.getInstance();
    final completedSummariesJson =
        prefs.getStringList(_completedSummariesKey) ?? [];

    for (final summaryJson in completedSummariesJson) {
      final summary = jsonDecode(summaryJson);
      if (summary['chapterId'] == chapterId) {
        print('✅ DEBUG: Found completed summary for chapter: $chapterId');
        return summary;
      }
    }
    print('❌ DEBUG: No completed summary found for chapter: $chapterId');
    return null;
  }

  // Check if a summary request is pending for a chapter
  Future<bool> isSummaryPending(String chapterId) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingRequestsJson = prefs.getStringList(_pendingRequestsKey) ?? [];

    final isPending = pendingRequestsJson.any((r) {
      final request = jsonDecode(r);
      return request['chapterId'] == chapterId;
    });

    print('🔍 DEBUG: Summary pending for $chapterId: $isPending');
    return isPending;
  }

  // Show notification
  Future<void> _showNotification({
    required String title,
    required String body,
    required String chapterId,
  }) async {
    try {
      final mockMessage = MockRemoteMessage(
        title: title,
        body: body,
        data: {'chapterId': chapterId, 'type': 'summary'},
      );
      await _notificationService.showNotification(mockMessage);
    } catch (e) {
      print('❌ DEBUG: Failed to show notification: $e');
    }
  }

  // Clear completed summary
  Future<void> clearCompletedSummary(String chapterId) async {
    final prefs = await SharedPreferences.getInstance();
    final completedSummariesJson =
        prefs.getStringList(_completedSummariesKey) ?? [];

    completedSummariesJson.removeWhere((s) {
      final summary = jsonDecode(s);
      return summary['chapterId'] == chapterId;
    });

    await prefs.setStringList(_completedSummariesKey, completedSummariesJson);
    print('🗑️ DEBUG: Cleared completed summary for chapter: $chapterId');
  }

  // Dispose resources
  void dispose() {
    print('🛑 DEBUG: Disposing SummaryBackgroundService');
    _processingTimer?.cancel();
  }
}
