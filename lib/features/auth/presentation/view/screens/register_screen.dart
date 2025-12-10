import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/utils/validators.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/auth/presentation/view/widgets/PrimaryBtn.dart';
import 'package:tionova/features/auth/presentation/view/widgets/SecondaryBtn.dart';
import 'package:tionova/features/auth/presentation/view/widgets/ThemedTextFormField.dart';
import 'package:tionova/features/auth/presentation/view/widgets/auth_background.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  final formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          // Go to verify code screen, pass email
          context.go('/auth/verify-reset-code', extra: state.email);
        } else if (state is AuthFailure || state is RegisterFailure) {
          final failure = state is AuthFailure
              ? state.failure
              : (state as RegisterFailure).failure;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                failure.errMessage.isNotEmpty
                    ? failure.errMessage
                    : 'Registration failed',
              ),
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
                      final logoBottomSpacing = keyboardHeight > 0 ? 8.0 : 16.0;
                      final sectionSpacing = keyboardHeight > 0 ? 12.0 : 20.0;
                      final fieldSpacing = keyboardHeight > 0 ? 8.0 : 16.0;

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

                                  if (keyboardHeight == 0) const Spacer(),
                                  // Registration Form
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
                                                  width: double.infinity,
                                                ),
                                                Text(
                                                  'Create Account',
                                                  style: theme
                                                      .textTheme
                                                      .headlineSmall
                                                      ?.copyWith(
                                                        color: isDark
                                                            ? Colors.white
                                                            : Colors.black87,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  'Join TioNova and start your learning journey',
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

                                            // Username
                                            Text(
                                              'Username',
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white70
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ThemedTextFormField(
                                              controller: _usernameController,
                                              hintText: 'Username',
                                              prefixIcon: Icons.person_rounded,
                                              isDark: isDark,
                                              validator:
                                                  Validators.validateUsername,
                                            ),
                                            SizedBox(height: fieldSpacing),

                                            // Email
                                            Text(
                                              'Email',
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white70
                                                    : Colors.black87,
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
                                              validator:
                                                  Validators.validateEmail,
                                            ),
                                            SizedBox(height: fieldSpacing),

                                            // Password
                                            Text(
                                              'Password',
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white70
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ThemedTextFormField(
                                              controller: _passwordController,
                                              hintText: 'Password',
                                              prefixIcon: Icons.lock_rounded,
                                              obscureText: _obscure1,
                                              isDark: isDark,
                                              validator: Validators
                                                  .validatePasswordStrong,
                                              suffixIcon: IconButton(
                                                onPressed: () => setState(
                                                  () => _obscure1 = !_obscure1,
                                                ),
                                                icon: Icon(
                                                  _obscure1
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
                                            SizedBox(height: fieldSpacing),

                                            // Confirm Password
                                            Text(
                                              'Confirm Password',
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white70
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ThemedTextFormField(
                                              controller: _confirmController,
                                              hintText: 'Confirm Password',
                                              prefixIcon:
                                                  Icons.lock_outline_rounded,
                                              obscureText: _obscure2,
                                              isDark: isDark,
                                              validator:
                                                  Validators.validateConfirmPassword(
                                                    _passwordController.text,
                                                  ),
                                              suffixIcon: IconButton(
                                                onPressed: () => setState(
                                                  () => _obscure2 = !_obscure2,
                                                ),
                                                icon: Icon(
                                                  _obscure2
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
                                            SizedBox(
                                              height: keyboardHeight > 0
                                                  ? 16.0
                                                  : 26.0,
                                            ),
                                            BlocBuilder<AuthCubit, AuthState>(
                                              builder: (context, state) {
                                                final isLoading =
                                                    state is AuthLoading ||
                                                    state is RegisterLoading;
                                                return PrimaryBtn(
                                                  label: 'Create Account',
                                                  isLoading: isLoading,
                                                  onPressed: () {
                                                    if (formKey.currentState!
                                                        .validate()) {
                                                      context
                                                          .read<AuthCubit>()
                                                          .register(
                                                            _emailController
                                                                .text
                                                                .trim(),
                                                            _usernameController
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

                                            SizedBox(
                                              height: keyboardHeight > 0
                                                  ? 8.0
                                                  : 12.0,
                                            ),
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
                                                          : Colors.black38,
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
                                            SizedBox(
                                              height: keyboardHeight > 0
                                                  ? 8.0
                                                  : 12.0,
                                            ),
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
                                                onPressed: () =>
                                                    context.go('/auth/login'),
                                                child: Text(
                                                  'Already have an account? Log in here',
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
