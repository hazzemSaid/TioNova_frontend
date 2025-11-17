import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:either_dart/either.dart';
import 'package:tionova/features/challenges/data/datasource/remote_Livechallenge_datasource.dart';
import 'package:tionova/features/challenges/data/model/challenge_code.dart';
import '../mocks.dart';

void main() {
  group('RemoteLiveChallengeDataSource', () {
    late MockDio mockDio;
    late RemoteLiveChallengeDataSource ds;

    setUp(() {
      mockDio = MockDio();
      ds = RemoteLiveChallengeDataSource(dio: mockDio);
    });

    test('createLiveChallenge returns ChallengeCode on 200', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: '/'), data: {'challengeCode': 'C1', 'qr': 'base64'}, statusCode: 200),
      );

      final res = await ds.createLiveChallenge(title: 't', chapterId: '1');
      expect(res.isRight, true);
      final code = (res as Right).right as ChallengeCode;
      expect(code.challengeCode, 'C1');
    });

    test('createLiveChallenge returns Left on error', () async {
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(requestOptions: RequestOptions(path: '/'), data: {'message': 'err'}, statusCode: 500));

      final res = await ds.createLiveChallenge(title: 't', chapterId: '1');
      expect(res.isLeft, true);
    });
  });
}
