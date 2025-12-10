import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';

class AuthLandingScreen extends StatelessWidget {
  const AuthLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final isLandscape = size.width > size.height;
    final isCompact = size.height < 650;

    // Responsive values
    final horizontalPadding = isTablet ? 48.0 : 24.0;
    final buttonHeight = isTablet ? 60.0 : 56.0;
    final buttonFontSize = isTablet ? 18.0 : 16.0;
    final headlineFontSize = isTablet ? 42.0 : (size.width < 400 ? 28.0 : 34.0);
    final subtitleFontSize = isTablet ? 18.0 : 16.0;
    final socialButtonSize = isTablet ? 56.0 : 50.0;
    final socialIconSize = isTablet ? 28.0 : 24.0;
    final topFlex = isLandscape ? 60 : 85;
    final bottomFlex = isLandscape ? 40 : 45;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        top: false,
        child: isLandscape && !isTablet
            // Landscape mode for phones - side by side layout
            ? _buildLandscapeLayout(
                context,
                theme,
                isDark,
                size,
                isTablet,
                isCompact,
                horizontalPadding,
                buttonHeight,
                buttonFontSize,
                headlineFontSize,
                subtitleFontSize,
                socialButtonSize,
                socialIconSize,
              )
            // Portrait mode or tablet landscape
            : _buildPortraitLayout(
                context,
                theme,
                isDark,
                size,
                isTablet,
                isCompact,
                horizontalPadding,
                buttonHeight,
                buttonFontSize,
                headlineFontSize,
                subtitleFontSize,
                socialButtonSize,
                socialIconSize,
                topFlex,
                bottomFlex,
              ),
      ),
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    Size size,
    bool isTablet,
    bool isCompact,
    double horizontalPadding,
    double buttonHeight,
    double buttonFontSize,
    double headlineFontSize,
    double subtitleFontSize,
    double socialButtonSize,
    double socialIconSize,
    int topFlex,
    int bottomFlex,
  ) {
    return Column(
      children: [
        // Top section with background image and text
        Expanded(
          flex: topFlex,
          child: Stack(
            children: [
              // Background image
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage(
                      'assets/images/auth_background.jpg',
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.2),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
              // Gradient overlay for text readability
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: isTablet ? 250 : 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),
              // Text content positioned at bottom
              Positioned(
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: isTablet ? 40 : 28,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 600 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discover\nthe best study\nexperience!',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: headlineFontSize,
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      Text(
                        'Let TioNova guide you',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w400,
                          fontSize: subtitleFontSize,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom section with buttons
        Expanded(
          flex: bottomFlex,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: Transform.translate(
              offset: const Offset(0, -32),
              child: _buildButtonSection(
                context,
                theme,
                isDark,
                isTablet,
                isCompact,
                horizontalPadding,
                buttonHeight,
                buttonFontSize,
                socialButtonSize,
                socialIconSize,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    Size size,
    bool isTablet,
    bool isCompact,
    double horizontalPadding,
    double buttonHeight,
    double buttonFontSize,
    double headlineFontSize,
    double subtitleFontSize,
    double socialButtonSize,
    double socialIconSize,
  ) {
    return Row(
      children: [
        // Left side - Image with text
        Expanded(
          flex: 55,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage(
                      'assets/images/auth_background.jpg',
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.2),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                  ),
                ),
              ),
              // Text content
              Positioned(
                left: 24,
                right: 24,
                bottom: 32,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover\nthe best study\nexperience!',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Let TioNova guide you',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Right side - Buttons
        Expanded(
          flex: 45,
          child: Container(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _buildButtonSection(
                  context,
                  theme,
                  isDark,
                  isTablet,
                  true, // compact in landscape
                  16,
                  buttonHeight - 4,
                  buttonFontSize - 1,
                  socialButtonSize - 6,
                  socialIconSize - 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonSection(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    bool isTablet,
    bool isCompact,
    double horizontalPadding,
    double buttonHeight,
    double buttonFontSize,
    double socialButtonSize,
    double socialIconSize,
  ) {
    final verticalSpacing = isCompact ? 10.0 : 16.0;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: isCompact ? 32 : 50),

            // Create new account button
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 400 : double.infinity,
              ),
              child: SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: () => context.go('/auth/register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4804A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'Create new account',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: buttonFontSize,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        size: 20,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: verticalSpacing),

            // I already have an account
            TextButton(
              onPressed: () => context.go('/auth/login'),
              child: Text(
                'I already have an account',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: isTablet ? 16 : 15,
                ),
              ),
            ),

            SizedBox(height: verticalSpacing),

            // OR divider
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 300 : double.infinity,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: isDark
                          ? Colors.white.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: isDark
                          ? Colors.white.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isCompact ? 16 : 24),

            // Social login buttons
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                if (state is AuthFailure) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.failure.errMessage),
                        backgroundColor: Theme.of(context).colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  });
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      isGoogle: true,
                      isDark: isDark,
                      isLoading: state is AuthLoading,
                      size: socialButtonSize,
                      iconSize: socialIconSize,
                      onTap: state is AuthLoading
                          ? null
                          : () => getIt<AuthCubit>().googleSignIn(),
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: verticalSpacing),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    bool isGoogle = false,
    required bool isDark,
    bool isLoading = false,
    required double size,
    required double iconSize,
    VoidCallback? onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isLoading
                  ? SizedBox(
                      key: const ValueKey('loading'),
                      width: iconSize - 4,
                      height: iconSize - 4,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    )
                  : Image.asset(
                      'assets/icons/google.png',
                      key: const ValueKey('icon'),
                      width: iconSize,
                      height: iconSize,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
