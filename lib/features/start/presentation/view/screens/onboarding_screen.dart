import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/router/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _index = 0;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    await AppRouter.setNotFirstTime();
    if (context.mounted) {
      context.go('/auth');
    }
  }

  void _back() {
    if (_index > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _index = i),
              children: [
                _OnboardPage(
                  rotationController: _rotationController,
                  icon: Icons.track_changes,
                  centerImage: 'assets/images/Container.png',
                  orbitIcons: const [
                    'assets/images/Icon (1).png',
                    'assets/images/Icon (2).png',
                    'assets/images/Icon (3).png',
                  ],
                  title: 'Smart Study Goals',
                  subtitle:
                      'Set personalized learning objectives and track your progress with AI-powered insights that adapt to your study patterns.',
                ),
                _OnboardPage(
                  rotationController: _rotationController,
                  icon: Icons.psychology_alt_rounded,
                  centerImage: 'assets/images/🧠.png',
                  orbitIcons: const [
                    'assets/images/Icon (4).png',
                    'assets/images/Icon (5).png',
                    'assets/images/Icon (6).png',
                  ],
                  title: 'AI-Powered Learning',
                  subtitle:
                      'Get instant summaries, interactive quizzes, and personalized study recommendations powered by advanced AI technology.',
                ),
                _OnboardPage(
                  rotationController: _rotationController,
                  icon: Icons.rocket_launch_rounded,
                  centerImage: 'assets/images/🚀.png',
                  orbitIcons: const [
                    'assets/images/Icon (7).png',
                    'assets/images/Icon (5).png',
                    'assets/images/Vector.png',
                  ],
                  title: 'Ready to Excel?',
                  subtitle:
                      "Join thousands of students who've improved their learning with TioNova. Start your personalized study journey today!",
                  bullets: const [
                    'Organize study materials in folders',
                    'AI-generated summaries and quizzes',
                    'Track progress with streaks',
                    'Challenge friends and classmates',
                  ],
                ),
              ],
            ),

            // Skip button
            Positioned(
              top: 8,
              right: 12,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  'Skip',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                children: [
                  // Back button
                  SizedBox(
                    width: 56,
                    height: 44,
                    child: Opacity(
                      opacity: _index == 0 ? 0.3 : 1,
                      child: ElevatedButton(
                        onPressed: _index == 0 ? null : _back,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.surfaceVariant,
                          foregroundColor: colorScheme.onSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.zero,
                          elevation: 0,
                        ),
                        child: const Icon(Icons.chevron_left_rounded),
                      ),
                    ),
                  ),

                  // Page indicators
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) {
                            final active = i == _index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: active ? 28 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: active
                                    ? colorScheme.primary
                                    : colorScheme.outline.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),

                  // Next / Get Started button
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _index == 2 ? 'Get Started' : 'Continue',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded),
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
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final AnimationController rotationController;
  final IconData icon;
  final String centerImage;
  final List<String> orbitIcons;
  final String title;
  final String subtitle;
  final List<String>? bullets;

  const _OnboardPage({
    required this.rotationController,
    required this.icon,
    required this.centerImage,
    required this.orbitIcons,
    required this.title,
    required this.subtitle,
    this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),

          // Animated circular orbit with icons
          SizedBox(
            width: 280,
            height: 280,
            child: AnimatedBuilder(
              animation: rotationController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.surfaceVariant.withOpacity(0.3),
                      ),
                    ),

                    // Center image
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.surfaceVariant.withOpacity(0.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Image.asset(centerImage, fit: BoxFit.contain),
                      ),
                    ),

                    // Orbiting icons
                    ...List.generate(orbitIcons.length, (index) {
                      final angle =
                          (rotationController.value * 2 * 3.14159) +
                          (index * 2 * 3.14159 / orbitIcons.length);
                      final radius = 120.0;
                      final x = radius * cos(angle);
                      final y = radius * sin(angle);

                      return Transform.translate(
                        offset: Offset(x, y),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getIconColor(index, isDark),
                            boxShadow: [
                              BoxShadow(
                                color: _getIconColor(
                                  index,
                                  isDark,
                                ).withOpacity(0.03),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              orbitIcons[index],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 40),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              fontSize: 26,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          if (bullets != null) ...[
            const SizedBox(height: 32),
            ...bullets!
                .map(
                  (bullet) => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 20,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primaryContainer,
                          ),
                          child: Icon(
                            _getBulletIcon(bullets!.indexOf(bullet)),
                            color: colorScheme.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            bullet,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],

          const Spacer(),
        ],
      ),
    );
  }

  Color _getIconColor(int index, bool isDark) {
    // Use theme-based colors with opacity for orbit icons
    final colors = [
      const Color.fromARGB(100, 157, 78, 221), // Purple
      const Color.fromARGB(100, 0, 217, 255), // Cyan
      const Color.fromARGB(100, 33, 150, 243), // Blue
      const Color.fromARGB(100, 76, 175, 80), // Green
      const Color.fromARGB(100, 255, 152, 0), // Orange
      const Color.fromARGB(100, 255, 107, 107), // Red
    ];
    return colors[index % colors.length];
  }

  IconData _getBulletIcon(int index) {
    final icons = [
      Icons.folder_rounded,
      Icons.auto_awesome_rounded,
      Icons.local_fire_department_rounded,
      Icons.group_rounded,
    ];
    return icons[index % icons.length];
  }

  double cos(double angle) {
    return math.cos(angle);
  }

  double sin(double angle) {
    return math.sin(angle);
  }
}
