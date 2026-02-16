// Main Layout with Adaptive Navigation
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

    if (!_shouldShowLayout(currentPath)) {
      return widget.child;
    }

    return kIsWeb ? _buildWebLayout(context) : _buildMobileLayout(context);
  }

  bool _shouldShowLayout(String path) {
    // 1. Distraction-free screens (Exclusion for BOTH Web and Mobile)
    final distractionFreePaths = [
      '/auth',
      '/quiz/',
      '/challenges/live/',
      '/challenges/lobby/',
      '/challenges/results/',
      '/pdf',
      '/practice',
      '/mindmap',
      '/notes',
      '/summary',
      '/create',
      '/edit',
    ];

    if (distractionFreePaths.any((segment) => path.contains(segment))) {
      return false;
    }

    // 2. Mobile-specific navigation rules
    if (!kIsWeb) {
      // On mobile, the bottom nav should only be visible on the main tab roots.
      // Any deep "pushed" screen (folder detail, chapter detail, etc.) hides it.
      final mainTabs = ['/', '/folders', '/challenges', '/profile'];

      // We check for exact matches to ensure bottom nav only shows on root tab views
      return mainTabs.contains(path);
    }

    // 3. Web: sidebar/header is usually persistent on all non-distraction-free screens.
    return true;
  }

  // Mobile layout with bottom navigation
  Widget _buildMobileLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentPath = GoRouterState.of(context).uri.path;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DotPainter(
                colorScheme.primary.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.05 : 0.03,
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
      bottomNavigationBar: _customBottomNavigationBar(context, currentPath),
    );
  }

  // Web/Desktop layout with permanent sidebar
  Widget _buildWebLayout(BuildContext context) {
    return _WebLayoutWrapper(child: widget.child);
  }

  // Custom Bottom Navigation Bar
  Widget _customBottomNavigationBar(BuildContext context, String currentPath) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                  child: _BottomNavItem(
                    icon: Icons.home,
                    label: "Home",
                    route: '/',
                    currentPath: currentPath,
                    onTap: () => context.go('/'),
                  ),
                ),
                Expanded(
                  child: _BottomNavItem(
                    icon: Icons.folder_outlined,
                    label: "Folders",
                    route: '/folders',
                    currentPath: currentPath,
                    onTap: () => context.go('/folders'),
                  ),
                ),
                Expanded(
                  child: _BottomNavItem(
                    icon: Icons.emoji_events_outlined,
                    label: "Challenges",
                    route: '/challenges',
                    currentPath: currentPath,
                    onTap: () => context.go('/challenges'),
                  ),
                ),
                Expanded(
                  child: _BottomNavItem(
                    icon: Icons.person_outline,
                    label: "Profile",
                    route: '/profile',
                    currentPath: currentPath,
                    onTap: () => context.go('/profile'),
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

// Stateful wrapper for web layout sidebar state
class _WebLayoutWrapper extends StatefulWidget {
  final Widget child;

  const _WebLayoutWrapper({required this.child});

  @override
  State<_WebLayoutWrapper> createState() => _WebLayoutWrapperState();
}

class _WebLayoutWrapperState extends State<_WebLayoutWrapper> {
  bool _isSidebarClosed = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentPath = GoRouterState.of(context).uri.path;

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
          backgroundColor: colorScheme.background,
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
                        setState(() {
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
                            child: _buildSidebar(
                              context,
                              sidebarWidth,
                              currentPath,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!_isSidebarClosed) {
                            setState(() {
                              _isSidebarClosed = true;
                            });
                          }
                        },
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          color: colorScheme.background,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _DotPainter(
                                    colorScheme.primary.withValues(
                                      alpha: theme.brightness == Brightness.dark
                                          ? 0.05
                                          : 0.03,
                                    ),
                                  ),
                                ),
                              ),
                              widget.child,
                            ],
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
  Widget _buildSidebar(BuildContext context, double width, String currentPath) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
                    setState(() {
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
                  route: '/',
                  currentPath: currentPath,
                  isCollapsed: isCollapsed,
                ),
                _buildSidebarItem(
                  context: context,
                  icon: Icons.folder_outlined,
                  label: 'Folders',
                  route: '/folders',
                  currentPath: currentPath,
                  isCollapsed: isCollapsed,
                ),
                _buildSidebarItem(
                  context: context,
                  icon: Icons.emoji_events_outlined,
                  label: 'Challenges',
                  route: '/challenges',
                  currentPath: currentPath,
                  isCollapsed: isCollapsed,
                ),
                _buildSidebarItem(
                  context: context,
                  icon: Icons.person_outline,
                  label: 'Profile',
                  route: '/profile',
                  currentPath: currentPath,
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
    required String route,
    required String currentPath,
    required bool isCollapsed,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = route == '/'
        ? currentPath == '/'
        : currentPath.startsWith(route);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.go(route);
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
}

// Bottom Navigation Item Widget
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String currentPath;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = route == '/'
        ? currentPath == '/'
        : currentPath.startsWith(route);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  final Color color;
  _DotPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const double spacing = 30.0;
    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
