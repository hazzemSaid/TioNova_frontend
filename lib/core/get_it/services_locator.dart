// core/get_it/services_locator.dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:tionova/core/services/app_usage_tracker_service.dart';
import 'package:tionova/features/auth/data/AuthDataSource/Iauthdatasource.dart';
import 'package:tionova/features/auth/data/AuthDataSource/ilocal_auth_data_source.dart';
import 'package:tionova/features/auth/data/AuthDataSource/localauthdatasource.dart';
import 'package:tionova/features/auth/data/AuthDataSource/remoteauthdatasource.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';
import 'package:tionova/features/auth/data/repo/authrepoimp.dart';
import 'package:tionova/features/auth/data/services/Tokenstorage.dart';
import 'package:tionova/features/auth/data/services/auth_service.dart';
import 'package:tionova/features/auth/domain/repo/authrepo.dart';
import 'package:tionova/features/auth/domain/usecases/forgetPasswordusecase.dart';
import 'package:tionova/features/auth/domain/usecases/googleauthusecase.dart';
import 'package:tionova/features/auth/domain/usecases/loginusecase.dart';
import 'package:tionova/features/auth/domain/usecases/registerusecase.dart';
import 'package:tionova/features/auth/domain/usecases/resetpasswordusecase.dart';
import 'package:tionova/features/auth/domain/usecases/verifyCodeusecase.dart';
import 'package:tionova/features/auth/domain/usecases/verifyEmailusecase.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/challenges/data/datasource/remote_Livechallenge_datasource.dart';
import 'package:tionova/features/challenges/data/repo/LiveChallenge_Imprepo.dart';
import 'package:tionova/features/challenges/domain/repo/LiveChallenge_repo.dart';
import 'package:tionova/features/challenges/domain/usecase/checkAndAdvanceusecase.dart';
import 'package:tionova/features/challenges/domain/usecase/createLiveChallengeusecase.dart';
import 'package:tionova/features/challenges/domain/usecase/disconnectFromLiveChallengeusecase.dart';
import 'package:tionova/features/challenges/domain/usecase/joinLiveChallengeusecase.dart';
import 'package:tionova/features/challenges/domain/usecase/startLiveChallengeusecase.dart';
import 'package:tionova/features/challenges/domain/usecase/submitLiveAnswerusecase.dart';
import 'package:tionova/features/challenges/presentation/bloc/challenge_cubit.dart';
import 'package:tionova/features/folder/data/datasources/FolderRemoteDataSource.dart';
import 'package:tionova/features/folder/data/datasources/chapterRemoteDataSource.dart';
import 'package:tionova/features/folder/data/repoimp/ChapterRepoImpt.dart';
import 'package:tionova/features/folder/data/repoimp/FolderRepoImp.dart';
import 'package:tionova/features/folder/domain/repo/IChapterRepository.dart';
import 'package:tionova/features/folder/domain/usecases/AddnoteUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/CreateChapterUseCase.dart';
// import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart'; // Not directly used
import 'package:tionova/features/folder/domain/usecases/CreateFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/DeleteFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/DeleteNoteUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GenerateSummaryUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetAllFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetChaperContentPdfUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetChaptersUserCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetNotesByChapterIdUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/UpdateFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/createMindmapUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/getAvailableUsersForShareUseCase.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/features/home/data/datasource/analysis_remote_datasource.dart';
import 'package:tionova/features/home/data/repoImp/analysis_repo_imp.dart';
import 'package:tionova/features/home/domain/usecases/analysisusecase.dart';
import 'package:tionova/features/home/presentation/bloc/Analysiscubit.dart';
import 'package:tionova/features/quiz/data/datasources/remotequizdatasource.dart';
import 'package:tionova/features/quiz/data/repo/Quizrepoimp.dart';
import 'package:tionova/features/quiz/domain/repo/Quizrepo.dart';
import 'package:tionova/features/quiz/domain/usecases/CreateQuizUseCase.dart';
import 'package:tionova/features/quiz/domain/usecases/GetHistoryUseCase.dart';
import 'package:tionova/features/quiz/domain/usecases/UserQuizStatusUseCase.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizcubit.dart';

final getIt = GetIt.instance;
// http://192.168.1.12:3000/api/v1
//https://tio-nova-backend.vercel.app/api/v1
// final baseUrl = 'https://tio-nova-backend.vercel.app/api/v1';
final baseUrl = 'http://192.168.1.12:3000/api/v1';
Future<void> setupServiceLocator() async {
  // Initialize Hive
  // Hive.init(appDocumentDir.path); // Removed redundant init, use Hive.initFlutter() from main.dart

  // Register Hive adapters
  if (!Hive.isAdapterRegistered(UserModelAdapter().typeId)) {
    Hive.registerAdapter(UserModelAdapter());
  }

  // Open Hive box
  final box = await Hive.openBox('auth_box');
  final Dio dio = Dio(BaseOptions(baseUrl: baseUrl));

  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        // Check if error is due to unauthorized (token expired)
        if (error.response?.statusCode == 401) {
          // Use static methods directly from TokenStorage
          final refreshToken = await TokenStorage.getRefreshToken();

          if (refreshToken != null) {
            try {
              final refreshResponse = await dio.post(
                '/auth/refresh-token',
                data: {'refreshToken': refreshToken},
              );
              final newAccessToken = refreshResponse.data['token'];
              final newRefreshToken = refreshResponse.data['refreshToken'];
              // Save both tokens
              await TokenStorage.saveTokens(newAccessToken, newRefreshToken);

              // Retry the original request with new token
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newAccessToken';
              final cloneReq = await dio.fetch(opts);
              return handler.resolve(cloneReq);
            } catch (e) {
              // If refresh fails, sign out the user with token expired flag
              await TokenStorage.clearTokens();
              final authCubit = getIt<AuthCubit>();
              authCubit.signOut(
                isTokenExpired: true,
              ); // This will emit AuthFailure with token expired message

              // Forward error to request
              return handler.next(error);
            }
          } else {
            // No refresh token found, sign out the user with token expired flag
            final authCubit = getIt<AuthCubit>();
            authCubit.signOut(isTokenExpired: true);
            return handler.next(error);
          }
        }
        return handler.next(error);
      },
      onRequest: (options, handler) async {
        // Use static method directly from TokenStorage
        final accessToken = await TokenStorage.getAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        handler.next(options);
      },
    ),
  );
  // Services
  getIt.registerLazySingleton<Dio>(() => dio);
  getIt.registerLazySingleton<AuthService>(() => AuthService(dio: dio));
  // Register TokenStorage just once
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());

  // Register App Usage Tracker Service
  getIt.registerLazySingleton<AppUsageTrackerService>(
    () => AppUsageTrackerService(),
  );

  // Data Sources
  getIt.registerLazySingleton<IAuthDataSource>(
    () => Remoteauthdatasource(
      dio: getIt<Dio>(),
      authService: getIt<AuthService>(),
    ),
  );

  getIt.registerLazySingleton<ILocalAuthDataSource>(
    () => LocalAuthDataSource(box),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepoImp(
      remoteDataSource: getIt<IAuthDataSource>(),
      localDataSource: getIt<ILocalAuthDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<Googleauthusecase>(
    () => Googleauthusecase(authRepo: getIt<AuthRepo>()),
  );
  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(getIt<AuthRepo>()),
  );
  getIt.registerLazySingleton<VerifyEmailUseCase>(
    () => VerifyEmailUseCase(getIt<AuthRepo>()),
  );
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepo>()),
  );
  // New Use Cases
  getIt.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(getIt<AuthRepo>()),
  );
  getIt.registerLazySingleton<ForgetPasswordUseCase>(
    () => ForgetPasswordUseCase(getIt<AuthRepo>()),
  );
  getIt.registerLazySingleton<VerifyCodeUseCase>(
    () => VerifyCodeUseCase(getIt<AuthRepo>()),
  );
  // Bloc
  getIt.registerSingleton<AuthCubit>(
    AuthCubit(
      resetPasswordUseCase: getIt<ResetPasswordUseCase>(),
      forgetPasswordUseCase: getIt<ForgetPasswordUseCase>(),
      verifyCodeUseCase: getIt<VerifyCodeUseCase>(),
      loginUseCase: getIt<LoginUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
      verifyEmailUseCase: getIt<VerifyEmailUseCase>(),
      tokenStorage:
          TokenStorage(), // Provide instance directly since TokenStorage uses static methods
      googleauthusecase: getIt<Googleauthusecase>(),
      localAuthDataSource: getIt<ILocalAuthDataSource>(),
    ),
  );

  //folder
  getIt.registerLazySingleton<FolderRemoteDataSource>(
    () => FolderRemoteDataSource(getIt<Dio>()),
  );
  // FolderRepoImp
  getIt.registerLazySingleton<FolderRepoImp>(
    () => FolderRepoImp(remoteDataSource: getIt<FolderRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetAllFolderUseCase>(
    () => GetAllFolderUseCase(getIt<FolderRepoImp>()),
  );

  getIt.registerLazySingleton<CreateFolderUseCase>(
    () => CreateFolderUseCase(getIt<FolderRepoImp>()),
  );

  getIt.registerLazySingleton<UpdateFolderUseCase>(
    () => UpdateFolderUseCase(getIt<FolderRepoImp>()),
  );

  getIt.registerLazySingleton<DeleteFolderUseCase>(
    () => DeleteFolderUseCase(getIt<FolderRepoImp>()),
  );

  // Chapter related registrations
  getIt.registerLazySingleton<ChapterRemoteDataSource>(
    () => ChapterRemoteDataSource(getIt<Dio>()),
  );

  getIt.registerLazySingleton<IChapterRepository>(
    () => ChapterRepoImpl(remoteDataSource: getIt<ChapterRemoteDataSource>()),
  );

  getIt.registerLazySingleton<GenerateSummaryUseCase>(
    () => GenerateSummaryUseCase(getIt<IChapterRepository>()),
  );

  getIt.registerLazySingleton<GetChaptersUseCase>(
    () => GetChaptersUseCase(getIt<IChapterRepository>()),
  );

  getIt.registerLazySingleton<CreateChapterUseCase>(
    () => CreateChapterUseCase(getIt<IChapterRepository>()),
  );

  getIt.registerLazySingleton<GetChapterContentPdfUseCase>(
    () => GetChapterContentPdfUseCase(getIt<IChapterRepository>()),
  );
  getIt.registerLazySingleton<CreateMindmapUseCase>(
    () => CreateMindmapUseCase(getIt<IChapterRepository>()),
  );
  getIt.registerLazySingleton<Addnoteusecase>(
    () => Addnoteusecase(getIt<IChapterRepository>()),
  );
  getIt.registerLazySingleton<Deletenoteusecase>(
    () => Deletenoteusecase(getIt<IChapterRepository>()),
  );

  getIt.registerLazySingleton<Getnotesbychapteridusecase>(
    () => Getnotesbychapteridusecase(getIt<IChapterRepository>()),
  );
  // Register ChapterCubit
  getIt.registerFactory(
    () => ChapterCubit(
      getNotesByChapterIdUseCase: getIt<Getnotesbychapteridusecase>(),
      addNoteUseCase: getIt<Addnoteusecase>(),
      deleteNoteUseCase: getIt<Deletenoteusecase>(),
      createMindmapUseCase: getIt<CreateMindmapUseCase>(),
      generateSummaryUseCase: getIt<GenerateSummaryUseCase>(),
      getChaptersUseCase: getIt<GetChaptersUseCase>(),
      createChapterUseCase: getIt<CreateChapterUseCase>(),
      getChapterContentPdfUseCase: getIt<GetChapterContentPdfUseCase>(),
    ),
  );
  getIt.registerLazySingleton<GetAvailableUsersForShareUseCase>(
    () => GetAvailableUsersForShareUseCase(getIt<FolderRepoImp>()),
  );

  // You can register FolderCubit similarly if needed
  getIt.registerFactory(
    () => FolderCubit(
      getAvailableUsersForShareUseCase:
          getIt<GetAvailableUsersForShareUseCase>(),
      getAllFolderUseCase: getIt<GetAllFolderUseCase>(),
      createFolderUseCase: getIt<CreateFolderUseCase>(),
      updateFolderUseCase: getIt<UpdateFolderUseCase>(),
      deleteFolderUseCase: getIt<DeleteFolderUseCase>(),
    ),
  );

  //quiz
  getIt.registerLazySingleton<RemoteQuizDataSource>(
    () => RemoteQuizDataSource(dio: getIt<Dio>()),
  );

  getIt.registerLazySingleton<QuizRepo>(
    () => QuizRepoImp(remoteQuizDataSource: getIt<RemoteQuizDataSource>()),
  );

  getIt.registerLazySingleton<CreateQuizUseCase>(
    () => CreateQuizUseCase(quizRepo: getIt<QuizRepo>()),
  );

  getIt.registerLazySingleton<UserQuizStatusUseCase>(
    () => UserQuizStatusUseCase(getIt<QuizRepo>()),
  );
  getIt.registerLazySingleton<GetHistoryUseCase>(
    () => GetHistoryUseCase(quizrepo: getIt<QuizRepo>()),
  );
  getIt.registerFactory(
    () => QuizCubit(
      createQuizUseCase: getIt<CreateQuizUseCase>(),
      userQuizStatusUseCase: getIt<UserQuizStatusUseCase>(),
      getHistoryUseCase: getIt<GetHistoryUseCase>(),
    ),
  );

  //challenge
  getIt.registerLazySingleton<RemoteLiveChallengeDataSource>(
    () => RemoteLiveChallengeDataSource(dio: getIt<Dio>()),
  );

  getIt.registerLazySingleton<LiveChallengeRepo>(
    () => LiveChallengeImpRepo(
      remoteDataSource: getIt<RemoteLiveChallengeDataSource>(),
    ),
  );
  getIt.registerLazySingleton<CreateLiveChallengeUseCase>(
    () => CreateLiveChallengeUseCase(repository: getIt<LiveChallengeRepo>()),
  );
  getIt.registerLazySingleton<JoinLiveChallengeUseCase>(
    () => JoinLiveChallengeUseCase(repository: getIt<LiveChallengeRepo>()),
  );
  getIt.registerLazySingleton<StartLiveChallengeUseCase>(
    () => StartLiveChallengeUseCase(repository: getIt<LiveChallengeRepo>()),
  );
  getIt.registerLazySingleton<SubmitLiveAnswerUseCase>(
    () => SubmitLiveAnswerUseCase(repository: getIt<LiveChallengeRepo>()),
  );
  getIt.registerLazySingleton<Disconnectfromlivechallengeusecase>(
    () => Disconnectfromlivechallengeusecase(
      repository: getIt<LiveChallengeRepo>(),
    ),
  );
  getIt.registerLazySingleton<CheckAndAdvanceUseCase>(
    () => CheckAndAdvanceUseCase(liveChallengeRepo: getIt<LiveChallengeRepo>()),
  );
  getIt.registerFactory(
    () => ChallengeCubit(
      checkAndAdvanceUseCase: getIt<CheckAndAdvanceUseCase>(),
      submitLiveAnswerUseCase: getIt<SubmitLiveAnswerUseCase>(),
      createLiveChallengeUseCase: getIt<CreateLiveChallengeUseCase>(),
      disconnectfromlivechallengeusecase:
          getIt<Disconnectfromlivechallengeusecase>(),
      startLiveChallengeUseCase: getIt<StartLiveChallengeUseCase>(),
      joinLiveChallengeUseCase: getIt<JoinLiveChallengeUseCase>(),
    ),
  );
  //data source analysis
  getIt.registerLazySingleton<AnalysisRemoteDataSource>(
    () => AnalysisRemoteDataSourceImpl(dio: getIt<Dio>()),
  );
  //repo analysis
  getIt.registerLazySingleton<AnalysisRepositoryImpl>(
    () => AnalysisRepositoryImpl(
      analysisRemoteDataSource: getIt<AnalysisRemoteDataSource>(),
    ),
  );
  //usecase analysis
  getIt.registerLazySingleton<AnalysisUseCase>(
    () => AnalysisUseCase(repository: getIt<AnalysisRepositoryImpl>()),
  );
  // Register AnalysisCubit
  getIt.registerFactory(
    () => AnalysisCubit(analysisUseCase: getIt<AnalysisUseCase>()),
  );
}
