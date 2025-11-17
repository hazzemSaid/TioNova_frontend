// No json helper required here

import 'package:dio/dio.dart';
import 'package:dio/src/response.dart' show Response;
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tionova/features/home/data/datasource/analysis_remote_datasource.dart';
import 'package:tionova/features/home/data/models/analysisModel.dart';
import '../mocks.dart';

void main() {
  group('AnalysisRemoteDataSource', () {
    late MockDio mockDio;
    late AnalysisRemoteDataSourceImpl dataSource;

    setUp(() {
      mockDio = MockDio();
      dataSource = AnalysisRemoteDataSourceImpl(dio: mockDio);
    });

    test('parses analysis JSON successfully', () async {
      final fixture = {
        'data': {
          'userId': 'u1',
          'recentChapters': [],
          'recentFolders': [],
          'lastMindmaps': [],
          'totalChapters': 1,
          'lastSummary': null,
          'avgScore': 10,
          'lastRank': 1,
        }
      };

      when(() => mockDio.get(any()))
          .thenAnswer((_) async => Response(requestOptions: RequestOptions(path: '/'), data: fixture, statusCode: 200));

      final res = await dataSource.fetchAnalysisData();

      expect(res.isRight, true);
      final model = (res as Right).right as Analysismodel;
      expect(model.userId, 'u1');
      expect(model.totalChapters, 1);
    });

    test('returns failure on non-200', () async {
      when(() => mockDio.get(any()))
          .thenAnswer((_) async => Response(requestOptions: RequestOptions(path: '/'), data: {}, statusCode: 500));

      final res = await dataSource.fetchAnalysisData();

      expect(res.isLeft, true);
    });
  });
}
