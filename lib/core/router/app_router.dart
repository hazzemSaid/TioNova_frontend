import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/auth/presentation/view/screens/auth_landing_screen.dart';
import 'package:tionova/features/auth/presentation/view/screens/login_screen.dart';
import 'package:tionova/features/auth/presentation/view/screens/register_screen.dart';
import 'package:tionova/features/start/presentation/view/screens/TioNovaspalsh.dart';
import 'package:tionova/features/start/presentation/view/screens/notifications_screen.dart';
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
      debugLogDiagnostics: true,
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
          ],
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
