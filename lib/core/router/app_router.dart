import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
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
import 'package:tionova/features/folder/presentation/view/screens/folder_screen.dart';
import 'package:tionova/features/folder/presentation/view/screens/mindmap_screen.dart';
import 'package:tionova/features/folder/presentation/view/screens/notes_screen.dart';
import 'package:tionova/features/folder/presentation/view/screens/pdf_viewer_screen.dart';
import 'package:tionova/features/home/presentation/view/screens/home_screen.dart';
import 'package:tionova/features/preferences/presentation/Bloc/PreferencesCubit.dart';
import 'package:tionova/features/preferences/presentation/screens/preferences_screen.dart';
import 'package:tionova/features/profile/data/models/profile_model.dart';
import 'package:tionova/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:tionova/features/profile/presentation/view/screens/edit_profile_screen.dart';
import 'package:tionova/features/profile/presentation/view/screens/profile_screen.dart';
import 'package:tionova/features/quiz/data/models/UserQuizStatusModel.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizcubit.dart';
import 'package:tionova/features/quiz/presentation/view/practice_mode_screen.dart';
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
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  // Check if it's the first time opening the app
  static Future<bool> isFirstTime() async {
    // On web, skip first-time check and go directly to auth
    if (kIsWeb) {
      return false; // Skip onboarding on web
    }

    try {
      final box = await Hive.openBox('app_settings').timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          throw TimeoutException('Hive box open timeout');
        },
      );
      return box.get('is_first_time', defaultValue: true) as bool;
    } catch (e) {
      // If there's an error, assume it's the first time
      print('⚠️ Error checking first time: $e');
      return true;
    }
  }

  // Mark that the app has been opened before
  static Future<void> setNotFirstTime() async {
    if (kIsWeb) return; // Skip on web

    try {
      final box = await Hive.openBox('app_settings').timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          throw TimeoutException('Hive box open timeout');
        },
      );
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
      navigatorKey: navigatorKey,
      initialLocation: '/splash',
      refreshListenable: _authNotifier,
      debugLogDiagnostics: false,
      redirect: (BuildContext context, GoRouterState state) async {
        final currentAuthState = authCubit.state;
        final path = state.uri.path;

        // ✅ Authenticated user
        if (currentAuthState is AuthSuccess) {
          if (path == '/splash') return null;

          if (path.startsWith('/auth') ||
              path == '/onboarding' ||
              path == '/theme-selection') {
            final isnew = await getIt<PreferencesCubit>().checkIfNewUser();
            if (isnew) {
              return '/settings/preferences';
            }
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
        // ════════════════════════════════════════════════════════════════════
        // SPLASH & ONBOARDING ROUTES
        // ════════════════════════════════════════════════════════════════════
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/theme-selection',
          name: 'theme-selection',
          builder: (context, state) => const ThemeSelectionScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),

        // ════════════════════════════════════════════════════════════════════
        // AUTH ROUTES: /auth/*
        // ════════════════════════════════════════════════════════════════════
        GoRoute(
          path: '/auth',
          name: 'auth',
          builder: (context, state) => const AuthLandingScreen(),
          routes: [
            GoRoute(
              path: 'login',
              name: 'login',
              builder: (context, state) => const LoginScreen(),
            ),
            GoRoute(
              path: 'register',
              name: 'register',
              builder: (context, state) => const RegisterScreen(),
            ),
            GoRoute(
              path: 'forgot-password',
              name: 'forgot-password',
              builder: (context, state) => const ForgotPasswordScreen(),
            ),
            GoRoute(
              path: 'verify-reset-code',
              name: 'verify-reset-code',
              builder: (context, state) =>
                  VerifyResetCodeScreen(email: state.extra as String),
            ),
            GoRoute(
              path: 'reset-password',
              name: 'reset-password',
              builder: (context, state) {
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
              builder: (context, state) =>
                  CheckEmailScreen(email: state.extra as String),
            ),
          ],
        ),

        // ════════════════════════════════════════════════════════════════════
        // MAIN SHELL ROUTES (with MainLayout navigation)
        // ════════════════════════════════════════════════════════════════════
        ShellRoute(
          builder: (context, state, child) => MainLayout(child: child),
          routes: [
            // ──────────────────────────────────────────────────────────────────
            // HOME: /
            // ──────────────────────────────────────────────────────────────────
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),

            // ──────────────────────────────────────────────────────────────────
            // FOLDERS: /folders
            // ──────────────────────────────────────────────────────────────────
            GoRoute(
              path: '/folders',
              name: 'folders',
              builder: (context, state) => MultiBlocProvider(
                providers: [
                  BlocProvider<FolderCubit>(
                    create: (context) => getIt<FolderCubit>(),
                  ),
                  BlocProvider<ChapterCubit>(
                    create: (context) => getIt<ChapterCubit>(),
                  ),
                ],
                child: const FolderScreen(),
              ),
            ),

            // ──────────────────────────────────────────────────────────────────
            // CHALLENGES: /challenges
            // ──────────────────────────────────────────────────────────────────
            GoRoute(
              path: '/challenges',
              name: 'challenges',
              builder: (context, state) => BlocProvider<ChallengeCubit>(
                create: (context) => getIt<ChallengeCubit>(),
                child: const ChallangeScreen(),
              ),
            ),

            // ──────────────────────────────────────────────────────────────────
            // PROFILE: /profile
            // ──────────────────────────────────────────────────────────────────
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => BlocProvider<ProfileCubit>(
                create: (context) => getIt<ProfileCubit>()..fetchProfile(),
                child: const ProfileScreen(),
              ),
            ),

            // ──────────────────────────────────────────────────────────────────
            // SETTINGS ROUTES: /settings/*
            // ──────────────────────────────────────────────────────────────────
            GoRoute(
              path: '/settings/preferences',
              name: 'preferences',
              builder: (context, state) => BlocProvider<PreferencesCubit>(
                create: (_) => getIt<PreferencesCubit>(),
                child: const PreferencesScreen(),
              ),
            ),

            // ──────────────────────────────────────────────────────────────────
            // PROFILE EDIT ROUTE: /profile/edit
            // ──────────────────────────────────────────────────────────────────
            GoRoute(
              path: '/profile/edit',
              name: 'profile-edit',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                final profile = extra?['profile'] as Profile?;
                final profileCubit = extra?['profileCubit'] as ProfileCubit?;

                if (profile == null) {
                  throw ArgumentError('Profile is required for this route');
                }

                final child = EditProfileScreen(profile: profile);

                if (profileCubit != null) {
                  return BlocProvider.value(value: profileCubit, child: child);
                }
                return BlocProvider<ProfileCubit>(
                  create: (context) => getIt<ProfileCubit>(),
                  child: child,
                );
              },
            ),

            // ──────────────────────────────────────────────────────────────────
            // FOLDER DETAIL ROUTES: /folders/:folderId/*
            // ──────────────────────────────────────────────────────────────────
            GoRoute(
              path: '/folders/:folderId',
              name: 'folder-detail',
              builder: (context, state) {
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
                    ownerId: extra?['ownerId'] as String? ?? '',
                  ),
                );
              },
              routes: [
                // Create new chapter: /folders/:folderId/chapters/new
                GoRoute(
                  path: 'chapters/new',
                  name: 'create-chapter',
                  builder: (context, state) {
                    final folderId = state.pathParameters['folderId']!;
                    final extra = state.extra as Map<String, dynamic>?;
                    final existingCubit =
                        extra?['chapterCubit'] as ChapterCubit?;
                    final child = CreateChapterScreen(
                      folderId: folderId,
                      folderTitle: extra?['folderTitle'] as String? ?? 'Folder',
                    );
                    if (existingCubit != null) {
                      return BlocProvider.value(
                        value: existingCubit,
                        child: child,
                      );
                    }
                    return BlocProvider<ChapterCubit>(
                      create: (context) => getIt<ChapterCubit>(),
                      child: child,
                    );
                  },
                ),

                // Chapter detail: /folders/:folderId/chapters/:chapterId
                GoRoute(
                  path: 'chapters/:chapterId',
                  name: 'chapter-detail',
                  builder: (context, state) {
                    final extra = (state.extra as Map<String, dynamic>?) ?? {};
                    final existingCubit =
                        extra['chapterCubit'] as ChapterCubit?;
                    final child = ChapterDetailScreen(
                      chapter: extra['chapter'] as ChapterModel,
                      folderColor:
                          extra['folderColor'] as Color? ?? Colors.blue,
                      folderOwnerId: extra['folderOwnerId'] as String?,
                    );
                    if (existingCubit != null) {
                      return BlocProvider.value(
                        value: existingCubit,
                        child: child,
                      );
                    }
                    return BlocProvider<ChapterCubit>(
                      create: (context) => getIt<ChapterCubit>(),
                      child: child,
                    );
                  },
                  routes: [
                    // PDF Viewer: /folders/:folderId/chapters/:chapterId/pdf
                    GoRoute(
                      path: 'pdf',
                      name: 'chapter-pdf',
                      builder: (context, state) {
                        final chapterId = state.pathParameters['chapterId']!;
                        final extra = state.extra as Map<String, dynamic>?;
                        final existingCubit =
                            extra?['chapterCubit'] as ChapterCubit?;
                        final child = PDFViewerScreen(
                          chapterId: chapterId,
                          chapterTitle:
                              extra?['chapterTitle'] as String? ?? 'PDF Viewer',
                        );
                        if (existingCubit != null) {
                          return BlocProvider.value(
                            value: existingCubit,
                            child: child,
                          );
                        }
                        return BlocProvider<ChapterCubit>(
                          create: (context) => getIt<ChapterCubit>(),
                          child: child,
                        );
                      },
                    ),

                    // Notes: /folders/:folderId/chapters/:chapterId/notes
                    GoRoute(
                      path: 'notes',
                      name: 'chapter-notes',
                      builder: (context, state) {
                        final chapterId = state.pathParameters['chapterId']!;
                        final extra = state.extra as Map<String, dynamic>?;
                        final chapterCubit =
                            extra?['chapterCubit'] as ChapterCubit?;
                        final child = NotesScreen(
                          chapterId: chapterId,
                          chapterTitle:
                              extra?['chapterTitle'] as String? ?? 'Notes',
                          accentColor: extra?['accentColor'] as Color?,
                          folderOwnerId: extra?['folderOwnerId'] as String?,
                        );
                        if (chapterCubit != null) {
                          return BlocProvider.value(
                            value: chapterCubit,
                            child: child,
                          );
                        }
                        return BlocProvider<ChapterCubit>(
                          create: (context) => getIt<ChapterCubit>(),
                          child: child,
                        );
                      },
                    ),

                    // Summary: /folders/:folderId/chapters/:chapterId/summary
                    GoRoute(
                      path: 'summary',
                      name: 'chapter-summary',
                      builder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>;
                        return SummaryViewerScreen(
                          summaryData: extra['summaryData'] as SummaryModel,
                          chapterTitle: extra['chapterTitle'] as String,
                          accentColor:
                              extra['accentColor'] as Color? ?? Colors.blue,
                        );
                      },
                    ),

                    // Raw Summary: /folders/:folderId/chapters/:chapterId/raw-summary
                    GoRoute(
                      path: 'raw-summary',
                      name: 'chapter-raw-summary',
                      builder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>;
                        return RawSummaryViewerScreen(
                          summaryText: extra['summaryText'] as String,
                          chapterTitle: extra['chapterTitle'] as String,
                          accentColor:
                              extra['accentColor'] as Color? ?? Colors.blue,
                        );
                      },
                    ),

                    // Mindmap: /folders/:folderId/chapters/:chapterId/mindmap
                    GoRoute(
                      path: 'mindmap',
                      name: 'chapter-mindmap',
                      builder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>?;
                        final mindmap = extra?['mindmap'] as Mindmapmodel?;
                        if (mindmap == null) {
                          throw ArgumentError(
                            'Mindmap data is required for this route',
                          );
                        }
                        return MindmapScreen(mindmap: mindmap);
                      },
                    ),

                    // Quiz: /folders/:folderId/chapters/:chapterId/quiz
                    GoRoute(
                      path: 'quiz',
                      name: 'chapter-quiz',
                      builder: (context, state) {
                        final folderId = state.pathParameters['folderId']!;
                        final chapterId = state.pathParameters['chapterId']!;
                        return BlocProvider<QuizCubit>(
                          create: (context) => getIt<QuizCubit>(),
                          child: QuizScreen(
                            chapterId: chapterId,
                            folderId: folderId,
                          ),
                        );
                      },
                      routes: [
                        // Quiz Questions: /folders/:folderId/chapters/:chapterId/quiz/questions
                        GoRoute(
                          path: 'questions',
                          name: 'quiz-questions',
                          builder: (context, state) {
                            final extra = state.extra as Map<String, dynamic>;
                            final folderId = state.pathParameters['folderId']!;
                            final chapterId =
                                state.pathParameters['chapterId']!;
                            return BlocProvider<QuizCubit>(
                              create: (context) => getIt<QuizCubit>(),
                              child: QuizQuestionsScreen(
                                quiz: extra['quiz'],
                                answers: extra['answers'] as List<String?>,
                                chapterId: chapterId,
                                folderId: folderId,
                              ),
                            );
                          },
                        ),

                        // Quiz Results: /folders/:folderId/chapters/:chapterId/quiz/results
                        GoRoute(
                          path: 'results',
                          name: 'quiz-results',
                          builder: (context, state) {
                            final extra = state.extra as Map<String, dynamic>;
                            final chapterId =
                                state.pathParameters['chapterId']!;
                            return BlocProvider<QuizCubit>(
                              create: (context) => getIt<QuizCubit>(),
                              child: QuizResultsScreen(
                                quiz: extra['quiz'],
                                userAnswers:
                                    extra['userAnswers'] as List<String?>,
                                chapterId: chapterId,
                                timeTaken: extra['timeTaken'] as int,
                              ),
                            );
                          },
                        ),

                        // Quiz History: /folders/:folderId/chapters/:chapterId/quiz/history
                        GoRoute(
                          path: 'history',
                          name: 'quiz-history',
                          builder: (context, state) {
                            final folderId = state.pathParameters['folderId']!;
                            final chapterId =
                                state.pathParameters['chapterId']!;
                            final extra = state.extra as Map<String, dynamic>?;
                            return BlocProvider<QuizCubit>(
                              create: (context) => getIt<QuizCubit>(),
                              child: QuizHistoryScreen(
                                chapterId: chapterId,
                                folderId: folderId,
                                quizTitle: extra?['quizTitle'] as String?,
                              ),
                            );
                          },
                        ),

                        // Quiz Review: /folders/:folderId/chapters/:chapterId/quiz/review
                        GoRoute(
                          path: 'review',
                          name: 'quiz-review',
                          builder: (context, state) {
                            final extra = state.extra as Map<String, dynamic>;
                            return BlocProvider<QuizCubit>(
                              create: (context) => getIt<QuizCubit>(),
                              child: QuizReviewScreen(
                                attempt: extra['attempt'] as Attempt,
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // Practice Mode: /folders/:folderId/chapters/:chapterId/practice
                    GoRoute(
                      path: 'practice',
                      name: 'chapter-practice',
                      builder: (context, state) {
                        final chapterId = state.pathParameters['chapterId']!;
                        final extra = state.extra as Map<String, dynamic>?;
                        return PracticeModeScreen(
                          chapterId: chapterId,
                          chapterTitle: extra?['chapterTitle'] as String?,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            // ════════════════════════════════════════════════════════════════════
            // QUICK ACCESS ROUTES (for Home Screen without folder context)
            // These routes allow direct access from home screen without folderId
            // ════════════════════════════════════════════════════════════════════

            // Chapter detail without folder context (for home screen)
            GoRoute(
              path: '/chapters/:chapterId',
              name: 'chapter-detail-quick',
              builder: (context, state) {
                final extra = (state.extra as Map<String, dynamic>?) ?? {};
                final existingCubit = extra['chapterCubit'] as ChapterCubit?;
                final child = ChapterDetailScreen(
                  chapter: extra['chapter'] as ChapterModel,
                  folderColor: extra['folderColor'] as Color? ?? Colors.blue,
                  folderOwnerId: extra['folderOwnerId'] as String?,
                );
                if (existingCubit != null) {
                  return BlocProvider.value(value: existingCubit, child: child);
                }
                return BlocProvider<ChapterCubit>(
                  create: (context) => getIt<ChapterCubit>(),
                  child: child,
                );
              },
              routes: [
                // PDF Viewer: /chapters/:chapterId/pdf
                GoRoute(
                  path: 'pdf',
                  name: 'chapter-pdf-quick',
                  builder: (context, state) {
                    final chapterId = state.pathParameters['chapterId']!;
                    final extra = state.extra as Map<String, dynamic>?;
                    final existingCubit =
                        extra?['chapterCubit'] as ChapterCubit?;
                    final child = PDFViewerScreen(
                      chapterId: chapterId,
                      chapterTitle:
                          extra?['chapterTitle'] as String? ?? 'PDF Viewer',
                    );
                    if (existingCubit != null) {
                      return BlocProvider.value(
                        value: existingCubit,
                        child: child,
                      );
                    }
                    return BlocProvider<ChapterCubit>(
                      create: (context) => getIt<ChapterCubit>(),
                      child: child,
                    );
                  },
                ),

                // Notes: /chapters/:chapterId/notes
                GoRoute(
                  path: 'notes',
                  name: 'chapter-notes-quick',
                  builder: (context, state) {
                    final chapterId = state.pathParameters['chapterId']!;
                    final extra = state.extra as Map<String, dynamic>?;
                    final chapterCubit =
                        extra?['chapterCubit'] as ChapterCubit?;
                    final child = NotesScreen(
                      chapterId: chapterId,
                      chapterTitle:
                          extra?['chapterTitle'] as String? ?? 'Notes',
                      accentColor: extra?['accentColor'] as Color?,
                      folderOwnerId: extra?['folderOwnerId'] as String?,
                    );
                    if (chapterCubit != null) {
                      return BlocProvider.value(
                        value: chapterCubit,
                        child: child,
                      );
                    }
                    return BlocProvider<ChapterCubit>(
                      create: (context) => getIt<ChapterCubit>(),
                      child: child,
                    );
                  },
                ),

                // Summary: /chapters/:chapterId/summary
                GoRoute(
                  path: 'summary',
                  name: 'chapter-summary-quick',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>;
                    return SummaryViewerScreen(
                      summaryData: extra['summaryData'] as SummaryModel,
                      chapterTitle: extra['chapterTitle'] as String,
                      accentColor:
                          extra['accentColor'] as Color? ?? Colors.blue,
                    );
                  },
                ),

                // Raw Summary: /chapters/:chapterId/raw-summary
                GoRoute(
                  path: 'raw-summary',
                  name: 'chapter-raw-summary-quick',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>;
                    return RawSummaryViewerScreen(
                      summaryText: extra['summaryText'] as String,
                      chapterTitle: extra['chapterTitle'] as String,
                      accentColor:
                          extra['accentColor'] as Color? ?? Colors.blue,
                    );
                  },
                ),

                // Mindmap: /chapters/:chapterId/mindmap
                GoRoute(
                  path: 'mindmap',
                  name: 'chapter-mindmap-quick',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>?;
                    final mindmap = extra?['mindmap'] as Mindmapmodel?;
                    if (mindmap == null) {
                      throw ArgumentError(
                        'Mindmap data is required for this route',
                      );
                    }
                    return MindmapScreen(mindmap: mindmap);
                  },
                ),

                // Quiz: /chapters/:chapterId/quiz
                GoRoute(
                  path: 'quiz',
                  name: 'chapter-quiz-quick',
                  builder: (context, state) {
                    final chapterId = state.pathParameters['chapterId']!;
                    final extra = state.extra as Map<String, dynamic>?;
                    final folderId = extra?['folderId'] as String? ?? '';
                    return BlocProvider<QuizCubit>(
                      create: (context) => getIt<QuizCubit>(),
                      child: QuizScreen(
                        chapterId: chapterId,
                        folderId: folderId,
                      ),
                    );
                  },
                  routes: [
                    // Quiz Questions: /chapters/:chapterId/quiz/questions
                    GoRoute(
                      path: 'questions',
                      name: 'quiz-questions-quick',
                      builder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>;
                        final chapterId = state.pathParameters['chapterId']!;
                        final folderId = extra['folderId'] as String? ?? '';
                        return BlocProvider<QuizCubit>(
                          create: (context) => getIt<QuizCubit>(),
                          child: QuizQuestionsScreen(
                            quiz: extra['quiz'],
                            answers: extra['answers'] as List<String?>,
                            chapterId: chapterId,
                            folderId: folderId,
                          ),
                        );
                      },
                    ),

                    // Quiz Results: /chapters/:chapterId/quiz/results
                    GoRoute(
                      path: 'results',
                      name: 'quiz-results-quick',
                      builder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>;
                        final chapterId = state.pathParameters['chapterId']!;
                        return BlocProvider<QuizCubit>(
                          create: (context) => getIt<QuizCubit>(),
                          child: QuizResultsScreen(
                            quiz: extra['quiz'],
                            userAnswers: extra['userAnswers'] as List<String?>,
                            chapterId: chapterId,
                            timeTaken: extra['timeTaken'] as int,
                          ),
                        );
                      },
                    ),

                    // Quiz History: /chapters/:chapterId/quiz/history
                    GoRoute(
                      path: 'history',
                      name: 'quiz-history-quick',
                      builder: (context, state) {
                        final chapterId = state.pathParameters['chapterId']!;
                        final extra = state.extra as Map<String, dynamic>?;
                        final folderId = extra?['folderId'] as String? ?? '';
                        return BlocProvider<QuizCubit>(
                          create: (context) => getIt<QuizCubit>(),
                          child: QuizHistoryScreen(
                            chapterId: chapterId,
                            folderId: folderId,
                            quizTitle: extra?['quizTitle'] as String?,
                          ),
                        );
                      },
                    ),

                    // Quiz Review: /chapters/:chapterId/quiz/review
                    GoRoute(
                      path: 'review',
                      name: 'quiz-review-quick',
                      builder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>;
                        return BlocProvider<QuizCubit>(
                          create: (context) => getIt<QuizCubit>(),
                          child: QuizReviewScreen(
                            attempt: extra['attempt'] as Attempt,
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // Practice Mode: /chapters/:chapterId/practice
                GoRoute(
                  path: 'practice',
                  name: 'chapter-practice-quick',
                  builder: (context, state) {
                    final chapterId = state.pathParameters['chapterId']!;
                    final extra = state.extra as Map<String, dynamic>?;
                    return PracticeModeScreen(
                      chapterId: chapterId,
                      chapterTitle: extra?['chapterTitle'] as String?,
                    );
                  },
                ),
              ],
            ),

            GoRoute(
              path: '/summary-viewer',
              name: 'summary-viewer',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>;
                return SummaryViewerScreen(
                  summaryData: extra['summaryData'] as SummaryModel,
                  chapterTitle: extra['chapterTitle'] as String,
                  accentColor: extra['accentColor'] as Color? ?? Colors.blue,
                );
              },
            ),
            GoRoute(
              path: '/mindmap-viewer',
              name: 'mindmap-viewer',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                final mindmap = extra?['mindmap'] as Mindmapmodel?;
                if (mindmap == null) {
                  throw ArgumentError(
                    'Mindmap data is required for this route',
                  );
                }
                return MindmapScreen(mindmap: mindmap);
              },
            ),

            // ════════════════════════════════════════════════════════════════════
            // CHALLENGE ROUTES: /challenges/*
            // ════════════════════════════════════════════════════════════════════
            GoRoute(
              path: '/challenges/join',
              name: 'challenge-join',
              builder: (context, state) => BlocProvider<ChallengeCubit>(
                create: (context) => getIt<ChallengeCubit>(),
                child: const EntercodeScreen(),
              ),
            ),
            GoRoute(
              path: '/challenges/scan',
              name: 'challenge-scan',
              builder: (context, state) => BlocProvider<ChallengeCubit>(
                create: (context) => getIt<ChallengeCubit>(),
                child: const QrScannerScreen(),
              ),
            ),
            GoRoute(
              path: '/challenges/select',
              name: 'challenge-select',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                final folderCubit = extra?['folderCubit'] as FolderCubit?;
                final chapterCubit = extra?['chapterCubit'] as ChapterCubit?;
                final challengeCubit =
                    extra?['challengeCubit'] as ChallengeCubit?;
                // Note: AuthCubit is already provided at app root level
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
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                final challengeCubit =
                    extra?['challengeCubit'] as ChallengeCubit?;
                final folderCubit = extra?['folderCubit'] as FolderCubit?;
                final chapterCubit = extra?['chapterCubit'] as ChapterCubit?;
                // Note: AuthCubit is already provided at app root level
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
              path: '/challenges/lobby/:code',
              name: 'challenge-lobby',
              builder: (context, state) {
                final code = state.pathParameters['code']!;
                final extra = state.extra as Map<String, dynamic>?;
                final challengeCubit =
                    extra?['challengeCubit'] as ChallengeCubit?;
                // Note: AuthCubit is already provided at app root level
                final child = ChallengeWaitingLobbyScreen(
                  challengeCode: code,
                  challengeName:
                      extra?['challengeName'] as String? ?? 'Challenge',
                );
                if (challengeCubit != null) {
                  return BlocProvider.value(
                    value: challengeCubit,
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
              path: '/challenges/live/:code',
              name: 'challenge-live',
              builder: (context, state) {
                final code = state.pathParameters['code']!;
                final extra = state.extra as Map<String, dynamic>?;
                final challengeCubit =
                    extra?['challengeCubit'] as ChallengeCubit?;
                // Note: AuthCubit is already provided at app root level
                final child = LiveQuestionScreen(
                  challengeCode: code,
                  challengeName:
                      extra?['challengeName'] as String? ?? 'Challenge',
                );
                if (challengeCubit != null) {
                  return BlocProvider.value(
                    value: challengeCubit,
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
              path: '/challenges/results/:code',
              name: 'challenge-results',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                return ChallengeCompletionScreen(
                  challengeName:
                      extra?['challengeName'] as String? ?? 'Challenge',
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
          ],
        ),
      ],
    );
  }
}
