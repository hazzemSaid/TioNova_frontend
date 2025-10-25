import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/challenges/domain/repo/LiveChallenge_repo.dart';

class SubmitLiveAnswerUseCase {
  final LiveChallengeRepo repository;
  SubmitLiveAnswerUseCase({required this.repository});
  Future<Either<Failure, void>> call({
    required String token,
    required String challengeCode,
    required String answer,
  }) {
    return repository.submitLiveAnswer(
      token: token,
      challengeCode: challengeCode,
      answer: answer,
    );
  }
}
