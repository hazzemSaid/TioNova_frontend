// Widget testing helper to wrap widgets with necessary providers
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tionova/core/theme/app_pallete.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/challenges/presentation/bloc/challenge_cubit.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizcubit.dart';

/// Pumps a widget with MaterialApp and necessary theme configuration
Future<void> pumpApp(
  WidgetTester tester,
  Widget widget, {
  ThemeMode themeMode = ThemeMode.light,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPallete.gradient1,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPallete.gradient1,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppPallete.backgroundColor,
      ),
      themeMode: themeMode,
      home: widget,
    ),
  );
}

/// Pumps a widget with MaterialApp, theme, and BLoC providers
Future<void> pumpAppWithBlocs(
  WidgetTester tester,
  Widget widget, {
  AuthCubit? authCubit,
  ChallengeCubit? challengeCubit,
  QuizCubit? quizCubit,
  FolderCubit? folderCubit,
  ThemeMode themeMode = ThemeMode.light,
}) async {
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        if (authCubit != null)
          BlocProvider<AuthCubit>.value(value: authCubit),
        if (challengeCubit != null)
          BlocProvider<ChallengeCubit>.value(value: challengeCubit),
        if (quizCubit != null) BlocProvider<QuizCubit>.value(value: quizCubit),
        if (folderCubit != null)
          BlocProvider<FolderCubit>.value(value: folderCubit),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppPallete.gradient1,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppPallete.gradient1,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: AppPallete.backgroundColor,
        ),
        themeMode: themeMode,
        home: widget,
      ),
    ),
  );
}

/// Pumps a widget with router context for navigation testing
Future<void> pumpAppWithRouter(
  WidgetTester tester,
  Widget widget, {
  ThemeMode themeMode = ThemeMode.light,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPallete.gradient1,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPallete.gradient1,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppPallete.backgroundColor,
      ),
      themeMode: themeMode,
      routes: {
        '/': (context) => widget,
        '/login': (context) => const Scaffold(body: Text('Login')),
        '/home': (context) => const Scaffold(body: Text('Home')),
        '/quiz': (context) => const Scaffold(body: Text('Quiz')),
        '/challenge': (context) => const Scaffold(body: Text('Challenge')),
      },
    ),
  );
}

/// Pumps a widget with Provider for state management testing
Future<void> pumpAppWithProviders(
  WidgetTester tester,
  Widget widget, {
  List<ChangeNotifierProvider>? providers,
  ThemeMode themeMode = ThemeMode.light,
}) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: providers ?? [],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppPallete.gradient1,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppPallete.gradient1,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: AppPallete.backgroundColor,
        ),
        themeMode: themeMode,
        home: widget,
      ),
    ),
  );
}

/// Helper to find widgets by type
Finder findWidgetByType<T>() => find.byType(T);

/// Helper to find widgets by key
Finder findWidgetByKey(Key key) => find.byKey(key);

/// Helper to find widgets by text
Finder findWidgetByText(String text) => find.text(text);

/// Helper to find widgets by icon
Finder findWidgetByIcon(IconData icon) => find.byIcon(icon);

/// Helper to tap on a widget and settle
Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Helper to enter text and settle
Future<void> enterTextAndSettle(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}

/// Helper to scroll until visible
Future<void> scrollUntilVisible(
  WidgetTester tester,
  Finder item,
  Finder scrollable,
  double delta,
) async {
  await tester.scrollUntilVisible(
    item,
    delta,
    scrollable: scrollable,
  );
  await tester.pumpAndSettle();
}

/// Helper to verify widget exists
void expectWidgetExists(Finder finder) {
  expect(finder, findsOneWidget);
}

/// Helper to verify widget doesn't exist
void expectWidgetNotFound(Finder finder) {
  expect(finder, findsNothing);
}

/// Helper to verify multiple widgets exist
void expectWidgetsExist(Finder finder, int count) {
  expect(finder, findsNWidgets(count));
}
