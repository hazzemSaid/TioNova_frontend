import 'package:flutter/material.dart';
import 'package:tionova/features/quiz/presentation/view/quiz_questions_screen.dart';
import 'package:tionova/features/quiz/presentation/widgets/quiz_header.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentStep = 0;
  int selectedAnswer = -1;
  bool reviewing = false;
  bool submitted = false;

  // Dummy data for demonstration
  final quizInfo = {
    'title': 'Binary Search Trees Mastery',
    'description':
        'Test your understanding of BST concepts, operations, and implementations.',
    'questions': 5,
    'timeLimit': '15m',
    'difficulty': 'Medium',
  };

  final questions = [
    {
      'question':
          'What is the time complexity of searching in a balanced Binary Search Tree?',
      'options': ['O(1)', 'O(log n)', 'O(n)', 'O(n log n)'],
      'correct': 1,
      'explanation':
          'In a balanced BST, the height is O(log n), so search operations take O(log n) time.',
    },
    {
      'question':
          'In a Binary Search Tree, where are nodes with smaller values located?',
      'options': ['Left subtree', 'Right subtree', 'Root', 'Leaf'],
      'correct': 0,
      'explanation':
          'Nodes with smaller values are always in the left subtree.',
    },
    {
      'question': 'What happens to BST performance in the worst case scenario?',
      'options': [
        'Remains O(log n)',
        'Degrades to O(n)',
        'Becomes O(1)',
        'Improves to O(n log n)',
      ],
      'correct': 1,
      'explanation':
          'In the worst case, BST becomes a linear chain, so operations degrade to O(n).',
    },
    {
      'question':
          'Which traversal method visits nodes in sorted order in a BST?',
      'options': ['Preorder', 'Postorder', 'Inorder', 'Level order'],
      'correct': 2,
      'explanation':
          'Inorder traversal (left, root, right) visits BST nodes in ascending order.',
    },
    {
      'question': 'What is the minimum number of nodes in a BST of height h?',
      'options': ['h', 'h + 1', '2^h', '2^h - 1'],
      'correct': 1,
      'explanation':
          'A BST of height h has at minimum h + 1 nodes (when it forms a linear chain).',
    },
  ];

  List<int?> answers = List.filled(5, null);

  void selectAnswer(int index) {
    setState(() {
      answers[currentStep] = index;
    });
  }

  void nextQuestion() {
    if (currentStep < questions.length - 1) {
      setState(() {
        currentStep++;
        selectedAnswer = answers[currentStep] ?? -1;
      });
    } else {
      setState(() {
        reviewing = true;
      });
    }
  }

  void previousQuestion() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
        selectedAnswer = answers[currentStep] ?? -1;
      });
    }
  }

  void submitQuiz() {
    setState(() {
      submitted = true;
    });
  }

  void continueAnswering() {
    setState(() {
      reviewing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = Colors.black;
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
                      const Text(
                        'Binary Search Trees Mastery',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Test your understanding of BST concepts, operations, and implementations.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QuizQuestionsScreen(),
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
