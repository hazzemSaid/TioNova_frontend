import 'package:tionova/features/challenges/domain/repo/LiveChallenge_repo.dart';

class Disconnectfromlivechallengeusecase {
  final LiveChallengeRepo repository;
  Disconnectfromlivechallengeusecase({required this.repository});
  Future<void> call({required String challengeCode}) {
    return repository.disconnectFromLiveChallenge(challengeCode: challengeCode);
  }
}
