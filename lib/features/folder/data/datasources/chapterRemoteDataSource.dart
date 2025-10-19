import 'dart:convert'; // For base64Decode and jsonEncode
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/core/utils/error_handling_utils.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/data/models/FileDataModel.dart';
import 'package:tionova/features/folder/data/models/NoteModel.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/data/models/mindmapmodel.dart';
import 'package:tionova/features/folder/domain/repo/IChapterRepository.dart';

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
  // Helper method to recursively sanitize all strings in a JSON object
  dynamic _sanitizeJsonData(dynamic data) {
    if (data == null) return null;

    if (data is String) {
      try {
        // Remove invalid UTF-8 characters
        final bytes = utf8.encode(data);
        return utf8.decode(bytes, allowMalformed: true);
      } catch (e) {
        // If encoding fails, replace problematic characters
        return data.replaceAll(RegExp(r'[^\x00-\x7F]+'), '');
      }
    } else if (data is Map) {
      // Convert to Map<String, dynamic> explicitly
      final Map<String, dynamic> sanitizedMap = {};
      data.forEach((key, value) {
        final sanitizedKey = key is String
            ? _sanitizeJsonData(key) as String
            : key.toString();
        sanitizedMap[sanitizedKey] = _sanitizeJsonData(value);
      });
      return sanitizedMap;
    } else if (data is List) {
      return data.map((item) => _sanitizeJsonData(item)).toList();
    }

    return data;
  }

  Future<Either<Failure, SummaryResponse>> GenerateSummary({
    required String token,
    required String chapterId,
  }) async {
    print('DEBUG: GenerateSummary API call started');
    print('Chapter ID: $chapterId');
    print(
      'Token (first 20 chars): ${token.length > 20 ? token.substring(0, 20) : token}...',
    );

    try {
      print('Making POST request to /summarizecchapter');

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

      print('Response received - Status: ${response.statusCode}');
      print('Response data keys: ${response.data?.keys}');

      if (response.statusCode == 200) {
        try {
          // Sanitize the response data before parsing
          final sanitizedData = _sanitizeJsonData(response.data);

          // Parse the complete response using SummaryResponse.fromJson
          final summaryResponse = SummaryResponse.fromJson(sanitizedData);
          print('Summary parsed successfully');
          print(
            'Key concepts count: ${summaryResponse.summary.keyConcepts.length}',
          );
          print('Examples count: ${summaryResponse.summary.examples.length}');
          print(
            'Professional implications count: ${summaryResponse.summary.professionalImplications.length}',
          );
          return Right(summaryResponse);
        } catch (parseError) {
          print('Error parsing summary response: $parseError');
          return Left(
            ServerFailure('Failed to parse summary response: $parseError'),
          );
        }
      } else {
        print('Non-200 status code: ${response.statusCode}');
        return Left(
          ServerFailure(
            'Failed to generate summary - Status: ${response.statusCode}',
          ),
        );
      }
    } catch (e) {
      print('Exception in GenerateSummary: $e');
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

  @override
  Future<Either<Failure, Notemodel>> addNote({
    required String title,
    required String chapterId,
    required String token,
    required Map<String, dynamic> rawData,
  }) async {
    /**
     * Add a new note
     * Routes based on type:
     * - POST /notes/text (for text notes)
     * - POST /notes/image (for image notes with file upload)
     * - POST /notes/voice (for voice notes with file upload)
     */
    try {
      final noteType = rawData['type'] as String?;

      if (noteType == null || noteType.isEmpty) {
        return Left(ServerFailure('Note type is required'));
      }

      Response response;

      switch (noteType) {
        case 'text':
          // Text notes: Send as JSON
          response = await _dio.post(
            '/notes/text',
            data: {'title': title, 'chapterId': chapterId, 'rawData': rawData},
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Authorization': "Bearer $token",
              },
            ),
          );
          break;

        case 'image':
          // Image notes: Send as multipart with file upload
          final imageData = rawData['data'] as String?;
          if (imageData == null || imageData.isEmpty) {
            return Left(ServerFailure('Image data is required'));
          }

          // Decode base64 to bytes
          final bytes = base64Decode(
            imageData.contains(',') ? imageData.split(',').last : imageData,
          );

          final formData = FormData.fromMap({
            'title': title,
            'chapterId': chapterId,
            'file': MultipartFile.fromBytes(
              bytes,
              filename: rawData['meta']?['fileName'] ?? 'image.jpg',
              contentType: MediaType.parse('image/jpeg'),
            ),
            // Send meta as JSON string if present
            if (rawData['meta'] != null) 'meta': jsonEncode(rawData['meta']),
          });

          response = await _dio.post(
            '/notes/image',
            data: formData,
            options: Options(headers: {'Authorization': "Bearer $token"}),
          );
          break;

        case 'voice':
          // Voice notes: Send as multipart with file upload
          final voiceData = rawData['data'] as String?;
          if (voiceData == null || voiceData.isEmpty) {
            return Left(ServerFailure('Voice data is required'));
          }

          // Decode base64 to bytes
          final bytes = base64Decode(
            voiceData.contains(',') ? voiceData.split(',').last : voiceData,
          );

          final formData = FormData.fromMap({
            'title': title,
            'chapterId': chapterId,
            'file': MultipartFile.fromBytes(
              bytes,
              filename: rawData['meta']?['fileName'] ?? 'voice.aac',
              contentType: MediaType.parse('audio/aac'),
            ),
            // Send meta as JSON string if present
            if (rawData['meta'] != null) 'meta': jsonEncode(rawData['meta']),
          });

          response = await _dio.post(
            '/notes/voice',
            data: formData,
            options: Options(headers: {'Authorization': "Bearer $token"}),
          );
          break;

        default:
          return Left(
            ServerFailure(
              'Invalid note type: $noteType. Must be text, image, or voice',
            ),
          );
      }

      return ErrorHandlingUtils.handleApiResponse<Notemodel>(
        response: response,
        onSuccess: (data) {
          // Response structure: { status: "success", data: { note: {...} } }
          return Notemodel.fromJson(
            data['data']['note'] as Map<String, dynamic>,
          );
        },
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote({
    required String noteId,
    required String token,
  }) async {
    // * Delete a note
    //  * @route DELETE /api/notes/:noteId
    try {
      final response = await _dio.delete(
        '/notes/$noteId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': "Bearer $token",
          },
        ),
      );

      return ErrorHandlingUtils.handleApiResponse<void>(
        response: response,
        onSuccess: (data) {
          print('✅ Note deleted successfully');
          return null;
        },
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
    }
  }

  @override
  Future<Either<Failure, List<Notemodel>>> getNotesByChapterId({
    required String chapterId,
    required String token,
  }) async {
    ///notes/chapter/:chapterId
    try {
      final response = await _dio.get(
        '/notes/chapter/$chapterId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': "Bearer $token",
          },
        ),
      );

      return ErrorHandlingUtils.handleApiResponse<List<Notemodel>>(
        response: response,
        onSuccess: (data) {
          // Response structure: { status: "success", data: { notes: [...], count: 5 } }
          final notesData = data['data']['notes'] as List;
          return notesData
              .map(
                (noteJson) =>
                    Notemodel.fromJson(noteJson as Map<String, dynamic>),
              )
              .toList();
        },
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
    }
  }
}
