// Main Layout with Adaptive Navigation
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/challenges/presentation/bloc/challenge_cubit.dart';
import 'package:tionova/features/challenges/presentation/view/screens/challange_screen.dart';
import 'package:tionova/features/folder/presentation/view/screens/folder_screen.dart';
import 'package:tionova/features/home/presentation/provider/index_mainLayout.dart';
import 'package:tionova/features/home/presentation/view/screens/home_screen.dart';
import 'package:tionova/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:tionova/features/profile/presentation/view/screens/profile_screen.dart';
import 'package:tionova/utils/widgets/BottomNavItem.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isDisposed = false;

  // Lazy loaded screens
  final List<Widget?> _screens = List.filled(4, null);

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // Safe setState that checks if widget is still mounted
  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  // Get screen by index - creates the widget only when needed
  Widget _getScreen(int index) {
    if (_screens[index] == null) {
      switch (index) {
        case 0:
          _screens[index] = const HomeScreen();
          break;
        case 1:
          // FolderCubit is provided by MainLayout route in router
          _screens[index] = const FolderScreen();
          break;
        case 2:
          // ChallengeCubit will be provided by specific challenge routes
          // For the main screen, we provide it here since it's accessed from MainLayout
          _screens[index] = BlocProvider<ChallengeCubit>(
            create: (context) => getIt<ChallengeCubit>(),
            child: const ChallangeScreen(),
          );
          break;
        case 3:
          _screens[index] = BlocProvider<ProfileCubit>(
            create: (context) => getIt<ProfileCubit>()..fetchProfile(),
            child: const ProfileScreen(),
          );
          break;
      }
    }
    return _screens[index]!;
  }

  @override
  Widget build(BuildContext context) {
    return _buildMobileLayout(context);
  }

  // Mobile layout with bottom navigation
  Widget _buildMobileLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final indexProvider = context.watch<IndexMainLayout>();
    final currentIndex = indexProvider.index;
    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      body: IndexedStack(
        index: currentIndex,
        sizing: StackFit.expand,
        children: List.generate(
          _screens.length,
          (index) => currentIndex == index || _screens[index] != null
              ? _getScreen(index)
              : Container(),
        ),
      ),
      bottomNavigationBar: _customBottomNavigationBar(context),
    );
  }

  // Custom Bottom Navigation Bar
  Widget _customBottomNavigationBar(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final indexProvider = context.watch<IndexMainLayout>();
    final currentIndex = indexProvider.index;
    return Container(
      height: isIOS ? 70 : 65,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.4),
            width: 0.5,
          ),
        ),
        boxShadow: isIOS
            ? [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Material(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: BottomNavItem(
                    icon: Icons.home,
                    label: "Home",
                    index: 0,
                    currentIndex: currentIndex,
                    onTap: () => _safeSetState(
                      () => context.read<IndexMainLayout>().index = 0,
                    ),
                  ),
                ),
                Expanded(
                  child: BottomNavItem(
                    icon: Icons.folder_outlined,
                    label: "Folders",
                    index: 1,
                    currentIndex: currentIndex,
                    onTap: () => _safeSetState(
                      () => context.read<IndexMainLayout>().index = 1,
                    ),
                  ),
                ),
                Expanded(
                  child: BottomNavItem(
                    icon: Icons.emoji_events_outlined,
                    label: "Challenges",
                    index: 2,
                    currentIndex: currentIndex,
                    onTap: () => _safeSetState(
                      () => context.read<IndexMainLayout>().index = 2,
                    ),
                  ),
                ),
                Expanded(
                  child: BottomNavItem(
                    icon: Icons.person_outline,
                    label: "Profile",
                    index: 3,
                    currentIndex: currentIndex,
                    onTap: () => _safeSetState(
                      () => context.read<IndexMainLayout>().index = 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
