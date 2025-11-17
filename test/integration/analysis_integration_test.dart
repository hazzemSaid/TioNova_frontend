import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tionova/features/home/data/datasource/analysis_remote_datasource.dart';

void main() {
  final runIntegration = Platform.environment['RUN_INTEGRATION_TEST'] == 'true';

  test('Integration: fetch analysis from real backend', () async {
    if (!runIntegration) {
      // Skip by default - set RUN_INTEGRATION_TEST=true to enable
      return;
    }

    final baseUrl = Platform.environment['API_BASE_URL'] ?? 'http://localhost:3000/api/v1';
    final dio = Dio(BaseOptions(baseUrl: baseUrl));
    final token = Platform.environment['AUTH_TOKEN'];
    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
    final ds = AnalysisRemoteDataSourceImpl(dio: dio);

    final response = await ds.fetchAnalysisData();
    expect(response.isRight, true, reason: 'Ensure backend returns expected analysis JSON');
  });
}
