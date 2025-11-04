// Main Layout with Adaptive Navigation
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/challenges/presentation/bloc/challenge_cubit.dart';
import 'package:tionova/features/challenges/presentation/view/screens/challange_screen.dart';
import 'package:tionova/features/folder/presentation/view/screens/folder_screen.dart';
import 'package:tionova/features/home/presentation/view/screens/home_screen.dart';
import 'package:tionova/features/profile/presentation/view/screens/profile_screen.dart';
import 'package:tionova/utils/widgets/BottomNavItem.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
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
          _screens[index] = const ProfileScreen();
          break;
      }
    }
    return _screens[index]!;
  }

  // Check if the layout should use side navigation
  bool _shouldUseSideNav(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return kIsWeb && width >= 768; // Tablet/Desktop web view
  }

  @override
  Widget build(BuildContext context) {
    final useSideNav = _shouldUseSideNav(context);

    if (useSideNav) {
      return _buildWebLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  // Web layout with side navigation
  Widget _buildWebLayout(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          // Side Navigation
          _buildSideNavigation(context),
          // Main content
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              sizing: StackFit.expand,
              children: List.generate(
                _screens.length,
                (index) => _currentIndex == index || _screens[index] != null
                    ? _getScreen(index)
                    : Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mobile layout with bottom navigation
  Widget _buildMobileLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      body: IndexedStack(
        index: _currentIndex,
        sizing: StackFit.expand,
        children: List.generate(
          _screens.length,
          (index) => _currentIndex == index || _screens[index] != null
              ? _getScreen(index)
              : Container(),
        ),
      ),
      bottomNavigationBar: _customBottomNavigationBar(context),
    );
  }

  // Side navigation for web/tablet
  Widget _buildSideNavigation(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: colorScheme.outline.withOpacity(0.4),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Logo/Header
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.school,
                      size: 24,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'TIONOVA',
                    style:
                        theme.textTheme.titleMedium?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: colorScheme.onSurface,
                        ) ??
                        TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: colorScheme.onSurface,
                        ),
                  ),
                ],
              ),
            ),
            Divider(color: colorScheme.outline.withOpacity(0.4), height: 1),
            const SizedBox(height: 16),
            // Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildSideNavItem(icon: Icons.home, label: "Home", index: 0),
                  _buildSideNavItem(
                    icon: Icons.folder_outlined,
                    label: "Folders",
                    index: 1,
                  ),
                  _buildSideNavItem(
                    icon: Icons.emoji_events_outlined,
                    label: "Challenges",
                    index: 2,
                  ),
                  _buildSideNavItem(
                    icon: Icons.person_outline,
                    label: "Profile",
                    index: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _safeSetState(() => _currentIndex = index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primaryContainer
                    : colorScheme.outline.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style:
                      theme.textTheme.bodyLarge?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ) ??
                      TextStyle(
                        fontSize: 16,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _customBottomNavigationBar(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                    currentIndex: _currentIndex,
                    onTap: () => _safeSetState(() => _currentIndex = 0),
                  ),
                ),
                Expanded(
                  child: BottomNavItem(
                    icon: Icons.folder_outlined,
                    label: "Folders",
                    index: 1,
                    currentIndex: _currentIndex,
                    onTap: () => _safeSetState(() => _currentIndex = 1),
                  ),
                ),
                Expanded(
                  child: BottomNavItem(
                    icon: Icons.emoji_events_outlined,
                    label: "Challenges",
                    index: 2,
                    currentIndex: _currentIndex,
                    onTap: () => _safeSetState(() => _currentIndex = 2),
                  ),
                ),
                Expanded(
                  child: BottomNavItem(
                    icon: Icons.person_outline,
                    label: "Profile",
                    index: 3,
                    currentIndex: _currentIndex,
                    onTap: () => _safeSetState(() => _currentIndex = 3),
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
