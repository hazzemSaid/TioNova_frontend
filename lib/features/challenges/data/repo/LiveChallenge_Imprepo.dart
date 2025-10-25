import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/challenges/data/datasource/remote_Livechallenge_datasource.dart';
import 'package:tionova/features/challenges/data/model/challenge_code.dart';
import 'package:tionova/features/challenges/domain/repo/LiveChallenge_repo.dart';

class LiveChallengeImpRepo implements LiveChallengeRepo {
  final RemoteLiveChallengeDataSource remoteDataSource;

  LiveChallengeImpRepo({required this.remoteDataSource});

  @override
  Future<Either<Failure, ChallengeCode>> createLiveChallenge({
    required String token,
    required String title,
    required String chapterId,
  }) {
    return remoteDataSource.createLiveChallenge(
      token: token,
      title: title,
      chapterId: chapterId,
    );
  }

  @override
  Future<Either<Failure, void>> disconnectFromLiveChallenge({
    required String token,
    required String challengeCode,
  }) {
    return remoteDataSource.disconnectFromLiveChallenge(
      token: token,
      challengeCode: challengeCode,
    );
  }

  @override
  Future<Either<Failure, void>> joinLiveChallenge({
    required String token,
    required String challengeCode,
    bool isReconnection = false,
  }) {
    return remoteDataSource.joinLiveChallenge(
      token: token,
      challengeCode: challengeCode,
      isReconnection: isReconnection,
    );
  }

  @override
  Future<Either<Failure, void>> startLiveChallenge({
    required String token,
    required String challengeCode,
  }) {
    return remoteDataSource.startLiveChallenge(
      token: token,
      challengeCode: challengeCode,
    );
  }

  @override
  Future<Either<Failure, void>> submitLiveAnswer({
    required String token,
    required String challengeCode,
    required String answer,
  }) {
    return remoteDataSource.submitLiveAnswer(
      token: token,
      challengeCode: challengeCode,
      answer: answer,
    );
  }
}
