import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tionova/features/auth/data/AuthDataSource/ilocal_auth_data_source.dart';
import 'package:tionova/features/auth/domain/usecases/forgetPasswordusecase.dart';
import 'package:tionova/features/auth/domain/usecases/googleauthusecase.dart';
import 'package:tionova/features/auth/domain/usecases/loginusecase.dart';
import 'package:tionova/features/auth/domain/usecases/registerusecase.dart';
import 'package:tionova/features/auth/domain/usecases/resetpasswordusecase.dart';
import 'package:tionova/features/auth/domain/usecases/verifyCodeusecase.dart';
import 'package:tionova/features/auth/domain/usecases/verifyEmailusecase.dart';
import 'package:tionova/features/challenges/domain/usecase/checkAndAdvanceusecase.dart';
import 'package:tionova/features/challenges/domain/usecase/createLiveChallengeusecase.dart';
import 'package:tionova/features/challenges/domain/usecase/disconnectFromLiveChallengeusecase.dart';
import 'package:tionova/features/challenges/domain/usecase/joinLiveChallengeusecase.dart';
import 'package:tionova/features/challenges/domain/usecase/startLiveChallengeusecase.dart';
import 'package:tionova/features/challenges/domain/usecase/submitLiveAnswerusecase.dart';
import 'package:tionova/features/folder/domain/usecases/AddnoteUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/CreateChapterUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/DeleteNoteUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GenerateSummaryUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetChaperContentPdfUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetChaptersUserCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetNotesByChapterIdUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/createMindmapUseCase.dart';
import 'package:tionova/features/home/domain/usecases/analysisusecase.dart';

class MockAnalysisUseCase extends Mock implements AnalysisUseCase {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockGoogleAuthUseCase extends Mock implements Googleauthusecase {}

class MockVerifyEmailUseCase extends Mock implements VerifyEmailUseCase {}

class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}

class MockForgetPasswordUseCase extends Mock implements ForgetPasswordUseCase {}

class MockVerifyCodeUseCase extends Mock implements VerifyCodeUseCase {}

class MockLocalAuthDataSource extends Mock implements ILocalAuthDataSource {}

class MockCreateLiveChallengeUseCase extends Mock
    implements CreateLiveChallengeUseCase {}

class MockJoinLiveChallengeUseCase extends Mock
    implements JoinLiveChallengeUseCase {}

class MockStartLiveChallengeUseCase extends Mock
    implements StartLiveChallengeUseCase {}

class MockSubmitLiveAnswerUseCase extends Mock
    implements SubmitLiveAnswerUseCase {}

class MockDisconnectUseCase extends Mock
    implements Disconnectfromlivechallengeusecase {}

class MockCheckAndAdvanceUseCase extends Mock
    implements CheckAndAdvanceUseCase {}

class MockGetChaptersUseCase extends Mock implements GetChaptersUseCase {}

class MockDio extends Mock implements Dio {}

class MockGetNotesByChapterUseCase extends Mock
    implements Getnotesbychapteridusecase {}

class MockAddNoteUseCase extends Mock implements Addnoteusecase {}

class MockDeleteNoteUseCase extends Mock implements Deletenoteusecase {}

class MockCreateChapterUseCase extends Mock implements CreateChapterUseCase {}

class MockCreateMindmapUseCase extends Mock implements CreateMindmapUseCase {}

class MockGetChapterContentPdfUseCase extends Mock
    implements GetChapterContentPdfUseCase {}

class MockGenerateSummaryUseCase extends Mock
    implements GenerateSummaryUseCase {}
