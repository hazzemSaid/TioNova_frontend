import 'package:flutter/material.dart';

/// A reusable full-screen overlay layout for authentication screens
/// Full background image with dark gradient overlay and centered content
/// The ENTIRE screen scrolls, not just the form container
class AuthSplitLayout extends StatelessWidget {
  final Widget formContent;
  final bool isDark;

  const AuthSplitLayout({
    super.key,
    required this.formContent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = orientation == Orientation.landscape;
    final isMobileHeight = screenHeight < 600;
    
    // Responsive values
    final horizontalPadding = screenWidth < 600 ? 16.0 : 24.0;
    final verticalPadding = isLandscape ? 16.0 : 32.0;
    final maxFormWidth = screenWidth < 600 ? 340 : 360;

    return Scaffold(
      body: Stack(
        children: [
          // Full background image (fixed, doesn't scroll)
          Positioned.fill(
            child: Image.asset(
              'assets/images/auth_background.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(0, 0.3),
            ),
          ),

          // Dark overlay gradient (fixed, doesn't scroll)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.8),
                    const Color(0xFF0A0A0A).withOpacity(0.95),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // Full screen scrollable content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalPadding,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxFormWidth.toDouble()),
                          child: formContent,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
