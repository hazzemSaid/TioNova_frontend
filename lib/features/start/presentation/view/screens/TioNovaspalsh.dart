import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<double>> _scaleAnimations;
  late AnimationController _shimmerController;

  late AnimationController _subtitleController;
  late Animation<Offset> _slideSubtitle;
  late Animation<double> _fadeSubtitle;

  final String text = "TIONOVA";

  final List<int> order = [0, 1, 2, 3, 4, 5, 6];

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(
          duration: const Duration(
            seconds: 3,
          ), // Reduced duration for better UX
          vsync: this,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            // Navigate to the main app after animation completes
            Future.delayed(const Duration(milliseconds: 500), () async {
              if (mounted) {
                // Check if it's the first time opening the app
                final isFirst = await AppRouter.isFirstTime();

                // Navigate using GoRouter
                if (context.mounted) {
                  if (isFirst) {
                    GoRouter.of(context).go('/onboarding');
                  } else {
                    GoRouter.of(context).go('/auth');
                  }
                }
              }
            });
          }
        });

    _fadeAnimations = List.generate(text.length, (index) {
      final start = order.indexOf(index) * 0.1;
      final end = start + 0.25;
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeIn),
      );
    });

    _scaleAnimations = List.generate(text.length, (index) {
      final start = order.indexOf(index) * 0.1;
      final end = start + 0.25;
      return Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.elasticOut),
        ),
      );
    });

    _controller.forward();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // subtitle controller
    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideSubtitle =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _subtitleController, curve: Curves.easeOut),
        );

    _fadeSubtitle = CurvedAnimation(
      parent: _subtitleController,
      curve: Curves.easeIn,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _subtitleController.forward();
        // Navigation is now handled in the animation status listener
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start the animation when the widget is first built
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _shimmerController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  Color _getBaseColor(int index) {
    if (index <= 2) {
      return Colors.grey.shade400;
    } else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                final shimmerPosition = Tween<double>(
                  begin: -1,
                  end: 2,
                ).animate(_shimmerController).value;

                return ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.6),
                        Colors.white.withOpacity(0.1),
                      ],
                      stops: [
                        shimmerPosition - 0.3,
                        shimmerPosition,
                        shimmerPosition + 0.3,
                      ],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(text.length, (index) {
                      return FadeTransition(
                        opacity: _fadeAnimations[index],
                        child: ScaleTransition(
                          scale: _scaleAnimations[index],
                          child: Text(
                            text[index],
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: _getBaseColor(index),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            SlideTransition(
              position: _slideSubtitle,
              child: FadeTransition(
                opacity: _fadeSubtitle,
                child: const Text(
                  "AI Study Assistant",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 78, 76, 76),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
