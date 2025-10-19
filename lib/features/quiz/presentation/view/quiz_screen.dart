// features/quiz/presentation/view/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/quiz/data/models/QuizModel.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizcubit.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizstate.dart';
import 'package:tionova/features/quiz/presentation/widgets/quiz_header.dart';

class QuizScreen extends StatefulWidget {
  final String token;
  final String chapterId;

  const QuizScreen({super.key, required this.token, required this.chapterId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the widget is mounted and the context is valid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<QuizCubit>().createQuiz(
          token: widget.token,
          chapterId: widget.chapterId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = Colors.black;

    return BlocConsumer<QuizCubit, QuizState>(
      listener: (context, state) {
        if (state is CreateQuizFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.failure.errMessage)));
        }
      },
      builder: (context, state) {
        if (state is CreateQuizLoading) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFE9500)),
            ),
          );
        }

        if (state is CreateQuizSuccess) {
          // If quiz is successfully loaded, show the quiz content
          return _buildQuizContent(context, bgColor, state.quiz);
        }

        // Default view or error state
        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  QuizHeader(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.white,
                            size: 64,
                          ),
                          const SizedBox(height: 24),
                          if (state is CreateQuizSuccess) ...[
                            Text(
                              state.quiz.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Test your knowledge with this quiz',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ] else if (state is CreateQuizLoading) ...[
                            const CircularProgressIndicator(
                              color: Color(0xFFFE9500),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Loading quiz...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C2C2E),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: const [
                                    Text(
                                      '5',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Questions',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C2C2E),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: const [
                                    Text(
                                      '15m',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Time Limit',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFE9500),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Medium',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Multiple choice questions',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Review answers before submitting',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Detailed explanations provided',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),
                          ElevatedButton(
                            onPressed: () {
                              final quizState = state;
                              if (quizState is CreateQuizSuccess) {
                                context.push(
                                  '/quiz-questions',
                                  extra: {
                                    'quiz': quizState.quiz,
                                    'answers': List.filled(
                                      quizState.quiz.questions.length,
                                      null,
                                    ),
                                    'token': widget.token,
                                    'chapterId': widget.chapterId,
                                  },
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFE9500),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 16,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Start Quiz',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuizContent(
    BuildContext context,
    Color bgColor,
    QuizModel quiz,
  ) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: isWeb
            ? _buildWebLayout(context, quiz)
            : _buildMobileLayout(context, quiz),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, QuizModel quiz) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF1C1C1E), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Purple gradient icon
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9D7FFF), Color(0xFFC4A9FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),
              // Quiz title
              Text(
                quiz.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                'Test your understanding of BST concepts, operations, and implementations.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              // Stats row - Wrap for responsiveness
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildStatCard('${quiz.questions.length}', 'Questions'),
                  _buildStatCard('15m', 'Time Limit'),
                  _buildStatCard('60%', 'Pass Mark'),
                  _buildStatCard('Medium', 'Difficulty', isOrange: true),
                ],
              ),
              const SizedBox(height: 48),
              // Features list
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureItem(
                    'Multiple choice questions with single correct answer',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    'Review all your answers before submitting',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    'Detailed explanations provided for each question',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    'Timer will start automatically when you begin',
                  ),
                ],
              ),
              const SizedBox(height: 48),
              // Start Quiz button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    context.push(
                      '/quiz-questions',
                      extra: {
                        'quiz': quiz,
                        'answers': List.filled(quiz.questions.length, null),
                        'token': widget.token,
                        'chapterId': widget.chapterId,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Start Quiz',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, {bool isOrange = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: isOrange ? const Color(0xFFFE9500) : Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, QuizModel quiz) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const QuizHeader(),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.white, size: 64),
                  const SizedBox(height: 24),
                  Text(
                    quiz.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Test your knowledge with ${quiz.questions.length} questions',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${quiz.questions.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Questions',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: const [
                            Text(
                              '15m',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Time Limit',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFE9500),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Medium',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white70,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Multiple choice questions',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white70,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Review answers before submitting',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white70,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Detailed explanations provided',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () {
                      context.push(
                        '/quiz-questions',
                        extra: {
                          'quiz': quiz,
                          'answers': List.filled(quiz.questions.length, null),
                          'token': widget.token,
                          'chapterId': widget.chapterId,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFE9500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Start Quiz',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
