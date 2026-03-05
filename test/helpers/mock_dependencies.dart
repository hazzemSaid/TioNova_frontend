// Test helper file for mock dependencies using Mocktail
import 'package:mocktail/mocktail.dart';
import 'package:tionova/features/auth/domain/repo/authrepo.dart';
import 'package:tionova/features/auth/domain/usecases/forgetPasswordusecase.dart';
import 'package:tionova/features/auth/domain/usecases/googleauthusecase.dart';
import 'package:tionova/features/auth/domain/usecases/loginusecase.dart';
import 'package:tionova/features/auth/domain/usecases/registerusecase.dart';
import 'package:tionova/features/auth/domain/usecases/resetpasswordusecase.dart';
import 'package:tionova/features/auth/domain/usecases/verifyCodeusecase.dart';
import 'package:tionova/features/auth/domain/usecases/verifyEmailusecase.dart';

// ========== REPOSITORIES ==========

/// Mock for AuthRepo
class MockAuthRepo extends Mock implements AuthRepo {}

// ========== AUTH USE CASES ==========

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockGoogleAuthUseCase extends Mock implements Googleauthusecase {}

class MockForgetPasswordUseCase extends Mock implements ForgetPasswordUseCase {}

class MockVerifyCodeUseCase extends Mock implements VerifyCodeUseCase {}

class MockVerifyEmailUseCase extends Mock implements VerifyEmailUseCase {}

class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}

