import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/challenges/domain/repo/LiveChallenge_repo.dart';

/// Use case for checking if all players have answered and advancing to next question
class CheckAndAdvanceUseCase {
  final LiveChallengeRepo liveChallengeRepo;

  CheckAndAdvanceUseCase({required this.liveChallengeRepo});

  /// Check if all participants answered and advance if needed
  /// Returns: { needsAdvance, advanced, completed, timeRemaining, currentIndex }
  Future<Either<Failure, Map<String, dynamic>>> call({
    required String challengeCode,
  }) async {
    return await liveChallengeRepo.checkAndAdvance(
      challengeCode: challengeCode,
    );
  }
}
