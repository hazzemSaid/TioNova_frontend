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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSidebarClosed = false;

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
    final isWeb = _isWeb();
    return isWeb ? _buildWebLayout(context) : _buildMobileLayout(context);
  }

  bool _isWeb() {
    // Check if running on web platform
    return identical(0, 0.0); // This returns true only on web
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

  // Web/Desktop layout with permanent sidebar
  Widget _buildWebLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final indexProvider = context.watch<IndexMainLayout>();
    final currentIndex = indexProvider.index;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isLarge = width >= 1200;
        final isMedium = width >= 900 && width < 1200;
        final double minDrawerWidth = isLarge ? 88 : (isMedium ? 80 : 0);
        final double maxDrawerWidth = isLarge ? 296 : (isMedium ? 264 : 240);
        final double sidebarWidth = _isSidebarClosed
            ? minDrawerWidth
            : maxDrawerWidth;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: colorScheme.onPrimary,
          body: Column(
            children: [
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.menu, color: colorScheme.onSurface),
                      onPressed: () {
                        _safeSetState(() {
                          _isSidebarClosed = !_isSidebarClosed;
                        });
                      },
                      tooltip: _isSidebarClosed
                          ? 'Open sidebar'
                          : 'Close sidebar',
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width: sidebarWidth,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border(
                          right: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: ClipRect(
                        child: OverflowBox(
                          maxWidth: maxDrawerWidth,
                          minWidth: maxDrawerWidth,
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            width: maxDrawerWidth,
                            child: _buildSidebar(context, sidebarWidth),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!_isSidebarClosed) {
                            _safeSetState(() {
                              _isSidebarClosed = true;
                            });
                          }
                        },
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          color: colorScheme.onPrimary,
                          child: IndexedStack(
                            index: currentIndex,
                            sizing: StackFit.expand,
                            children: List.generate(
                              _screens.length,
                              (index) =>
                                  currentIndex == index ||
                                      _screens[index] != null
                                  ? _getScreen(index)
                                  : Container(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Permanent Sidebar for Web
  Widget _buildSidebar(BuildContext context, double width) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final indexProvider = context.watch<IndexMainLayout>();
    final currentIndex = indexProvider.index;
    final bool isCollapsed = width < 160;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header with toggle and close buttons
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isCollapsed)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'TioNova',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Study Assistant',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: colorScheme.onSurface,
                    size: 20,
                  ),
                  onPressed: () {
                    _safeSetState(() {
                      _isSidebarClosed = true;
                    });
                  },
                  tooltip: 'Close sidebar',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSidebarItem(
                  context: context,
                  icon: Icons.home,
                  label: 'Home',
                  index: 0,
                  currentIndex: currentIndex,
                  isCollapsed: isCollapsed,
                ),
                _buildSidebarItem(
                  context: context,
                  icon: Icons.folder_outlined,
                  label: 'Folders',
                  index: 1,
                  currentIndex: currentIndex,
                  isCollapsed: isCollapsed,
                ),
                _buildSidebarItem(
                  context: context,
                  icon: Icons.emoji_events_outlined,
                  label: 'Challenges',
                  index: 2,
                  currentIndex: currentIndex,
                  isCollapsed: isCollapsed,
                ),
                _buildSidebarItem(
                  context: context,
                  icon: Icons.person_outline,
                  label: 'Profile',
                  index: 3,
                  currentIndex: currentIndex,
                  isCollapsed: isCollapsed,
                ),
              ],
            ),
          ),
          // Footer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '© 2025 TioNova',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required int currentIndex,
    required bool isCollapsed,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = currentIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _safeSetState(() {
            context.read<IndexMainLayout>().index = index;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
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
            color: colorScheme.outline.withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
        boxShadow: isIOS
            ? [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
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
