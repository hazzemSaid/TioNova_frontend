import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:tionova/core/constants/app_constants.dart';
import 'package:tionova/core/services/firebase_realtime_service.dart';
import 'package:tionova/core/utils/network_error_helper.dart';
import 'package:tionova/features/auth/data/AuthDataSource/Iauthdatasource.dart';
import 'package:tionova/features/auth/data/AuthDataSource/remoteauthdatasource.dart';
import 'package:tionova/features/auth/data/repo/authrepoimp.dart';
import 'package:tionova/features/auth/data/services/auth_service.dart';
import 'package:tionova/features/auth/data/services/token_storage.dart';
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
import 'package:tionova/features/chapter/data/datasources/remote/chapterRemoteDataSource.dart';
import 'package:tionova/features/chapter/data/reposimp/ChapterRepoImpt.dart';
import 'package:tionova/features/chapter/domain/repos/IChapterRepository.dart';
import 'package:tionova/features/chapter/domain/usecases/AddnoteUseCase.dart';
import 'package:tionova/features/chapter/domain/usecases/CreateChapterUseCase.dart';
import 'package:tionova/features/chapter/domain/usecases/DeleteChapterUseCase.dart';
import 'package:tionova/features/chapter/domain/usecases/DeleteNoteUseCase.dart';
import 'package:tionova/features/chapter/domain/usecases/GenerateSmartNodeUseCase.dart';
import 'package:tionova/features/chapter/domain/usecases/GenerateSummaryUseCase.dart';
import 'package:tionova/features/chapter/domain/usecases/GetChaperContentPdfUseCase.dart';
import 'package:tionova/features/chapter/domain/usecases/GetChapterSummaryUseCase.dart';
import 'package:tionova/features/chapter/domain/usecases/GetChaptersUserCase.dart';
import 'package:tionova/features/chapter/domain/usecases/GetMindmapUseCase.dart';
import 'package:tionova/features/chapter/domain/usecases/GetNotesByChapterIdUseCase.dart';
import 'package:tionova/features/chapter/domain/usecases/SaveMindmapUseCase.dart';
import 'package:tionova/features/chapter/domain/usecases/UpdateChapterUseCase.dart';
import 'package:tionova/features/chapter/domain/usecases/UpdateNoteUseCase.dart';
import 'package:tionova/features/chapter/domain/usecases/createMindmapUseCase.dart';
import 'package:tionova/features/chapter/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/chapter/presentation/bloc/mindmap/mindmap_cubit.dart';
import 'package:tionova/features/folder/data/datasources/FolderRemoteDataSource.dart';
import 'package:tionova/features/folder/data/repoimp/FolderRepoImp.dart';
import 'package:tionova/features/folder/domain/usecases/CreateFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/DeleteFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetAllFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetPublicFoldersUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/UpdateFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/getAvailableUsersForShareUseCase.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/features/home/data/datasource/analysis_remote_datasource.dart';
import 'package:tionova/features/home/data/repoImp/analysis_repo_imp.dart';
import 'package:tionova/features/home/domain/usecases/analysisusecase.dart';
import 'package:tionova/features/home/presentation/bloc/Analysiscubit.dart';
import 'package:tionova/features/preferences/data/datasources/preferencesreomtedatasource.dart';
import 'package:tionova/features/preferences/data/repo/PreferencesRepositoryimp.dart';
import 'package:tionova/features/preferences/domain/repo/PreferencesRepository.dart';
import 'package:tionova/features/preferences/domain/usecase/GetPreferencesUseCase.dart';
import 'package:tionova/features/preferences/domain/usecase/UpdatePreferencesUseCase.dart';
import 'package:tionova/features/preferences/presentation/Bloc/PreferencesCubit.dart';
import 'package:tionova/features/profile/data/datasource/remote_data_source_profile.dart';
import 'package:tionova/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:tionova/features/profile/domain/repo/profile_repository.dart';
import 'package:tionova/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:tionova/features/quiz/data/datasources/remotequizdatasource.dart';
import 'package:tionova/features/quiz/data/repo/Quizrepoimp.dart';
import 'package:tionova/features/quiz/domain/repo/Quizrepo.dart';
import 'package:tionova/features/quiz/domain/usecases/CreateQuizUseCase.dart';
import 'package:tionova/features/quiz/domain/usecases/GetHistoryUseCase.dart';
import 'package:tionova/features/quiz/domain/usecases/GetPracticeModeQuestionsUseCase.dart';
import 'package:tionova/features/quiz/domain/usecases/UserQuizStatusUseCase.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizcubit.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  debugPrint('🔧 Setting up service locator...');
  // Initialize Hive
  // Hive.init(appDocumentDir.path); // Removed redundant init, use Hive.initFlutter() from main.dart
  // final Dio dio2 = Dio(BaseOptions(baseUrl: baseUrl));
  // dio2.post('$baseUrl/error-log', data: {"الحمد لله رب العالمين"});
  // Register Hive adapters - wrap in try-catch for web
  // // Only register if Hive is available (skips on Safari private mode)
  // if (HiveManager.isHiveAvailable) {
  //   try {
  //     if (!Hive.isAdapterRegistered(UserModelAdapter().typeId)) {
  //       Hive.registerAdapter(UserModelAdapter());
  //     }
  //   } catch (e) {
  //     print('⚠️ Error registering UserModelAdapter: $e');
  //     if (!kIsWeb) rethrow;
  //   }
  // }

  // Hive box opening disabled for web compatibility
  // Box? box;
  // if (!HiveManager.isHiveAvailable) {
  //   // Hive not available (Safari private mode), use null box
  //   print('ℹ️ Skipping auth_box (Hive not available)');
  //   box = null;
  // } else if (kIsWeb) {
  //   // On web with Hive available, use shorter timeout and fallback gracefully
  //   try {
  //     box = await Hive.openBox('auth_box').timeout(
  //       const Duration(seconds: 2),
  //       onTimeout: () {
  //         print('⚠️ Timeout opening auth_box on web');
  //         throw TimeoutException('auth_box timeout');
  //       },
  //     );
  //     print('✅ auth_box opened successfully on web');
  //   } catch (e) {
  //     print('⚠️ Error opening auth_box on web: $e');
  //     // On web, we'll use null box and handle it in LocalAuthDataSource
  //     box = null;
  //   }
  // } else {
  //   // On mobile/desktop, normal box opening
  //   box = await Hive.openBox('auth_box');
  // }

  final Dio dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  final logger = PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    error: true,
    compact: true,
    maxWidth: 120,
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        logger.onRequest(options, handler);
      },
      onResponse: (response, handler) {
        final contentType = response.headers.value('content-type');
        final isBinary =
            contentType != null &&
            (contentType.contains('application/pdf') ||
                contentType.contains('image/') ||
                contentType.contains('application/octet-stream') ||
                contentType.contains('audio/') ||
                contentType.contains('video/'));

        final isBytes =
            response.requestOptions.responseType == ResponseType.bytes;
        final isStream =
            response.requestOptions.responseType == ResponseType.stream;

        if (isBinary || isBytes || isStream) {
          print(
            '📦 [Binary Response] ${response.statusCode} ${response.requestOptions.path}',
          );
          handler.next(response);
        } else if (response.requestOptions.path.contains('getchaptercontent')) {
          print(
            '📦 [Chapter Content Response] ${response.statusCode} ${response.requestOptions.path} (Body hidden)',
          );
          handler.next(response);
        } else {
          logger.onResponse(response, handler);
        }
      },
      onError: (error, handler) {
        logger.onError(error, handler);
      },
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        // Check if error is due to unauthorized (token expired)
        if (error.response?.statusCode == 401) {
          final tokenStorage = getIt<TokenStorage>();
          final refreshToken = await tokenStorage.getRefreshToken();

          if (refreshToken != null) {
            try {
              final refreshResponse = await dio.post(
                '/auth/refresh-token',
                data: {'refreshToken': refreshToken},
              );

              if (refreshResponse.statusCode == 200) {
                final responseData = refreshResponse.data;
                final newAccessToken = responseData['token']?.toString();
                final newRefreshToken = responseData['refreshToken']
                    ?.toString();
                final expiresIn = responseData['expiresIn'] as int? ?? 3600;

                if (newAccessToken != null && newRefreshToken != null) {
                  // Save both tokens
                  await tokenStorage.saveTokens(
                    newAccessToken,
                    newRefreshToken,
                    expiresIn: expiresIn,
                  );

                  // Retry the original request with new token
                  final opts = error.requestOptions;
                  opts.headers['Authorization'] = 'Bearer $newAccessToken';
                  final cloneReq = await dio.fetch(opts);
                  return handler.resolve(cloneReq);
                }
              }
            } catch (e) {
              // If refresh fails, sign out the user with token expired flag
              await tokenStorage.clearTokens();
              final authCubit = getIt<AuthCubit>();
              authCubit.signOut(isTokenExpired: true);
              return handler.next(error);
            }
          } else {
            // No refresh token found, sign out the user with token expired flag
            await tokenStorage.clearTokens();
            final authCubit = getIt<AuthCubit>();
            authCubit.signOut(isTokenExpired: true);
            return handler.next(error);
          }
        }
        return handler.next(error);
      },
      onRequest: (options, handler) async {
        final tokenStorage = getIt<TokenStorage>();
        final accessToken = await tokenStorage.getAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        handler.next(options);
      },
    ),
  );

  // Connection error interceptor - shows dialog when server is unreachable
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) {
        // Check for connection errors
        if (error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout ||
            NetworkErrorHelper.isConnectionError(error)) {
          // Show the server down dialog
          NetworkErrorHelper.showServerDownDialog(
            title: 'Server Unavailable',
            message:
                'The app is currently unable to connect to the server. Please check your internet connection or try again later.',
          );
        }
        // Always pass the error to the next handler
        handler.next(error);
      },
    ),
  );
  // Services
  getIt.registerLazySingleton<Dio>(() => dio);
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(dio: dio, tokenStorage: getIt<TokenStorage>()),
  );
  // Register TokenStorage just once
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());

  // // Register App Usage Tracker Service
  // getIt.registerLazySingleton<AppUsageTrackerService>(
  //   () => AppUsageTrackerService(),
  // );

  FirebaseDatabase? firebaseDatabase;
  try {
    firebaseDatabase = FirebaseDatabase.instance;
    debugPrint('✅ FirebaseDatabase instance created');
  } catch (e) {
    debugPrint('❌ Failed to create FirebaseDatabase instance: $e');
    if (kIsWeb) {
      debugPrint(
        'ℹ️ Web platform detected, continuing without Firebase Realtime Database',
      );
    } else {
      rethrow;
    }
  }

  if (firebaseDatabase != null && !getIt.isRegistered<FirebaseDatabase>()) {
    final db = firebaseDatabase;
    getIt.registerLazySingleton<FirebaseDatabase>(() => db!);
  }
  if (!getIt.isRegistered<FirebaseRealtimeService>()) {
    getIt.registerLazySingleton<FirebaseRealtimeService>(
      () => FirebaseRealtimeService(firebaseDatabase),
    );
  }

  // Data Sources
  getIt.registerLazySingleton<IAuthDataSource>(
    () => Remoteauthdatasource(
      dio: getIt<Dio>(),
      authService: getIt<AuthService>(),
      tokenStorage: getIt<TokenStorage>(),
    ),
  );

  // // Use web-safe auth data source when Hive box is not available
  // if (box != null) {
  //   final nonNullBox = box; // Store in non-nullable local variable
  //   getIt.registerLazySingleton<ILocalAuthDataSource>(
  //     () => LocalAuthDataSource(nonNullBox),
  //   );
  // } else {
  //   // Web fallback - use in-memory storage
  //   getIt.registerLazySingleton<ILocalAuthDataSource>(
  //     () => WebLocalAuthDataSource(),
  //   );
  // }

  // Repository
  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepoImp(
      remoteDataSource: getIt<IAuthDataSource>(),
      // localDataSource: getIt<ILocalAuthDataSource>(),
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
      tokenStorage: getIt<TokenStorage>(),
      googleauthusecase: getIt<Googleauthusecase>(),
      // localAuthDataSource: getIt<ILocalAuthDataSource>(),
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

  getIt.registerLazySingleton<GetPublicFoldersUseCase>(
    () => GetPublicFoldersUseCase(getIt<FolderRepoImp>()),
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

  getIt.registerLazySingleton<UpdateNoteUseCase>(
    () => UpdateNoteUseCase(getIt<IChapterRepository>()),
  );

  getIt.registerLazySingleton<Getnotesbychapteridusecase>(
    () => Getnotesbychapteridusecase(getIt<IChapterRepository>()),
  );

  getIt.registerLazySingleton<GetMindmapUseCase>(
    () => GetMindmapUseCase(getIt<IChapterRepository>()),
  );

  // AI-powered mindmap node generation use cases
  getIt.registerLazySingleton<GenerateSmartNodeUseCase>(
    () => GenerateSmartNodeUseCase(getIt<IChapterRepository>()),
  );

  getIt.registerLazySingleton<SaveMindmapUseCase>(
    () => SaveMindmapUseCase(getIt<IChapterRepository>()),
  );

  // Register MindmapCubit with AI and save capabilities
  getIt.registerFactory(
    () => MindmapCubit(
      generateSmartNodeUseCase: getIt<GenerateSmartNodeUseCase>(),
      saveMindmapUseCase: getIt<SaveMindmapUseCase>(),
      getMindmapUseCase: getIt<GetMindmapUseCase>(),
    ),
  );

  getIt.registerLazySingleton<GetChapterSummaryUseCase>(
    () => GetChapterSummaryUseCase(getIt<IChapterRepository>()),
  );

  getIt.registerLazySingleton<UpdateChapterUseCase>(
    () => UpdateChapterUseCase(repository: getIt<IChapterRepository>()),
  );

  getIt.registerLazySingleton<DeleteChapterUseCase>(
    () => DeleteChapterUseCase(getIt<IChapterRepository>()),
  );

  // Register ChapterCubit with Firebase
  getIt.registerFactory(
    () => ChapterCubit(
      getNotesByChapterIdUseCase: getIt<Getnotesbychapteridusecase>(),
      addNoteUseCase: getIt<Addnoteusecase>(),
      deleteNoteUseCase: getIt<Deletenoteusecase>(),
      updateNoteUseCase: getIt<UpdateNoteUseCase>(),
      createMindmapUseCase: getIt<CreateMindmapUseCase>(),
      generateSummaryUseCase: getIt<GenerateSummaryUseCase>(),
      getChaptersUseCase: getIt<GetChaptersUseCase>(),
      createChapterUseCase: getIt<CreateChapterUseCase>(),
      getChapterContentPdfUseCase: getIt<GetChapterContentPdfUseCase>(),
      firebaseService: getIt<FirebaseRealtimeService>(),
      getMindmapUseCase: getIt<GetMindmapUseCase>(),
      getChapterSummaryUseCase: getIt<GetChapterSummaryUseCase>(),
      updateChapterUseCase: getIt<UpdateChapterUseCase>(),
      deleteChapterUseCase: getIt<DeleteChapterUseCase>(),
    ),
  );

  getIt.registerLazySingleton<GetAvailableUsersForShareUseCase>(
    () => GetAvailableUsersForShareUseCase(getIt<FolderRepoImp>()),
  );

  // Register FolderCubit
  getIt.registerFactory(
    () => FolderCubit(
      getAvailableUsersForShareUseCase:
          getIt<GetAvailableUsersForShareUseCase>(),
      getAllFolderUseCase: getIt<GetAllFolderUseCase>(),
      createFolderUseCase: getIt<CreateFolderUseCase>(),
      updateFolderUseCase: getIt<UpdateFolderUseCase>(),
      deleteFolderUseCase: getIt<DeleteFolderUseCase>(),
      getPublicFoldersUseCase: getIt<GetPublicFoldersUseCase>(),
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
  getIt.registerLazySingleton<GetPracticeModeQuestionsUseCase>(
    () => GetPracticeModeQuestionsUseCase(quizRepo: getIt<QuizRepo>()),
  );
  getIt.registerFactory(
    () => QuizCubit(
      createQuizUseCase: getIt<CreateQuizUseCase>(),
      userQuizStatusUseCase: getIt<UserQuizStatusUseCase>(),
      getHistoryUseCase: getIt<GetHistoryUseCase>(),
      getPracticeModeQuestionsUseCase: getIt<GetPracticeModeQuestionsUseCase>(),
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
  getIt.registerLazySingleton(
    () => AnalysisCubit(analysisUseCase: getIt<AnalysisUseCase>()),
  );

  //preferences
  //PreferencesRemoteDataSourceImpl
  getIt.registerLazySingleton<PreferencesRemoteDataSourceImpl>(
    () => PreferencesRemoteDataSourceImpl(dio: getIt<Dio>()),
  );
  //PreferencesRepository
  getIt.registerLazySingleton<PreferencesRepository>(
    () => PreferencesRepositoryimp(
      preferencesRemoteDataSourceImpl: getIt<PreferencesRemoteDataSourceImpl>(),
    ),
  );
  getIt.registerLazySingleton<GetPreferencesUseCase>(
    () => GetPreferencesUseCase(repository: getIt<PreferencesRepository>()),
  );
  getIt.registerLazySingleton<UpdatePreferencesUseCase>(
    () => UpdatePreferencesUseCase(repository: getIt<PreferencesRepository>()),
  );

  //cubit prefernces
  getIt.registerLazySingleton(
    () => PreferencesCubit(
      getPreferencesUseCase: getIt<GetPreferencesUseCase>(),
      updatePreferencesUseCase: getIt<UpdatePreferencesUseCase>(),
    ),
  );

  // Profile
  getIt.registerLazySingleton<remoteDataSourceProfile>(
    () => RemoteDataSourceProfileImpl(dio: getIt<Dio>()),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: getIt<remoteDataSourceProfile>(),
    ),
  );

  getIt.registerFactory(
    () => ProfileCubit(repository: getIt<ProfileRepository>()),
  );
}
