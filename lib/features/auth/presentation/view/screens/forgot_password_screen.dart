import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/auth/presentation/view/widgets/PrimaryBtn.dart';
import 'package:tionova/features/auth/presentation/view/widgets/ThemedTextFormField.dart';
import 'package:tionova/features/theme/presentation/widgets/theme_toggle_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetCode() {
    if (formKey.currentState!.validate()) {
      context.read<AuthCubit>().forgetPassword(_emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is ForgetPasswordEmailSent) {
          context.go('/auth/verify-reset-code', extra: state.email);
        } else if (state is ForgetPasswordFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure.errMessage),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  final isTablet = w >= 800;
                  final isCompact = h < 700 || w < 360;
                  final logoWidth = isTablet ? w * 0.15 : w * 0.25;
                  return CustomScrollView(
                    slivers: [
                      // Top bar
                      SliverToBoxAdapter(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => context.pop(),
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            ThemeToggleButton(),
                          ],
                        ),
                      ),

                      // Spacing
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: isCompact ? h * 0.03 : h * 0.05,
                        ),
                      ),

                      // Forgot Password Form
                      SliverToBoxAdapter(
                        child: Align(
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isTablet ? 520 : double.infinity,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: isDark
                                    ? Colors.white10
                                    : Colors.black.withAlpha(5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(25),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: isCompact ? 10 : 15),
                                    Center(
                                      child: Image.asset(
                                        isDark
                                            ? 'assets/images/logo2.png'
                                            : 'assets/images/logo1.png',
                                        width: logoWidth.clamp(60.0, 80.0),
                                      ),
                                    ),
                                    SizedBox(height: isCompact ? 20 : 25),
                                    Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Enter your email and we\'ll send you a code\nto reset your password',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    // Email
                                    Text(
                                      'Email',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ThemedTextFormField(
                                      controller: _emailController,
                                      hintText: 'Email',
                                      prefixIcon: Icons.email_rounded,
                                      keyboardType: TextInputType.emailAddress,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 24),

                                    // Send Reset Code button with loading
                                    BlocBuilder<AuthCubit, AuthState>(
                                      builder: (context, state) {
                                        final isLoading = state is AuthLoading;
                                        return Column(
                                          children: [
                                            PrimaryBtn(
                                              label: isLoading
                                                  ? 'Sending...'
                                                  : 'Send Reset Code',
                                              onPressed: isLoading
                                                  ? null
                                                  : _sendResetCode,
                                              buttonColor: isDark
                                                  ? Colors.white10
                                                  : Colors.black87,
                                              textColor: Colors.white,
                                            ),
                                            if (isLoading)
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                  top: 16.0,
                                                ),
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Bottom login link
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: () => context.go('/auth/login'),
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                size: 16,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              label: Text(
                                'Back to Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).viewInsets.bottom + 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
