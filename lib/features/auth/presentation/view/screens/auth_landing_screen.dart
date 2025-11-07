import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/auth/presentation/view/widgets/PrimaryBtn.dart';
import 'package:tionova/features/auth/presentation/view/widgets/SecondaryBtn.dart';
import 'package:tionova/features/auth/presentation/view/widgets/auth_background.dart';

class AuthLandingScreen extends StatelessWidget {
  const AuthLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600 && size.width <= 900;
    final isMobile = size.width < 600;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AuthBackground(
        isDark: isDark,
        child: SafeArea(
          child: _buildMobileLayout(context, isDark, theme, isTablet, isMobile),
        ),
      ),
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
    print(isDark);
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
                    'assets/images/logo2.png',
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
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  fontSize: 25,
                                ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.waving_hand_rounded,
                      color: const Color(0xFFFFD700),
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
                            color: Colors.white54,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: isVerySmall ? 20 : (isTablet ? 48 : 32)),

                // Main card with buttons
                Container(
                  padding: EdgeInsets.all(
                    isVerySmall ? 20 : (isTablet ? 32 : 28),
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1E1E)
                        : Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                        spreadRadius: -5,
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
          color: Colors.white54,
          fontSize: fontSize,
          height: 1.5,
        ),
        children: [
          const TextSpan(
            text: 'By continuing, you agree to our ',
            style: TextStyle(color: Colors.white),
          ),
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
            ),
          ),
          const TextSpan(
            text: ' and ',
            style: TextStyle(color: Colors.white),
          ),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
