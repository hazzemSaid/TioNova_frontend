// features/quiz/data/models/UserQuizStatusModel.dart
/*{
    "success": true,
    "message": "Quiz history retrieved successfully",
    "history": {
        "attempts": [
            {
                "startedAt": "2025-09-25T13:06:12.869Z",
                "completedAt": "2025-09-25T13:06:12.869Z",
                "totalQuestions": 10,
                "correct": 10,
                "degree": 100,
                "state": "Passed",
                "answers": [
                    {
                        "question": "In agile processes, is planning incremental, and is it easier to change the process to reflect changing customer requirements?",
                        "options": [
                            "a) True",
                            "b) False",
                            "c) Sometimes",
                            "d) It depends on the project"
                        ],
                        "correctAnswer": "a",
                        "selectedOption": "a",
                        "isCorrect": true
                    },
                    {
                        "question": "For most types of systems, where is the majority of costs incurred?",
                        "options": [
                            "a) During initial design",
                            "b) During implementation",
                            "c) After software release and deployment",
                            "d) During testing"
                        ],
                        "correctAnswer": "c",
                        "selectedOption": "c",
                        "isCorrect": true
                    },
                    {
                        "question": "What does a Burn Down Chart primarily display?",
                        "options": [
                            "a) The velocity of a team",
                            "b) The capacity of team members",
                            "c) The amount of remaining work relative to time",
                            "d) How many more items can be completed in a sprint"
                        ],
                        "correctAnswer": "c",
                        "selectedOption": "c",
                        "isCorrect": true
                    },
                    {
                        "question": "Which software engineering model incorporates risk assessment as a key activity?",
                        "options": [
                            "a) Waterfall Model",
                            "b) Incremental Development",
                            "c) Spiral Model",
                            "d) Reuse-Oriented Software Engineering"
                        ],
                        "correctAnswer": "c",
                        "selectedOption": "c",
                        "isCorrect": true
                    },
                    {
                        "question": "Which of the following is NOT an Agile methodology?",
                        "options": [
                            "a) Scrum",
                            "b) Kanban",
                            "c) Waterfall",
                            "d) Extreme Programming (XP)"
                        ],
                        "correctAnswer": "c",
                        "selectedOption": "c",
                        "isCorrect": true
                    },
                    {
                        "question": "A software company develops a game for Windows, macOS, and Android.  Some features don't work correctly when switching platforms. Which software attribute is compromised?",
                        "options": [
                            "a) Portability",
                            "b) Reusability",
                            "c) Availability",
                            "d) Maintainability"
                        ],
                        "correctAnswer": "a",
                        "selectedOption": "a",
                        "isCorrect": true
                    },
                    {
                        "question": "What does equivalence partitioning analysis belong to?",
                        "options": [
                            "a) Black box testing",
                            "b) White box testing",
                            "c) Red box testing",
                            "d) None of the above"
                        ],
                        "correctAnswer": "a",
                        "selectedOption": "a",
                        "isCorrect": true
                    },
                    {
                        "question": "Who is typically responsible for unit testing?",
                        "options": [
                            "a) Software tester",
                            "b) Developer",
                            "c) User",
                            "d) Project Manager"
                        ],
                        "correctAnswer": "b",
                        "selectedOption": "b",
                        "isCorrect": true
                    },
                    {
                        "question": "A software development team completes 120,000 lines of code (LOC) over 10 person-months. What's their productivity in KLOC per person-month?",
                        "options": [
                            "a) 12 KLOC",
                            "b) 10 KLOC",
                            "c) 8 KLOC",
                            "d) 6 KLOC"
                        ],
                        "correctAnswer": "a",
                        "selectedOption": "a",
                        "isCorrect": true
                    },
                    {
                        "question": "In the context of software requirements, what type of requirement is 'Users should be able to search for specific items within the system'?",
                        "options": [
                            "a) Functional Requirement",
                            "b) Non-functional Requirement",
                            "c) User Story",
                            "d) Use Case"
                        ],
                        "correctAnswer": "a",
                        "selectedOption": "a",
                        "isCorrect": true
                    }
                ]
            },
            {
                "startedAt": "2025-09-25T13:13:07.789Z",
                "completedAt": "2025-09-25T13:13:07.789Z",
                "totalQuestions": 10,
                "correct": 10,
                "degree": 100,
                "state": "Passed",
                "answers": [
                    {
                        "question": "In agile processes, is planning incremental, and is it easier to change the process to reflect changing customer requirements?",
                        "options": [
                            "a) True",
                            "b) False",
                            "c) Sometimes",
                            "d) It depends on the project"
                        ],
                        "correctAnswer": "a",
                        "selectedOption": "a",
                        "isCorrect": true
                    },
                    {
                        "question": "For most types of systems, where is the majority of costs incurred?",
                        "options": [
                            "a) During initial design",
                            "b) During implementation",
                            "c) After software release and deployment",
                            "d) During testing"
                        ],
                        "correctAnswer": "c",
                        "selectedOption": "c",
                        "isCorrect": true
                    },
                    {
                        "question": "What does a Burn Down Chart primarily display?",
                        "options": [
                            "a) The velocity of a team",
                            "b) The capacity of team members",
                            "c) The amount of remaining work relative to time",
                            "d) How many more items can be completed in a sprint"
                        ],
                        "correctAnswer": "c",
                        "selectedOption": "c",
                        "isCorrect": true
                    },
                    {
                        "question": "Which software engineering model incorporates risk assessment as a key activity?",
                        "options": [
                            "a) Waterfall Model",
                            "b) Incremental Development",
                            "c) Spiral Model",
                            "d) Reuse-Oriented Software Engineering"
                        ],
                        "correctAnswer": "c",
                        "selectedOption": "c",
                        "isCorrect": true
                    },
                    {
                        "question": "Which of the following is NOT an Agile methodology?",
                        "options": [
                            "a) Scrum",
                            "b) Kanban",
                            "c) Waterfall",
                            "d) Extreme Programming (XP)"
                        ],
                        "correctAnswer": "c",
                        "selectedOption": "c",
                        "isCorrect": true
                    },
                    {
                        "question": "A software company develops a game for Windows, macOS, and Android.  Some features don't work correctly when switching platforms. Which software attribute is compromised?",
                        "options": [
                            "a) Portability",
                            "b) Reusability",
                            "c) Availability",
                            "d) Maintainability"
                        ],
                        "correctAnswer": "a",
                        "selectedOption": "a",
                        "isCorrect": true
                    },
                    {
                        "question": "What does equivalence partitioning analysis belong to?",
                        "options": [
                            "a) Black box testing",
                            "b) White box testing",
                            "c) Red box testing",
                            "d) None of the above"
                        ],
                        "correctAnswer": "a",
                        "selectedOption": "a",
                        "isCorrect": true
                    },
                    {
                        "question": "Who is typically responsible for unit testing?",
                        "options": [
                            "a) Software tester",
                            "b) Developer",
                            "c) User",
                            "d) Project Manager"
                        ],
                        "correctAnswer": "b",
                        "selectedOption": "b",
                        "isCorrect": true
                    },
                    {
                        "question": "A software development team completes 120,000 lines of code (LOC) over 10 person-months. What's their productivity in KLOC per person-month?",
                        "options": [
                            "a) 12 KLOC",
                            "b) 10 KLOC",
                            "c) 8 KLOC",
                            "d) 6 KLOC"
                        ],
                        "correctAnswer": "a",
                        "selectedOption": "a",
                        "isCorrect": true
                    },
                    {
                        "question": "In the context of software requirements, what type of requirement is 'Users should be able to search for specific items within the system'?",
                        "options": [
                            "a) Functional Requirement",
                            "b) Non-functional Requirement",
                            "c) User Story",
                            "d) Use Case"
                        ],
                        "correctAnswer": "a",
                        "selectedOption": "a",
                        "isCorrect": true
                    }
                ]
            },
            {
                "startedAt": "2025-09-25T13:14:00.788Z",
                "completedAt": "2025-09-25T13:14:00.788Z",
                "totalQuestions": 10,
                "correct": 0,
                "degree": 0,
                "state": "Failed",
                "answers": [
                    {
                        "question": "In agile processes, is planning incremental, and is it easier to change the process to reflect changing customer requirements?",
                        "options": [
                            "a) True",
                            "b) False",
                            "c) Sometimes",
                            "d) It depends on the project"
                        ],
                        "correctAnswer": "a",
                        "selectedOption": "z",
                        "isCorrect": false
                    },
                    {
                        "question": "For most types of systems, where is the majority of costs incurred?",
                        "options": [
                            "a) During initial design",
                            "b) During implementation",
                            "c) After software release and deployment",
                            "d) During testing"
                        ],
                        "correctAnswer": "c",
                        "selectedOption": "z",
                        "isCorrect": false
                    },
                    {
                        "question": "What does a Burn Down Chart primarily display?",
                        "options": [
                            "a) The velocity of a team",
                            "b) The capacity of team members",
                            "c) The amount of remaining work relative to time",
                            "d) How many more items can be completed in a sprint"
                        ],
                        "correctAnswer": "c",
                        "selectedOption": "z",
                        "isCorrect": false
                    },
                    {
                        "question": "Which software engineering model incorporates risk assessment as a key activity?",
                        "options": [
                            "a) Waterfall Model",
                            "b) Incremental Development",
                            "c) Spiral Model",
                            "d) Reuse-Oriented Software Engineering"
                        ],
                        "correctAnswer": "c",
                        "selectedOption": "z",
                        "isCorrect": false
                    },
                    {
                        "question": "Which of the following is NOT an Agile methodology?",
                        "options": [
                            "a) Scrum",
                            "b) Kanban",
                            "c) Waterfall",
                            "d) Extreme Programming (XP)"
                        ],
                        "correctAnswer": "c",
                        "selectedOption": "z",
                        "isCorrect": false
                    },
                    {
                        "question": "A software company develops a game for Windows, macOS, and Android.  Some features don't work correctly when switching platforms. Which software attribute is compromised?",
                        "options": [
                            "a) Portability",
                            "b) Reusability",
                            "c) Availability",
                            "d) Maintainability"
                        ],
                        "correctAnswer": "a",
                        "selectedOption": "z",
                        "isCorrect": false
                    },
                    {
                        "question": "What does equivalence partitioning analysis belong to?",
                        "options": [
                            "a) Black box testing",
                            "b) White box testing",
                            "c) Red box testing",
                            "d) None of the above"
                        ],
                        "correctAnswer": "a",
                        "selectedOption": "z",
                        "isCorrect": false
                    },
                    {
                        "question": "Who is typically responsible for unit testing?",
                        "options": [
                            "a) Software tester",
                            "b) Developer",
                            "c) User",
                            "d) Project Manager"
                        ],
                        "correctAnswer": "b",
                        "selectedOption": "z",
                        "isCorrect": false
                    },
                    {
                        "question": "A software development team completes 120,000 lines of code (LOC) over 10 person-months. What's their productivity in KLOC per person-month?",
                        "options": [
                            "a) 12 KLOC",
                            "b) 10 KLOC",
                            "c) 8 KLOC",
                            "d) 6 KLOC"
                        ],
                        "correctAnswer": "a",
                        "selectedOption": "z",
                        "isCorrect": false
                    },
                    {
                        "question": "In the context of software requirements, what type of requirement is 'Users should be able to search for specific items within the system'?",
                        "options": [
                            "a) Functional Requirement",
                            "b) Non-functional Requirement",
                            "c) User Story",
                            "d) Use Case"
                        ],
                        "correctAnswer": "a",
                        "selectedOption": "z",
                        "isCorrect": false
                    }
                ]
            }
        ],
        "overallStatus": "Failed",
        "overallScore": 0,
        "totalAttempts": 3,
        "bestScore": 100,
        "averageScore": 67,
        "passRate": 67
    }
}*/
import 'package:equatable/equatable.dart';

class UserQuizStatusModel extends Equatable {
  final List<Attempt> attempts;
  final String overallStatus;
  final int overallScore;
  final int totalAttempts;
  final int bestScore;
  final int averageScore;
  final int passRate;

  const UserQuizStatusModel({
    required this.attempts,
    required this.overallStatus,
    required this.overallScore,
    required this.totalAttempts,
    required this.bestScore,
    required this.averageScore,
    required this.passRate,
  });

  factory UserQuizStatusModel.fromJson(Map<String, dynamic> json) {
    final attemptsJson = (json['attempts'] as List?) ?? const [];
    final attemptsList = attemptsJson
        .where((e) => e != null)
        .map((e) => Attempt.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return UserQuizStatusModel(
      attempts: attemptsList,
      overallStatus: (json['overallStatus'] ?? '').toString(),
      overallScore: (json['overallScore'] ?? 0) as int,
      totalAttempts: (json['totalAttempts'] ?? 0) as int,
      bestScore: (json['bestScore'] ?? 0) as int,
      averageScore: (json['averageScore'] ?? 0) as int,
      passRate: (json['passRate'] ?? 0) as int,
    );
  }
  @override
  List<Object?> get props => [
    attempts,
    overallStatus,
    overallScore,
    totalAttempts,
    bestScore,
    averageScore,
    passRate,
  ];
  @override
  bool get stringify => true;
}

class Attempt extends Equatable {
  final DateTime startedAt;
  final DateTime completedAt;
  final int totalQuestions;
  final int correct;
  final int degree;
  final String state;
  final List<Answer> answers;

  const Attempt({
    required this.startedAt,
    required this.completedAt,
    required this.totalQuestions,
    required this.correct,
    required this.degree,
    required this.state,
    required this.answers,
  });

  factory Attempt.fromJson(Map<String, dynamic> json) {
    final answersJson = (json['answers'] as List?) ?? const [];
    final answersList = answersJson
        .where((e) => e != null)
        .map((e) => Answer.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return Attempt(
      startedAt:
          DateTime.tryParse((json['startedAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      completedAt:
          DateTime.tryParse((json['completedAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      totalQuestions: (json['totalQuestions'] ?? 0) as int,
      correct: (json['correct'] ?? 0) as int,
      degree: (json['degree'] ?? 0) as int,
      state: (json['state'] ?? '').toString(),
      answers: answersList,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
    startedAt,
    completedAt,
    totalQuestions,
    correct,
    degree,
    state,
    answers,
  ];
  @override
  bool get stringify => true;
}

class Answer extends Equatable {
  final String? questionId;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String selectedOption;
  final bool isCorrect;
  final String? explanation;

  Answer({
    this.questionId,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.selectedOption,
    required this.isCorrect,
    this.explanation,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    final optionsFromJson = (json['options'] as List?) ?? const [];
    final optionsList = optionsFromJson
        .map((e) => e?.toString() ?? '')
        .toList()
        .cast<String>();

    return Answer(
      questionId: json['questionId']?.toString(),
      question: (json['question'] ?? '').toString(),
      options: optionsList,
      correctAnswer: (json['correctAnswer'] ?? '').toString(),
      selectedOption: (json['selectedOption'] ?? '').toString(),
      isCorrect: (json['isCorrect'] ?? false) as bool,
      explanation: (json['explanation'] ?? '').toString().isEmpty
          ? null
          : (json['explanation'] ?? '').toString(),
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
    questionId,
    question,
    options,
    correctAnswer,
    selectedOption,
    isCorrect,
    explanation,
  ];
  @override
  bool get stringify => true;
}
