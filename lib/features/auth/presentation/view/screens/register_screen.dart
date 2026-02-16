import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/utils/validators.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/auth/presentation/utils/auth_error_handler.dart';
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

  Widget _buildFormContent(bool isDark, bool isDesktop) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            'Create Account',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 32 : 24,
              fontWeight: FontWeight.bold,
              color: isDesktop
                  ? Colors.white
                  : (isDark ? Colors.white : Colors.black),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join TioNova and start your learning journey',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: isDesktop
                  ? Colors.white70
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          const SizedBox(height: 32),

          // Username Field
          Text(
            'Username',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDesktop
                  ? Colors.white70
                  : (isDark ? Colors.white70 : Colors.black54),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ThemedTextFormField(
            controller: _usernameController,
            hintText: 'Enter your username',
            prefixIcon: Icons.person_rounded,
            isDark: isDesktop ? true : isDark,
            validator: Validators.validateUsername,
          ),
          const SizedBox(height: 16),

          // Email Field
          Text(
            'Email',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDesktop
                  ? Colors.white70
                  : (isDark ? Colors.white70 : Colors.black54),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ThemedTextFormField(
            controller: _emailController,
            hintText: 'Enter your email',
            prefixIcon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            isDark: isDesktop ? true : isDark,
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 16),

          // Password Field
          Text(
            'Password',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDesktop
                  ? Colors.white70
                  : (isDark ? Colors.white70 : Colors.black54),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ThemedTextFormField(
            controller: _passwordController,
            hintText: 'Enter your password',
            prefixIcon: Icons.lock_rounded,
            obscureText: _obscure1,
            isDark: isDesktop ? true : isDark,
            validator: Validators.validatePasswordStrong,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure1 = !_obscure1),
              icon: Icon(
                _obscure1
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: isDesktop
                    ? Colors.white54
                    : (isDark ? Colors.white54 : Colors.black54),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Confirm Password Field
          Text(
            'Confirm Password',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDesktop
                  ? Colors.white70
                  : (isDark ? Colors.white70 : Colors.black54),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ThemedTextFormField(
            controller: _confirmController,
            hintText: 'Confirm your password',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscure2,
            isDark: isDesktop ? true : isDark,
            validator: Validators.validateConfirmPassword(
              _passwordController.text,
            ),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure2 = !_obscure2),
              icon: Icon(
                _obscure2
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: isDesktop
                    ? Colors.white54
                    : (isDark ? Colors.white54 : Colors.black54),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Create Account Button
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final isLoading =
                  state is AuthLoading || state is RegisterLoading;
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            context.read<AuthCubit>().register(
                              _emailController.text.trim(),
                              _usernameController.text.trim(),
                              _passwordController.text,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // OR Divider
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: isDesktop
                      ? Colors.white.withOpacity(0.15)
                      : (isDark ? Colors.white12 : Colors.black12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: isDesktop
                        ? Colors.white38
                        : (isDark ? Colors.white38 : Colors.black38),
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: isDesktop
                      ? Colors.white.withOpacity(0.15)
                      : (isDark ? Colors.white12 : Colors.black12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Google Sign Up
          SecondaryBtn(
            label: 'Continue with Google',
            onPressed: () {},
            icon: Image.asset(
              'assets/icons/google.png',
              width: 24,
              height: 24,
              color: isDesktop
                  ? Colors.white70
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
            isDark: isDesktop ? true : isDark,
          ),

          const SizedBox(height: 16),

          // Login Link
          Center(
            child: TextButton(
              onPressed: () => context.go('/auth/login'),
              child: Text(
                'Already have an account? Log in here',
                style: TextStyle(
                  color: isDesktop
                      ? Colors.white70
                      : (isDark ? Colors.white70 : Colors.black54),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final effectiveIsDark = kIsWeb ? true : isDark;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          context.go('/auth/verify-reset-code', extra: state.email);
        } else if (state is AuthFailure || state is RegisterFailure) {
          final failure = state is AuthFailure
              ? state.failure
              : (state as RegisterFailure).failure;
          AuthErrorHandler.showErrorDialog(
            context,
            title: 'Registration Failed',
            errorMessage: failure.errMessage.isNotEmpty
                ? failure.errMessage
                : 'Registration failed',
          );
        }
      },
      child: Scaffold(
        body: AuthBackground(
          isDark: effectiveIsDark,
          child: SingleChildScrollView(
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: _buildFormContent(effectiveIsDark, kIsWeb),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
