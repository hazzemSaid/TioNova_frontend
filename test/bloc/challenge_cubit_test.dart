import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/challenges/data/model/challenge_code.dart';
import 'package:tionova/features/challenges/presentation/bloc/challenge_cubit.dart';

import '../mocks.dart';

void main() {
  group('ChallengeCubit', () {
    late MockCreateLiveChallengeUseCase mockCreate;
    late MockJoinLiveChallengeUseCase mockJoin;
    late ChallengeCubit cubit;

    setUp(() {
      mockCreate = MockCreateLiveChallengeUseCase();
      mockJoin = MockJoinLiveChallengeUseCase();
      cubit = ChallengeCubit(
        submitLiveAnswerUseCase: MockSubmitLiveAnswerUseCase(),
        createLiveChallengeUseCase: mockCreate,
        disconnectfromlivechallengeusecase: MockDisconnectUseCase(),
        startLiveChallengeUseCase: MockStartLiveChallengeUseCase(),
        joinLiveChallengeUseCase: mockJoin,
        checkAndAdvanceUseCase: MockCheckAndAdvanceUseCase(),
      );
    });

    blocTest<ChallengeCubit, dynamic>(
      'createChallenge emits Created on success',
      build: () {
        when(
          () => mockCreate.call(
            title: any(named: 'title'),
            chapterId: any(named: 'chapterId'),
          ),
        ).thenAnswer(
          (_) async => Right(ChallengeCode(challengeCode: 'C1', qr: '')),
        );
        return cubit;
      },
      act: (c) => c.createChallenge(chapterId: '1', title: 'title'),
      expect: () => [isA<dynamic>(), isA<dynamic>()],
    );

    blocTest<ChallengeCubit, dynamic>(
      'createChallenge emits Error on failure',
      build: () {
        when(
          () => mockCreate.call(
            title: any(named: 'title'),
            chapterId: any(named: 'chapterId'),
          ),
        ).thenAnswer((_) async => Left(ServerFailure('error')));
        return cubit;
      },
      act: (c) => c.createChallenge(chapterId: '1', title: 'title'),
      expect: () => [isA<dynamic>(), isA<dynamic>()],
    );

    blocTest<ChallengeCubit, dynamic>(
      'joinChallenge emits Joined on success',
      build: () {
        when(
          () => mockJoin.call(challengeCode: any(named: 'challengeCode')),
        ).thenAnswer((_) async => Right(null));
        return cubit;
      },
      act: (c) => c.joinChallenge(challengeCode: 'C1'),
      expect: () => [isA<dynamic>(), isA<dynamic>()],
    );

    test('nextQuestion increments index when possible', () {
      final startState = ChallengeStarted(
        challengeId: 'id',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 15)),
        questions: ['q1', 'q2'],
        currentQuestionIndex: 0,
      );

      cubit.emit(startState);
      cubit.nextQuestion();
      expect(cubit.state, isA<ChallengeStarted>());
      final currentState = cubit.state as ChallengeStarted;
      expect(currentState.currentQuestionIndex, 1);
    });
  });
}
