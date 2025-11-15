import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/challenges/domain/repo/LiveChallenge_repo.dart';

class StartLiveChallengeUseCase {
  final LiveChallengeRepo repository;
  StartLiveChallengeUseCase({required this.repository});
  Future<Either<Failure, void>> call({required String challengeCode}) {
    return repository.startLiveChallenge(challengeCode: challengeCode);
  }
}
