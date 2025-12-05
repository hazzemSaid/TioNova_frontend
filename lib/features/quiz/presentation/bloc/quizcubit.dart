// features/quiz/presentation/bloc/quizcubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/utils/safe_emit.dart';
import 'package:tionova/features/quiz/domain/usecases/CreateQuizUseCase.dart';
import 'package:tionova/features/quiz/domain/usecases/GetHistoryUseCase.dart';
import 'package:tionova/features/quiz/domain/usecases/UserQuizStatusUseCase.dart';
import 'package:tionova/features/quiz/domain/usecases/GetPracticeModeQuestionsUseCase.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizstate.dart';
import 'package:tionova/features/quiz/data/models/PracticeModeQuizModel.dart';

class QuizCubit extends Cubit<QuizState> {
  QuizCubit({
    required this.createQuizUseCase,
    required this.userQuizStatusUseCase,
    required this.getHistoryUseCase,
    required this.getPracticeModeQuestionsUseCase,
  }) : super(QuizInitial());

  final GetHistoryUseCase getHistoryUseCase;
  final CreateQuizUseCase createQuizUseCase;
  final UserQuizStatusUseCase userQuizStatusUseCase;
  final GetPracticeModeQuestionsUseCase getPracticeModeQuestionsUseCase;

  // Practice Mode state tracking
  PracticeModeQuizModel? _currentPracticeQuiz;
  int _currentQuestionIndex = 0;
  int _correctCount = 0;
  String? _selectedAnswer;

  void createQuiz({required String chapterId}) async {
    safeEmit(CreateQuizLoading());
    final result = await createQuizUseCase.call(chapterId: chapterId);
    result.fold(
      (failure) => safeEmit(CreateQuizFailure(failure: failure)),
      (quiz) => safeEmit(CreateQuizSuccess(quiz: quiz)),
    );
  }

  void setuserquizstatus({
    required String quizId,
    required Map<String, dynamic> body,
    required String chapterId,
  }) async {
    safeEmit(UserQuizStatusLoading());
    final result = await userQuizStatusUseCase.call(
      quizId: quizId,
      body: body,
      chapterId: chapterId,
    );
    result.fold(
      (failure) => safeEmit(UserQuizStatusFailure(failure: failure)),
      (status) => safeEmit(UserQuizStatusSuccess(status: status)),
    );
  }

  void gethistory({required String chapterId}) async {
    safeEmit(GetHistoryLoading());
    final result = await getHistoryUseCase.call(chapterId: chapterId);
    result.fold(
      (failure) => safeEmit(GetHistoryFailure(failure: failure)),
      (history) => safeEmit(GetHistorySuccess(history: history)),
    );
  }

  // Practice Mode Methods
  void getPracticeMode({required String chapterId}) async {
    safeEmit(PracticeModeLoading());
    final result = await getPracticeModeQuestionsUseCase.call(
      chapterId: chapterId,
    );
    result.fold((failure) => safeEmit(PracticeModeFailure(failure: failure)), (
      quiz,
    ) {
      _currentPracticeQuiz = quiz;
      _currentQuestionIndex = 0;
      _correctCount = 0;
      _selectedAnswer = null;
      safeEmit(
        PracticeModeReady(quiz: quiz, currentQuestionIndex: 0, correctCount: 0),
      );
    });
  }

  void selectPracticeAnswer(String answer) {
    if (_currentPracticeQuiz == null) return;

    _selectedAnswer = answer;
    safeEmit(
      PracticeModeAnswerSelected(
        quiz: _currentPracticeQuiz!,
        currentQuestionIndex: _currentQuestionIndex,
        selectedAnswer: answer,
        correctCount: _correctCount,
      ),
    );
  }

  void checkPracticeAnswer() {
    if (_currentPracticeQuiz == null || _selectedAnswer == null) return;

    final currentQuestion =
        _currentPracticeQuiz!.questions[_currentQuestionIndex];
    final isCorrect = _selectedAnswer == currentQuestion.answer;

    if (isCorrect) {
      _correctCount++;
    }

    safeEmit(
      PracticeModeAnswerChecked(
        quiz: _currentPracticeQuiz!,
        currentQuestionIndex: _currentQuestionIndex,
        selectedAnswer: _selectedAnswer!,
        isCorrect: isCorrect,
        correctAnswer: currentQuestion.answer,
        explanation: currentQuestion.explanation,
        correctCount: _correctCount,
      ),
    );
  }

  void nextPracticeQuestion() {
    if (_currentPracticeQuiz == null) return;

    _currentQuestionIndex++;
    _selectedAnswer = null;

    if (_currentQuestionIndex >= _currentPracticeQuiz!.questions.length) {
      // Practice session complete
      safeEmit(
        PracticeModeComplete(
          totalQuestions: _currentPracticeQuiz!.questions.length,
          correctCount: _correctCount,
        ),
      );
    } else {
      // Move to next question
      safeEmit(
        PracticeModeReady(
          quiz: _currentPracticeQuiz!,
          currentQuestionIndex: _currentQuestionIndex,
          correctCount: _correctCount,
        ),
      );
    }
  }

  void resetPracticeMode() {
    _currentPracticeQuiz = null;
    _currentQuestionIndex = 0;
    _correctCount = 0;
    _selectedAnswer = null;
    safeEmit(QuizInitial());
  }
}
