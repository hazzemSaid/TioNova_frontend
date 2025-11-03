import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/auth/presentation/view/widgets/PrimaryBtn.dart';
import 'package:tionova/features/auth/presentation/view/widgets/SecondaryBtn.dart';
import 'package:tionova/features/theme/presentation/widgets/theme_toggle_button.dart';

class AuthLandingScreen extends StatelessWidget {
  const AuthLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 900;
    final isTablet = size.width >= 600 && size.width <= 900;
    final isMobile = size.width < 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0A0A0A),
                    const Color(0xFF1A1A1A),
                    const Color(0xFF0D0D0D),
                  ]
                : [
                    const Color(0xFFFAFAFA),
                    const Color(0xFFFFFFFF),
                    const Color(0xFFF5F5F5),
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: isWeb
              ? _buildWebLayout(context, isDark, theme)
              : _buildMobileLayout(context, isDark, theme, isTablet, isMobile),
        ),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, bool isDark, ThemeData theme) {
    final size = MediaQuery.of(context).size;

    return Row(
      children: [
        // Left side - Branding
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Image.asset(
                  isDark
                      ? 'assets/images/logo2.png'
                      : 'assets/images/logo1.png',
                  color: isDark ? null : Colors.black87,
                  fit: BoxFit.contain,
                  width: 280,
                ),
                const SizedBox(height: 48),
                // Headline
                Text(
                  'Your intelligent\nstudy companion',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Description
                Text(
                  'Organize, learn, and excel with AI-powered insights.\nTransform your study experience with intelligent tools.',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 40),
                // Features
                _buildFeatureRow(
                  Icons.auto_awesome_rounded,
                  'AI-Powered Learning',
                  isDark,
                ),
                const SizedBox(height: 16),
                _buildFeatureRow(
                  Icons.folder_rounded,
                  'Smart Organization',
                  isDark,
                ),
                const SizedBox(height: 16),
                _buildFeatureRow(
                  Icons.trending_up_rounded,
                  'Track Progress',
                  isDark,
                ),
              ],
            ),
          ),
        ),
        // Right side - Auth Form
        Expanded(
          flex: 4,
          child: Container(
            margin: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(0.4)
                  : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                children: [
                  // Glassmorphism effect
                  if (isDark)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.05),
                              Colors.white.withOpacity(0.02),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Theme toggle
                        Align(
                          alignment: Alignment.topRight,
                          child: ThemeToggleButton(),
                        ),
                        const Spacer(),
                        // Welcome text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.waving_hand_rounded,
                              color: isDark
                                  ? const Color(0xFFFFD700)
                                  : const Color(0xFFFF9800),
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Welcome!',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Get started with your account',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Auth buttons
                        _buildAuthButtons(
                          context,
                          isDark,
                          false,
                          size.width * 0.3,
                        ),
                        const Spacer(),
                        // Terms
                        _buildTermsText(isDark, 13),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    bool isDark,
    ThemeData theme,
    bool isTablet,
    bool isMobile,
  ) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = isTablet ? 40.0 : 10.0;
    final maxWidth = isTablet ? 500.0 : double.infinity;
    final isVerySmall = size.height < 650; // Detect very small screens

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 5,
            ),
            child: Column(
              children: [
                // Logo section
                Container(
                  padding: EdgeInsets.all(isVerySmall ? 16 : 24),

                  child: Image.asset(
                    isDark
                        ? 'assets/images/logo2.png'
                        : 'assets/images/logo1.png',
                    color: isDark ? null : Colors.black87,
                    fit: BoxFit.contain,
                    width: isVerySmall ? 130 : (isTablet ? 200 : 140),
                  ),
                ),

                SizedBox(height: isVerySmall ? 10 : (isTablet ? 24 : 16)),

                // Welcome text with icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'Welcome to TioNova',
                        style:
                            (isVerySmall
                                    ? theme.textTheme.titleLarge
                                    : (isTablet
                                          ? theme.textTheme.headlineMedium
                                          : theme.textTheme.headlineSmall))
                                ?.copyWith(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  fontSize: 25,
                                ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.waving_hand_rounded,
                      color: isDark
                          ? const Color(0xFFFFD700)
                          : const Color(0xFFFF9800),
                      size: isVerySmall ? 20 : (isTablet ? 28 : 24),
                    ),
                  ],
                ),

                SizedBox(height: isVerySmall ? 8 : (isTablet ? 16 : 12)),

                // Tagline
                Text(
                  'Your intelligent study companion.\nOrganize, learn, and excel with\nAI-powered insights.',
                  style:
                      (isVerySmall
                              ? theme.textTheme.bodyMedium
                              : (isTablet
                                    ? theme.textTheme.titleMedium
                                    : theme.textTheme.bodyLarge))
                          ?.copyWith(
                            color: isDark ? Colors.white54 : Colors.black54,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: isVerySmall ? 20 : (isTablet ? 48 : 32)),

                // Main card with buttons
                Container(
                  padding: EdgeInsets.all(
                    isVerySmall ? 16 : (isTablet ? 32 : 24),
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _buildAuthButtons(
                    context,
                    isDark,
                    true,
                    double.infinity,
                    isVerySmall: isVerySmall,
                  ),
                ),

                SizedBox(height: isVerySmall ? 16 : 24),

                // Terms
                _buildTermsText(isDark, isMobile ? 11 : 12),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black54,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthButtons(
    BuildContext context,
    bool isDark,
    bool isMobile,
    double width, {
    bool isVerySmall = false,
  }) {
    final buttonSpacing = isVerySmall ? 12.0 : 16.0;
    final dividerSpacing = isVerySmall ? 16.0 : 24.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Login Button
        SizedBox(
          width: width,
          child: PrimaryBtn(
            label: 'Login to Your Account',
            onPressed: () => context.go('/auth/login'),
            textColor: isDark ? Colors.black : Colors.white,
            buttonColor: isDark ? Colors.white : Colors.black,
            icon: Icons.login_rounded,
          ),
        ),
        SizedBox(height: buttonSpacing),
        // Register Button
        SizedBox(
          width: width,
          child: SecondaryBtn(
            isDark: isDark,
            label: 'Create New Account',
            icon: Icon(
              Icons.person_add_rounded,
              size: 20,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => context.go('/auth/register'),
          ),
        ),
        SizedBox(height: dividerSpacing),
        // Divider
        Row(
          children: [
            Expanded(
              child: Divider(
                color: isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'OR',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: isVerySmall ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
              ),
            ),
          ],
        ),
        SizedBox(height: dividerSpacing),
        // Google Sign In
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
            return SizedBox(
              width: width,
              child: SecondaryBtn(
                isDark: isDark,
                label: state is AuthLoading
                    ? 'Signing in...'
                    : 'Continue with Google',
                icon: state is AuthLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      )
                    : Image.asset(
                        'assets/icons/google.png',
                        width: 20,
                        height: 20,
                        color: isDark ? Colors.white : null,
                      ),
                onPressed: state is AuthLoading
                    ? () {}
                    : () => getIt<AuthCubit>().googleSignIn(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTermsText(bool isDark, double fontSize) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          color: isDark ? Colors.white54 : Colors.black54,
          fontSize: fontSize,
          height: 1.5,
        ),
        children: [
          const TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: isDark ? Colors.white : Colors.black,
            ),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
