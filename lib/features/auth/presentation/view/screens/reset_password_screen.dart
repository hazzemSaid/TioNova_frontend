import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/theme/app_theme.dart';
import 'package:tionova/core/utils/validators.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/auth/presentation/utils/auth_error_handler.dart';
import 'package:tionova/features/auth/presentation/view/widgets/ThemedTextFormField.dart';
import 'package:tionova/features/auth/presentation/view/widgets/auth_background.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String code;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (formKey.currentState!.validate()) {
      final newPassword = _passwordController.text.trim();
      context.read<AuthCubit>().resetPassword(
        email: widget.email,
        code: widget.code,
        newPassword: newPassword,
      );
    }
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
            'Create New Password',
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

          // Subtitle
          Text(
            'Your new password must be different from your previous password.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: isDesktop
                  ? Colors.white70
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          const SizedBox(height: 32),

          // New Password
          Text(
            'New Password',
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
            hintText: 'Enter new password',
            prefixIcon: Icons.lock_rounded,
            obscureText: _obscurePassword,
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: isDesktop
                    ? Colors.white54
                    : (isDark ? Colors.white54 : Colors.black54),
              ),
            ),
            isDark: isDesktop ? true : isDark,
            validator: Validators.validatePasswordStrong,
          ),
          const SizedBox(height: 12),

          // Password Requirements
          _buildPasswordRequirements(isDark, isDesktop),
          const SizedBox(height: 20),

          // Confirm Password
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
            controller: _confirmPasswordController,
            hintText: 'Confirm new password',
            prefixIcon: Icons.lock_rounded,
            obscureText: _obscureConfirmPassword,
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              child: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: isDesktop
                    ? Colors.white54
                    : (isDark ? Colors.white54 : Colors.black54),
              ),
            ),
            isDark: isDesktop ? true : isDark,
            validator: Validators.validateConfirmPassword(
              _passwordController.text,
            ),
          ),
          const SizedBox(height: 24),

          // Reset Password button
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _resetPassword,
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
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Back to Login
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => context.go('/auth/login'),
              icon: Icon(
                Icons.arrow_back_rounded,
                size: 16,
                color: isDesktop
                    ? Colors.white70
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
              label: Text(
                'Back to Login',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDesktop
                      ? Colors.white70
                      : (isDark ? Colors.white70 : Colors.black54),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirements(bool isDark, bool isDesktop) {
    final password = _passwordController.text;

    final hasLength = password.length >= 8;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequirementItem(
            'At least 8 characters',
            hasLength,
            isDark,
            isDesktop,
          ),
          const SizedBox(height: 6),
          _buildRequirementItem(
            'One uppercase letter',
            hasUppercase,
            isDark,
            isDesktop,
          ),
          const SizedBox(height: 6),
          _buildRequirementItem(
            'One lowercase letter',
            hasLowercase,
            isDark,
            isDesktop,
          ),
          const SizedBox(height: 6),
          _buildRequirementItem('One number', hasNumber, isDark, isDesktop),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(
    String text,
    bool isMet,
    bool isDark,
    bool isDesktop,
  ) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isMet
              ? Colors.green
              : (isDark ? Colors.white30 : Colors.black26),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: isDesktop ? 14 : 12,
            color: isMet
                ? (isDesktop
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black87))
                : (isDark ? Colors.white54 : Colors.black54),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIsDark = kIsWeb ? true : isDark;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Password reset successfully!'),
              backgroundColor: AppTheme.accentGreen,
            ),
          );
          context.go('/');
        } else if (state is ResetPasswordFailure) {
          AuthErrorHandler.showErrorDialog(
            context,
            title: 'Password Reset Failed',
            errorMessage: state.failure.errMessage,
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
