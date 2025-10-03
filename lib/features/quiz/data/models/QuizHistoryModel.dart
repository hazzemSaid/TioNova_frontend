/*{
    "success": true,
    "message": "Quiz history retrieved successfully",
    "history": {
        "attempts": [
            {
                "startedAt": "2025-09-25T16:54:59.484Z",
                "completedAt": "2025-09-25T16:54:59.484Z",
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
            }
        ],
        "overallStatus": "Passed",
        "overallScore": 100,
        "totalAttempts": 1,
        "bestScore": 100,
        "averageScore": 100,
        "passRate": 100
    }
}*/
import 'package:equatable/equatable.dart';

class QuizHistoryModel extends Equatable {
  String? id;
  String? userId;
  String? quizId;
  String? quizName;
  int? totalQuestions;
  int? totalAttempts;
  int? bestScore;
  int? averageScore;
  int? passRate;
  String? overallStatus;
  String? createdAt;
  String? updatedAt;
  final List<Question> questions;
  QuizHistoryModel({
    required this.questions,
    this.id,
    this.userId,
    this.quizId,
    this.quizName,
    this.totalQuestions,
    this.totalAttempts,
    this.bestScore,
    this.averageScore,
    this.passRate,
    this.overallStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory QuizHistoryModel.fromJson(Map<String, dynamic> json) {
    return QuizHistoryModel(
      questions: json['history'].map((e) => Question.fromJson(e)).toList(),
      id: json['_id'],
      userId: json['userId'],
      quizId: json['quizId'],
      quizName: json['quizName'],
      totalQuestions: json['totalQuestions'],
      totalAttempts: json['totalAttempts'],
      bestScore: json['bestScore'],
      averageScore: json['averageScore'],
      passRate: json['passRate'],
      overallStatus: json['overallStatus'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
    id,
    userId,
    quizId,
    quizName,
    totalQuestions,
    totalAttempts,
    bestScore,
    averageScore,
    passRate,
    overallStatus,
    createdAt,
    updatedAt,
    questions,
  ];
}

class Question extends Equatable {
  String? question;
  String? correctAnswer;
  String? selectedOption;
  bool? isCorrect;
  Question({
    this.question,
    this.correctAnswer,
    this.selectedOption,
    this.isCorrect,
  });
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      correctAnswer: json['correctAnswer'],
      selectedOption: json['selectedOption'],
      isCorrect: json['isCorrect'],
    );
  }
  @override
  // TODO: implement props
  List<Object?> get props => [
    question,
    correctAnswer,
    selectedOption,
    isCorrect,
  ];
}
