import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/challenges/presentation/bloc/challenge_cubit.dart';
import 'package:tionova/features/challenges/presentation/view/screens/challenge_completion_screen.dart';

class LiveQuestionScreen extends StatefulWidget {
  final String challengeCode;
  final String challengeName;

  const LiveQuestionScreen({
    super.key,
    required this.challengeCode,
    required this.challengeName,
  });

  @override
  State<LiveQuestionScreen> createState() => _LiveQuestionScreenState();
}

class _LiveQuestionScreenState extends State<LiveQuestionScreen>
    with TickerProviderStateMixin {
  // Firebase references
  DatabaseReference? _questionsRef;
  DatabaseReference? _currentIndexRef;
  DatabaseReference? _currentStartTimeRef;
  DatabaseReference? _statusRef;
  DatabaseReference? _leaderboardRef;
  DatabaseReference? _answersRef;

  // Firebase subscriptions
  StreamSubscription<DatabaseEvent>? _questionsSubscription;
  StreamSubscription<DatabaseEvent>? _currentIndexSubscription;
  StreamSubscription<DatabaseEvent>? _currentStartTimeSubscription;
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

  @override
  void initState() {
    super.initState();

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
    // Get total players from participants count
    final participantsPath =
        'liveChallenges/${widget.challengeCode}/participants';
    FirebaseDatabase.instance.ref(participantsPath).once().then((event) {
      if (!mounted) return;

      final data = event.snapshot.value;
      if (data != null) {
        int count = 0;
        if (data is Map) {
          count = data.length;
        } else if (data is List) {
          count = data.where((item) => item != null).length;
        }

        setState(() {
          _totalPlayers = count;
        });

        print('LiveQuestionScreen - Total players: $_totalPlayers');
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
      'LiveQuestionScreen - Correct answer index from Firebase: $correctAnswerIndex',
    );

    if (correctAnswerIndex != null) {
      _correctAnswer = String.fromCharCode(65 + (correctAnswerIndex as int));
    }

    // Get user's rank from leaderboard
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      final username = authState.user.username;
      print(
        'LiveQuestionScreen - Looking for username in leaderboard: $username',
      );
      for (int i = 0; i < _leaderboard.length; i++) {
        if (_leaderboard[i]['username'] == username) {
          _currentRank = i + 1;
          print('LiveQuestionScreen - Found user at rank: $_currentRank');
          break;
        }
      }
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

    if (startTime != null) {
      final elapsed =
          (DateTime.now().millisecondsSinceEpoch - startTime) ~/ 1000;
      _timeRemaining = 30 - elapsed;

      print('LiveQuestionScreen - Elapsed: $elapsed seconds');
      print('LiveQuestionScreen - Time remaining: $_timeRemaining seconds');
    } else {
      _timeRemaining = 30;
      print('LiveQuestionScreen - No start time, defaulting to 30 seconds');
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
          _timeRemaining--;
        });

        print(
          'LiveQuestionScreen - Timer tick: $_timeRemaining seconds remaining',
        );

        if (_timeRemaining <= 0) {
          print('LiveQuestionScreen - Timer expired!');
          timer.cancel();
          if (!_hasAnswered) {
            // If user has selected an answer but not submitted, submit it
            if (_selectedAnswer != null) {
              print(
                'LiveQuestionScreen - Auto-submitting selected answer: $_selectedAnswer',
              );
              _submitAnswer(_selectedAnswer);
            } else {
              print(
                'LiveQuestionScreen - Timer expired - No answer selected, submitting X',
              );
              _handleNoAnswer();
            }
          }
        }
      });
    } else {
      print('LiveQuestionScreen - Time already expired, auto-submitting');
      if (!_hasAnswered) {
        // If user has selected an answer but not submitted, submit it
        if (_selectedAnswer != null) {
          print(
            'LiveQuestionScreen - Auto-submitting selected answer: $_selectedAnswer',
          );
          _submitAnswer(_selectedAnswer);
        } else {
          print('LiveQuestionScreen - No answer selected, submitting X');
          _handleNoAnswer();
        }
      }
    }
  }

  Future<void> _handleNoAnswer() async {
    print('LiveQuestionScreen - Handling no answer (timeout)');

    setState(() {
      _hasAnswered = true;
      _selectedAnswer = 'X'; // Mark as X for display in feedback
      _isWaitingForOthers = true;
    });

    // Submit "X" as no answer to the backend
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) {
      print('LiveQuestionScreen - Auth state is not AuthSuccess');
      return;
    }

    await context.read<ChallengeCubit>().submitAnswer(
      token: authState.token,
      challengeCode: widget.challengeCode,
      answer: 'X', // X = no answer/timeout
    );

    print('LiveQuestionScreen - No answer submitted, waiting for others...');
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

    setState(() {
      _hasAnswered = true;
      _selectedAnswer = answer;
      _isWaitingForOthers = true;
    });

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) {
      print('LiveQuestionScreen - Auth state is not AuthSuccess');
      return;
    }

    // Submit answer via API
    // Backend expects answer as a string ("A", "B", "C", "D")
    print('LiveQuestionScreen - Submitting answer: "$answer"');

    await context.read<ChallengeCubit>().submitAnswer(
      token: authState.token,
      challengeCode: widget.challengeCode,
      answer: answer,
    );

    print(
      'LiveQuestionScreen - Answer submitted, waiting for other players...',
    );
  }

  void _navigateToCompletion() {
    if (!mounted) return;

    print('LiveQuestionScreen - Navigating to completion screen');

    // Get current user's data from auth
    final authState = context.read<AuthCubit>().state;
    String currentUsername = 'Unknown';
    if (authState is AuthSuccess) {
      currentUsername = authState.user.username;
    }

    // Find user's rank and score in leaderboard
    int userRank = _leaderboard.length + 1;
    int userScore = 0;

    for (int i = 0; i < _leaderboard.length; i++) {
      final entry = _leaderboard[i];
      if (entry['username'] == currentUsername) {
        userRank = i + 1;
        userScore = entry['score'] ?? 0;
        break;
      }
    }

    // Calculate correct answers and accuracy
    // Assuming each correct answer is worth points (adjust logic if needed)
    final totalQuestions = _questions.length;
    final correctAnswers = userScore; // Adjust based on your scoring system
    final accuracy = totalQuestions > 0
        ? (correctAnswers / totalQuestions * 100)
        : 0.0;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<ChallengeCubit>()),
            BlocProvider.value(value: context.read<AuthCubit>()),
          ],
          child: ChallengeCompletionScreen(
            challengeName: widget.challengeName,
            finalScore: userScore,
            correctAnswers: correctAnswers,
            totalQuestions: totalQuestions,
            accuracy: accuracy,
            rank: userRank,
            leaderboard: _leaderboard,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('LiveQuestionScreen - dispose called');
    _questionTimer?.cancel();
    _questionsSubscription?.cancel();
    _currentIndexSubscription?.cancel();
    _currentStartTimeSubscription?.cancel();
    _statusSubscription?.cancel();
    _leaderboardSubscription?.cancel();
    _answersSubscription?.cancel();

    // Dispose animation controllers
    _questionSlideController.dispose();
    _optionsController.dispose();
    _timerPulseController.dispose();
    _feedbackController.dispose();

    super.dispose();
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
        print('LiveQuestionScreen - BlocListener state: ${state.runtimeType}');

        if (state is ChallengeCompleted) {
          print('LiveQuestionScreen - ChallengeCompleted state received');
          // Navigate to completion screen
          _navigateToCompletion();
        } else if (state is ChallengeError) {
          print('LiveQuestionScreen - Error state: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is AnswerSubmitted) {
          print(
            'LiveQuestionScreen - Answer submitted for question ${state.questionIndex}',
          );
          print('LiveQuestionScreen - Is correct: ${state.isCorrect}');
          print('LiveQuestionScreen - Current score: ${state.currentScore}');

          // Store answer result
          setState(() {
            _wasCorrect = state.isCorrect;
          });
        }
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressBar(),
              _buildTimerBar(),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close, color: _textPrimary),
            onPressed: () => _showExitDialog(),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.challengeName,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Question ${_currentQuestionIndex + 1} of 3',
                  style: TextStyle(color: _textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentQuestionIndex + 1) / 3;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: _cardBg,
                valueColor: AlwaysStoppedAnimation<Color>(_green),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBar() {
    final timerProgress = _timeRemaining / 30;
    final isUrgent = _timeRemaining <= 10;

    return AnimatedBuilder(
      animation: _timerPulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isUrgent ? _timerPulseAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isUrgent
                  ? _red.withOpacity(0.15)
                  : _green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUrgent
                    ? _red.withOpacity(0.3)
                    : _green.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: isUrgent ? _red : _green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${_timeRemaining}s',
                            style: TextStyle(
                              color: isUrgent ? _red : _green,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'remaining',
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: timerProgress,
                          backgroundColor: _cardBg,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isUrgent ? _red : _green,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
      return _buildFeedbackState();
    }

    // Show waiting state if user has answered
    if (_isWaitingForOthers) {
      return _buildWaitingState();
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

                  return _buildOptionButton(
                    label: optionLabel,
                    text: optionText,
                    isSelected: isSelected,
                    onTap: _hasAnswered
                        ? null
                        : () {
                            setState(() {
                              _selectedAnswer = optionLabel;
                            });
                          },
                  );
                }).toList(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(Icons.hourglass_empty, color: _green, size: 64),
                const SizedBox(height: 24),
                Text(
                  'Waiting for other players...',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_totalAnsweredPlayers}/$_totalPlayers players answered',
                  style: TextStyle(color: _textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _totalPlayers > 0
                          ? _totalAnsweredPlayers / _totalPlayers
                          : 0,
                      backgroundColor: _cardBg,
                      valueColor: AlwaysStoppedAnimation<Color>(_green),
                      minHeight: 8,
                    ),
                  ),
                ),
                if (_selectedAnswer != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _green.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: _green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Your answer: $_selectedAnswer',
                          style: TextStyle(
                            color: _green,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackState() {
    final isCorrect = _wasCorrect ?? false;
    final userAnswer = _selectedAnswer ?? 'X'; // X = no answer
    final correctAnswer = _correctAnswer ?? '?';

    return ScaleTransition(
      scale: _feedbackScaleAnimation,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Result Icon with Hero Animation
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Transform.rotate(
                      angle: (1 - value) * 0.5,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? _green.withOpacity(0.15)
                              : _red.withOpacity(0.15),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isCorrect ? _green : _red).withOpacity(
                                0.3,
                              ),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? _green : _red,
                          size: 80,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Result Text with Fade Animation
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Text(
                      isCorrect
                          ? 'Correct!'
                          : userAnswer == 'X'
                          ? 'Time Out!'
                          : 'Incorrect!',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Answer Info
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    if (userAnswer != 'X') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Your answer: ',
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isCorrect ? _green : _red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              userAnswer,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!isCorrect) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Correct answer: ',
                              style: TextStyle(
                                color: _textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                correctAnswer,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ] else ...[
                      Text(
                        'You didn\'t answer in time',
                        style: TextStyle(color: _textSecondary, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Correct answer: ',
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              correctAnswer,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Rank Display
              if (_currentRank != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _green.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_events, color: _green, size: 32),
                          const SizedBox(width: 12),
                          Text(
                            'Your Rank',
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '#$_currentRank',
                        style: TextStyle(
                          color: _green,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'out of $_totalPlayers players',
                        style: TextStyle(color: _textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Next Question Info
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: _green,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Next question loading...',
                      style: TextStyle(
                        color: _green,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = _selectedAnswer != null && !_hasAnswered;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canSubmit ? () => _submitAnswer(_selectedAnswer) : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: canSubmit ? _green : _cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.send,
                color: canSubmit ? Colors.white : _textSecondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                _hasAnswered ? 'Submitted' : 'Submit Answer',
                style: TextStyle(
                  color: canSubmit ? Colors.white : _textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String label,
    required String text,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? _green : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? _green : _cardBg,
                    border: Border.all(
                      color: isSelected ? _green : _textSecondary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : _textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
    showModalBottomSheet(
      context: context,
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
            else
              ..._leaderboard.take(5).map((entry) {
                final rank = (_leaderboard.indexOf(entry) + 1);
                return _buildLeaderboardEntry(
                  rank: rank,
                  username: entry['username'] ?? 'Unknown',
                  score: entry['score'] ?? 0,
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardEntry({
    required int rank,
    required String username,
    required int score,
  }) {
    final isMedalist = rank <= 3;
    final medalColor = rank == 1
        ? const Color(0xFFFFD700)
        : rank == 2
        ? const Color(0xFFC0C0C0)
        : const Color(0xFFCD7F32);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isMedalist ? medalColor.withOpacity(0.2) : _bg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: isMedalist ? medalColor : _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            username.length > 2
                ? username.substring(0, 2).toUpperCase()
                : username.toUpperCase(),
            style: TextStyle(
              color: _textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              username,
              style: TextStyle(
                color: _textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$score',
            style: TextStyle(
              color: _green,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.circle, color: _green, size: 8),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
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
