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
import 'package:tionova/features/challenges/presentation/services/firebase_challenge_helper.dart';
import 'package:tionova/features/challenges/presentation/view/utils/live_question_helper.dart';
import 'package:tionova/features/challenges/presentation/view/utils/live_question_theme.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/challenge_header.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/challenge_progress_bar.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/challenge_timer_bar.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/live_question_content.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/live_question_leaderboard_button.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/live_question_leaderboard_sheet.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/live_question_loading.dart';
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
    _navigator = Navigator.of(context);
  }

  void _setupFirebaseListeners() {
    print('LiveQuestionScreen - Setting up Firebase listeners');
    // Use Safari-compatible helper for Firebase operations

    // 1. Listen to questions list
    final questionsPath = 'liveChallenges/${widget.challengeCode}/questions';
    _questionsRef = FirebaseChallengeHelper.getRef(questionsPath);

    _questionsSubscription = _questionsRef!.onValue.listen(
      (event) {
        if (!mounted) return;

        final data = event.snapshot.value;
        if (data != null) {
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

          setState(() {
            _questions = questions;
            if (_currentQuestionIndex < _questions.length) {
              _currentQuestion = _questions[_currentQuestionIndex];

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
    _currentIndexRef = FirebaseChallengeHelper.getRef(currentIndexPath);

    _currentIndexSubscription = _currentIndexRef!.onValue.listen(
      (event) {
        if (!mounted) return;

        final index = event.snapshot.value as int?;
        if (index != null && index != _currentQuestionIndex) {
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
    _currentStartTimeRef = FirebaseChallengeHelper.getRef(startTimePath);

    _currentStartTimeSubscription = _currentStartTimeRef!.onValue.listen(
      (event) {
        if (!mounted) return;

        final startTime = event.snapshot.value as int?;
        if (startTime != null && startTime != _questionStartTime) {
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
    _currentEndTimeRef = FirebaseChallengeHelper.getRef(endTimePath);

    _currentEndTimeSubscription = _currentEndTimeRef!.onValue.listen(
      (event) {
        if (!mounted) return;

        final endTime = event.snapshot.value as int?;
        if (endTime != null && endTime != _questionEndTime) {
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
    _statusRef = FirebaseChallengeHelper.getRef(statusPath);

    _statusSubscription = _statusRef!.onValue.listen(
      (event) {
        if (!mounted) return;

        final status = event.snapshot.value as String?;
        if (status == 'completed') {
          _navigateToCompletion();
        }
      },
      onError: (error) {
        print('LiveQuestionScreen - Status listener ERROR: $error');
      },
    );

    // 5. Listen to leaderboard updates
    final leaderboardPath = 'liveChallenges/${widget.challengeCode}/rankings';
    _leaderboardRef = FirebaseChallengeHelper.getRef(leaderboardPath);

    _leaderboardSubscription = _leaderboardRef!.onValue.listen(
      (event) {
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
  }

  /// Start polling service to check for question advances
  void _startPolling() {
    _pollingService = ChallengePollingService(
      pollingInterval: const Duration(seconds: 5),
      onPoll: () async {
        if (!mounted) return;

        final response = await context
            .read<ChallengeCubit>()
            .checkAndAdvanceQuestion(challengeCode: widget.challengeCode);

        if (!mounted) return;

        if (response != null) {
          final dynamic timeRemainingRaw = response['timeRemaining'];

          // Normalize server-provided timeRemaining which may be in ms or s.
          final int normalized =
              LiveQuestionHelper.normalizeServerTimeRemaining(
                timeRemainingRaw,
                _getQuestionDurationSeconds(),
              );

          // Sync timer if normalized value is valid
          if (normalized >= 0 && _timeRemaining != normalized) {
            if (mounted) {
              setState(() {
                _timeRemaining = normalized;
              });
            }
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
    _answersSubscription?.cancel();

    final answersPath =
        'liveChallenges/${widget.challengeCode}/answers/$_currentQuestionIndex';
    _answersRef = FirebaseChallengeHelper.getRef(answersPath);

    _answersSubscription = _answersRef!.onValue.listen(
      (event) {
        if (!mounted) return;

        final data = event.snapshot.value;
        if (data != null) {
          int answeredCount = 0;

          if (data is Map) {
            answeredCount = data.length;
          } else if (data is List) {
            answeredCount = data.where((item) => item != null).length;
          }

          setState(() {
            _totalAnsweredPlayers = answeredCount;
          });

          // Check if all players have answered
          if (_hasAnswered &&
              answeredCount >= _totalPlayers &&
              _totalPlayers > 0) {
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
    final participantsPath =
        'liveChallenges/${widget.challengeCode}/participants';
    FirebaseChallengeHelper.getOnce(participantsPath).then((snapshot) {
      if (!mounted || snapshot == null) return;

      final data = snapshot.value;
      if (data != null) {
        int count = 0;
        if (data is Map) {
          data.forEach((key, value) {
            if (value is Map) {
              final active = value['active'];
              if (active == null || active == true) {
                count++;
              }
            } else {
              count++;
            }
          });
        } else if (data is List) {
          count = data.where((item) => item != null).length;
        }

        setState(() {
          _totalPlayers = count;
        });
      }
    });
  }

  void _showAnswerFeedback() {
    if (_showingFeedback) return;

    final correctAnswerIndex = _currentQuestion?['answer'];

    if (correctAnswerIndex != null) {
      if (correctAnswerIndex is String) {
        _correctAnswer = correctAnswerIndex.toUpperCase();
      } else if (correctAnswerIndex is int) {
        _correctAnswer = String.fromCharCode(65 + correctAnswerIndex);
      }
    }

    if (_selectedAnswer != null && _correctAnswer != null) {
      final selectedUpper = _selectedAnswer?.toUpperCase();
      final correctUpper = _correctAnswer?.toUpperCase();
      final localCorrectness = (selectedUpper == correctUpper);

      if (_wasCorrect != localCorrectness) {
        _wasCorrect = localCorrectness;
      }
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      final userId = authState.user.id;
      for (int i = 0; i < _leaderboard.length; i++) {
        if (_leaderboard[i]['userId'] == userId) {
          _currentRank = i + 1;
          break;
        }
      }
    }

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

    _feedbackController.reset();
    _feedbackController.forward();
  }

  void _startQuestionTimer(int? startTime) {
    _questionTimer?.cancel();

    final int questionDuration = _getQuestionDurationSeconds();

    if (startTime != null) {
      final endTimeMs =
          _questionEndTime ?? (startTime + questionDuration * 1000);
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final remainingMs = endTimeMs - nowMs;

      final rawRemaining = (remainingMs / 1000).ceil();
      _timeRemaining = rawRemaining.clamp(0, questionDuration);
    } else {
      _timeRemaining = questionDuration;
    }

    if (_timeRemaining > 0) {
      setState(() {});

      _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          _timeRemaining = (_timeRemaining - 1).clamp(0, questionDuration);
        });

        if (_timeRemaining <= 0) {
          timer.cancel();
          _soundService.playTimeoutSound();
          _vibrationService.warning();

          if (_hasAnswered) {
            _showAnswerFeedback();
          }

          _triggerCheckAdvance();
        } else if (_timeRemaining == 10) {
          _soundService.playTimerWarningSound();
          _vibrationService.warning();
        }
      });
    } else {
      if (_hasAnswered) {
        _showAnswerFeedback();
      }
      _triggerCheckAdvance();
    }
  }

  Future<void> _triggerCheckAdvance() async {
    if (!mounted) return;

    if (_checkAdvanceCalled) return;

    _checkAdvanceCalled = true;

    try {
      await context.read<ChallengeCubit>().checkAndAdvanceQuestion(
        challengeCode: widget.challengeCode,
      );
    } catch (e) {
      print('LiveQuestionScreen - check-advance error: $e');
    }
  }

  int _getQuestionDurationSeconds() {
    return LiveQuestionHelper.getQuestionDurationSeconds(_currentQuestion);
  }

  Future<void> _submitAnswer(String? answer) async {
    if (_hasAnswered) return;
    if (answer == null) return;

    _vibrationService.medium();

    setState(() {
      _hasAnswered = true;
      _selectedAnswer = answer;
      _isWaitingForOthers = true;
    });

    final answerToSubmit = answer.toLowerCase();

    await context.read<ChallengeCubit>().submitAnswer(
      challengeCode: widget.challengeCode,
      answer: answerToSubmit,
    );
  }

  void _navigateToCompletion() {
    if (!mounted) return;

    String? currentUserId;
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      currentUserId = authState.user.id;
    }

    int userRank = _leaderboard.length + 1;
    int userScore = 0;

    for (int i = 0; i < _leaderboard.length; i++) {
      final entry = _leaderboard[i];
      if (entry['userId'] == currentUserId) {
        userRank = i + 1;
        userScore = entry['score'] ?? 0;
        break;
      }
    }

    final totalQuestions = _questions.length;
    final correctAnswers = userScore;
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disconnectFromChallenge();

    _questionTimer?.cancel();
    _questionsSubscription?.cancel();
    _currentIndexSubscription?.cancel();
    _currentStartTimeSubscription?.cancel();
    _currentEndTimeSubscription?.cancel();
    _statusSubscription?.cancel();
    _leaderboardSubscription?.cancel();
    _answersSubscription?.cancel();

    _stopPolling();

    _questionSlideController.dispose();
    _optionsController.dispose();
    _timerPulseController.dispose();
    _feedbackController.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _disconnectFromChallenge();
    }
  }

  Future<void> _disconnectFromChallenge() async {
    if (!mounted) return;

    try {
      await context.read<ChallengeCubit>().disconnectFromChallenge(
        challengeCode: widget.challengeCode,
      );
    } catch (e) {
      print('LiveQuestionScreen - Error disconnecting from challenge: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChallengeCubit, ChallengeState>(
      listener: (context, state) {
        if (!mounted) return;

        if (state is ChallengeCompleted) {
          _navigateToCompletion();
        } else if (state is ChallengeError) {
          CustomDialogs.showErrorDialog(
            context,
            title: 'Error!',
            message: state.message,
          );
        } else if (state is AnswerSubmitted) {
          if (mounted) {
            setState(() {
              _wasCorrect = state.isCorrect;
            });
          }
        }
      },
      child: Scaffold(
        backgroundColor: LiveQuestionTheme.bg,
        body: SafeArea(
          child: Column(
            children: [
              ChallengeHeader(
                challengeName: widget.challengeName,
                currentIndex: _currentQuestionIndex,
                totalQuestions: _questions.isNotEmpty ? _questions.length : 0,
                onExit: _showExitDialog,
                textPrimary: LiveQuestionTheme.textPrimary,
                textSecondary: LiveQuestionTheme.textSecondary,
              ),
              ChallengeProgressBar(
                currentIndex: _currentQuestionIndex,
                totalQuestions: _questions.isNotEmpty ? _questions.length : 0,
                cardBg: LiveQuestionTheme.cardBg,
                textPrimary: LiveQuestionTheme.textPrimary,
                accentGreen: LiveQuestionTheme.green,
              ),
              ChallengeTimerBar(
                timeRemaining: _timeRemaining,
                durationSeconds: _getQuestionDurationSeconds(),
                isUrgent: _timeRemaining <= 10,
                pulse: _timerPulseAnimation,
                cardBg: LiveQuestionTheme.cardBg,
                textSecondary: LiveQuestionTheme.textSecondary,
                accentGreen: LiveQuestionTheme.green,
                dangerRed: LiveQuestionTheme.red,
              ),
              Expanded(
                child: _currentQuestion == null
                    ? const LiveQuestionLoading()
                    : LiveQuestionContent(
                        question: _currentQuestion!,
                        showingFeedback: _showingFeedback,
                        wasCorrect: _wasCorrect ?? false,
                        selectedAnswer: _selectedAnswer,
                        correctAnswer: _correctAnswer,
                        currentRank: _currentRank,
                        totalPlayers: _totalPlayers,
                        feedbackScaleAnimation: _feedbackScaleAnimation,
                        isWaitingForOthers: _isWaitingForOthers,
                        totalAnsweredPlayers: _totalAnsweredPlayers,
                        questionSlideAnimation: _questionSlideAnimation,
                        optionsFadeAnimation: _optionsFadeAnimation,
                        hasAnswered: _hasAnswered,
                        vibrationService: _vibrationService,
                        onAnswerSelected: (answer) => setState(() {
                          _selectedAnswer = answer;
                        }),
                        onSubmit: () => _submitAnswer(_selectedAnswer),
                      ),
              ),
              LiveQuestionLeaderboardButton(onTap: _showLeaderboard),
            ],
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
      backgroundColor: LiveQuestionTheme.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          LiveQuestionLeaderboardSheet(leaderboard: _leaderboard),
    );
  }

  void _showExitDialog() {
    if (!mounted) return;

    final dialogContext = _navigator?.context ?? context;

    showDialog(
      context: dialogContext,
      builder: (context) => AlertDialog(
        backgroundColor: LiveQuestionTheme.cardBg,
        title: const Text(
          'Leave Challenge?',
          style: TextStyle(color: LiveQuestionTheme.textPrimary),
        ),
        content: const Text(
          'You will lose your progress and points.',
          style: TextStyle(color: LiveQuestionTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: LiveQuestionTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Leave',
              style: TextStyle(color: LiveQuestionTheme.red),
            ),
          ),
        ],
      ),
    );
  }
}
