import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:tionova/core/utils/safe_emit.dart';
import 'package:tionova/features/challenges/domain/usecase/checkAndAdvanceusecase.dart';
import 'package:tionova/features/challenges/domain/usecase/createLiveChallengeusecase.dart';
import 'package:tionova/features/challenges/domain/usecase/disconnectFromLiveChallengeusecase.dart';
import 'package:tionova/features/challenges/domain/usecase/joinLiveChallengeusecase.dart';
import 'package:tionova/features/challenges/domain/usecase/startLiveChallengeusecase.dart';
import 'package:tionova/features/challenges/domain/usecase/submitLiveAnswerusecase.dart';
import 'package:tionova/features/challenges/presentation/services/firebase_challenge_helper.dart';
import 'package:tionova/features/chapter/data/models/ChapterModel.dart';

part 'challenge_state.dart';

class ChallengeCubit extends Cubit<ChallengeState> {
  final CreateLiveChallengeUseCase createLiveChallengeUseCase;
  final Disconnectfromlivechallengeusecase disconnectfromlivechallengeusecase;
  final StartLiveChallengeUseCase startLiveChallengeUseCase;
  final JoinLiveChallengeUseCase joinLiveChallengeUseCase;
  final SubmitLiveAnswerUseCase submitLiveAnswerUseCase;
  final CheckAndAdvanceUseCase checkAndAdvanceUseCase;

  // Firebase listeners
  StreamSubscription<DatabaseEvent>? _statusSubscription;
  StreamSubscription<DatabaseEvent>? _currentQuestionSubscription;
  StreamSubscription<DatabaseEvent>? _questionsSubscription;
  StreamSubscription<DatabaseEvent>? _rankingsSubscription;
  StreamSubscription<DatabaseEvent>? _participantsSubscription;

  String? _currentChallengeCode;
  int _currentQuestionIndex = 0;
  List<dynamic> _questions = [];

  ChallengeCubit({
    required this.submitLiveAnswerUseCase,
    required this.createLiveChallengeUseCase,
    required this.disconnectfromlivechallengeusecase,
    required this.startLiveChallengeUseCase,
    required this.joinLiveChallengeUseCase,
    required this.checkAndAdvanceUseCase,
  }) : super(ChallengeInitial());

  /// Create a new live challenge with comprehensive error handling
  Future<void> createChallenge({
    required String chapterId,
    required String title,
    ChapterModel? chapterContext,
  }) async {
    try {
      // Validate inputs before making API call
      if (chapterId.isEmpty) {
        safeEmit(
          ChallengeError('Please select a chapter to create a challenge'),
        );
        return;
      }

      if (title.isEmpty) {
        safeEmit(ChallengeError('Please provide a title for the challenge'));
        return;
      }

      safeEmit(ChallengeLoading());

      final result = await createLiveChallengeUseCase.call(
        title: title,
        chapterId: chapterId,
      );

      result.fold(
        (failure) {
          // Provide user-friendly error messages
          final errorMessage = _getCreateChallengeErrorMessage(
            failure.toString(),
          );
          safeEmit(ChallengeError(errorMessage));
        },
        (challengeCode) {
          // Validate the challenge code before emitting success
          if (challengeCode.challengeCode.isEmpty) {
            safeEmit(
              ChallengeError(
                'Failed to generate challenge code. Please try again.',
              ),
            );
            return;
          }

          safeEmit(
            ChallengeCreated(
              inviteCode: challengeCode.challengeCode,
              challengeName: title,
              questionsCount: 10, // Default value, update as needed
              durationMinutes: 15, // Default value, update as needed
              chapterContext: chapterContext, // Include chapter context
            ),
          );
        },
      );
    } on FormatException catch (e) {
      // Handle JSON parsing errors
      if (kDebugMode) {
        print('ChallengeCubit - FormatException: ${e.message}');
      }
      safeEmit(
        ChallengeError('Invalid response from server. Please try again.'),
      );
    } catch (e) {
      if (kDebugMode) {
        print('ChallengeCubit - createChallenge exception: ${e.toString()}');
      }
      safeEmit(ChallengeError(_getCreateChallengeErrorMessage(e.toString())));
    }
  }

  /// Get user-friendly error message for challenge creation failures
  String _getCreateChallengeErrorMessage(String originalError) {
    final lowerError = originalError.toLowerCase();

    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (lowerError.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (lowerError.contains('unauthorized') ||
        lowerError.contains('401')) {
      return 'Session expired. Please log in again.';
    } else if (lowerError.contains('chapter') &&
        lowerError.contains('not found')) {
      return 'The selected chapter could not be found. Please select a different chapter.';
    } else if (lowerError.contains('insufficient') ||
        lowerError.contains('content')) {
      return 'The selected chapter doesn\'t have enough content to generate quiz questions.';
    } else if (lowerError.contains('server') || lowerError.contains('500')) {
      return 'Server error. Please try again later.';
    } else if (originalError.isNotEmpty && originalError.length < 100) {
      return originalError;
    }

    return 'Failed to create challenge. Please try again.';
  }

  /// Join an existing live challenge using invite code
  Future<void> joinChallenge({required String challengeCode}) async {
    try {
      if (kDebugMode) {
        print(
          'ChallengeCubit - joinChallenge called with code: $challengeCode',
        );
      }
      safeEmit(ChallengeLoading());

      final result = await joinLiveChallengeUseCase.call(
        challengeCode: challengeCode,
      );

      result.fold(
        (failure) {
          if (kDebugMode) {
            print(
              'ChallengeCubit - joinChallenge failed: ${failure.errMessage}',
            );
            print('ChallengeCubit - Status code: ${failure.statusCode}');
          }
          safeEmit(ChallengeError(failure.errMessage));
        },
        (_) {
          if (kDebugMode) {
            print(
              'ChallengeCubit - joinChallenge success, emitting ChallengeJoined',
            );
          }

          _currentChallengeCode = challengeCode;

          safeEmit(
            ChallengeJoined(
              challengeId: challengeCode,
              participantId: '', // Will be set from backend response
              challengeName: 'Challenge', // Will be updated from backend
              questionsCount: 10,
              durationMinutes: 15,
              participants: [],
            ),
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('ChallengeCubit - joinChallenge exception: ${e.toString()}');
      }
      safeEmit(ChallengeError('Failed to join challenge: ${e.toString()}'));
    }
  }

  /// Set up listeners for participants (called from waiting lobby when challenge starts)
  void setupParticipantListeners(String challengeCode) {
    if (kDebugMode) {
      print(
        'ChallengeCubit - Setting up participant listeners for: $challengeCode',
      );
    }
    _currentChallengeCode = challengeCode;
    _setupFirebaseListeners(challengeCode);
  }

  /// Start the live challenge (host only)
  Future<void> startChallenge({required String challengeCode}) async {
    try {
      if (kDebugMode) {
        print(
          'ChallengeCubit - startChallenge called for code: $challengeCode',
        );
      }

      // Validate minimum participants before starting
      final participantCount = await _getParticipantCount(challengeCode);
      if (participantCount < 2) {
        safeEmit(ChallengeError('Need at least 2 participants to start'));
        return;
      }

      safeEmit(ChallengeLoading());

      final result = await startLiveChallengeUseCase.call(
        challengeCode: challengeCode,
      );

      result.fold(
        (failure) {
          if (kDebugMode) {
            print(
              'ChallengeCubit - startChallenge failed: ${failure.toString()}',
            );
          }
          safeEmit(ChallengeError(failure.toString()));
        },
        (_) {
          if (kDebugMode) {
            print(
              'ChallengeCubit - startChallenge success, setting up listeners',
            );
          }
          _currentChallengeCode = challengeCode;

          // Set up Firebase listeners for real-time updates
          _setupFirebaseListeners(challengeCode);

          safeEmit(
            ChallengeStarted(
              challengeId: challengeCode,
              startTime: DateTime.now(),
              endTime: DateTime.now().add(const Duration(minutes: 15)),
              questions: [], // Will be populated from Firebase
              currentQuestionIndex: 0,
            ),
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('ChallengeCubit - startChallenge exception: ${e.toString()}');
      }
      safeEmit(ChallengeError('Failed to start challenge: ${e.toString()}'));
    }
  }

  /// Submit an answer for the current question
  Future<void> submitAnswer({
    required String challengeCode,
    required String answer,
  }) async {
    try {
      if (kDebugMode) {
        print(
          'ChallengeCubit - Submitting answer: "$answer" for question $_currentQuestionIndex',
        );
      }

      final result = await submitLiveAnswerUseCase.call(
        challengeCode: challengeCode,
        answer: answer,
      );

      result.fold(
        (failure) {
          if (kDebugMode) {
            print(
              'ChallengeCubit - Submit answer failed: ${failure.toString()}',
            );
          }
          safeEmit(ChallengeError(failure.toString()));
        },
        (response) {
          if (kDebugMode) {
            print('ChallengeCubit - Answer submitted successfully');
          }

          // Emit answer submitted state
          safeEmit(
            AnswerSubmitted(
              challengeId: challengeCode,
              questionIndex: _currentQuestionIndex,
              selectedAnswer: answer,
              isCorrect: false, // Will be updated from Firebase rankings
              currentScore: 0, // Will be updated from Firebase rankings
            ),
          );

          // Return to challenge started state to show next question
          // The question index will be updated by Firebase listener
          if (state is AnswerSubmitted && _questions.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_currentChallengeCode != null) {
                safeEmit(
                  ChallengeStarted(
                    challengeId: _currentChallengeCode!,
                    startTime: DateTime.now(),
                    endTime: DateTime.now().add(const Duration(minutes: 15)),
                    questions: _questions,
                    currentQuestionIndex: _currentQuestionIndex,
                  ),
                );
              }
            });
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('ChallengeCubit - Submit answer exception: ${e.toString()}');
      }
      safeEmit(ChallengeError('Failed to submit answer: ${e.toString()}'));
    }
  }

  /// Move to next question
  void nextQuestion() {
    if (state is ChallengeStarted) {
      final currentState = state as ChallengeStarted;
      if (currentState.currentQuestionIndex <
          currentState.questions.length - 1) {
        safeEmit(
          currentState.copyWith(
            currentQuestionIndex: currentState.currentQuestionIndex + 1,
          ),
        );
      } else {
        // Challenge completed
        _completeChallenge(currentState.challengeId);
      }
    }
  }

  /// Complete the challenge and show results
  void _completeChallenge(String challengeId) {
    // This would typically fetch final results from backend
    safeEmit(
      ChallengeCompleted(
        challengeId: challengeId,
        finalScore: 0, // Will be updated from backend
        correctAnswers: 0,
        totalQuestions: 0,
        accuracy: 0.0,
        rank: 0,
        leaderboard: [],
      ),
    );
  }

  /// Disconnect from live challenge
  Future<void> disconnectFromChallenge({required String challengeCode}) async {
    try {
      if (kDebugMode) {
        print('ChallengeCubit - Disconnecting from challenge: $challengeCode');
      }

      await disconnectfromlivechallengeusecase.call(
        challengeCode: challengeCode,
      );

      _cleanupListeners();
      _currentChallengeCode = null;
      _currentQuestionIndex = 0;
      _questions = [];

      safeEmit(const ChallengeDisconnected());

      if (kDebugMode) {
        print('ChallengeCubit - Successfully disconnected');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ChallengeCubit - Disconnect failed: ${e.toString()}');
      }
      safeEmit(ChallengeError('Failed to disconnect: ${e.toString()}'));
    }
  }

  /// Check if all players answered and advance to next question if needed
  /// Used for polling mechanism
  Future<Map<String, dynamic>?> checkAndAdvanceQuestion({
    required String challengeCode,
  }) async {
    try {
      if (kDebugMode) {
        print('ChallengeCubit - Checking if should advance question');
      }

      final result = await checkAndAdvanceUseCase.call(
        challengeCode: challengeCode,
      );

      return result.fold(
        (failure) {
          if (kDebugMode) {
            print(
              'ChallengeCubit - Check advance failed: ${failure.toString()}',
            );
          }
          return null;
        },
        (response) {
          if (kDebugMode) {
            print('ChallengeCubit - Check advance response: $response');
          }

          // Extract response data (lint: variables may not be used immediately)
          final advanced = response['advanced'] as bool? ?? false;
          final completed = response['completed'] as bool? ?? false;
          final currentIndex = response['currentIndex'] as int? ?? 0;

          if (completed) {
            if (kDebugMode) {
              print('ChallengeCubit - Challenge completed');
            }
            _handleChallengeCompletion();
          } else if (advanced) {
            if (kDebugMode) {
              print('ChallengeCubit - Advanced to question $currentIndex');
            }
            _currentQuestionIndex = currentIndex;
            _updateCurrentQuestion(currentIndex);
          }

          return response;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('ChallengeCubit - Check advance exception: ${e.toString()}');
      }
      return null;
    }
  }

  /// Update participants list (for real-time updates)
  void updateParticipants({
    required String challengeId,
    required List<String> participants,
  }) {
    final canStartChallenge = participants.length >= 2;
    safeEmit(
      ParticipantsUpdated(
        challengeId: challengeId,
        participants: participants,
        participantCount: participants.length,
        canStartChallenge: canStartChallenge,
      ),
    );
  }

  /// Get participant count for validation
  Future<int> _getParticipantCount(String challengeCode) async {
    try {
      final snapshot = await FirebaseChallengeHelper.getOnce(
        'liveChallenges/$challengeCode/participants',
      );

      if (snapshot?.value == null) return 0;

      final data = snapshot!.value as Map<dynamic, dynamic>;
      int activeCount = 0;

      data.forEach((userId, userData) {
        final participantData = Map<String, dynamic>.from(userData as Map);
        if (participantData['active'] == true) {
          activeCount++;
        }
      });

      return activeCount;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting participant count: $e');
      }
      return 0;
    }
  }

  /// Update leaderboard (for real-time updates)
  void updateLeaderboard({
    required String challengeId,
    required List<dynamic> leaderboard,
  }) {
    safeEmit(
      LeaderboardUpdated(challengeId: challengeId, leaderboard: leaderboard),
    );
  }

  /// Set up Firebase listeners for real-time challenge updates
  void _setupFirebaseListeners(String challengeCode) {
    if (kDebugMode) {
      print(
        'ChallengeCubit - Setting up Firebase listeners for: $challengeCode',
      );
    }
    // Use Safari-compatible helper for Firebase operations with enhanced error handling

    // 1. Listen to challenge status
    final statusPath = 'liveChallenges/$challengeCode/meta/status';
    _statusSubscription = FirebaseChallengeHelper.listenToValue(
      statusPath,
      onData: (snapshot) {
        final status = snapshot.value as String?;
        if (kDebugMode) {
          print('ChallengeCubit - Status changed to: $status');
        }

        if (status == 'completed') {
          if (kDebugMode) {
            print('ChallengeCubit - Challenge completed, showing results');
          }
          _handleChallengeCompletion();
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print('ChallengeCubit - Status listener error: $error');
        }
      },
    );

    // 2. Listen to current question index
    final currentQuestionPath =
        'liveChallenges/$challengeCode/current/questionIndex';
    _currentQuestionSubscription = FirebaseChallengeHelper.listenToValue(
      currentQuestionPath,
      onData: (snapshot) {
        final questionIndex = snapshot.value as int?;
        if (questionIndex != null && questionIndex != _currentQuestionIndex) {
          if (kDebugMode) {
            print('ChallengeCubit - Question index changed to: $questionIndex');
          }
          _currentQuestionIndex = questionIndex;
          _updateCurrentQuestion(questionIndex);
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print('ChallengeCubit - Question index listener error: $error');
        }
      },
    );

    // 3. Listen to questions list
    final questionsPath = 'liveChallenges/$challengeCode/questions';
    _questionsSubscription = FirebaseChallengeHelper.listenToValue(
      questionsPath,
      onData: (snapshot) {
        final data = snapshot.value;
        if (data != null) {
          if (kDebugMode) {
            print('ChallengeCubit - Questions data received');
          }
          _questions = FirebaseChallengeHelper.parseQuestions(snapshot);
          if (kDebugMode) {
            print('ChallengeCubit - Parsed ${_questions.length} questions');
          }

          // Update state with questions
          if (state is ChallengeStarted) {
            final currentState = state as ChallengeStarted;
            safeEmit(currentState.copyWith(questions: _questions));
          }
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print('ChallengeCubit - Questions listener error: $error');
        }
      },
    );

    // 4. Listen to rankings/leaderboard
    final rankingsPath = 'liveChallenges/$challengeCode/rankings';
    _rankingsSubscription = FirebaseChallengeHelper.listenToValue(
      rankingsPath,
      onData: (snapshot) {
        final data = snapshot.value;
        if (data != null) {
          if (kDebugMode) {
            print('ChallengeCubit - Rankings data received');
          }
          final rankings = FirebaseChallengeHelper.parseRankings(snapshot);
          updateLeaderboard(challengeId: challengeCode, leaderboard: rankings);
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print('ChallengeCubit - Rankings listener error: $error');
        }
      },
    );

    // 5. Listen to participants for real-time updates
    final participantsPath = 'liveChallenges/$challengeCode/participants';
    _participantsSubscription = FirebaseChallengeHelper.listenToValue(
      participantsPath,
      onData: (snapshot) {
        final participants = FirebaseChallengeHelper.parseParticipants(
          snapshot,
        );
        final activeCount = FirebaseChallengeHelper.countActiveParticipants(
          snapshot,
        );

        if (kDebugMode) {
          print('ChallengeCubit - Participants updated: $activeCount active');
        }

        // Update participants in state
        final usernames = participants
            .where((p) => p['active'] == true)
            .map((p) => p['username'] as String)
            .toList();

        updateParticipants(challengeId: challengeCode, participants: usernames);
      },
      onError: (error) {
        if (kDebugMode) {
          print('ChallengeCubit - Participants listener error: $error');
        }
      },
    );

    if (kDebugMode) {
      print('ChallengeCubit - All Firebase listeners set up successfully');
    }
  }

  /// Update current question in state
  void _updateCurrentQuestion(int questionIndex) {
    if (state is ChallengeStarted) {
      final currentState = state as ChallengeStarted;
      safeEmit(currentState.copyWith(currentQuestionIndex: questionIndex));
    }
  }

  /// Handle challenge completion
  void _handleChallengeCompletion() {
    if (_currentChallengeCode != null) {
      // Fetch final rankings using Safari-compatible helper
      FirebaseChallengeHelper.getOnce(
        'liveChallenges/$_currentChallengeCode/rankings',
      ).then((snapshot) {
        if (snapshot == null) return;
        final rankings = FirebaseChallengeHelper.parseRankings(snapshot);

        // Find current user's rank and score
        // This would need user ID to find their specific data
        safeEmit(
          ChallengeCompleted(
            challengeId: _currentChallengeCode!,
            finalScore: 0, // Will be updated with actual score
            correctAnswers: 0,
            totalQuestions: _questions.length,
            accuracy: 0.0,
            rank: 0,
            leaderboard: rankings,
          ),
        );
      });
    }
  }

  /// Clean up Firebase listeners
  void _cleanupListeners() {
    if (kDebugMode) {
      print('ChallengeCubit - Cleaning up Firebase listeners');
    }

    // Use helper's cleanup method for better error handling
    FirebaseChallengeHelper.cancelSubscriptions([
      _statusSubscription,
      _currentQuestionSubscription,
      _questionsSubscription,
      _rankingsSubscription,
      _participantsSubscription,
    ]);

    _statusSubscription = null;
    _currentQuestionSubscription = null;
    _questionsSubscription = null;
    _rankingsSubscription = null;
    _participantsSubscription = null;
  }

  /// Reset to initial state
  void reset() {
    _cleanupListeners();
    _currentChallengeCode = null;
    _currentQuestionIndex = 0;
    _questions = [];
    safeEmit(ChallengeInitial());
  }

  @override
  Future<void> close() {
    _cleanupListeners();
    return super.close();
  }

  /// Handle real-time events from WebSocket/Socket.IO
  void handleRealtimeEvent(Map<String, dynamic> event) {
    final eventType = event['type'] as String?;

    switch (eventType) {
      case 'participant_joined':
        final challengeId = event['challengeId'] as String? ?? '';
        final participants = List<String>.from(event['participants'] ?? []);
        updateParticipants(
          challengeId: challengeId,
          participants: participants,
        );
        break;

      case 'participant_left':
        final challengeId = event['challengeId'] as String? ?? '';
        final participants = List<String>.from(event['participants'] ?? []);
        updateParticipants(
          challengeId: challengeId,
          participants: participants,
        );
        break;

      case 'leaderboard_updated':
        final challengeId = event['challengeId'] as String? ?? '';
        final leaderboard = List<dynamic>.from(event['leaderboard'] ?? []);
        updateLeaderboard(challengeId: challengeId, leaderboard: leaderboard);
        break;

      case 'challenge_started':
        // Handle when host starts the challenge
        final challengeId = event['challengeId'] as String? ?? '';
        final startTime = DateTime.parse(
          event['startTime'] ?? DateTime.now().toIso8601String(),
        );
        final endTime = DateTime.parse(
          event['endTime'] ?? DateTime.now().toIso8601String(),
        );
        final questions = List<dynamic>.from(event['questions'] ?? []);

        emit(
          ChallengeStarted(
            challengeId: challengeId,
            startTime: startTime,
            endTime: endTime,
            questions: questions,
            currentQuestionIndex: 0,
          ),
        );
        break;

      case 'challenge_ended':
        final challengeId = event['challengeId'] as String? ?? '';
        final finalScore = event['finalScore'] as int? ?? 0;
        final correctAnswers = event['correctAnswers'] as int? ?? 0;
        final totalQuestions = event['totalQuestions'] as int? ?? 0;
        final accuracy = (event['accuracy'] as num?)?.toDouble() ?? 0.0;
        final rank = event['rank'] as int? ?? 0;
        final leaderboard = List<dynamic>.from(event['leaderboard'] ?? []);

        emit(
          ChallengeCompleted(
            challengeId: challengeId,
            finalScore: finalScore,
            correctAnswers: correctAnswers,
            totalQuestions: totalQuestions,
            accuracy: accuracy,
            rank: rank,
            leaderboard: leaderboard,
          ),
        );
        break;

      default:
        // Unknown event type
        break;
    }
  }
}
