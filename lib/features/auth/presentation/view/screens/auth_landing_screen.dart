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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF121212), const Color(0xFF000000)]
                : [const Color(0xFFE0E0E0), const Color(0xFFBDBDBD)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                final isTablet = w >= 800;
                final isCompact = h < 700 || w < 360;
                final logoWidth = isTablet ? w * 0.3 : w * 0.6;
                return CustomScrollView(
                  slivers: [
                    // Top bar with settings
                    SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox.shrink(),
                          ThemeToggleButton(),
                        ],
                      ),
                    ),

                    // Spacing
                    SliverToBoxAdapter(
                      child: SizedBox(height: isCompact ? h * 0.1 : h * 0.15),
                    ),

                    // Logo
                    SliverToBoxAdapter(
                      child: Center(
                        child: Image.asset(
                          isDark
                              ? 'assets/images/logo2.png' // Use dark theme logo
                              : 'assets/images/logo1.png', // Use light theme logo
                          color: isDark
                              ? null
                              : Colors
                                    .black87, // Optional: Tint light theme logo
                          fit: BoxFit.contain,
                          width: logoWidth.clamp(160.0, 420.0),
                        ),
                      ),
                    ),

                    // Spacing
                    SliverToBoxAdapter(
                      child: SizedBox(height: isCompact ? h * 0.08 : h * 0.12),
                    ),

                    // Tagline
                    SliverToBoxAdapter(
                      child: Text(
                        'Your intelligent study companion. Organize, learn, and\nexcel with AI-powered insights.',
                        style:
                            (isTablet
                                    ? theme.textTheme.titleMedium
                                    : theme.textTheme.bodyMedium)
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                  height: 1.3,
                                ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Spacing
                    SliverToBoxAdapter(
                      child: SizedBox(height: isCompact ? 16 : 24),
                    ),

                    // Login Button
                    SliverToBoxAdapter(
                      child: PrimaryBtn(
                        label: 'Login to Your Account',
                        onPressed: () => context.go('/auth/login'),
                        textColor: isDark ? Colors.black : Colors.white,
                        buttonColor: isDark ? Colors.white : Colors.black,
                      ),
                    ),

                    // Spacing
                    SliverToBoxAdapter(
                      child: SizedBox(height: isCompact ? 12 : 16),
                    ),

                    // Register Button
                    SliverToBoxAdapter(
                      child: SecondaryBtn(
                        isDark: isDark,
                        label: 'Create New Account',
                        onPressed: () => context.go('/auth/register'),
                      ),
                    ),

                    // Spacing
                    SliverToBoxAdapter(
                      child: SizedBox(height: isCompact ? 12 : 16),
                    ),

                    // Divider with OR
                    SliverToBoxAdapter(
                      child: Row(
                        children: [
                          const Expanded(child: Divider(color: Colors.white24)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: Text(
                              'OR CONTINUE WITH',
                              style: TextStyle(
                                color: isDark ? Colors.white38 : Colors.black38,
                                fontSize: isCompact ? 11 : 12,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: Colors.white24)),
                        ],
                      ),
                    ),

                    // Spacing
                    SliverToBoxAdapter(
                      child: SizedBox(height: isCompact ? 12 : 16),
                    ),

                    // Google Sign In Button
                    SliverToBoxAdapter(
                      child: BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          if (state is AuthFailure) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.failure.errMessage),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            });
                          }
                          return SecondaryBtn(
                            isDark: isDark,
                            label: state is AuthLoading
                                ? 'Signing in...'
                                : 'Continue with Google',
                            icon: state is AuthLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  )
                                : Image.asset(
                                    'assets/icons/google.png',
                                    width: 24,
                                    height: 24,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                            onPressed: state is AuthLoading
                                ? () {} // Empty callback when loading
                                : () => getIt<AuthCubit>().googleSignIn(),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
