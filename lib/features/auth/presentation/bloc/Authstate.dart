import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';

abstract class AuthState {}

// --- General Auth States ---
class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

// --- Success/Failure States ---
class AuthSuccess extends AuthState {
  final UserModel user;
  AuthSuccess({required this.user});
}

class AuthFailure extends AuthState {
  final Failure failure;
  AuthFailure({required this.failure});
}

// --- Register States ---
class RegisterSuccess extends AuthState {
  final String email;
  RegisterSuccess({required this.email});
}

class RegisterLoading extends AuthState {}

class RegisterFailure extends AuthState {
  final Failure failure;
  RegisterFailure({required this.failure});
}

// --- Forget Password Flow States ---
class ForgetPasswordEmailSent extends AuthState {
  final String email;
  ForgetPasswordEmailSent({required this.email});
}

class ForgetPasswordFailure extends AuthState {
  final Failure failure;
  ForgetPasswordFailure({required this.failure});
}

class VerifyCodeSuccess extends AuthState {
  final String email;
  final String code;
  VerifyCodeSuccess({required this.email, required this.code});
}

class VerifyCodeFailure extends AuthState {
  final Failure failure;
  VerifyCodeFailure({required this.failure});
}

class ResetPasswordSuccess extends AuthState {}

class ResetPasswordFailure extends AuthState {
  final Failure failure;
  ResetPasswordFailure({required this.failure});
}
