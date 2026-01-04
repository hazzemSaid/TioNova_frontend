import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tionova/core/blocobserve/blocobserv.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/core/router/app_router.dart';
import 'package:tionova/core/services/app_usage_tracker_service.dart';
import 'package:tionova/core/services/hive_manager.dart';
import 'package:tionova/core/services/notification/notification_service.dart';
import 'package:tionova/core/services/shorebird_service.dart';
import 'package:tionova/core/theme/app_theme.dart';
import 'package:tionova/core/widgets/update_checker_widget.dart';
import 'package:tionova/features/auth/data/AuthDataSource/Iauthdatasource.dart';
import 'package:tionova/features/auth/data/AuthDataSource/ilocal_auth_data_source.dart';
import 'package:tionova/features/auth/data/AuthDataSource/localauthdatasource.dart';
import 'package:tionova/features/auth/data/AuthDataSource/remoteauthdatasource.dart';
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
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/theme/presentation/bloc/theme_cubit.dart';
import 'package:tionova/firebase_options.dart';

// Background message handler - only used on non-web platforms
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kIsWeb) return; // Skip on web
  await NotificationService.backgroundMessageHandler(message);
}

class AppInitializer {
  static Future<void> initializeApp() async {
    // Initialize Flutter bindings and services
    WidgetsFlutterBinding.ensureInitialized();

    // ==========================================
    // CRITICAL: Initialize Firebase FIRST
    // ==========================================
    // Initialize Firebase - check using Firebase.apps list
    print('🔧 Checking Firebase initialization...');
    print('🔧 Number of existing Firebase apps: ${Firebase.apps.length}');

    // Skip Firebase app deletion on web – delete() not supported.
    if (!kIsWeb && Firebase.apps.isNotEmpty) {
      print('⚠️ Found existing Firebase apps:');
      for (final app in Firebase.apps) {
        print('   - App name: ${app.name}');
        print('   - App options: ${app.options}');
        print('   - Database URL: ${app.options.databaseURL}');

        // delete() is only available on mobile/desktop runtimes
        await app.delete();
        print('   ✅ Deleted app: ${app.name}');
      }
    } else if (!kIsWeb) {
      print('ℹ️ No existing Firebase apps found (this is good!)');
    } else if (kIsWeb && Firebase.apps.isNotEmpty) {
      // Web: keep existing apps; delete() throws UnsupportedError here.
      print('ℹ️ Web platform detected – keeping existing Firebase apps intact');
    }

    // Now initialize with fresh config
    print('🔧 Initializing Firebase with config...');
    print(
      '🔧 Target Database URL: ${DefaultFirebaseOptions.currentPlatform.databaseURL}',
    );

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⚠️ Firebase initialization timeout');
          throw TimeoutException('Firebase init timeout');
        },
      );
      print('✅ Firebase initialized successfully with NEW config');

      // Verify the initialized app
      final app = Firebase.app();
      print('✅ Verified app name: ${app.name}');
      print('✅ Verified Database URL: ${app.options.databaseURL}');
    } catch (e) {
      print('❌ Error initializing Firebase: $e');
      // On web, continue without Firebase if it fails
      if (!kIsWeb) {
        rethrow;
      }
      print('ℹ️ Continuing without Firebase on web...');
    }

    // ==========================================
    // Register background message handler (skip on web)
    // ==========================================
    NotificationService? notificationService;
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // ==========================================
      // Initialize Notification Service (after Firebase)
      // ==========================================
      notificationService = NotificationService();
      await notificationService.initialize(
        onNotificationTap: _handleNotificationTap,
      );
      print('✅ Push notifications initialized');
    }

    // Initialize Hive (needed for theme and auth) - with error handling for web
    try {
      await HiveManager.initializeHive();
    } catch (e) {
      print('⚠️ Hive initialization failed: $e');
      if (!kIsWeb) rethrow;
    }

    // Register Hive adapters - wrap in try-catch for web
    // Only register if Hive is available (skips on Safari private mode)

    // Open only critical boxes with timeout for web
    // Skip if Hive is not available (Safari private mode)
    if (HiveManager.isHiveAvailable) {
      try {
        await Hive.openBox("themeBox").timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            print('⚠️ Timeout opening themeBox, continuing...');
            throw TimeoutException('themeBox timeout');
          },
        );
      } catch (e) {
        print('⚠️ Error opening themeBox: $e');
        // Continue without the box on web if it fails
      }
    } else {
      print('ℹ️ Skipping themeBox (Hive not available)');
    }

    // Setup service locator (critical for auth) - with timeout for web
    try {
      await setupServiceLocator().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⚠️ Service locator setup timeout');
          throw TimeoutException('setupServiceLocator timeout');
        },
      );
    } catch (e) {
      print('⚠️ Error setting up service locator: $e');
      if (!kIsWeb) rethrow;
      // On web, we need to handle this gracefully
      print('ℹ️ Attempting minimal service locator setup for web...');
      await setupMinimalServiceLocatorForWeb();
    }

    // Initialize auth cubit with timeout for web platforms
    final authCubit = getIt<AuthCubit>();
    try {
      await authCubit.start().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          print('⚠️ AuthCubit.start() timeout, continuing with initial state');
        },
      );
    } catch (e) {
      print('⚠️ Error during authCubit.start(): $e');
      // Continue with initial state
    }

    // Initialize SharedPreferences (needed for theme)
    // Safari (especially private mode) can block localStorage
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          print('⚠️ SharedPreferences timeout (Safari private mode?)');
          throw TimeoutException('SharedPreferences timeout');
        },
      );
      print('✅ SharedPreferences initialized');
    } catch (e) {
      print('⚠️ Error getting SharedPreferences: $e');
      // On Safari, SharedPreferences might fail - we'll run without theme persistence
      prefs = null;
    }

    // Initialize router
    AppRouter.initialize();
    Bloc.observer = AppBlocObserver();

    // ==========================================
    // START APP IMMEDIATELY - Show splash screen!
    // ==========================================
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(prefs: prefs)),
          BlocProvider<AuthCubit>.value(value: authCubit),
        ],
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            return BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                return UpdateCheckerWidget(
                  child: MaterialApp.router(
                    debugShowCheckedModeBanner: false,
                    routerConfig: AppRouter.router,
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeMode,
                  ),
                );
              },
            );
          },
        ),
      ),
    );

    // ==========================================
    // DEFERRED INITIALIZATION (After first frame)
    // ==========================================
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('🔄 Starting deferred initialization...');

      try {
        // Initialize App Usage Tracker
        final usageTracker = getIt<AppUsageTrackerService>();
        await usageTracker.initialize();
        print('✅ AppUsageTrackerService initialized');

        // Initialize Shorebird Code Push
        final shorebirdService = ShorebirdService();
        await shorebirdService.initialize();
        print('✅ Shorebird Code Push initialized');

        // Get FCM token and setup notification subscriptions (skip on web)
        if (!kIsWeb && notificationService != null) {
          try {
            final token = await notificationService.getFcmToken();
            print('🔑 Device FCM Token: $token');

            // Subscribe to default topics based on user context
            // You can customize this based on your app logic
            await notificationService.subscribeToTopics([
              'all_users', // Send to all users
              // Add more topics as needed based on user role, class, etc.
            ]);
            print('✅ Subscribed to notification topics');
          } catch (e) {
            print('⚠️ Error setting up FCM: $e');
          }
        }

        print('✅ All deferred services initialized successfully');
      } catch (e) {
        print('⚠️ Error during deferred initialization: $e');
        // Don't crash the app, just log the error
      }
    });
  }

  // Handle notification tap
  static Future<void> _handleNotificationTap(RemoteMessage message) async {
    print('📬 Notification tapped: ${message.notification?.title}');
    // You can add custom navigation or logic here based on notification data
    // Example: navigate to specific screen based on notification type
    // final data = message.data;
    // if (data['type'] == 'challenge') {
    //   navigateToChallengeScreen(data['challengeId']);
    // }
  }

  /// Minimal service locator setup for web when full setup fails
  /// This provides just enough to show the auth screen
  static Future<void> setupMinimalServiceLocatorForWeb() async {
    print('🔧 Setting up minimal services for web...');

    const baseUrl = 'https://tio-nova-backend.vercel.app/api/v1';

    // Only register if not already registered
    if (!getIt.isRegistered<Dio>()) {
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      getIt.registerLazySingleton<Dio>(() => dio);
    }

    // Register TokenStorage if not registered
    if (!getIt.isRegistered<TokenStorage>()) {
      getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());
    }

    // Register AuthService if not registered
    if (!getIt.isRegistered<AuthService>()) {
      getIt.registerLazySingleton<AuthService>(
        () => AuthService(dio: getIt<Dio>()),
      );
    }

    // Register WebLocalAuthDataSource as fallback
    if (!getIt.isRegistered<ILocalAuthDataSource>()) {
      getIt.registerLazySingleton<ILocalAuthDataSource>(
        () => WebLocalAuthDataSource(),
      );
    }

    // Register IAuthDataSource if not registered
    if (!getIt.isRegistered<IAuthDataSource>()) {
      getIt.registerLazySingleton<IAuthDataSource>(
        () => Remoteauthdatasource(
          dio: getIt<Dio>(),
          authService: getIt<AuthService>(),
        ),
      );
    }

    // Register AuthRepo if not registered
    if (!getIt.isRegistered<AuthRepo>()) {
      getIt.registerLazySingleton<AuthRepo>(
        () => AuthRepoImp(
          remoteDataSource: getIt<IAuthDataSource>(),
          localDataSource: getIt<ILocalAuthDataSource>(),
        ),
      );
    }

    // Register all required use cases
    if (!getIt.isRegistered<Googleauthusecase>()) {
      getIt.registerLazySingleton<Googleauthusecase>(
        () => Googleauthusecase(authRepo: getIt<AuthRepo>()),
      );
    }

    if (!getIt.isRegistered<LoginUseCase>()) {
      getIt.registerLazySingleton<LoginUseCase>(
        () => LoginUseCase(getIt<AuthRepo>()),
      );
    }

    if (!getIt.isRegistered<RegisterUseCase>()) {
      getIt.registerLazySingleton<RegisterUseCase>(
        () => RegisterUseCase(getIt<AuthRepo>()),
      );
    }

    if (!getIt.isRegistered<VerifyEmailUseCase>()) {
      getIt.registerLazySingleton<VerifyEmailUseCase>(
        () => VerifyEmailUseCase(getIt<AuthRepo>()),
      );
    }

    if (!getIt.isRegistered<ResetPasswordUseCase>()) {
      getIt.registerLazySingleton<ResetPasswordUseCase>(
        () => ResetPasswordUseCase(getIt<AuthRepo>()),
      );
    }

    if (!getIt.isRegistered<ForgetPasswordUseCase>()) {
      getIt.registerLazySingleton<ForgetPasswordUseCase>(
        () => ForgetPasswordUseCase(getIt<AuthRepo>()),
      );
    }

    if (!getIt.isRegistered<VerifyCodeUseCase>()) {
      getIt.registerLazySingleton<VerifyCodeUseCase>(
        () => VerifyCodeUseCase(getIt<AuthRepo>()),
      );
    }

    // Register AuthCubit if not registered
    if (!getIt.isRegistered<AuthCubit>()) {
      getIt.registerLazySingleton<AuthCubit>(
        () => AuthCubit(
          googleauthusecase: getIt<Googleauthusecase>(),
          loginUseCase: getIt<LoginUseCase>(),
          registerUseCase: getIt<RegisterUseCase>(),
          verifyEmailUseCase: getIt<VerifyEmailUseCase>(),
          resetPasswordUseCase: getIt<ResetPasswordUseCase>(),
          forgetPasswordUseCase: getIt<ForgetPasswordUseCase>(),
          verifyCodeUseCase: getIt<VerifyCodeUseCase>(),
          localAuthDataSource: getIt<ILocalAuthDataSource>(),
          tokenStorage: getIt<TokenStorage>(),
        ),
      );
    }

    print('✅ Minimal web services configured');
  }

  /// Minimal web app runner for Safari fallback
  /// This runs a basic version of the app without Hive/Firebase dependencies
  static Future<void> runMinimalWebApp() async {
    print('🔧 Running minimal web app for Safari...');

    WidgetsFlutterBinding.ensureInitialized();

    // Try Firebase but don't fail if it doesn't work
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ).timeout(const Duration(seconds: 5));
      }
      print('✅ Firebase initialized in minimal mode');
    } catch (e) {
      print('⚠️ Firebase skipped in minimal mode: $e');
    }

    // Setup minimal services
    await setupMinimalServiceLocatorForWeb();

    // Get auth cubit
    final authCubit = getIt<AuthCubit>();

    // Initialize router
    AppRouter.initialize();
    Bloc.observer = AppBlocObserver();

    // Run app with system theme (no SharedPreferences dependency)
    runApp(
      MultiBlocProvider(
        providers: [BlocProvider<AuthCubit>.value(value: authCubit)],
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerConfig: AppRouter.router,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.system,
            );
          },
        ),
      ),
    );

    print('✅ Minimal web app running');
  }
}
