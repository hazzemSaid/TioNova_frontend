import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tionova/features/challenges/domain/usecase/checkAndAdvanceusecase.dart';
import 'package:tionova/features/challenges/domain/usecase/createLiveChallengeusecase.dart';
import 'package:tionova/features/challenges/domain/usecase/disconnectFromLiveChallengeusecase.dart';
import 'package:tionova/features/challenges/domain/usecase/joinLiveChallengeusecase.dart';
import 'package:tionova/features/challenges/domain/usecase/startLiveChallengeusecase.dart';
import 'package:tionova/features/challenges/domain/usecase/submitLiveAnswerusecase.dart';

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

  /// Create a new live challenge
  Future<void> createChallenge({
    required String token,
    required String chapterId,
    required String title,
  }) async {
    try {
      emit(ChallengeLoading());

      final result = await createLiveChallengeUseCase.call(
        token: token,
        title: title,
        chapterId: chapterId,
      );

      result.fold((failure) => emit(ChallengeError(failure.toString())), (
        challengeCode,
      ) {
        emit(
          ChallengeCreated(
            inviteCode: challengeCode.challengeCode,
            challengeName: title,
            questionsCount: 10, // Default value, update as needed
            durationMinutes: 15, // Default value, update as needed
          ),
        );
      });
    } catch (e) {
      emit(ChallengeError('Failed to create challenge: ${e.toString()}'));
    }
  }

  /// Join an existing live challenge using invite code
  Future<void> joinChallenge({
    required String token,
    required String challengeCode,
  }) async {
    try {
      print('ChallengeCubit - joinChallenge called with code: $challengeCode');
      emit(ChallengeLoading());

      final result = await joinLiveChallengeUseCase.call(
        token: token,
        challengeCode: challengeCode,
      );

      result.fold(
        (failure) {
          print('ChallengeCubit - joinChallenge failed: ${failure.errMessage}');
          print('ChallengeCubit - Status code: ${failure.statusCode}');
          emit(ChallengeError(failure.errMessage));
        },
        (_) {
          print(
            'ChallengeCubit - joinChallenge success, emitting ChallengeJoined',
          );

          _currentChallengeCode = challengeCode;

          emit(
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
      print('ChallengeCubit - joinChallenge exception: ${e.toString()}');
      emit(ChallengeError('Failed to join challenge: ${e.toString()}'));
    }
  }

  /// Set up listeners for participants (called from waiting lobby when challenge starts)
  void setupParticipantListeners(String challengeCode) {
    print(
      'ChallengeCubit - Setting up participant listeners for: $challengeCode',
    );
    _currentChallengeCode = challengeCode;
    _setupFirebaseListeners(challengeCode);
  }

  /// Start the live challenge (host only)
  Future<void> startChallenge({
    required String token,
    required String challengeCode,
  }) async {
    try {
      print('ChallengeCubit - startChallenge called for code: $challengeCode');
      emit(ChallengeLoading());

      final result = await startLiveChallengeUseCase.call(
        token: token,
        challengeCode: challengeCode,
      );

      result.fold(
        (failure) {
          print(
            'ChallengeCubit - startChallenge failed: ${failure.toString()}',
          );
          emit(ChallengeError(failure.toString()));
        },
        (_) {
          print(
            'ChallengeCubit - startChallenge success, setting up listeners',
          );
          _currentChallengeCode = challengeCode;

          // Set up Firebase listeners for real-time updates
          _setupFirebaseListeners(challengeCode);

          emit(
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
      print('ChallengeCubit - startChallenge exception: ${e.toString()}');
      emit(ChallengeError('Failed to start challenge: ${e.toString()}'));
    }
  }

  /// Submit an answer for the current question
  Future<void> submitAnswer({
    required String token,
    required String challengeCode,
    required String answer,
  }) async {
    try {
      print(
        'ChallengeCubit - Submitting answer: "$answer" for question $_currentQuestionIndex',
      );

      final result = await submitLiveAnswerUseCase.call(
        token: token,
        challengeCode: challengeCode,
        answer: answer,
      );

      result.fold(
        (failure) {
          print('ChallengeCubit - Submit answer failed: ${failure.toString()}');
          emit(ChallengeError(failure.toString()));
        },
        (response) {
          print('ChallengeCubit - Answer submitted successfully');

          // Emit answer submitted state
          emit(
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
                emit(
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
      print('ChallengeCubit - Submit answer exception: ${e.toString()}');
      emit(ChallengeError('Failed to submit answer: ${e.toString()}'));
    }
  }

  /// Move to next question
  void nextQuestion() {
    if (state is ChallengeStarted) {
      final currentState = state as ChallengeStarted;
      if (currentState.currentQuestionIndex <
          currentState.questions.length - 1) {
        emit(
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
    emit(
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
  Future<void> disconnectFromChallenge({
    required String token,
    required String challengeCode,
  }) async {
    try {
      print('ChallengeCubit - Disconnecting from challenge: $challengeCode');

      await disconnectfromlivechallengeusecase.call(
        token: token,
        challengeCode: challengeCode,
      );

      _cleanupListeners();
      _currentChallengeCode = null;
      _currentQuestionIndex = 0;
      _questions = [];

      emit(const ChallengeDisconnected());

      print('ChallengeCubit - Successfully disconnected');
    } catch (e) {
      print('ChallengeCubit - Disconnect failed: ${e.toString()}');
      emit(ChallengeError('Failed to disconnect: ${e.toString()}'));
    }
  }

  /// Check if all players answered and advance to next question if needed
  /// Used for polling mechanism
  Future<Map<String, dynamic>?> checkAndAdvanceQuestion({
    required String token,
    required String challengeCode,
  }) async {
    try {
      print('ChallengeCubit - Checking if should advance question');

      final result = await checkAndAdvanceUseCase.call(
        token: token,
        challengeCode: challengeCode,
      );

      return result.fold(
        (failure) {
          print('ChallengeCubit - Check advance failed: ${failure.toString()}');
          return null;
        },
        (response) {
          print('ChallengeCubit - Check advance response: $response');

          // Extract response data (lint: variables may not be used immediately)
          final advanced = response['advanced'] as bool? ?? false;
          final completed = response['completed'] as bool? ?? false;
          final currentIndex = response['currentIndex'] as int? ?? 0;

          if (completed) {
            print('ChallengeCubit - Challenge completed');
            _handleChallengeCompletion();
          } else if (advanced) {
            print('ChallengeCubit - Advanced to question $currentIndex');
            _currentQuestionIndex = currentIndex;
            _updateCurrentQuestion(currentIndex);
          }

          return response;
        },
      );
    } catch (e) {
      print('ChallengeCubit - Check advance exception: ${e.toString()}');
      return null;
    }
  }

  /// Update participants list (for real-time updates)
  void updateParticipants({
    required String challengeId,
    required List<String> participants,
  }) {
    emit(
      ParticipantsUpdated(
        challengeId: challengeId,
        participants: participants,
        participantCount: participants.length,
      ),
    );
  }

  /// Update leaderboard (for real-time updates)
  void updateLeaderboard({
    required String challengeId,
    required List<dynamic> leaderboard,
  }) {
    emit(
      LeaderboardUpdated(challengeId: challengeId, leaderboard: leaderboard),
    );
  }

  /// Set up Firebase listeners for real-time challenge updates
  void _setupFirebaseListeners(String challengeCode) {
    print('ChallengeCubit - Setting up Firebase listeners for: $challengeCode');
    final database = FirebaseDatabase.instance;

    // 1. Listen to challenge status
    final statusPath = 'liveChallenges/$challengeCode/meta/status';
    _statusSubscription = database.ref(statusPath).onValue.listen((event) {
      final status = event.snapshot.value as String?;
      print('ChallengeCubit - Status changed to: $status');

      if (status == 'completed') {
        print('ChallengeCubit - Challenge completed, showing results');
        _handleChallengeCompletion();
      }
    });

    // 2. Listen to current question index
    final currentQuestionPath =
        'liveChallenges/$challengeCode/current/questionIndex';
    _currentQuestionSubscription = database
        .ref(currentQuestionPath)
        .onValue
        .listen((event) {
          final questionIndex = event.snapshot.value as int?;
          if (questionIndex != null && questionIndex != _currentQuestionIndex) {
            print('ChallengeCubit - Question index changed to: $questionIndex');
            _currentQuestionIndex = questionIndex;
            _updateCurrentQuestion(questionIndex);
          }
        });

    // 3. Listen to questions list
    final questionsPath = 'liveChallenges/$challengeCode/questions';
    _questionsSubscription = database.ref(questionsPath).onValue.listen((
      event,
    ) {
      final data = event.snapshot.value;
      if (data != null) {
        print('ChallengeCubit - Questions data received');
        _questions = _parseQuestions(data);
        print('ChallengeCubit - Parsed ${_questions.length} questions');

        // Update state with questions
        if (state is ChallengeStarted) {
          final currentState = state as ChallengeStarted;
          emit(currentState.copyWith(questions: _questions));
        }
      }
    });

    // 4. Listen to rankings/leaderboard
    final rankingsPath = 'liveChallenges/$challengeCode/rankings';
    _rankingsSubscription = database.ref(rankingsPath).onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        print('ChallengeCubit - Rankings data received');
        final rankings = _parseRankings(data);
        updateLeaderboard(challengeId: challengeCode, leaderboard: rankings);
      }
    });

    print('ChallengeCubit - All Firebase listeners set up successfully');
  }

  /// Parse questions from Firebase data
  List<dynamic> _parseQuestions(dynamic data) {
    if (data is List) {
      return data;
    } else if (data is Map) {
      return data.values.toList();
    }
    return [];
  }

  /// Parse rankings from Firebase data
  List<dynamic> _parseRankings(dynamic data) {
    if (data is List) {
      return data;
    } else if (data is Map) {
      final rankings = <Map<String, dynamic>>[];
      data.forEach((key, value) {
        if (value is Map) {
          rankings.add(Map<String, dynamic>.from(value));
        }
      });
      // Sort by score descending
      rankings.sort((a, b) => (b['score'] ?? 0).compareTo(a['score'] ?? 0));
      return rankings;
    }
    return [];
  }

  /// Update current question in state
  void _updateCurrentQuestion(int questionIndex) {
    if (state is ChallengeStarted) {
      final currentState = state as ChallengeStarted;
      emit(currentState.copyWith(currentQuestionIndex: questionIndex));
    }
  }

  /// Handle challenge completion
  void _handleChallengeCompletion() {
    if (_currentChallengeCode != null) {
      // Fetch final rankings
      final database = FirebaseDatabase.instance;
      database
          .ref('liveChallenges/$_currentChallengeCode/rankings')
          .once()
          .then((snapshot) {
            final data = snapshot.snapshot.value;
            final rankings = _parseRankings(data);

            // Find current user's rank and score
            // This would need user ID to find their specific data
            emit(
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
    print('ChallengeCubit - Cleaning up Firebase listeners');
    _statusSubscription?.cancel();
    _currentQuestionSubscription?.cancel();
    _questionsSubscription?.cancel();
    _rankingsSubscription?.cancel();
    _participantsSubscription?.cancel();

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
    emit(ChallengeInitial());
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
