import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/challenges/data/model/challenge_code.dart';

abstract class LiveChallengeRepo {
  /*API: POST /createLiveChallenge

Response: { challengeCode, qr, questions } */
  Future<Either<Failure, ChallengeCode>> createLiveChallenge({
    required String title,
    required String chapterId,
  });
  /*API: POST /joinLiveChallenge

Body: { challengeCode }

If reconnected: isReconnection: true*/
  Future<Either<Failure, void>> joinLiveChallenge({
    required String challengeCode,
    bool isReconnection = false,
  });
  /*Step 4: Start Challenge (Owner Only)

API: POST /startLiveChallenge

Changes meta.status → in-progress

Sets current.index = 0  tip this part for owner only*/
  Future<Either<Failure, void>> startLiveChallenge({
    required String challengeCode,
  });
  /*API: POST /api/v1/live/challenges/answer

Body: { challengeCode: string, answer: string }

Auth: required

Returns: { success, message, isCorrect, currentIndex, rankings }*/
  Future<Either<Failure, void>> submitLiveAnswer({
    required String challengeCode,
    required String answer,
  });
  /*API (on app pause): POST /disconnectFromLiveChallenge

On reconnect → joinLiveChallenge (will resume from current index)*/
  Future<Either<Failure, void>> disconnectFromLiveChallenge({
    required String challengeCode,
  });

  /*API: POST /api/v1/live/challenges/check-advance

Body: { challengeCode: string }

Auth: required

Returns: { needsAdvance, advanced, completed, timeRemaining, currentIndex }

Behavior: Checks if all players answered, advances to next question if needed*/
  Future<Either<Failure, Map<String, dynamic>>> checkAndAdvance({
    required String challengeCode,
  });
}
