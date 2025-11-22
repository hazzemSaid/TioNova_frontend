import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/utils/safe_navigation.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/auth/presentation/view/widgets/PrimaryBtn.dart';
import 'package:tionova/features/auth/presentation/view/widgets/SecondaryBtn.dart';
import 'package:tionova/features/auth/presentation/view/widgets/ThemedTextFormField.dart';
import 'package:tionova/features/auth/presentation/view/widgets/auth_background.dart';
import 'package:tionova/features/preferences/presentation/Bloc/PreferencesCubit.dart';

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
      listener: (context, state) async {
        if (state is AuthSuccess) {
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
        resizeToAvoidBottomInset: true,
        body: AuthBackground(
          isDark: isDark,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final keyboardHeight = MediaQuery.of(
                        context,
                      ).viewInsets.bottom;
                      final w = MediaQuery.of(context).size.width;
                      final h = constraints.maxHeight;
                      final isTablet = w >= 800;
                      final isCompact = h < 650;
                      final logoWidth = isTablet ? w * 0.25 : w * 0.5;

                      // Dynamic spacing based on keyboard state
                      final containerPadding = keyboardHeight > 0
                          ? 16.0
                          : (isCompact ? 24.0 : 32.0);
                      final logoSize = keyboardHeight > 0
                          ? 50.0
                          : logoWidth.clamp(90.0, 100.0);
                      final topSpacing = keyboardHeight > 0
                          ? 4.0
                          : (isCompact ? 10.0 : 15.0);
                      final logoBottomSpacing = keyboardHeight > 0
                          ? 12.0
                          : (isCompact ? 20.0 : 25.0);
                      final sectionSpacing = keyboardHeight > 0 ? 12.0 : 20.0;
                      final fieldSpacing = keyboardHeight > 0 ? 8.0 : 16.0;
                      final dividerSpacing = keyboardHeight > 0 ? 8.0 : 12.0;

                      return Form(
                        key: formKey,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: keyboardHeight > 0 ? 8 : 16,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight:
                                  constraints.maxHeight -
                                  (keyboardHeight > 0 ? 16 : 32),
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                children: [
                                  // Top bar
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            context.safePop(fallback: '/auth'),
                                        icon: Icon(
                                          Icons.arrow_back_rounded,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (keyboardHeight == 0) const Spacer(),
                                  // Login Form
                                  Align(
                                    alignment: Alignment.center,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: isTablet
                                            ? 520
                                            : double.infinity,
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(
                                          containerPadding,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          color: isDark
                                              ? const Color(0xFF1E1E1E)
                                              : Colors.white.withOpacity(0.95),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 30,
                                              offset: const Offset(0, 10),
                                              spreadRadius: 0,
                                            ),
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                              spreadRadius: -5,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(height: topSpacing),
                                                Center(
                                                  child: Image.asset(
                                                    isDark
                                                        ? 'assets/images/logo2.png'
                                                        : 'assets/images/logo1.png',
                                                    width: logoSize,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: logoBottomSpacing,
                                                ),
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
                                                  style: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: isDark
                                                            ? Colors.white70
                                                            : Colors.black54,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: sectionSpacing),

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
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              isDark: isDark,
                                            ),
                                            SizedBox(height: fieldSpacing),

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
                                                      ? Icons
                                                            .visibility_off_rounded
                                                      : Icons
                                                            .visibility_rounded,
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
                                                onPressed: () => context.go(
                                                  '/auth/forgot-password',
                                                ),
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
                                                final isLoading =
                                                    state is AuthLoading;
                                                return PrimaryBtn(
                                                  label: isLoading
                                                      ? 'Signing In...'
                                                      : 'Sign In',
                                                  onPressed: isLoading
                                                      ? null
                                                      : () {
                                                          if (formKey
                                                              .currentState!
                                                              .validate()) {
                                                            context
                                                                .read<
                                                                  AuthCubit
                                                                >()
                                                                .login(
                                                                  _emailController
                                                                      .text
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

                                            SizedBox(height: dividerSpacing),
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
                                                  padding:
                                                      const EdgeInsets.symmetric(
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
                                            SizedBox(height: dividerSpacing),
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
                                            SizedBox(height: fieldSpacing),
                                            Align(
                                              alignment: Alignment.center,
                                              child: TextButton(
                                                onPressed: () => context.go(
                                                  '/auth/register',
                                                ),
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
                                  if (keyboardHeight == 0) const Spacer(),
                                ],
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
          ),
        ),
      ),
    );
  }
}
