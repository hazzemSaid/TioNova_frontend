import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/challenges/data/model/challenge_code.dart';
import 'package:tionova/features/challenges/domain/repo/LiveChallenge_repo.dart';

class CreateLiveChallengeUseCase {
  final LiveChallengeRepo repository;

  CreateLiveChallengeUseCase({required this.repository});
  Future<Either<Failure, ChallengeCode>> call({
    required String title,
    required String chapterId,
  }) {
    return repository.createLiveChallenge(title: title, chapterId: chapterId);
  }
}
