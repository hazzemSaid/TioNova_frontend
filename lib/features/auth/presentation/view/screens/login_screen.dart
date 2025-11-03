import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/auth/presentation/view/widgets/PrimaryBtn.dart';
import 'package:tionova/features/auth/presentation/view/widgets/SecondaryBtn.dart';
import 'package:tionova/features/auth/presentation/view/widgets/ThemedTextFormField.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go('/');
        } else if (state is AuthFailure) {
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
                  final logoWidth = isTablet ? w * 0.25 : w * 0.5;
                  return Form(
                    key: formKey,
                    child: CustomScrollView(
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
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: isCompact ? h * 0.09 : h * 0.05,
                          ),
                        ),
                        // Login Form
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
                                      : Colors.black.withValues(alpha: 0.05),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(height: isCompact ? 10 : 15),
                                        Center(
                                          child: Image.asset(
                                            isDark
                                                ? 'assets/images/logo2.png'
                                                : 'assets/images/logo1.png',
                                            width: logoWidth.clamp(90.0, 100.0),
                                          ),
                                        ),
                                        SizedBox(height: isCompact ? 20 : 25),
                                        Text(
                                          'Welcome Back',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 6,
                                          width: double.infinity,
                                        ),
                                        Text(
                                          'Sign in to continue your learning journey',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: isDark
                                                    ? Colors.white70
                                                    : Colors.black54,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

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
                                    const SizedBox(height: 16),

                                    // Password
                                    Text(
                                      'Password',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ThemedTextFormField(
                                      controller: _passwordController,
                                      hintText: 'Password',
                                      prefixIcon: Icons.lock_rounded,
                                      obscureText: _obscure,
                                      isDark: isDark,
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(
                                          () => _obscure = !_obscure,
                                        ),
                                        icon: Icon(
                                          _obscure
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black54,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () =>
                                            context.go('/auth/forgot-password'),
                                        child: Text(
                                          'Forgot password?',
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.black54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 8),
                                    BlocBuilder<AuthCubit, AuthState>(
                                      builder: (context, state) {
                                        final isLoading = state is AuthLoading;
                                        return PrimaryBtn(
                                          label: isLoading
                                              ? 'Signing In...'
                                              : 'Sign In',
                                          onPressed: isLoading
                                              ? null
                                              : () {
                                                  if (formKey.currentState!
                                                      .validate()) {
                                                    context
                                                        .read<AuthCubit>()
                                                        .login(
                                                          _emailController.text
                                                              .trim(),
                                                          _passwordController
                                                              .text,
                                                        );
                                                  }
                                                },
                                          buttonColor: isDark
                                              ? Colors.white10
                                              : Colors.black87,
                                          textColor: isDark
                                              ? Colors.white
                                              : Colors.white,
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                            color: isDark
                                                ? Colors.white12
                                                : Colors.black12,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0,
                                          ),
                                          child: Text(
                                            'OR',
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white38
                                                  : Colors.black54,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Divider(
                                            color: isDark
                                                ? Colors.white12
                                                : Colors.black12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    SecondaryBtn(
                                      label: 'Continue with Google',
                                      onPressed: () {},
                                      icon: Image.asset(
                                        'assets/icons/google.png',
                                        width: 24,
                                        height: 24,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 16),
                                    Align(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        onPressed: () =>
                                            context.go('/auth/register'),
                                        child: Text(
                                          "Don't have an account? Sign Up here",
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.black54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
