// features/quiz/presentation/view/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/quiz/data/models/QuizModel.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizcubit.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizstate.dart';
import 'package:tionova/features/quiz/presentation/view/quiz_questions_screen.dart';
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider.value(
                                      value: context.read<QuizCubit>(),
                                      child: QuizQuestionsScreen(
                                        quiz: quizState.quiz,
                                        answers: List.filled(
                                          quizState.quiz.questions.length,
                                          null,
                                        ),
                                        token: widget.token,
                                        chapterId: widget.chapterId,
                                      ),
                                    ),
                                  ),
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
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
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
                      const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 64,
                      ),
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
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: context.read<QuizCubit>(),
                                child: QuizQuestionsScreen(
                                  quiz: quiz,
                                  answers: List.filled(
                                    quiz.questions.length,
                                    null,
                                  ),
                                  token: widget.token,
                                  chapterId: widget.chapterId,
                                ),
                              ),
                            ),
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
        ),
      ),
    );
  }
}
