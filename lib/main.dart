// // main.dart
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tionova/core/blocobserve/blocobserv.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/core/models/pdf_cache_model.dart';
import 'package:tionova/core/models/summary_cache_model.dart';
import 'package:tionova/core/router/app_router.dart';
import 'package:tionova/core/services/app_usage_tracker_service.dart';
import 'package:tionova/core/services/download_service.dart';
import 'package:tionova/core/services/hive_manager.dart';
// import 'package:tionova/core/services/summary_background_service.dart'; // DISABLED
import 'package:tionova/core/services/summary_cache_service.dart';
import 'package:tionova/core/theme/app_theme.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/theme/presentation/bloc/theme_cubit.dart';
import 'package:tionova/firebase_options.dart';

// Create an instance of NotificationService
// final notificationService = NotificationService();

// // Background message handler
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await NotificationService.backgroundMessageHandler(message);
// }

Future<void> main() async {
  // Initialize Flutter bindings and services
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase - check using Firebase.apps list
  print('🔧 Checking Firebase initialization...');
  print('🔧 Number of existing Firebase apps: ${Firebase.apps.length}');

  if (Firebase.apps.isNotEmpty) {
    print('⚠️ Found existing Firebase apps:');
    for (var app in Firebase.apps) {
      print('   - App name: ${app.name}');
      print('   - App options: ${app.options}');
      print('   - Database URL: ${app.options.databaseURL}');

      // Delete the app
      await app.delete();
      print('   ✅ Deleted app: ${app.name}');
    }
  } else {
    print('ℹ️ No existing Firebase apps found (this is good!)');
  }

  // Now initialize with fresh config
  print('🔧 Initializing Firebase with config...');
  print(
    '🔧 Target Database URL: ${DefaultFirebaseOptions.currentPlatform.databaseURL}',
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully with NEW config');

    // Verify the initialized app
    final app = Firebase.app();
    print('✅ Verified app name: ${app.name}');
    print('✅ Verified Database URL: ${app.options.databaseURL}');
  } catch (e) {
    print('❌ Error initializing Firebase: $e');
    rethrow;
  }

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

  // Initialize App Usage Tracker
  print('🚀 Main: Initializing AppUsageTrackerService...');
  final usageTracker = getIt<AppUsageTrackerService>();
  await usageTracker.initialize();
  print('✅ Main: AppUsageTrackerService initialized');

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
    MultiBlocProvider(
      providers: [
        // Global providers - needed throughout the app
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit(prefs: prefs)),
        BlocProvider<AuthCubit>.value(value: authCubit),
      ],
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                routerConfig: AppRouter.router,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
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
      create: (context) => ThemeCubit(prefs: prefs),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'TioNova',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
