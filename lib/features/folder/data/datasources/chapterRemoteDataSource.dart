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
  }) async {
    try {
      final response = await _dio.get(
        '/getchapters/$folderId',
        options: Options(headers: {'Content-Type': 'application/json'}),
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
    required FileData file,
  }) async {
    try {
      print('🟢 [DataSource] createChapter() started');
      print(
        '📄 File details: ${file.filename}, size: ${file.bytes.length} bytes, mimeType: ${file.mimeType}',
      );

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

      print(
        '📦 [DataSource] FormData created, making POST request to /createchapter...',
      );
      final response = await _dio.post('/createchapter', data: formData);
      print('✅ [DataSource] POST response received: ${response.statusCode}');

      return ErrorHandlingUtils.handleApiResponse<void>(
        response: response,
        onSuccess: (_) {
          print('✅ [DataSource] createChapter success');
          return null;
        },
      );
    } catch (e) {
      print('❌ [DataSource] Exception in createChapter: $e');
      return ErrorHandlingUtils.handleDioError(e);
    }
  }

  @override
  Future<Either<Failure, Uint8List>> getchapercontentpdf({
    required String chapterId,
  }) async {
    try {
      print('Fetching chapter content for ID: $chapterId');

      final response = await _dio.get(
        '/getchaptercontent/$chapterId',
        options: Options(
          responseType: ResponseType.json, // We expect JSON with Buffer data
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Ensure responseData is a Map before accessing it
        if (responseData is! Map<String, dynamic>) {
          print('Unexpected response data type: ${responseData.runtimeType}');
          return Left(
            ServerFailure(
              'Invalid response format: expected Map, got ${responseData.runtimeType}',
            ),
          );
        }

        // Safely access nested properties
        final success = responseData['success'];
        final content = responseData['content'];

        if (success == true && content != null) {
          // Ensure content is a Map before accessing 'data'
          if (content is! Map<String, dynamic>) {
            print('Unexpected content type: ${content.runtimeType}');
            return Left(
              ServerFailure(
                'Invalid content format: expected Map, got ${content.runtimeType}',
              ),
            );
          }

          final contentData = content['data'];

          if (contentData is List) {
            // Convert List<dynamic> to List<int> then to Uint8List
            // Handle both int and String (for base64 or string-encoded numbers)
            try {
              final intList = contentData.map((e) {
                if (e is int) {
                  return e;
                } else if (e is String) {
                  // Try to parse string as int
                  return int.parse(e);
                } else if (e is num) {
                  return e.toInt();
                } else {
                  throw FormatException('Cannot convert $e to int');
                }
              }).toList();
              final uint8List = Uint8List.fromList(intList);
              print(
                'Successfully converted PDF data, size: ${uint8List.length} bytes',
              );
              return Right(uint8List);
            } catch (e) {
              print('Error converting content data to Uint8List: $e');
              return Left(
                ServerFailure(
                  'Failed to convert PDF data: ${e.toString()}',
                ),
              );
            }
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

  // Helper method to recursively sanitize all strings in a JSON object
  dynamic _sanitizeJsonData(dynamic data) {
    if (data == null) return null;

    if (data is String) {
      try {
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
    required String chapterId,
  }) async {
    print('DEBUG: GenerateSummary API call started');
    print('Chapter ID: $chapterId');

    try {
      print('Making POST request to /summarizecchapter');

      final response = await _dio.post(
        '/summarizecchapter',
        data: {'chapterId': chapterId},
        options: Options(headers: {'Content-Type': 'application/json'}),
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
    required String chapterId,
  }) async {
    try {
      final response = await _dio.post(
        '/createmindmap',
        data: {'chapterId': chapterId},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return ErrorHandlingUtils.handleApiResponse<Mindmapmodel>(
        response: response,
        onSuccess: (data) {
          return Mindmapmodel.fromJson(data['data'] as Map<String, dynamic>);
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
            options: Options(headers: {'Content-Type': 'application/json'}),
          );
          break;

        case 'image':
          // Image notes: Send as multipart with file upload
          final imageData = rawData['data'] as String?;
          if (imageData == null || imageData.isEmpty) {}

          // Decode base64 to bytes
          final bytes = base64Decode(
            imageData!.contains(',') ? imageData.split(',').last : imageData,
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

          response = await _dio.post('/notes/image', data: formData);
          break;

        case 'voice':
          // Voice notes: Send as multipart with file upload
          final voiceData = rawData['data'] as String?;
          if (voiceData == null || voiceData.isEmpty) {
            return Left(ServerFailure('Voice data is required'));
          }

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

          response = await _dio.post('/notes/voice', data: formData);
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
  Future<Either<Failure, void>> deleteNote({required String noteId}) async {
    // * Delete a note
    //  * @route DELETE /api/notes/:noteId
    try {
      final response = await _dio.delete(
        '/notes/$noteId',
        options: Options(headers: {'Content-Type': 'application/json'}),
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
  }) async {
    ///notes/chapter/:chapterId
    try {
      final response = await _dio.get(
        '/notes/chapter/$chapterId',
        options: Options(headers: {'Content-Type': 'application/json'}),
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
