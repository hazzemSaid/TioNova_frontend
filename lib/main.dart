// // main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:tionova/core/services/notification/notification_service.dart';
import 'package:tionova/core/services/shorebird_service.dart';
import 'package:tionova/core/services/summary_cache_service.dart';
import 'package:tionova/core/theme/app_theme.dart';
import 'package:tionova/core/widgets/update_checker_widget.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/theme/presentation/bloc/theme_cubit.dart';
import 'package:tionova/firebase_options.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.backgroundMessageHandler(message);
}

// Handle notification tap
Future<void> _handleNotificationTap(RemoteMessage message) async {
  print('📬 Notification tapped: ${message.notification?.title}');
  // You can add custom navigation or logic here based on notification data
  // Example: navigate to specific screen based on notification type
  // final data = message.data;
  // if (data['type'] == 'challenge') {
  //   navigateToChallengeScreen(data['challengeId']);
  // }
}

Future<void> main() async {
  // Initialize Flutter bindings and services
  WidgetsFlutterBinding.ensureInitialized();

  // ==========================================
  // CRITICAL: Initialize Firebase FIRST
  // ==========================================
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

  // ==========================================
  // Register background message handler
  // ==========================================
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ==========================================
  // Initialize Notification Service (after Firebase)
  // ==========================================
  final notificationService = NotificationService();
  await notificationService.initialize(
    onNotificationTap: _handleNotificationTap,
  );

  print('✅ Push notifications initialized');

  // Initialize Hive (needed for theme and auth)
  await HiveManager.initializeHive();

  // Register Hive adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(PdfCacheModelAdapter());
    print('Main: Registered PdfCacheModelAdapter with typeId 0');
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(UserModelAdapter());
    print('Main: Registered UserModelAdapter with typeId 1');
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(SummaryCacheModelAdapter());
    print('Main: Registered SummaryCacheModelAdapter with typeId 2');
  }

  // Open only critical boxes
  await Hive.openBox("themeBox");

  // Setup service locator (critical for auth)
  await setupServiceLocator();

  // Initialize auth cubit
  final authCubit = getIt<AuthCubit>();
  await authCubit.start();

  // Initialize SharedPreferences (needed for theme)
  final prefs = await SharedPreferences.getInstance();

  // Initialize router
  AppRouter.initialize();
  Bloc.observer = AppBlocObserver();

  // ==========================================
  // START APP IMMEDIATELY - Show splash screen!
  // ==========================================
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit(prefs: prefs)),
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
      // Open cache boxes in background
      await HiveManager.safeOpenBox<PdfCacheModel>('pdfCache');
      await HiveManager.safeOpenBox<SummaryCacheModel>('summaryCache');
      print('✅ Cache boxes opened');

      // Initialize download service
      await DownloadService.initialize();
      print('✅ DownloadService initialized');

      // Initialize summary cache service
      await SummaryCacheService.initialize();
      print('✅ SummaryCacheService initialized');

      // Initialize App Usage Tracker
      final usageTracker = getIt<AppUsageTrackerService>();
      await usageTracker.initialize();
      print('✅ AppUsageTrackerService initialized');

      // Initialize Shorebird Code Push
      final shorebirdService = ShorebirdService();
      await shorebirdService.initialize();
      print('✅ Shorebird Code Push initialized');

      // Get FCM token and setup notification subscriptions
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

      print('✅ All deferred services initialized successfully');
    } catch (e) {
      print('⚠️ Error during deferred initialization: $e');
      // Don't crash the app, just log the error
    }
  });
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
