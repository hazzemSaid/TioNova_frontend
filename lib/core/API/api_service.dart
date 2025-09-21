import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api_config.dart';

/// Custom exception for no internet connection
class NoInternetConnectionException implements Exception {
  final String message;

  NoInternetConnectionException(this.message);

  @override
  String toString() => message;
}

/// Custom exception for handling 404 errors
class NotFoundException implements Exception {
  final String message;

  NotFoundException(this.message);

  @override
  String toString() => message;
}

class APIService {
  //            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2ODcyM2ZiM2ZjODI1ZDExMTc2ODVkNzciLCJ1c2VyTmFtZSI6InlvdXNzZWYiLCJyb2xlIjoib3duZXIiLCJpYXQiOjE3NTMyNjk4OTYsImV4cCI6MTc1NTg2MTg5Nn0.EbhCEtpWrnZmGYdt2ozmTwfjysK9geqWY2XD97YH0A4'

  static String Token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2OGFlYzA4ODExNjc1YzE4ZTMxNTZkNTUiLCJ1c2VyTmFtZSI6IkF1dm5ldCIsInJvbGUiOiJvd25lciIsInN1YnNjcmlwdGlvbkVuZERhdGUiOiIyMDI2LTA2LTAxVDAwOjAwOjAwLjAwMFoiLCJpYXQiOjE3NTY2MzU5NDksImV4cCI6MTc1OTIyNzk0OX0.CfkMxMyiEH6VRoJfXnYXroYGaxVBLvwYRmtUPyl1bd8";
  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: APIConfig.baseUrl,
            connectTimeout: const Duration(seconds: 120),
            receiveTimeout: const Duration(seconds: 120),
            sendTimeout: const Duration(seconds: 120),
            receiveDataWhenStatusError: true,
          ),
        )
        ..interceptors.add(
          PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
            responseHeader: true,
            responseBody: true,
            error: true,
            compact: true,
            maxWidth: 90,
          ),
        );

  // Check for Internet connection
  // static Future<bool> _hasInternetConnection() async {
  //   return await InternetConnectionChecker().hasConnection;
  // }

  // Handle Dio Request and connection errors
  static Future<Map<String, dynamic>> _handleDioRequest(
    Future<Response> dioRequest,
  ) async {
    // if (!hasConnection) {
    //   throw Exception('No Internet Connection');
    // }

    try {
      final response = await dioRequest;
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
      return {'data': response.data};
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw Exception('No Internet Connection');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Unable to resolve host, please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Request Timed Out. Please try again.');
      } else if (e.type == DioExceptionType.badResponse) {
        if (e.response?.statusCode == 401 &&
            e.response?.statusMessage == 'Unauthorized' &&
            e.response?.data['message'] != null &&
            e.response?.data['message'] == "Unauthenticated.") {}
      }
      rethrow;
    } catch (e) {
      if (e is SocketException) {
        throw Exception('No Internet Connection');
      }
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  /// POST request with form data
  static Future<Map<String, dynamic>> postFormData({
    required String endpoint,
    required FormData formData,
    Map<String, dynamic>? params,
    bool? isAuth = true,
  }) async {
    final headers = {
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
      if (isAuth == true) 'Authorization': 'Bearer $Token',
    };

    return _handleDioRequest(
      _dio.post(
        endpoint,
        data: formData,
        queryParameters: params ?? {},
        options: Options(headers: headers),
      ),
    );
  }

  /// General POST request with JSON body
  static Future<Map<String, dynamic>> post({
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? params,
    bool? isAuth = true,
  }) async {
    final headers = {
      'Accept': 'application/json',
      if (isAuth == true) 'Authorization': 'Bearer $Token',
    };

    return _handleDioRequest(
      _dio.post(
        endpoint,
        data: body,
        queryParameters: params ?? {},
        options: Options(headers: headers),
      ),
    );
  }

  /// General GET request
  static Future<Map<String, dynamic>> get({
    required String endpoint,
    Map<String, dynamic>? params,
    Map<String, dynamic>? body,
    bool? isAuth = true,
  }) async {
    final headers = {
      'Accept': 'application/json',
      if (isAuth == true) 'Authorization': 'Bearer $Token',
    };

    return _handleDioRequest(
      _dio.get(
        endpoint,
        queryParameters: params ?? {},
        data: body,
        options: Options(headers: headers),
      ),
    );
  }

  /// DELETE request
  static Future<Map<String, dynamic>> delete({
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? params,
    bool? isAuth = true,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      if (isAuth == true) 'Authorization': 'Bearer $Token',
    };

    return _handleDioRequest(
      _dio.delete(
        endpoint,
        data: body,
        queryParameters: params ?? {},
        options: Options(headers: headers),
      ),
    );
  }

  /// PUT request
  static Future<Map<String, dynamic>> put({
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? params,
    bool? isAuth = true,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      if (isAuth == true) 'Authorization': 'Bearer $Token',
    };

    return _handleDioRequest(
      _dio.put(
        endpoint,
        data: body,
        queryParameters: params ?? {},
        options: Options(headers: headers),
      ),
    );
  }

  /// PATCH request
  static Future<Map<String, dynamic>> patch({
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? params,
    bool? isAuth = true,
  }) async {
    final headers = {'Content-Type': 'application/json'};

    return _handleDioRequest(
      _dio.patch(
        endpoint,
        data: body,
        queryParameters: params ?? {},
        options: Options(headers: headers),
      ),
    );
  }

  /// DELETE request with form data
  static Future<Map<String, dynamic>> deleteFormData({
    required String endpoint,
    required FormData formData,
    Map<String, dynamic>? params,
    bool? isAuth = true,
  }) async {
    final headers = {
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
    };

    return _handleDioRequest(
      _dio.delete(
        endpoint,
        data: formData,
        queryParameters: params ?? {},
        options: Options(headers: headers),
      ),
    );
  }
}
