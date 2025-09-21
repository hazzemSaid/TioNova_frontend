import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/router/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
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
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _index = i),
              children: const [
                _OnboardPage(
                  color: Color(0xFFE6F0FF),
                  icon: Icons.track_changes,
                  title: 'Smart Study Goals',
                  subtitle:
                      'Set personalized learning objectives and track your progress with AI-powered insights that adapt to your study patterns.',
                ),
                _OnboardPage(
                  color: Color(0xFFE9FFF0),
                  icon: Icons.psychology_alt_rounded,
                  title: 'AI-Powered Learning',
                  subtitle:
                      'Get instant summaries, interactive quizzes, and personalized study recommendations powered by advanced AI technology.',
                ),
                _OnboardPage(
                  color: Color(0xFFF1E9FF),
                  icon: Icons.rocket_launch_rounded,
                  title: 'Ready to Excel?',
                  subtitle:
                      "Join thousands of students who've improved their learning with TioNova. Start your personalized study journey today!",
                  bullets: [
                    'Organize study materials in folders',
                    'AI-generated summaries and quizzes',
                    'Track progress with streaks',
                    'Challenge friends and compete',
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
                child: const Text('Skip'),
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
                          backgroundColor: const Color(0xFF0C0A1F),
                          foregroundColor: Colors.white,
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
                                    ? const Color(0xFF0C0A1F)
                                    : Colors.black12,
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
                          backgroundColor: const Color(0xFF0C0A1F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_index == 2 ? 'Get Started' : 'Next'),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right_rounded),
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
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String>? bullets;

  const _OnboardPage({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, size: 40, color: const Color(0xFF0C0A1F)),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          if (bullets != null) ...[
            const SizedBox(height: 50),
            for (final b in bullets!)
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(b, style: theme.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          const Spacer(),
        ],
      ),
    );
  }
}
