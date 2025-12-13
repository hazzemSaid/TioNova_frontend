import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/utils/validators.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/auth/presentation/view/widgets/SecondaryBtn.dart';
import 'package:tionova/features/auth/presentation/view/widgets/ThemedTextFormField.dart';
import 'package:tionova/features/auth/presentation/view/widgets/auth_background.dart';

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

  Widget _buildFormContent(bool isDark, bool isDesktop) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final spacingReducer = isLandscape ? 0.6 : 1.0;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            'Welcome Back',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 32 : 24,
              fontWeight: FontWeight.bold,
              color: isDesktop
                  ? Colors.white
                  : (isDark ? Colors.white : Colors.black),
            ),
          ),
          SizedBox(height: (8 * spacingReducer).toInt().toDouble()),
          Text(
            'Sign in to continue your learning journey',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: isDesktop
                  ? Colors.white70
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          SizedBox(height: (32 * spacingReducer).toInt().toDouble()),

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
          SizedBox(height: (8 * spacingReducer).toInt().toDouble()),
          ThemedTextFormField(
            controller: _emailController,
            hintText: 'Enter your email',
            prefixIcon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            isDark: isDesktop ? true : isDark,
            validator: Validators.validateEmail,
          ),
          SizedBox(height: (20 * spacingReducer).toInt().toDouble()),

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
          SizedBox(height: (8 * spacingReducer).toInt().toDouble()),
          ThemedTextFormField(
            controller: _passwordController,
            hintText: 'Enter your password',
            prefixIcon: Icons.lock_rounded,
            obscureText: _obscure,
            isDark: isDesktop ? true : isDark,
            validator: Validators.validatePassword,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: isDesktop
                    ? Colors.white54
                    : (isDark ? Colors.white54 : Colors.black54),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.go('/auth/forgot-password'),
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  color: isDesktop
                      ? Colors.white70
                      : (isDark ? Colors.white70 : Colors.black54),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sign In Button
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            context.read<AuthCubit>().login(
                              _emailController.text.trim(),
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
                          'Sign In',
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

          // Google Sign In
          SecondaryBtn(
            label: 'Continue with Google',
            onPressed: () {
              context.read<AuthCubit>().googleSignIn();
            },
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

          // Sign Up Link
          Center(
            child: TextButton(
              onPressed: () => context.go('/auth/register'),
              child: Text(
                "Don't have an account? Sign up here",
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
      listener: (context, state) async {
        if (state is AuthSuccess) {
          // Navigation handled by router
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
