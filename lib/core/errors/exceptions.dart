import 'package:tionova/core/errors/failure.dart';

class ServerException implements Exception {
  final Failure failure;
  const ServerException({required this.failure});
}
