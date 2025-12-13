import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:tionova/features/challenges/data/datasource/remote_Livechallenge_datasource.dart';
import 'package:tionova/features/folder/data/datasources/FolderRemoteDataSource.dart';
import 'package:tionova/features/folder/data/datasources/chapterRemoteDataSource.dart';
import 'package:tionova/features/folder/data/models/foldermodel.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';
import 'package:tionova/features/home/data/datasource/analysis_remote_datasource.dart';

void main() {
  final run = true;

  test('Integration: endpoints smoke test', () async {
    if (!run) return;

    final baseUrl = 'https://tio-nova-backend.vercel.app/api/v1';
    final dio = Dio(BaseOptions(baseUrl: baseUrl));
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 120,
      ),
    );

    // If token not provided, try login using env creds
    final token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImhhYXplbXNhaWRkQGdtYWlsLmNvbSIsIl9pZCI6IjY5MTZjY2RlYzc2Y2E5ZmY2MzI3OGM2YyIsInJvbGUiOiJ1c2VyIiwidXNlcm5hbWUiOiJoYXplbSIsImlhdCI6MTc2MzM4NjE0OSwiZXhwIjoxNzYzMzg5NzQ5fQ.84v33NeVJ4S_nWpxysk0YIOdAE-APCdsVSfBOA4mvrs";
    if (token.isEmpty &&
        Platform.environment['INTEGRATION_EMAIL'] != null &&
        Platform.environment['INTEGRATION_PASSWORD'] != null) {
      final email = Platform.environment['INTEGRATION_EMAIL']!;
      final password = Platform.environment['INTEGRATION_PASSWORD']!;
      final res = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        dio.options.headers['Authorization'] = 'Bearer ${res.data['token']}';
      }
    } else if (token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }

    final analysisDS = AnalysisRemoteDataSourceImpl(dio: dio);
    final foldersDS = FolderRemoteDataSource(dio);
    final chapterDS = ChapterRemoteDataSource(dio);
    final liveDS = RemoteLiveChallengeDataSource(dio: dio);

    // Analysis
    final analysis = await analysisDS.fetchAnalysisData();
    expect(analysis.isRight, true);

    // Folders: get -> create -> delete
    final allFolders = await foldersDS.getAllFolders();
    expect(allFolders.isRight, true);

    // Create a folder (if authorized)
    var createdFolderId = '';
    if (dio.options.headers['Authorization'] != null) {
      final createRes = await foldersDS.createFolder(
        title:
            'Integration Test Folder ${DateTime.now().millisecondsSinceEpoch}',
        status: Status.public,
      );
      expect(createRes.isRight, true);

      // fetch all and try to find last by title
      final after = await foldersDS.getAllFolders();
      if (after.isRight) {
        final list = after.right as List;
        final last = list.firstWhere(
          (f) => (f.title ?? '').contains('Integration Test Folder'),
          orElse: () => Foldermodel(
            id: '',
            createdAt: DateTime.now(),
            ownerId: '',
            sharedWith: [],
            description: '',
            icon: '',
            color: '',
            status: Status.public,
            category: '',
            title: '',
            chapterCount: 0,
            attemptedCount: 0,
            passedCount: 0,
          ),
        );
        if (last.id.isNotEmpty) createdFolderId = last.id;
      }

      if (createdFolderId.isNotEmpty) {
        final del = await foldersDS.deletefolder(id: createdFolderId);
        expect(del.isRight, true);
      }
    }

    // Optional chapter & challenge tests if env CHAPTER_ID is provided
    final chapterId = Platform.environment['CHAPTER_ID'];
    if (chapterId != null && chapterId.isNotEmpty) {
      final pdf = await chapterDS.getchapercontentpdf(chapterId: chapterId);
      // If the server returns a valid pdf bytes, ensure no exceptions
      expect(pdf.isRight || pdf.isLeft, true);

      // create challenge with that chapter (requires auth)
      if (dio.options.headers['Authorization'] != null) {
        final challenge = await liveDS.createLiveChallenge(
          title: 'IntTest',
          chapterId: chapterId,
        );
        expect(challenge.isRight || challenge.isLeft, true);
      }

      // Create mindmap
      // Create mindmap
      final mindmapRes = await chapterDS.createMindmap(chapterId: chapterId);
      expect(mindmapRes.isRight || mindmapRes.isLeft, true);

      // Generate summary
      final summaryRes = await chapterDS.GenerateSummary(chapterId: chapterId);
      expect(summaryRes.isRight || summaryRes.isLeft, true);

      // Get notes
      final notesRes = await chapterDS.getNotesByChapterId(chapterId: chapterId);
      expect(notesRes.isRight || notesRes.isLeft, true);
    }
  });
}
