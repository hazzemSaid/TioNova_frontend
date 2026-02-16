part of 'challenge_cubit.dart';

abstract class ChallengeState extends Equatable {
  const ChallengeState();

  @override
  List<Object?> get props => [];
}

class ChallengeInitial extends ChallengeState {}

// Loading States
class ChallengeLoading extends ChallengeState {}

// Create Challenge States
class ChallengeCreated extends ChallengeState {
  final String inviteCode;
  final String challengeName;
  final int questionsCount;
  final int durationMinutes;
  final ChapterModel? chapterContext; // Added chapter context

  const ChallengeCreated({
    required this.inviteCode,
    required this.challengeName,
    required this.questionsCount,
    required this.durationMinutes,
    this.chapterContext,
  });

  @override
  List<Object?> get props => [
    inviteCode,
    challengeName,
    questionsCount,
    durationMinutes,
    chapterContext,
  ];
}

// Join Challenge States
class ChallengeJoined extends ChallengeState {
  final String challengeId;
  final String participantId;
  final String challengeName;
  final int questionsCount;
  final int durationMinutes;
  final List<String> participants;

  const ChallengeJoined({
    required this.challengeId,
    required this.participantId,
    required this.challengeName,
    required this.questionsCount,
    required this.durationMinutes,
    required this.participants,
  });

  @override
  List<Object?> get props => [
    challengeId,
    participantId,
    challengeName,
    questionsCount,
    durationMinutes,
    participants,
  ];
}

// Start Challenge States
class ChallengeStarted extends ChallengeState {
  final String challengeId;
  final DateTime startTime;
  final DateTime endTime;
  final List<dynamic> questions;
  final int currentQuestionIndex;

  const ChallengeStarted({
    required this.challengeId,
    required this.startTime,
    required this.endTime,
    required this.questions,
    this.currentQuestionIndex = 0,
  });

  @override
  List<Object?> get props => [
    challengeId,
    startTime,
    endTime,
    questions,
    currentQuestionIndex,
  ];

  ChallengeStarted copyWith({
    String? challengeId,
    DateTime? startTime,
    DateTime? endTime,
    List<dynamic>? questions,
    int? currentQuestionIndex,
  }) {
    return ChallengeStarted(
      challengeId: challengeId ?? this.challengeId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
    );
  }
}

// Submit Answer States
class AnswerSubmitted extends ChallengeState {
  final String challengeId;
  final int questionIndex;
  final String selectedAnswer;
  final bool isCorrect;
  final int currentScore;

  const AnswerSubmitted({
    required this.challengeId,
    required this.questionIndex,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.currentScore,
  });

  @override
  List<Object?> get props => [
    challengeId,
    questionIndex,
    selectedAnswer,
    isCorrect,
    currentScore,
  ];
}

// Challenge Completed State
class ChallengeCompleted extends ChallengeState {
  final String challengeId;
  final int finalScore;
  final int correctAnswers;
  final int totalQuestions;
  final double accuracy;
  final int rank;
  final List<dynamic> leaderboard;

  const ChallengeCompleted({
    required this.challengeId,
    required this.finalScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.accuracy,
    required this.rank,
    required this.leaderboard,
  });

  @override
  List<Object?> get props => [
    challengeId,
    finalScore,
    correctAnswers,
    totalQuestions,
    accuracy,
    rank,
    leaderboard,
  ];
}

// Disconnect State
class ChallengeDisconnected extends ChallengeState {
  final String message;

  const ChallengeDisconnected({this.message = 'Disconnected from challenge'});

  @override
  List<Object?> get props => [message];
}

// Error State
class ChallengeError extends ChallengeState {
  final String message;

  const ChallengeError(this.message);

  @override
  List<Object?> get props => [message];
}

// Real-time Update States
class ParticipantsUpdated extends ChallengeState {
  final String challengeId;
  final List<String> participants;
  final int participantCount;
  final bool canStartChallenge; // Added validation flag

  const ParticipantsUpdated({
    required this.challengeId,
    required this.participants,
    required this.participantCount,
    required this.canStartChallenge,
  });

  @override
  List<Object?> get props => [
    challengeId,
    participants,
    participantCount,
    canStartChallenge,
  ];
}

class LeaderboardUpdated extends ChallengeState {
  final String challengeId;
  final List<dynamic> leaderboard;

  const LeaderboardUpdated({
    required this.challengeId,
    required this.leaderboard,
  });

  @override
  List<Object?> get props => [challengeId, leaderboard];
}
