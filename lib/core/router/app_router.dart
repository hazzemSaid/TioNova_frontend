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
import 'package:tionova/features/challenges/presentation/bloc/challenge_cubit.dart';
import 'package:tionova/features/challenges/presentation/view/screens/EnterCode_screen.dart';
import 'package:tionova/features/challenges/presentation/view/screens/challange_screen.dart';
import 'package:tionova/features/challenges/presentation/view/screens/challenge_completion_screen.dart';
import 'package:tionova/features/challenges/presentation/view/screens/challenge_waiting_lobby_screen.dart';
import 'package:tionova/features/challenges/presentation/view/screens/create_challenge_screen.dart';
import 'package:tionova/features/challenges/presentation/view/screens/live_question_screen.dart';
import 'package:tionova/features/challenges/presentation/view/screens/qr_scanner_screen.dart';
import 'package:tionova/features/challenges/presentation/view/screens/select_chapter_screen.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/data/models/mindmapmodel.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/features/folder/presentation/view/screens/RawSummaryViewerScreen.dart';
import 'package:tionova/features/folder/presentation/view/screens/SummaryViewerScreen.dart';
import 'package:tionova/features/folder/presentation/view/screens/chapter_detail_screen.dart';
import 'package:tionova/features/folder/presentation/view/screens/create_chapter_screen.dart';
import 'package:tionova/features/folder/presentation/view/screens/folder_detail_screen.dart';
import 'package:tionova/features/folder/presentation/view/screens/mindmap_screen.dart';
import 'package:tionova/features/folder/presentation/view/screens/notes_screen.dart';
import 'package:tionova/features/folder/presentation/view/screens/pdf_viewer_screen.dart';
import 'package:tionova/features/preferences/presentation/screens/preferences_screen.dart';
import 'package:tionova/features/quiz/data/models/UserQuizStatusModel.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizcubit.dart';
import 'package:tionova/features/quiz/presentation/view/quiz_history_screen.dart';
import 'package:tionova/features/quiz/presentation/view/quiz_questions_screen.dart';
import 'package:tionova/features/quiz/presentation/view/quiz_results_screen.dart';
import 'package:tionova/features/quiz/presentation/view/quiz_screen.dart';
import 'package:tionova/features/start/presentation/view/screens/TioNovaspalsh.dart';
import 'package:tionova/features/start/presentation/view/screens/onboarding_screen.dart';
import 'package:tionova/features/start/presentation/view/screens/theme_selection_screen.dart';
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
              path == '/onboarding' ||
              path == '/theme-selection') {
            return '/'; // go home
          }
          return null; // stay where they are
        }

        // ✅ Unauthenticated user (initial or failed auth)
        if (currentAuthState is AuthInitial ||
            currentAuthState is AuthFailure) {
          // Allow splash to handle first time check
          if (path == '/splash') return null;

          // Allow theme selection before onboarding
          if (path == '/theme-selection') return null;

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
              MultiBlocProvider(
                providers: [
                  BlocProvider<FolderCubit>(
                    create: (context) => getIt<FolderCubit>(),
                  ),
                  BlocProvider<ChapterCubit>(
                    create: (context) => getIt<ChapterCubit>(),
                  ),
                ],
                child: const MainLayout(),
              ),
        ),
        GoRoute(
          path: '/theme-selection',
          name: 'theme-selection',
          builder: (BuildContext context, GoRouterState state) =>
              const ThemeSelectionScreen(),
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
              builder: (BuildContext context, GoRouterState state) {
                final extra = state.extra as Map<String, dynamic>;
                return ResetPasswordScreen(
                  email: extra['email'] as String,
                  code: extra['code'] as String,
                );
              },
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
            return BlocProvider<QuizCubit>(
              create: (context) => getIt<QuizCubit>(),
              child: QuizScreen(chapterId: chapterId),
            );
          },
        ),
        GoRoute(
          path: '/quiz-questions',
          name: 'quiz-questions',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra as Map<String, dynamic>;
            return BlocProvider<QuizCubit>(
              create: (context) => getIt<QuizCubit>(),
              child: QuizQuestionsScreen(
                quiz: extra['quiz'],
                answers: extra['answers'] as List<String?>,
                chapterId: extra['chapterId'] as String,
              ),
            );
          },
        ),
        GoRoute(
          path: '/quiz-results',
          name: 'quiz-results',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra as Map<String, dynamic>;
            return BlocProvider<QuizCubit>(
              create: (context) => getIt<QuizCubit>(),
              child: QuizResultsScreen(
                quiz: extra['quiz'],
                userAnswers: extra['userAnswers'] as List<String?>,
                chapterId: extra['chapterId'] as String,
                timeTaken: extra['timeTaken'] as int,
              ),
            );
          },
        ),
        GoRoute(
          path: '/quiz-history/:chapterId',
          name: 'quiz-history',
          builder: (BuildContext context, GoRouterState state) {
            final chapterId = state.pathParameters['chapterId']!;
            final extra = state.extra as Map<String, dynamic>;
            return BlocProvider<QuizCubit>(
              create: (context) => getIt<QuizCubit>(),
              child: QuizHistoryScreen(
                chapterId: chapterId,
                quizTitle: extra['quizTitle'] as String,
              ),
            );
          },
        ),
        GoRoute(
          path: '/quiz-review',
          name: 'quiz-review',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra as Map<String, dynamic>;
            return BlocProvider<QuizCubit>(
              create: (context) => getIt<QuizCubit>(),
              child: QuizReviewScreen(attempt: extra['attempt'] as Attempt),
            );
          },
        ),
        // Folder & Chapter Routes
        GoRoute(
          path: '/folder/:folderId',
          name: 'folder-detail',
          builder: (BuildContext context, GoRouterState state) {
            final folderId = state.pathParameters['folderId']!;
            final extra = state.extra as Map<String, dynamic>?;
            return BlocProvider<ChapterCubit>(
              create: (context) => getIt<ChapterCubit>(),
              child: FolderDetailScreen(
                folderId: folderId,
                title: extra?['title'] as String? ?? 'Folder',
                subtitle: extra?['subtitle'] as String? ?? 'Subtitle',
                chapters: extra?['chapters'] as int? ?? 0,
                passed: extra?['passed'] as int? ?? 0,
                attempted: extra?['attempted'] as int? ?? 0,
                color: extra?['color'] as Color? ?? Colors.blue,
              ),
            );
          },
        ),
        GoRoute(
          path: '/chapter/:chapterId',
          name: 'chapter-detail',
          builder: (BuildContext context, GoRouterState state) {
            final extra = (state.extra as Map<String, dynamic>?) ?? {};
            final existingCubit =
                extra['chapterCubit'] as ChapterCubit? ?? null;
            final child = ChapterDetailScreen(
              chapter: extra['chapter'] as ChapterModel,
              folderColor: extra['folderColor'] as Color? ?? Colors.blue,
            );
            if (existingCubit != null) {
              return BlocProvider.value(value: existingCubit, child: child);
            }
            return BlocProvider<ChapterCubit>(
              create: (context) => getIt<ChapterCubit>(),
              child: child,
            );
          },
        ),
        GoRoute(
          path: '/create-chapter/:folderId',
          name: 'create-chapter',
          builder: (BuildContext context, GoRouterState state) {
            final folderId = state.pathParameters['folderId']!;
            final extra = state.extra as Map<String, dynamic>?;
            final existingCubit =
                extra?['chapterCubit'] as ChapterCubit? ?? null;
            final child = CreateChapterScreen(
              folderId: folderId,
              folderTitle: extra?['folderTitle'] as String? ?? 'Folder',
            );
            if (existingCubit != null) {
              return BlocProvider.value(value: existingCubit, child: child);
            }
            return BlocProvider<ChapterCubit>(
              create: (context) => getIt<ChapterCubit>(),
              child: child,
            );
          },
        ),
        GoRoute(
          path: '/pdf-viewer/:chapterId',
          name: 'pdf-viewer',
          builder: (BuildContext context, GoRouterState state) {
            final chapterId = state.pathParameters['chapterId']!;
            final extra = state.extra as Map<String, dynamic>?;
            final existingCubit =
                extra?['chapterCubit'] as ChapterCubit? ?? null;
            final child = PDFViewerScreen(
              chapterId: chapterId,
              chapterTitle: extra?['chapterTitle'] as String? ?? 'PDF Viewer',
            );
            if (existingCubit != null) {
              return BlocProvider.value(value: existingCubit, child: child);
            }
            return BlocProvider<ChapterCubit>(
              create: (context) => getIt<ChapterCubit>(),
              child: child,
            );
          },
        ),
        GoRoute(
          path: '/chapter/:chapterId/notes',
          name: 'chapter-notes',
          builder: (BuildContext context, GoRouterState state) {
            final chapterId = state.pathParameters['chapterId']!;
            final extra = state.extra as Map<String, dynamic>?;
            final chapterCubit = extra?['chapterCubit'] as ChapterCubit?;
            final child = NotesScreen(
              chapterId: chapterId,
              chapterTitle: extra?['chapterTitle'] as String? ?? 'Notes',
              accentColor: extra?['accentColor'] as Color?,
            );
            if (chapterCubit != null) {
              return BlocProvider.value(value: chapterCubit, child: child);
            }
            return BlocProvider<ChapterCubit>(
              create: (context) => getIt<ChapterCubit>(),
              child: child,
            );
          },
        ),
        GoRoute(
          path: '/mindmap-viewer',
          name: 'mindmap-viewer',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra as Map<String, dynamic>?;
            final mindmap = extra?['mindmap'] as Mindmapmodel?;
            if (mindmap == null) {
              throw ArgumentError('Mindmap data is required for this route');
            }
            return MindmapScreen(mindmap: mindmap);
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
        GoRoute(
          path: '/challenges',
          name: 'challenges',
          builder: (BuildContext context, GoRouterState state) =>
              BlocProvider<ChallengeCubit>(
                create: (context) => getIt<ChallengeCubit>(),
                child: ChallangeScreen(),
              ),
        ),
        GoRoute(
          path: '/challenges/scan-qr',
          name: 'scan-qr',
          builder: (BuildContext context, GoRouterState state) =>
              BlocProvider<ChallengeCubit>(
                create: (context) => getIt<ChallengeCubit>(),
                child: const QrScannerScreen(),
              ),
        ),
        GoRoute(
          path: '/challenges/waiting/:code',
          name: 'challenge-waiting',
          builder: (BuildContext context, GoRouterState state) {
            final code = state.pathParameters['code']!;
            final extra = state.extra as Map<String, dynamic>?;
            final challengeCubit =
                extra?['challengeCubit'] as ChallengeCubit? ?? null;
            final authCubit = extra?['authCubit'] as AuthCubit? ?? null;
            final child = ChallengeWaitingLobbyScreen(
              challengeCode: code,
              challengeName: extra?['challengeName'] as String? ?? 'Challenge',
            );
            if (challengeCubit != null || authCubit != null) {
              return MultiBlocProvider(
                providers: [
                  if (challengeCubit != null)
                    BlocProvider.value(value: challengeCubit)
                  else
                    BlocProvider<ChallengeCubit>(
                      create: (context) => getIt<ChallengeCubit>(),
                    ),
                  if (authCubit != null)
                    BlocProvider.value(value: authCubit)
                  else
                    BlocProvider<AuthCubit>(
                      create: (context) => getIt<AuthCubit>(),
                    ),
                ],
                child: child,
              );
            }
            return BlocProvider<ChallengeCubit>(
              create: (context) => getIt<ChallengeCubit>(),
              child: child,
            );
          },
        ),
        GoRoute(
          path: '/enter-code',
          name: 'enter-code',
          builder: (BuildContext context, GoRouterState state) {
            return BlocProvider<ChallengeCubit>(
              create: (context) => getIt<ChallengeCubit>(),
              child: EntercodeScreen(),
            );
          },
        ),
        GoRoute(
          path: '/challenges/select',
          name: 'challenge-select',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra as Map<String, dynamic>?;
            final folderCubit = extra?['folderCubit'] as FolderCubit?;
            final chapterCubit = extra?['chapterCubit'] as ChapterCubit?;
            final authCubit = extra?['authCubit'] as AuthCubit?;
            final challengeCubit = extra?['challengeCubit'] as ChallengeCubit?;
            return MultiBlocProvider(
              providers: [
                if (folderCubit != null)
                  BlocProvider.value(value: folderCubit)
                else
                  BlocProvider<FolderCubit>(
                    create: (context) => getIt<FolderCubit>(),
                  ),
                if (chapterCubit != null)
                  BlocProvider.value(value: chapterCubit)
                else
                  BlocProvider<ChapterCubit>(
                    create: (context) => getIt<ChapterCubit>(),
                  ),
                if (authCubit != null)
                  BlocProvider.value(value: authCubit)
                else
                  BlocProvider<AuthCubit>(
                    create: (context) => getIt<AuthCubit>(),
                  ),
                if (challengeCubit != null)
                  BlocProvider.value(value: challengeCubit)
                else
                  BlocProvider<ChallengeCubit>(
                    create: (context) => getIt<ChallengeCubit>(),
                  ),
              ],
              child: const SelectChapterScreen(),
            );
          },
        ),
        GoRoute(
          path: '/challenges/create',
          name: 'challenge-create',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra as Map<String, dynamic>?;
            final challengeCubit = extra?['challengeCubit'] as ChallengeCubit?;
            final authCubit = extra?['authCubit'] as AuthCubit?;
            final folderCubit = extra?['folderCubit'] as FolderCubit?;
            final chapterCubit = extra?['chapterCubit'] as ChapterCubit?;
            final child = CreateChallengeScreen(
              challengeName: extra?['challengeName'] as String?,
              questionsCount: extra?['questionsCount'] as int? ?? 10,
              durationMinutes: extra?['durationMinutes'] as int? ?? 15,
              inviteCode: extra?['inviteCode'] as String? ?? 'Q4DRE9',
              chapterName: extra?['chapterName'] as String?,
              chapterDescription: extra?['chapterDescription'] as String?,
            );
            return MultiBlocProvider(
              providers: [
                if (challengeCubit != null)
                  BlocProvider.value(value: challengeCubit)
                else
                  BlocProvider<ChallengeCubit>(
                    create: (context) => getIt<ChallengeCubit>(),
                  ),
                if (authCubit != null)
                  BlocProvider.value(value: authCubit)
                else
                  BlocProvider<AuthCubit>(
                    create: (context) => getIt<AuthCubit>(),
                  ),
                if (folderCubit != null)
                  BlocProvider.value(value: folderCubit)
                else
                  BlocProvider<FolderCubit>(
                    create: (context) => getIt<FolderCubit>(),
                  ),
                if (chapterCubit != null)
                  BlocProvider.value(value: chapterCubit)
                else
                  BlocProvider<ChapterCubit>(
                    create: (context) => getIt<ChapterCubit>(),
                  ),
              ],
              child: child,
            );
          },
        ),
        GoRoute(
          path: '/challenges/live/:code',
          name: 'challenge-live',
          builder: (BuildContext context, GoRouterState state) {
            final code = state.pathParameters['code']!;
            final extra = state.extra as Map<String, dynamic>?;
            final challengeCubit = extra?['challengeCubit'] as ChallengeCubit?;
            final authCubit = extra?['authCubit'] as AuthCubit?;
            return MultiBlocProvider(
              providers: [
                if (challengeCubit != null)
                  BlocProvider.value(value: challengeCubit)
                else
                  BlocProvider<ChallengeCubit>(
                    create: (context) => getIt<ChallengeCubit>(),
                  ),
                if (authCubit != null)
                  BlocProvider.value(value: authCubit)
                else
                  BlocProvider<AuthCubit>(
                    create: (context) => getIt<AuthCubit>(),
                  ),
              ],
              child: LiveQuestionScreen(
                challengeCode: code,
                challengeName:
                    extra?['challengeName'] as String? ?? 'Challenge',
              ),
            );
          },
        ),
        GoRoute(
          path: '/challenges/completed/:code',
          name: 'challenge-complete',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra as Map<String, dynamic>?;
            return ChallengeCompletionScreen(
              challengeName: extra?['challengeName'] as String? ?? 'Challenge',
              finalScore: extra?['finalScore'] as int? ?? 0,
              correctAnswers: extra?['correctAnswers'] as int? ?? 0,
              totalQuestions: extra?['totalQuestions'] as int? ?? 0,
              accuracy: extra?['accuracy'] as double? ?? 0,
              rank: extra?['rank'] as int? ?? 0,
              leaderboard:
                  extra?['leaderboard'] as List<Map<String, dynamic>>? ??
                  const <Map<String, dynamic>>[],
            );
          },
        ),
        // Preferences Route
        GoRoute(
          path: '/preferences',
          name: 'preferences',
          builder: (BuildContext context, GoRouterState state) =>
              const PreferencesScreen(),
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
