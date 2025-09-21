import 'package:dio/dio.dart';

import 'failure.dart';

class ServerFailure extends Failure {
  final String? name; // Optional field for the name
  final String? image; // Optional field for the image

  ServerFailure({
    required String errMessage,
    String? statusCode,
    this.name,
    this.image,
  }) : super(errMessage, statusCode);

  factory ServerFailure.fromDioException(DioException dioException) {
    String statusCode =
        dioException.response?.statusCode.toString() ?? "unknown";
    String errMessage =
        "Oops, Unexpected Error Occurred, Please try again later";

    switch (dioException.type) {
      case DioExceptionType.cancel:
        errMessage = "Request to server was cancelled";
        break;
      case DioExceptionType.connectionError:
        errMessage = "Connection to server failed due to internet connection";
        break;
      case DioExceptionType.connectionTimeout:
        errMessage = "Connection timeout with server";
        break;
      case DioExceptionType.receiveTimeout:
        errMessage = "Receive timeout in connection with server";
        break;
      case DioExceptionType.sendTimeout:
        errMessage = "Send timeout in connection with server";
        break;
      case DioExceptionType.badCertificate:
        errMessage = "Bad certificate in connection with server";
        break;
      case DioExceptionType.badResponse:
        return ServerFailure._fromResponse(dioException.response);
      default:
        return ServerFailure(
          errMessage: "Oops, Unexpected Error Occurred, Please try again later",
          statusCode: statusCode,
        );
    }

    return ServerFailure(errMessage: errMessage, statusCode: statusCode);
  }

  factory ServerFailure._fromResponse(Response? response) {
    final statusCode = response?.statusCode.toString() ?? "unknown";
    var responseData = response?.data;
    String errMessage =
        "Oops, Unexpected Error Occurred, Please try again later";
    String? name; // Optional
    String? image; // Optional

    if (responseData != null) {
      if (responseData is String) {
        errMessage = responseData;
      } else if (responseData.containsKey('errors')) {
        errMessage = responseData['errors'] is Map
            ? responseData['errors'].values.first.toString()
            : responseData['errors'].toString();
      } else if (responseData.containsKey('error')) {
        errMessage = responseData['error'] is Map
            ? responseData['error']['message']
            : responseData['error'].toString();
      } else if (responseData.containsKey('message')) {
        errMessage = responseData['message'];
      } else {
        errMessage = response?.statusMessage ?? errMessage;
      }

      // Extract name and image if the status code is 403 (banned account scenario)
      if (statusCode == '403') {
        name = responseData['data']?['name'] as String?;
        image = responseData['data']?['image'] as String?;
      }
    }

    return ServerFailure(
      errMessage: errMessage,
      statusCode: statusCode,
      name: name,
      image: image,
    );
  }
}
