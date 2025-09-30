// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tionova/core/blocobserve/blocobserv.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/core/models/pdf_cache_model.dart';
import 'package:tionova/core/models/summary_cache_model.dart';
import 'package:tionova/core/router/app_router.dart';
import 'package:tionova/core/services/download_service.dart';
import 'package:tionova/core/services/hive_manager.dart';
// import 'package:tionova/core/services/summary_background_service.dart'; // DISABLED
import 'package:tionova/core/services/summary_cache_service.dart';
import 'package:tionova/core/theme/app_theme.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
// import 'package:tionova/features/folder/domain/usecases/GenerateSummaryUseCase.dart'; // DISABLED
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/theme/presentation/bloc/theme_bloc.dart';
import 'package:tionova/features/theme/presentation/bloc/theme_state.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizcubit.dart';

import 'core/services/notification/notification_service.dart';

// Create an instance of NotificationService
final notificationService = NotificationService();

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.backgroundMessageHandler(message);
}

Future<void> main() async {
  // Initialize Flutter bindings and services
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await HiveManager.initializeHive();

  // Register all Hive adapters here to ensure they're registered before any box is opened
  // Only register if not already registered
  if (!Hive.isAdapterRegistered(0)) {
    // PdfCacheModel uses typeId 0
    Hive.registerAdapter(PdfCacheModelAdapter());
    print('Main: Registered PdfCacheModelAdapter with typeId 0');
  } else {
    print('Main: PdfCacheModelAdapter already registered with typeId 0');
  }

  if (!Hive.isAdapterRegistered(1)) {
    // UserModel now uses typeId 1
    Hive.registerAdapter(UserModelAdapter());
    print('Main: Registered UserModelAdapter with typeId 1');
  } else {
    print('Main: UserModelAdapter already registered with typeId 1');
  }

  if (!Hive.isAdapterRegistered(2)) {
    // SummaryCacheModel uses typeId 2
    Hive.registerAdapter(SummaryCacheModelAdapter());
    print('Main: Registered SummaryCacheModelAdapter with typeId 2');
  } else {
    print('Main: SummaryCacheModelAdapter already registered with typeId 2');
  }

  // Open Hive boxes with safe error handling
  await Hive.openBox("themeBox");
  await HiveManager.safeOpenBox<PdfCacheModel>('pdfCache');
  await HiveManager.safeOpenBox<SummaryCacheModel>('summaryCache');

  // Don't open auth_box here - let service locator handle it
  await setupServiceLocator();
  await DownloadService.initialize();
  await SummaryCacheService.initialize();

  // Initialize background summary service - DISABLED FOR NOW
  // print('🚀 Main: Initializing SummaryBackgroundService...');
  // final backgroundService = SummaryBackgroundService();
  // await backgroundService.initialize(
  //   generateSummaryUseCase: getIt<GenerateSummaryUseCase>(),
  // );
  // print('✅ Main: SummaryBackgroundService initialized');

  Bloc.observer = AppBlocObserver();

  AppRouter.initialize();

  // Debug: Check auth state in detail
  final authCubit = getIt<AuthCubit>();
  await authCubit.start();
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (context) => ThemeBloc(prefs: prefs)),
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<ChapterCubit>(create: (context) => getIt<ChapterCubit>()),
        BlocProvider<QuizCubit>(create: (context) => getIt<QuizCubit>()),
      ],
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                routerConfig: AppRouter.router,
                theme: ThemeData(
                  useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.blue,
                    brightness: themeState.isDarkMode
                        ? Brightness.dark
                        : Brightness.light,
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final GoRouter router;

  const MyApp({super.key, required this.prefs, required this.router});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeBloc(prefs: prefs),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'TioNova',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
