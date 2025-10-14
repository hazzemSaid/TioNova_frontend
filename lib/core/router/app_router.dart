import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/auth/presentation/view/screens/auth_landing_screen.dart';
import 'package:tionova/features/auth/presentation/view/screens/check_email_screen.dart';
import 'package:tionova/features/auth/presentation/view/screens/forgot_password_screen.dart';
import 'package:tionova/features/auth/presentation/view/screens/login_screen.dart';
import 'package:tionova/features/auth/presentation/view/screens/register_screen.dart';
import 'package:tionova/features/auth/presentation/view/screens/reset_password_screen.dart';
import 'package:tionova/features/auth/presentation/view/screens/verify_reset_code_screen.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/view/screens/RawSummaryViewerScreen.dart';
import 'package:tionova/features/folder/presentation/view/screens/SummaryViewerScreen.dart';
import 'package:tionova/features/folder/presentation/view/screens/chapter_detail_screen.dart';
import 'package:tionova/features/folder/presentation/view/screens/create_chapter_screen.dart';
import 'package:tionova/features/folder/presentation/view/screens/folder_detail_screen.dart';
import 'package:tionova/features/folder/presentation/view/screens/pdf_viewer_screen.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizcubit.dart';
import 'package:tionova/features/quiz/presentation/view/quiz_history_screen.dart';
import 'package:tionova/features/quiz/presentation/view/quiz_questions_screen.dart';
import 'package:tionova/features/quiz/presentation/view/quiz_results_screen.dart';
import 'package:tionova/features/quiz/presentation/view/quiz_screen.dart';
import 'package:tionova/features/start/presentation/view/screens/TioNovaspalsh.dart';
import 'package:tionova/features/start/presentation/view/screens/onboarding_screen.dart';
import 'package:tionova/utils/mainlayout.dart';

class AuthStateNotifier extends ChangeNotifier {
  AuthStateNotifier(this.authCubit) {
    _subscription = authCubit.stream.listen((state) {
      notifyListeners();
    });
  }

  final AuthCubit authCubit;
  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  AppRouter._();

  static late final GoRouter _router;
  static late final AuthStateNotifier _authNotifier;

  static GoRouter get router => _router;

  // Check if it's the first time opening the app
  static Future<bool> isFirstTime() async {
    try {
      final box = await Hive.openBox('app_settings');
      return box.get('is_first_time', defaultValue: true) as bool;
    } catch (e) {
      // If there's an error, assume it's the first time
      return true;
    }
  }

  // Mark that the app has been opened before
  static Future<void> setNotFirstTime() async {
    try {
      final box = await Hive.openBox('app_settings');
      await box.put('is_first_time', false);
    } catch (e) {
      // Handle error if needed
      print('Error setting first time flag: $e');
    }
  }

  static void initialize() {
    final authCubit = getIt<AuthCubit>();

    _authNotifier = AuthStateNotifier(authCubit);

    _router = GoRouter(
      initialLocation: '/splash',
      refreshListenable: _authNotifier,
      debugLogDiagnostics: false,
      redirect: (BuildContext context, GoRouterState state) {
        final currentAuthState = authCubit.state;
        final path = state.uri.path;

        // ✅ Authenticated user
        if (currentAuthState is AuthSuccess) {
          // Prevent going back to splash or auth screens after login
          if (path == '/splash' ||
              path.startsWith('/auth') ||
              path == '/onboarding') {
            return '/'; // go home
          }
          return null; // stay where they are
        }

        // ✅ Unauthenticated user (initial or failed auth)
        if (currentAuthState is AuthInitial ||
            currentAuthState is AuthFailure) {
          // Allow splash to handle first time check
          if (path == '/splash') return null;

          // Allow onboarding to be accessed before login
          if (path == '/onboarding') return null;

          // Block access to any protected routes (/, /notifications, etc.)
          if (!path.startsWith('/auth')) {
            return '/auth';
          }
          return null; // already inside /auth/*
        }

        // ✅ Default (e.g., loading state, if you have AuthLoading)
        return null;
      },

      routes: <RouteBase>[
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (BuildContext context, GoRouterState state) =>
              const SplashScreen(),
        ),
        GoRoute(
          path: '/',
          name: 'home',
          builder: (BuildContext context, GoRouterState state) =>
              const MainLayout(),
        ),
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (BuildContext context, GoRouterState state) =>
              const OnboardingScreen(),
        ),
        GoRoute(
          path: '/auth',
          name: 'auth',
          builder: (BuildContext context, GoRouterState state) =>
              const AuthLandingScreen(),
          routes: [
            GoRoute(
              path: 'login',
              name: 'login',
              builder: (BuildContext context, GoRouterState state) =>
                  const LoginScreen(),
            ),
            GoRoute(
              path: 'register',
              name: 'register',
              builder: (BuildContext context, GoRouterState state) =>
                  const RegisterScreen(),
            ),
            GoRoute(
              path: 'forgot-password',
              name: 'forgot-password',
              builder: (BuildContext context, GoRouterState state) =>
                  const ForgotPasswordScreen(),
            ),
            GoRoute(
              path: 'verify-reset-code',
              name: 'verify-reset-code',
              builder: (BuildContext context, GoRouterState state) =>
                  VerifyResetCodeScreen(email: state.extra as String),
            ),
            GoRoute(
              path: 'reset-password',
              name: 'reset-password',
              builder: (BuildContext context, GoRouterState state) =>
                  ResetPasswordScreen(email: state.extra as String),
            ),
            GoRoute(
              path: 'check-email',
              name: 'check-email',
              builder: (BuildContext context, GoRouterState state) =>
                  CheckEmailScreen(email: state.extra as String),
            ),
          ],
        ),
        // Quiz Routes
        GoRoute(
          path: '/quiz/:chapterId',
          name: 'quiz',
          builder: (BuildContext context, GoRouterState state) {
            final chapterId = state.pathParameters['chapterId']!;
            final extra = state.extra as Map<String, dynamic>?;
            final token = extra?['token'] as String;
            return BlocProvider<QuizCubit>(
              create: (context) => getIt<QuizCubit>(),
              child: QuizScreen(token: token, chapterId: chapterId),
            );
          },
        ),
        GoRoute(
          path: '/quiz-questions',
          name: 'quiz-questions',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra as Map<String, dynamic>;
            return QuizQuestionsScreen(
              quiz: extra['quiz'],
              answers: extra['answers'] as List<String?>,
              token: extra['token'] as String,
              chapterId: extra['chapterId'] as String,
            );
          },
        ),
        GoRoute(
          path: '/quiz-results',
          name: 'quiz-results',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra as Map<String, dynamic>;
            return QuizResultsScreen(
              quiz: extra['quiz'],
              userAnswers: extra['userAnswers'] as List<String?>,
              token: extra['token'] as String,
              chapterId: extra['chapterId'] as String,
              timeTaken: extra['timeTaken'] as int,
            );
          },
        ),
        GoRoute(
          path: '/quiz-history/:chapterId',
          name: 'quiz-history',
          builder: (BuildContext context, GoRouterState state) {
            final chapterId = state.pathParameters['chapterId']!;
            final extra = state.extra as Map<String, dynamic>;
            return QuizHistoryScreen(
              token: extra['token'] as String,
              chapterId: chapterId,
              quizTitle: extra['quizTitle'] as String,
            );
          },
        ),
        // Folder & Chapter Routes
        GoRoute(
          path: '/folder/:folderId',
          name: 'folder-detail',
          builder: (BuildContext context, GoRouterState state) {
            final folderId = state.pathParameters['folderId']!;
            final extra = state.extra as Map<String, dynamic>;
            return FolderDetailScreen(
              folderId: folderId,
              title: extra['title'] as String,
              subtitle: extra['subtitle'] as String,
              chapters: extra['chapters'] as int,
              passed: extra['passed'] as int,
              attempted: extra['attempted'] as int,
              color: extra['color'] as Color,
            );
          },
        ),
        GoRoute(
          path: '/chapter/:chapterId',
          name: 'chapter-detail',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra as Map<String, dynamic>;
            return BlocProvider<ChapterCubit>(
              create: (context) => getIt<ChapterCubit>(),
              child: ChapterDetailScreen(
                chapter: extra['chapter'] as ChapterModel,
                folderColor: extra['folderColor'] as Color? ?? Colors.blue,
              ),
            );
          },
        ),
        GoRoute(
          path: '/create-chapter/:folderId',
          name: 'create-chapter',
          builder: (BuildContext context, GoRouterState state) {
            final folderId = state.pathParameters['folderId']!;
            final extra = state.extra as Map<String, dynamic>?;
            return CreateChapterScreen(
              folderId: folderId,
              folderTitle: extra?['folderTitle'] as String? ?? 'Folder',
            );
          },
        ),
        GoRoute(
          path: '/pdf-viewer/:chapterId',
          name: 'pdf-viewer',
          builder: (BuildContext context, GoRouterState state) {
            final chapterId = state.pathParameters['chapterId']!;
            final extra = state.extra as Map<String, dynamic>?;
            return PDFViewerScreen(
              chapterId: chapterId,
              chapterTitle: extra?['chapterTitle'] as String? ?? 'PDF Viewer',
            );
          },
        ),
        GoRoute(
          path: '/summary-viewer',
          name: 'summary-viewer',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra as Map<String, dynamic>;
            return SummaryViewerScreen(
              summaryData: extra['summaryData'] as SummaryModel,
              chapterTitle: extra['chapterTitle'] as String,
              accentColor: extra['accentColor'] as Color? ?? Colors.blue,
            );
          },
        ),
        GoRoute(
          path: '/raw-summary-viewer',
          name: 'raw-summary-viewer',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra as Map<String, dynamic>;
            return RawSummaryViewerScreen(
              summaryText: extra['summaryText'] as String,
              chapterTitle: extra['chapterTitle'] as String,
              accentColor: extra['accentColor'] as Color? ?? Colors.blue,
            );
          },
        ),
        // GoRoute(
        //   path: '/notifications',
        //   name: 'notifications',
        //   builder: (BuildContext context, GoRouterState state) =>
        //       const NotificationsScreen(),
        // ),
      ],
    );
  }
}
