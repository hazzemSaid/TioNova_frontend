import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tionova/features/home/data/datasource/analysis_remote_datasource.dart';

/// Simple CLI script to call the /analysis API and print parsed data.
///
/// Usage (PowerShell / cmd):
///   setx API_BASE_URL "http://yourserver:3000/api/v1"
///   setx AUTH_TOKEN "your_jwt"
///   dart run bin/fetch_analysis.dart
///
/// Or set env vars inline:
///   API_BASE_URL=http://localhost:3000/api/v1 AUTH_TOKEN=abc123 dart run bin/fetch_analysis.dart

Future<void> main() async {
  final baseUrl =
      Platform.environment['API_BASE_URL'] ??
      'https://tio-nova-backend.vercel.app/api/v1';
  final token =
      Platform.environment['AUTH_TOKEN'] ??
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImhhYXplbXNhaWRkQGdtYWlsLmNvbSIsIl9pZCI6IjY5MTZjY2RlYzc2Y2E5ZmY2MzI3OGM2YyIsInJvbGUiOiJ1c2VyIiwidXNlcm5hbWUiOiJoYXplbSIsImlhdCI6MTc2MzM4NjE0OSwiZXhwIjoxNzYzMzg5NzQ5fQ.84v33NeVJ4S_nWpxysk0YIOdAE-APCdsVSfBOA4mvrs";

  final dio = Dio(BaseOptions(baseUrl: baseUrl));
  if (token != null && token.isNotEmpty) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  final ds = AnalysisRemoteDataSourceImpl(dio: dio);
  print('Calling $baseUrl/analysis ...');
  final result = await ds.fetchAnalysisData();

  result.fold(
    (failure) {
      print('ERROR: ${failure.errMessage}');
    },
    (analysis) {
      print('Success — parsed analysis for userId: ${analysis.userId}');
      print('Total chapters: ${analysis.totalChapters}');
      print('Avg Score: ${analysis.avgScore}');
    },
  );
}
