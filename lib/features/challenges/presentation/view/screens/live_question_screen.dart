import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/challenges/presentation/bloc/challenge_cubit.dart';
import 'package:tionova/features/challenges/presentation/services/challenge_polling_service.dart';
import 'package:tionova/features/challenges/presentation/services/challenge_sound_service.dart';
import 'package:tionova/features/challenges/presentation/services/challenge_vibration_service.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/challenge_header.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/challenge_progress_bar.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/challenge_timer_bar.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/feedback_state.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/leaderboard_entry.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/live_question_option_button.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/submit_button.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/waiting_state.dart';
import 'package:tionova/utils/widgets/custom_dialogs.dart';

class LiveQuestionScreen extends StatelessWidget {
  final String challengeCode;
  final String challengeName;

  const LiveQuestionScreen({
    super.key,
    required this.challengeCode,
    required this.challengeName,
  });

  @override
  Widget build(BuildContext context) {
    // Stateless wrapper delegates all logic to the body widget.
    return LiveQuestionScreenBody(
      challengeCode: challengeCode,
      challengeName: challengeName,
    );
  }
}

class LiveQuestionScreenBody extends StatefulWidget {
  final String challengeCode;
  final String challengeName;

  const LiveQuestionScreenBody({
    super.key,
    required this.challengeCode,
    required this.challengeName,
  });

  @override
  State<LiveQuestionScreenBody> createState() => _LiveQuestionScreenBodyState();
}

class _LiveQuestionScreenBodyState extends State<LiveQuestionScreenBody>
    with TickerProviderStateMixin, WidgetsBindingObserver, SafeContextMixin {
  // Services
  late final ChallengeSoundService _soundService;
  late final ChallengeVibrationService _vibrationService;
  ChallengePollingService? _pollingService;

  // Firebase references
  DatabaseReference? _questionsRef;
  DatabaseReference? _currentIndexRef;
  DatabaseReference? _currentStartTimeRef;
  DatabaseReference? _currentEndTimeRef;
  DatabaseReference? _statusRef;
  DatabaseReference? _leaderboardRef;
  DatabaseReference? _answersRef;

  // Firebase subscriptions
  StreamSubscription<DatabaseEvent>? _questionsSubscription;
  StreamSubscription<DatabaseEvent>? _currentIndexSubscription;
  StreamSubscription<DatabaseEvent>? _currentStartTimeSubscription;
  StreamSubscription<DatabaseEvent>? _currentEndTimeSubscription;
  StreamSubscription<DatabaseEvent>? _statusSubscription;
  StreamSubscription<DatabaseEvent>? _leaderboardSubscription;
  StreamSubscription<DatabaseEvent>? _answersSubscription;

  // Animation controllers
  late AnimationController _questionSlideController;
  late AnimationController _optionsController;
  late AnimationController _timerPulseController;
  late AnimationController _feedbackController;

  late Animation<Offset> _questionSlideAnimation;
  late Animation<double> _optionsFadeAnimation;
  late Animation<double> _timerPulseAnimation;
  late Animation<double> _feedbackScaleAnimation;

  // State variables
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  Map<String, dynamic>? _currentQuestion;
  List<Map<String, dynamic>> _leaderboard = [];
  int _timeRemaining = 30; // 30 seconds per question
  int? _questionStartTime;
  int? _questionEndTime; // Canonical end time from Firebase
  Timer? _questionTimer;
  String? _selectedAnswer;
  bool _hasAnswered = false;
  bool _isWaitingForOthers = false;
  bool _showingFeedback = false;
  bool? _wasCorrect;
  int? _currentRank;
  int _totalAnsweredPlayers = 0;
  int _totalPlayers = 0;
  String? _correctAnswer;
  bool _checkAdvanceCalled = false; // Debounce flag

  // Cached ancestor references (captured in didChangeDependencies)
  NavigatorState? _navigator;
  ScaffoldMessengerState? _scaffoldMessenger;

  @override
  @override
  void initState() {
    super.initState();

    // Add lifecycle observer to handle app state changes
    WidgetsBinding.instance.addObserver(this);

    // Initialize services
    _soundService = ChallengeSoundService();
    _vibrationService = ChallengeVibrationService();

    // Initialize animation controllers
    _questionSlideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _optionsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _timerPulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize animations
    _questionSlideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _questionSlideController,
            curve: Curves.easeOutCubic,
          ),
        );

    _optionsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _optionsController, curve: Curves.easeIn),
    );

    _timerPulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _timerPulseController, curve: Curves.easeInOut),
    );

    _feedbackScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut),
    );

    print(
      'LiveQuestionScreen - initState for challenge: ${widget.challengeCode}',
    );
    _updateTotalPlayers();
    _setupFirebaseListeners();
    _startPolling();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Cache Navigator and ScaffoldMessenger so async callbacks or dispose
    // can safely refer to them without performing ancestor lookups when
    // the State may be deactivated.
    _navigator = Navigator.of(context);
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  void _setupFirebaseListeners() {
    print('LiveQuestionScreen - Setting up Firebase listeners');
    final database = FirebaseDatabase.instance;

    // 1. Listen to questions list
    final questionsPath = 'liveChallenges/${widget.challengeCode}/questions';
    print(
      'LiveQuestionScreen - Setting up questions listener at: $questionsPath',
    );
    _questionsRef = database.ref(questionsPath);

    _questionsSubscription = _questionsRef!.onValue.listen(
      (event) {
        print('LiveQuestionScreen - Questions event received');
        print(
          'LiveQuestionScreen - Questions exists: ${event.snapshot.exists}',
        );

        if (!mounted) return;

        final data = event.snapshot.value;
        if (data != null) {
          print(
            'LiveQuestionScreen - Questions data type: ${data.runtimeType}',
          );
          print('LiveQuestionScreen - Questions data: $data');

          final questions = <Map<String, dynamic>>[];

          if (data is List) {
            for (var item in data) {
              if (item != null) {
                questions.add(Map<String, dynamic>.from(item as Map));
              }
            }
          } else if (data is Map) {
            data.forEach((key, value) {
              if (value != null) {
                questions.add(Map<String, dynamic>.from(value as Map));
              }
            });
          }

          print('LiveQuestionScreen - Parsed ${questions.length} questions');

          setState(() {
            _questions = questions;
            if (_currentQuestionIndex < _questions.length) {
              _currentQuestion = _questions[_currentQuestionIndex];
              print(
                'LiveQuestionScreen - Current question set: ${_currentQuestion?['question']}',
              );

              // Trigger animations for first question if not already animated
              if (_questionSlideController.isDismissed) {
                _questionSlideController.forward();
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (mounted && _optionsController.isDismissed) {
                    _optionsController.forward();
                  }
                });
              }
            }
          });
        }
      },
      onError: (error) {
        print('LiveQuestionScreen - Questions listener ERROR: $error');
      },
    );

    // 2. Listen to current question index
    final currentIndexPath =
        'liveChallenges/${widget.challengeCode}/current/index';
    print(
      'LiveQuestionScreen - Setting up index listener at: $currentIndexPath',
    );
    _currentIndexRef = database.ref(currentIndexPath);

    _currentIndexSubscription = _currentIndexRef!.onValue.listen(
      (event) {
        print('LiveQuestionScreen - Index event received');
        print('LiveQuestionScreen - Index value: ${event.snapshot.value}');

        if (!mounted) return;

        final index = event.snapshot.value as int?;
        if (index != null && index != _currentQuestionIndex) {
          print(
            'LiveQuestionScreen - Question index changed from $_currentQuestionIndex to $index',
          );

          setState(() {
            _currentQuestionIndex = index;
            _selectedAnswer = null;
            _hasAnswered = false;
            _isWaitingForOthers = false;
            _showingFeedback = false;
            _wasCorrect = null;
            _currentRank = null;
            _correctAnswer = null;
            _totalAnsweredPlayers = 0;
            _checkAdvanceCalled = false; // Reset debounce flag for new question

            if (_currentQuestionIndex < _questions.length) {
              _currentQuestion = _questions[_currentQuestionIndex];
              print(
                'LiveQuestionScreen - Showing question ${_currentQuestionIndex + 1}/${_questions.length}',
              );
            }
          });

          // Trigger animations for new question
          _questionSlideController.reset();
          _optionsController.reset();
          _questionSlideController.forward();
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) _optionsController.forward();
          });

          // Setup new answers listener for this question
          _setupAnswersListener();
        }
      },
      onError: (error) {
        print('LiveQuestionScreen - Index listener ERROR: $error');
      },
    );

    // 3. Listen to current question start time
    final startTimePath =
        'liveChallenges/${widget.challengeCode}/current/startTime';
    print(
      'LiveQuestionScreen - Setting up startTime listener at: $startTimePath',
    );
    _currentStartTimeRef = database.ref(startTimePath);

    _currentStartTimeSubscription = _currentStartTimeRef!.onValue.listen(
      (event) {
        print('LiveQuestionScreen - StartTime event received');
        print('LiveQuestionScreen - StartTime value: ${event.snapshot.value}');

        if (!mounted) return;

        final startTime = event.snapshot.value as int?;
        if (startTime != null && startTime != _questionStartTime) {
          print('LiveQuestionScreen - Question start time updated: $startTime');
          _questionStartTime = startTime;
          _startQuestionTimer(startTime);
        }
      },
      onError: (error) {
        print('LiveQuestionScreen - StartTime listener ERROR: $error');
      },
    );

    // 3b. Listen to current question END time (canonical from backend)
    final endTimePath =
        'liveChallenges/${widget.challengeCode}/current/endTime';
    print('LiveQuestionScreen - Setting up endTime listener at: $endTimePath');
    _currentEndTimeRef = database.ref(endTimePath);

    _currentEndTimeSubscription = _currentEndTimeRef!.onValue.listen(
      (event) {
        print('LiveQuestionScreen - EndTime event received');
        print('LiveQuestionScreen - EndTime value: ${event.snapshot.value}');

        if (!mounted) return;

        final endTime = event.snapshot.value as int?;
        if (endTime != null && endTime != _questionEndTime) {
          print('LiveQuestionScreen - Question end time updated: $endTime');
          _questionEndTime = endTime;
          // Re-sync timer with the canonical end time
          if (_questionStartTime != null) {
            _startQuestionTimer(_questionStartTime);
          }
        }
      },
      onError: (error) {
        print('LiveQuestionScreen - EndTime listener ERROR: $error');
      },
    );

    // 4. Listen to challenge status (to detect completion)
    final statusPath = 'liveChallenges/${widget.challengeCode}/meta/status';
    print('LiveQuestionScreen - Setting up status listener at: $statusPath');
    _statusRef = database.ref(statusPath);

    _statusSubscription = _statusRef!.onValue.listen(
      (event) {
        print('LiveQuestionScreen - Status event received');
        print('LiveQuestionScreen - Status value: ${event.snapshot.value}');

        if (!mounted) return;

        final status = event.snapshot.value as String?;
        if (status == 'completed') {
          print(
            'LiveQuestionScreen - Challenge completed! Navigating to results...',
          );
          _navigateToCompletion();
        }
      },
      onError: (error) {
        print('LiveQuestionScreen - Status listener ERROR: $error');
      },
    );

    // 5. Listen to leaderboard updates
    final leaderboardPath = 'liveChallenges/${widget.challengeCode}/rankings';
    print(
      'LiveQuestionScreen - Setting up leaderboard listener at: $leaderboardPath',
    );
    _leaderboardRef = database.ref(leaderboardPath);

    _leaderboardSubscription = _leaderboardRef!.onValue.listen(
      (event) {
        print('LiveQuestionScreen - Leaderboard event received');

        if (!mounted) return;

        final data = event.snapshot.value;
        if (data != null) {
          final rankings = <Map<String, dynamic>>[];

          if (data is List) {
            for (var item in data) {
              if (item != null) {
                rankings.add(Map<String, dynamic>.from(item as Map));
              }
            }
          } else if (data is Map) {
            data.forEach((key, value) {
              if (value != null) {
                rankings.add(Map<String, dynamic>.from(value as Map));
              }
            });
          }

          print(
            'LiveQuestionScreen - Leaderboard updated with ${rankings.length} entries',
          );

          setState(() {
            _leaderboard = rankings;
          });

          context.read<ChallengeCubit>().updateLeaderboard(
            challengeId: widget.challengeCode,
            leaderboard: rankings,
          );
        }
      },
      onError: (error) {
        print('LiveQuestionScreen - Leaderboard listener ERROR: $error');
      },
    );

    // 6. Listen to answers for current question (wait for all players)
    _setupAnswersListener();

    print('LiveQuestionScreen - All Firebase listeners set up successfully');
  }

  /// Start polling service to check for question advances
  void _startPolling() {
    print('LiveQuestionScreen - Starting polling service');
    _pollingService = ChallengePollingService(
      pollingInterval: const Duration(seconds: 5),
      onPoll: () async {
        // Avoid using context when the State has been unmounted
        if (!mounted) return;

        // Call checkAndAdvance API
        final response = await context
            .read<ChallengeCubit>()
            .checkAndAdvanceQuestion(challengeCode: widget.challengeCode);

        // If State became unmounted while awaiting, bail out before setState
        if (!mounted) return;

        if (response != null) {
          print('LiveQuestionScreen - Polling response: $response');

          final needsAdvance = response['needsAdvance'] as bool? ?? false;
          final dynamic timeRemainingRaw = response['timeRemaining'];

          // Normalize server-provided timeRemaining which may be in ms or s.
          final int normalized = _normalizeServerTimeRemaining(
            timeRemainingRaw,
          );
          print(
            'LiveQuestionScreen - timeRemaining raw: $timeRemainingRaw, normalized: $normalized',
          );

          // Sync timer if normalized value is valid
          if (normalized >= 0 && _timeRemaining != normalized) {
            if (mounted) {
              setState(() {
                _timeRemaining = normalized;
              });
            }
          }

          // Log polling status
          if (needsAdvance) {
            print('LiveQuestionScreen - Waiting for all players to answer...');
          }
        }
      },
      onError: (error) {
        print('LiveQuestionScreen - Polling error: $error');
      },
    );

    _pollingService!.startPolling();
  }

  /// Stop polling service
  void _stopPolling() {
    _pollingService?.stopPolling();
    _pollingService?.dispose();
    _pollingService = null;
  }

  void _setupAnswersListener() {
    // Cancel existing subscription
    _answersSubscription?.cancel();

    final answersPath =
        'liveChallenges/${widget.challengeCode}/answers/$_currentQuestionIndex';
    print('LiveQuestionScreen - Setting up answers listener at: $answersPath');
    _answersRef = FirebaseDatabase.instance.ref(answersPath);

    _answersSubscription = _answersRef!.onValue.listen(
      (event) {
        print('LiveQuestionScreen - Answers event received');

        if (!mounted) return;

        final data = event.snapshot.value;
        if (data != null) {
          int answeredCount = 0;

          if (data is Map) {
            answeredCount = data.length;
          } else if (data is List) {
            answeredCount = data.where((item) => item != null).length;
          }

          print(
            'LiveQuestionScreen - $answeredCount/$_totalPlayers players answered',
          );

          setState(() {
            _totalAnsweredPlayers = answeredCount;
          });

          // Check if all players have answered
          if (_hasAnswered &&
              answeredCount >= _totalPlayers &&
              _totalPlayers > 0) {
            print(
              'LiveQuestionScreen - All players answered! Showing feedback...',
            );
            _showAnswerFeedback();
          }
        }
      },
      onError: (error) {
        print('LiveQuestionScreen - Answers listener ERROR: $error');
      },
    );
  }

  void _updateTotalPlayers() {
    // Get total ACTIVE players from participants (exclude inactive: active === false)
    final participantsPath =
        'liveChallenges/${widget.challengeCode}/participants';
    FirebaseDatabase.instance.ref(participantsPath).once().then((event) {
      if (!mounted) return;

      final data = event.snapshot.value;
      if (data != null) {
        int count = 0;
        if (data is Map) {
          // Count only active participants
          data.forEach((key, value) {
            if (value is Map) {
              final active = value['active'];
              // active is true by default; only exclude if explicitly false
              if (active == null || active == true) {
                count++;
              }
            } else {
              count++; // legacy format without active flag
            }
          });
        } else if (data is List) {
          count = data.where((item) => item != null).length;
        }

        setState(() {
          _totalPlayers = count;
        });

        print('LiveQuestionScreen - Total ACTIVE players: $_totalPlayers');
      }
    });
  }

  void _showAnswerFeedback() {
    if (_showingFeedback) return; // Already showing feedback

    print('LiveQuestionScreen - Showing answer feedback');
    print('LiveQuestionScreen - Current question data: $_currentQuestion');

    // Get correct answer from current question (Firebase stores it in 'answer' field)
    final correctAnswerIndex = _currentQuestion?['answer'];
    print(
      'LiveQuestionScreen - Correct answer from Firebase: $correctAnswerIndex',
    );

    if (correctAnswerIndex != null) {
      // Handle both string ("a", "b", "c", "d") and int (0, 1, 2, 3) formats
      if (correctAnswerIndex is String) {
        _correctAnswer = correctAnswerIndex.toUpperCase();
      } else if (correctAnswerIndex is int) {
        _correctAnswer = String.fromCharCode(65 + correctAnswerIndex);
      }
    }

    // ALWAYS recalculate correctness locally with case-insensitive comparison
    // This overrides any backend response that may have used case-sensitive comparison
    if (_selectedAnswer != null && _correctAnswer != null) {
      final selectedUpper = _selectedAnswer?.toUpperCase();
      final correctUpper = _correctAnswer?.toUpperCase();
      final localCorrectness = (selectedUpper == correctUpper);

      print('LiveQuestionScreen - Local correctness comparison:');
      print('  Selected: $_selectedAnswer -> $selectedUpper');
      print('  Correct: $_correctAnswer -> $correctUpper');
      print('  Backend said: $_wasCorrect');
      print('  Local says: $localCorrectness');

      // Override backend's value if different
      if (_wasCorrect != localCorrectness) {
        print(
          'LiveQuestionScreen - ⚠️ Backend disagreed! Using local calculation.',
        );
        _wasCorrect = localCorrectness;
      }
    }

    // Get user's rank from leaderboard
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      final userId = authState.user.id;
      print('LiveQuestionScreen - Looking for userId in leaderboard: $userId');
      for (int i = 0; i < _leaderboard.length; i++) {
        if (_leaderboard[i]['userId'] == userId) {
          _currentRank = i + 1;
          print('LiveQuestionScreen - Found user at rank: $_currentRank');
          break;
        }
      }
    }

    // Play feedback based on correctness
    if (_wasCorrect == true) {
      _soundService.playCorrectSound();
      _vibrationService.success();
    } else if (_selectedAnswer != 'X') {
      _soundService.playIncorrectSound();
      _vibrationService.error();
    } else {
      _soundService.playTimeoutSound();
    }

    setState(() {
      _showingFeedback = true;
    });

    // Trigger feedback animation
    _feedbackController.reset();
    _feedbackController.forward();

    print('LiveQuestionScreen - Correct answer: $_correctAnswer');
    print('LiveQuestionScreen - User was correct: $_wasCorrect');
    print('LiveQuestionScreen - Current rank: $_currentRank');
  }

  void _startQuestionTimer(int? startTime) {
    print('LiveQuestionScreen - Starting question timer');
    print('LiveQuestionScreen - Start time: $startTime');

    _questionTimer?.cancel();

    final int questionDuration =
        _getQuestionDurationSeconds(); // seconds per question

    if (startTime != null) {
      // Use canonical endTime from Firebase if available, otherwise compute
      final endTimeMs =
          _questionEndTime ?? (startTime + questionDuration * 1000);
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final remainingMs = endTimeMs - nowMs;

      final rawRemaining = (remainingMs / 1000).ceil();
      _timeRemaining = rawRemaining.clamp(0, questionDuration);

      print('LiveQuestionScreen - Using endTimeMs: $endTimeMs');
      print('LiveQuestionScreen - Now ms: $nowMs');
      print('LiveQuestionScreen - Raw remaining (s): $rawRemaining');
      print(
        'LiveQuestionScreen - Clamped time remaining: $_timeRemaining seconds',
      );
    } else {
      _timeRemaining = questionDuration;
      print(
        'LiveQuestionScreen - No start time, defaulting to $questionDuration seconds',
      );
    }

    if (_timeRemaining > 0) {
      setState(() {}); // Update UI with initial time

      _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          print('LiveQuestionScreen - Widget not mounted, cancelling timer');
          timer.cancel();
          return;
        }

        setState(() {
          _timeRemaining = (_timeRemaining - 1).clamp(0, questionDuration);
        });

        print(
          'LiveQuestionScreen - Timer tick: $_timeRemaining seconds remaining',
        );

        if (_timeRemaining <= 0) {
          print('LiveQuestionScreen - Timer expired!');
          timer.cancel();

          // Play timeout sound
          _soundService.playTimeoutSound();
          _vibrationService.warning();

          // Show feedback if user has answered (even if others haven't)
          if (_hasAnswered) {
            print(
              'LiveQuestionScreen - Timer expired, showing feedback for answered user',
            );
            _showAnswerFeedback();
          }

          // Don't show timeout dialog - backend will handle auto-advance

          // Trigger check-advance once when timer expires
          _triggerCheckAdvance();
        } else if (_timeRemaining == 10) {
          // Play warning sound at 10 seconds
          _soundService.playTimerWarningSound();
          _vibrationService.warning();
        }
      });
    } else {
      print('LiveQuestionScreen - Time already expired');

      // Show feedback if user has answered (even if others haven't)
      if (_hasAnswered) {
        print(
          'LiveQuestionScreen - Time already expired, showing feedback for answered user',
        );
        _showAnswerFeedback();
      }

      // Don't show timeout dialog - backend will handle auto-advance
      // Trigger check-advance immediately if already expired
      _triggerCheckAdvance();
    }
  }

  /// Trigger check-advance API call (debounced per question)
  Future<void> _triggerCheckAdvance() async {
    if (!mounted) {
      print('LiveQuestionScreen - Widget not mounted, skipping check-advance');
      return;
    }

    if (_checkAdvanceCalled) {
      print(
        'LiveQuestionScreen - check-advance already called for this question',
      );
      return;
    }

    _checkAdvanceCalled = true;
    print(
      'LiveQuestionScreen - Triggering check-advance for question $_currentQuestionIndex',
    );

    try {
      final response = await context
          .read<ChallengeCubit>()
          .checkAndAdvanceQuestion(challengeCode: widget.challengeCode);

      if (!mounted) {
        print('LiveQuestionScreen - Widget unmounted after check-advance call');
        return;
      }

      if (response != null) {
        print('LiveQuestionScreen - check-advance response: $response');
        final advanced = response['advanced'] as bool? ?? false;
        final completed = response['completed'] as bool? ?? false;

        if (advanced) {
          print('LiveQuestionScreen - Question advanced by check-advance');
        }
        if (completed) {
          print('LiveQuestionScreen - Challenge completed by check-advance');
        }
      }
    } catch (e) {
      print('LiveQuestionScreen - check-advance error: $e');
    }
  }

  /// Normalize timeRemaining values coming from the server.
  /// The backend may return either seconds or milliseconds. We accept int/double/string
  /// and try to convert to seconds, then clamp to [0, questionDuration].
  int _normalizeServerTimeRemaining(dynamic value) {
    final int questionDuration = _getQuestionDurationSeconds();

    if (value == null) return -1;

    int raw;
    if (value is int) {
      raw = value;
    } else if (value is double) {
      raw = value.toInt();
    } else if (value is String) {
      raw = int.tryParse(value) ?? -1;
    } else {
      return -1;
    }

    // Heuristic:
    // - If raw >= 1000 and <= questionDuration*1000 => it's likely milliseconds
    // - If raw >= questionDuration*1000 => milliseconds
    // - Otherwise treat as seconds

    if (raw <= 0) return -1;

    if (raw >= 1000 && raw <= questionDuration * 1000) {
      final sec = ((raw + 999) ~/ 1000); // ceil
      return sec.clamp(0, questionDuration);
    }

    if (raw >= questionDuration * 1000) {
      final sec = ((raw + 999) ~/ 1000);
      return sec.clamp(0, questionDuration);
    }

    // raw is likely seconds; clamp to duration to avoid huge UI values
    if (raw > questionDuration) {
      debugPrint(
        'LiveQuestionScreen - server timeRemaining ($raw) > questionDuration; clamping to $questionDuration',
      );
      return questionDuration;
    }

    return raw.clamp(0, questionDuration);
  }

  /// Get the current question duration in seconds.
  /// Accepts multiple field names: 'durationSeconds', 'duration', 'durationMs'.
  /// Falls back to 30 seconds if not provided or invalid.
  int _getQuestionDurationSeconds() {
    const int defaultDuration = 30;
    if (_currentQuestion == null) return defaultDuration;

    final q = _currentQuestion!;

    // Prefer explicit seconds fields
    try {
      if (q.containsKey('durationSeconds')) {
        final v = q['durationSeconds'];
        if (v is int && v > 0) return v;
        if (v is String) return int.tryParse(v) ?? defaultDuration;
      }

      if (q.containsKey('duration')) {
        final v = q['duration'];
        if (v is int && v > 0) return v;
        if (v is String) return int.tryParse(v) ?? defaultDuration;
      }

      // If duration is provided in milliseconds
      if (q.containsKey('durationMs')) {
        final v = q['durationMs'];
        if (v is int) return ((v + 999) ~/ 1000).clamp(1, 600).toInt();
        if (v is String) {
          final parsed = int.tryParse(v);
          if (parsed != null) {
            return ((parsed + 999) ~/ 1000).clamp(1, 600).toInt();
          }
        }
      }
    } catch (e) {
      print('LiveQuestionScreen - error parsing question duration: $e');
    }

    return defaultDuration;
  }

  Future<void> _submitAnswer(String? answer) async {
    if (_hasAnswered) {
      print('LiveQuestionScreen - Already answered, ignoring submit');
      return;
    }

    if (answer == null) {
      print('LiveQuestionScreen - No answer selected');
      return;
    }

    print('LiveQuestionScreen - Submitting answer: $answer');
    print('LiveQuestionScreen - Question index: $_currentQuestionIndex');

    // Get the correct answer for logging
    final correctAnswerFromQuestion = _currentQuestion?['answer'];
    print('LiveQuestionScreen - Correct answer is: $correctAnswerFromQuestion');

    // Play submission feedback
    _vibrationService.medium();

    setState(() {
      _hasAnswered = true;
      _selectedAnswer = answer;
      _isWaitingForOthers = true;
    });

    // Submit answer via API
    // Backend expects answer in lowercase to match Firebase ("a", "b", "c", "d")
    final answerToSubmit = answer.toLowerCase();
    print(
      'LiveQuestionScreen - Converting "$answer" to "$answerToSubmit" before submitting',
    );
    print(
      'LiveQuestionScreen - Should match: "$answerToSubmit" == "$correctAnswerFromQuestion"',
    );

    await context.read<ChallengeCubit>().submitAnswer(
      challengeCode: widget.challengeCode,
      answer: answerToSubmit,
    );

    print(
      'LiveQuestionScreen - Answer submitted, waiting for other players...',
    );
  }

  void _navigateToCompletion() {
    if (!mounted) return;

    print('LiveQuestionScreen - Navigating to completion screen');

    // Get current user info
    String? currentUserId;
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      currentUserId = authState.user.id;
    }

    // Find user's rank and score in leaderboard
    int userRank = _leaderboard.length + 1;
    int userScore = 0;

    for (int i = 0; i < _leaderboard.length; i++) {
      final entry = _leaderboard[i];
      if (entry['userId'] == currentUserId) {
        userRank = i + 1;
        userScore = entry['score'] ?? 0;
        break;
      }
    } // Calculate correct answers and accuracy
    // Assuming each correct answer is worth points (adjust logic if needed)
    final totalQuestions = _questions.length;
    final correctAnswers = userScore; // Adjust based on your scoring system
    final accuracy = totalQuestions > 0
        ? (correctAnswers / totalQuestions * 100)
        : 0.0;

    if (!contextIsValid) return;

    safeContext((ctx) {
      GoRouter.of(ctx).pushNamed(
        'challenge-complete',
        pathParameters: {'code': widget.challengeCode},
        extra: {
          'challengeName': widget.challengeName,
          'finalScore': userScore,
          'correctAnswers': correctAnswers,
          'totalQuestions': totalQuestions,
          'accuracy': accuracy,
          'rank': userRank,
          'leaderboard': _leaderboard,
        },
      );
    });
  }

  @override
  @override
  void dispose() {
    print('LiveQuestionScreen - dispose called');

    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    // Call disconnect API when leaving the screen
    _disconnectFromChallenge();

    _questionTimer?.cancel();
    _questionsSubscription?.cancel();
    _currentIndexSubscription?.cancel();
    _currentStartTimeSubscription?.cancel();
    _currentEndTimeSubscription?.cancel();
    _statusSubscription?.cancel();
    _leaderboardSubscription?.cancel();
    _answersSubscription?.cancel();

    // Stop polling service
    _stopPolling();

    // Dispose animation controllers
    _questionSlideController.dispose();
    _optionsController.dispose();
    _timerPulseController.dispose();
    _feedbackController.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    print('LiveQuestionScreen - App lifecycle state: $state');

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // App is going to background or being terminated
      print(
        'LiveQuestionScreen - App paused/terminated, disconnecting from challenge',
      );
      _disconnectFromChallenge();
    }
  }

  /// Disconnect from the challenge (call disconnect API)
  Future<void> _disconnectFromChallenge() async {
    if (!mounted) {
      print('LiveQuestionScreen - Cannot disconnect: widget not mounted');
      return;
    }

    try {
      print(
        'LiveQuestionScreen - Calling disconnect API for challenge ${widget.challengeCode}',
      );

      await context.read<ChallengeCubit>().disconnectFromChallenge(
        challengeCode: widget.challengeCode,
      );

      print('LiveQuestionScreen - Successfully disconnected from challenge');
    } catch (e) {
      print('LiveQuestionScreen - Error disconnecting from challenge: $e');
      // Don't show error to user since they're leaving anyway
    }
  }

  Color get _bg => const Color(0xFF000000);
  Color get _cardBg => const Color(0xFF1C1C1E);
  Color get _textPrimary => const Color(0xFFFFFFFF);
  Color get _textSecondary => const Color(0xFF8E8E93);
  Color get _green => const Color.fromRGBO(0, 153, 102, 1);
  Color get _red => const Color(0xFFFF3B30);

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChallengeCubit, ChallengeState>(
      listener: (context, state) {
        // Prevent reacting after the State has been disposed.
        if (!mounted) return;

        print('LiveQuestionScreen - BlocListener state: ${state.runtimeType}');

        if (state is ChallengeCompleted) {
          print('LiveQuestionScreen - ChallengeCompleted state received');
          // Navigate to completion screen
          _navigateToCompletion();
        } else if (state is ChallengeError) {
          print('LiveQuestionScreen - Error state: ${state.message}');
          CustomDialogs.showErrorDialog(
            context,
            title: 'Error!',
            message: state.message,
          );
        } else if (state is AnswerSubmitted) {
          print(
            'LiveQuestionScreen - Answer submitted for question ${state.questionIndex}',
          );
          print(
            'LiveQuestionScreen - Backend says isCorrect: ${state.isCorrect}',
          );
          print('LiveQuestionScreen - Current score: ${state.currentScore}');

          // Store answer result from backend
          if (mounted) {
            setState(() {
              print(
                'LiveQuestionScreen - Overriding local _wasCorrect with backend response: ${state.isCorrect}',
              );
              _wasCorrect = state.isCorrect;
            });
          }
        }
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            children: [
              ChallengeHeader(
                challengeName: widget.challengeName,
                currentIndex: _currentQuestionIndex,
                totalQuestions: _questions.isNotEmpty ? _questions.length : 0,
                onExit: _showExitDialog,
                textPrimary: _textPrimary,
                textSecondary: _textSecondary,
              ),
              ChallengeProgressBar(
                currentIndex: _currentQuestionIndex,
                totalQuestions: _questions.isNotEmpty ? _questions.length : 0,
                cardBg: _cardBg,
                textPrimary: _textPrimary,
                accentGreen: _green,
              ),
              ChallengeTimerBar(
                timeRemaining: _timeRemaining,
                durationSeconds: _getQuestionDurationSeconds(),
                isUrgent: _timeRemaining <= 10,
                pulse: _timerPulseAnimation,
                cardBg: _cardBg,
                textSecondary: _textSecondary,
                accentGreen: _green,
                dangerRed: _red,
              ),
              Expanded(
                child: _currentQuestion == null
                    ? _buildLoadingState()
                    : _buildQuestionContent(),
              ),
              _buildLeaderboardButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _green),
          const SizedBox(height: 16),
          Text(
            'Loading question...',
            style: TextStyle(color: _textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent() {
    final question = _currentQuestion!;
    final options = List<String>.from(question['options'] ?? []);

    // Show feedback state if all players answered
    if (_showingFeedback) {
      return FeedbackState(
        isCorrect: _wasCorrect ?? false,
        userAnswer: _selectedAnswer ?? 'X',
        correctAnswer: _correctAnswer ?? '?',
        currentRank: _currentRank,
        totalPlayers: _totalPlayers,
        scale: _feedbackScaleAnimation,
        bg: _bg,
        cardBg: _cardBg,
        textPrimary: _textPrimary,
        textSecondary: _textSecondary,
        accentGreen: _green,
        dangerRed: _red,
      );
    }

    // Show waiting state if user has answered
    if (_isWaitingForOthers) {
      return WaitingState(
        totalAnsweredPlayers: _totalAnsweredPlayers,
        totalPlayers: _totalPlayers,
        selectedAnswer: _selectedAnswer,
        cardBg: _cardBg,
        textPrimary: _textPrimary,
        textSecondary: _textSecondary,
        accentGreen: _green,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Animated Question Card
          SlideTransition(
            position: _questionSlideAnimation,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _green.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Text(
                question['question'] ?? '',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Animated Options
          FadeTransition(
            opacity: _optionsFadeAnimation,
            child: Column(
              children: [
                ...options.asMap().entries.map((entry) {
                  final optionLabel = String.fromCharCode(
                    65 + entry.key,
                  ); // A, B, C, D
                  final optionText = entry.value;
                  final isSelected = _selectedAnswer == optionLabel;

                  return LiveQuestionOptionButton(
                    label: optionLabel,
                    text: optionText,
                    isSelected: isSelected,
                    onTap: _hasAnswered
                        ? null
                        : () {
                            _vibrationService.selection();
                            setState(() {
                              _selectedAnswer = optionLabel;
                            });
                          },
                    cardBg: _cardBg,
                    textPrimary: _textPrimary,
                    textSecondary: _textSecondary,
                    accentGreen: _green,
                  );
                }).toList(),
                const SizedBox(height: 24),
                SubmitButton(
                  canSubmit: _selectedAnswer != null && !_hasAnswered,
                  hasAnswered: _hasAnswered,
                  onSubmit: () => _submitAnswer(_selectedAnswer),
                  cardBg: _cardBg,
                  textSecondary: _textSecondary,
                  accentGreen: _green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLeaderboard(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events_outlined, color: _green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Live Scoreboard',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLeaderboard() {
    if (!mounted) return;

    final sheetContext = _navigator?.context ?? context;

    showModalBottomSheet(
      context: sheetContext,
      backgroundColor: _bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: _green, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Live Scoreboard',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_leaderboard.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No rankings yet',
                  style: TextStyle(color: _textSecondary),
                ),
              )
            else ...[
              // Get current user ID
              Builder(
                builder: (context) {
                  String? currentUserId;
                  if (context.read<AuthCubit>().state is AuthSuccess) {
                    currentUserId =
                        (context.read<AuthCubit>().state as AuthSuccess)
                            .user
                            .id;
                  }

                  return Column(
                    children: _leaderboard.take(5).map((entry) {
                      final rank = (_leaderboard.indexOf(entry) + 1);
                      return LeaderboardEntry(
                        rank: rank,
                        username:
                            entry['name'] ?? entry['username'] ?? 'Unknown',
                        score: entry['score'] ?? 0,
                        userId: entry['userId'],
                        currentUserId: currentUserId,
                        photoUrl: entry['photoUrl'],
                        cardBg: _cardBg,
                        textPrimary: _textPrimary,
                        textSecondary: _textSecondary,
                        accentGreen: _green,
                        bg: _bg,
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showExitDialog() {
    if (!mounted) return;

    final dialogContext = _navigator?.context ?? context;

    showDialog(
      context: dialogContext,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text('Leave Challenge?', style: TextStyle(color: _textPrimary)),
        content: Text(
          'You will lose your progress and points.',
          style: TextStyle(color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: _textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Leave', style: TextStyle(color: _red)),
          ),
        ],
      ),
    );
  }
}
