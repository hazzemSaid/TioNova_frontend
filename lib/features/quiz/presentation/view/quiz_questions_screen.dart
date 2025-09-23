import 'package:flutter/material.dart';
import 'package:tionova/features/quiz/presentation/view/quiz_review_screen.dart';
import 'package:tionova/features/quiz/presentation/widgets/quiz_header.dart';

class QuizQuestionsScreen extends StatefulWidget {
  const QuizQuestionsScreen({super.key});

  @override
  State<QuizQuestionsScreen> createState() => _QuizQuestionsScreenState();
}

class _QuizQuestionsScreenState extends State<QuizQuestionsScreen> {
  int currentStep = 0;
  List<int?> answers = List.filled(5, null);

  final questions = [
    {
      'question':
          'What is the time complexity of searching in a balanced Binary Search Tree?',
      'options': ['O(1)', 'O(log n)', 'O(n)', 'O(n log n)'],
      'correct': 1,
    },
    {
      'question':
          'In a Binary Search Tree, where are nodes with smaller values located?',
      'options': ['Left subtree', 'Right subtree', 'Root', 'Leaf'],
      'correct': 0,
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
    },
    {
      'question':
          'Which traversal method visits nodes in sorted order in a BST?',
      'options': ['Preorder', 'Postorder', 'Inorder', 'Level order'],
      'correct': 2,
    },
    {
      'question': 'What is the minimum number of nodes in a BST of height h?',
      'options': ['h', 'h + 1', '2^h', '2^h - 1'],
      'correct': 1,
    },
  ];

  void selectAnswer(int index) {
    setState(() {
      answers[currentStep] = index;
    });
  }

  void nextQuestion() {
    if (currentStep < questions.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              QuizReviewScreen(questions: questions, answers: answers),
        ),
      );
    }
  }

  void previousQuestion() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuizHeader(
                title: 'Question ${currentStep + 1} of ${questions.length}',
                timer: '14:59',
              ),
              const SizedBox(height: 16),
              // Progress bar
              LinearProgressIndicator(
                value: (currentStep + 1) / questions.length,
                backgroundColor: const Color(0xFF2C2C2E),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                questions[currentStep]['question']! as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Options as cards
              ...List<String>.from(
                questions[currentStep]['options']! as List,
              ).asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: () => selectAnswer(index),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: answers[currentStep] == index
                            ? Colors.white
                            : Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: answers[currentStep] == index
                              ? Color(0xFFFE9500)
                              : Color(0xFF3A3A3C),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: answers[currentStep] == index
                                    ? Colors.black
                                    : Colors.white70,
                                width: 2.0,
                              ),
                              color: answers[currentStep] == index
                                  ? Colors.black
                                  : Colors.transparent,
                            ),
                            child: answers[currentStep] == index
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                color: answers[currentStep] == index
                                    ? Colors.black
                                    : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: currentStep > 0 ? previousQuestion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2C2E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Previous',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFE9500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      currentStep == questions.length - 1
                          ? 'Review Answers'
                          : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
