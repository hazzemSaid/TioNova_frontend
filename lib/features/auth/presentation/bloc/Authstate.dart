import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;
  final String token;
  AuthSuccess({required this.user, required this.token});
}

class AuthFailure extends AuthState {
  final Failure failure;
  AuthFailure({required this.failure});
}
