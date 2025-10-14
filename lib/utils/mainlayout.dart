// Main Layout with Adaptive Navigation
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/features/folder/presentation/view/screens/folder_screen.dart';
import 'package:tionova/features/home/presentation/view/screens/home_screen.dart';
import 'package:tionova/features/home/presentation/view/widgets/CustomHeaderDelegate.dart';
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
          _screens[index] = BlocProvider(
            create: (context) => getIt<FolderCubit>(),
            child: const FolderScreen(),
          );
          break;
        case 2:
          _screens[index] = const ChallengesScreen();
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
    return Scaffold(
      backgroundColor: Colors.black,
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
    return Scaffold(
      backgroundColor: Colors.black,
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
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        border: Border(right: BorderSide(color: Color(0xFF1C1C1E), width: 1)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Logo/Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D4FF), Color(0xFF0066FF)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'TIONOVA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF1C1C1E), height: 1),
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
              color: isSelected ? const Color(0xFF1C1C1E) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF00D4FF).withOpacity(0.3)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? const Color(0xFF00D4FF)
                      : Colors.white.withOpacity(0.6),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.6),
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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

    return Container(
      height: isIOS ? 70 : 65,
      decoration: BoxDecoration(
        color: Colors.black,
        border: const Border(
          top: BorderSide(color: Color(0xFF1C1C1E), width: 0.5),
        ),
        boxShadow: isIOS
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
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
            color: Colors.transparent,
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
