import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/core/utils/error_handling_utils.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/data/models/FileDataModel.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/data/models/mindmapmodel.dart';
import 'package:tionova/features/folder/domain/repo/IChapterRepository.dart';
import 'package:tionova/features/folder/presentation/view/widgets/mind_map_section.dart';

class ChapterRemoteDataSource extends IChapterRepository {
  final Dio _dio;
  ChapterRemoteDataSource(this._dio);
  @override
  Future<Either<Failure, List<ChapterModel>>> getChaptersByFolderId({
    required String folderId,
    required String token,
  }) async {
    try {
      final response = await _dio.get(
        '/getchapters/$folderId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': "Bearer $token",
          },
        ),
      );

      return ErrorHandlingUtils.handleApiResponse<List<ChapterModel>>(
        response: response,
        onSuccess: (data) {
          return (data['chapters'] as List)
              .map((chapterJson) => ChapterModel.fromJson(chapterJson))
              .toList();
        },
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
    }
  }

  @override
  Future<Either<Failure, void>> createChapter({
    required String title,
    required String description,
    required String folderId,
    required String token,
    required FileData file,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'title': title,
        'description': description,
        'folderId': folderId,
        'file': MultipartFile.fromBytes(
          file.bytes,
          filename: file.filename,
          contentType: file.mimeType != null
              ? MediaType.parse(file.mimeType!)
              : MediaType.parse('application/pdf'),
        ),
      });

      final response = await _dio.post(
        '/createchapter',
        data: formData,
        options: Options(headers: {'Authorization': "Bearer $token"}),
      );

      return ErrorHandlingUtils.handleApiResponse<void>(
        response: response,
        onSuccess: (_) => null,
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
    }
  }

  @override
  Future<Either<Failure, Uint8List>> getchapercontentpdf({
    required String token,
    required String chapterId,
  }) async {
    try {
      print('Fetching chapter content for ID: $chapterId');

      final response = await _dio.get(
        '/getchaptercontent/$chapterId',
        options: Options(
          headers: {'Authorization': "Bearer $token"},
          responseType: ResponseType.json, // We expect JSON with Buffer data
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true &&
            responseData['content'] != null) {
          final contentData = responseData['content']['data'];

          if (contentData is List) {
            // Convert List<dynamic> to List<int> then to Uint8List
            final intList = contentData.map((e) => e as int).toList();
            final uint8List = Uint8List.fromList(intList);
            print(
              'Successfully converted PDF data, size: ${uint8List.length} bytes',
            );
            return Right(uint8List);
          } else {
            print('Unexpected content data type: ${contentData.runtimeType}');
            return Left(ServerFailure('Invalid PDF data format received'));
          }
        } else {
          final errorMessage = responseData['message'] ?? 'Unknown error';
          return Left(
            ServerFailure('Failed to fetch chapter content: $errorMessage'),
          );
        }
      } else {
        return Left(
          ServerFailure(
            'Failed to fetch chapter content: ${response.statusMessage}',
          ),
        );
      }
    } catch (e) {
      print('Error fetching chapter content: $e');
      return Left(
        ServerFailure('Error fetching chapter content: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, SummaryResponse>> GenerateSummary({
    required String token,
    required String chapterId,
  }) async {
    print('🔥 DEBUG: GenerateSummary API call started');
    print('📄 Chapter ID: $chapterId');
    print(
      '🔑 Token (first 20 chars): ${token.length > 20 ? token.substring(0, 20) : token}...',
    );

    try {
      print('🌐 Making POST request to /summarizecchapter');

      final response = await _dio.post(
        '/summarizecchapter',
        data: {'chapterId': chapterId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': "Bearer $token",
          },
        ),
      );

      print('✅ Response received - Status: ${response.statusCode}');
      print('📦 Response data keys: ${response.data?.keys}');

      if (response.statusCode == 200) {
        try {
          // Parse the complete response using SummaryResponse.fromJson
          final summaryResponse = SummaryResponse.fromJson(response.data);
          print('📝 Summary parsed successfully');
          print(
            '🔢 Key concepts count: ${summaryResponse.summary.keyConcepts.length}',
          );
          print('� Examples count: ${summaryResponse.summary.examples.length}');
          print(
            '💼 Professional implications count: ${summaryResponse.summary.professionalImplications.length}',
          );
          return Right(summaryResponse);
        } catch (parseError) {
          print('💥 Error parsing summary response: $parseError');
          return Left(
            ServerFailure('Failed to parse summary response: $parseError'),
          );
        }
      } else {
        print('❌ Non-200 status code: ${response.statusCode}');
        return Left(
          ServerFailure(
            'Failed to generate summary - Status: ${response.statusCode}',
          ),
        );
      }
    } catch (e) {
      print('💥 Exception in GenerateSummary: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Mindmapmodel>> createMindmap({
    required String token,
    required String chapterId,
  }) async {
    try {
      final response = await _dio.post(
        '/createmindmap',
        data: {'chapterId': chapterId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': "Bearer $token",
          },
        ),
      );
      return ErrorHandlingUtils.handleApiResponse<Mindmapmodel>(
        response: response,
        onSuccess: (data) {
          return Mindmapmodel.fromJson(data['data']);
        },
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
    }
  }
}
