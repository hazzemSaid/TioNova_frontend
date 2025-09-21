// core/errors/failure.dart
abstract class Failure {
  final String errMessage;
  final String? statusCode;
  const Failure(this.errMessage, [this.statusCode]);
}

class ServerFailure extends Failure {
  const ServerFailure(String message, [String? statusCode])
    : super(message, statusCode);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}
