import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/theme/app_theme.dart';
import 'package:tionova/core/utils/validators.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/auth/presentation/view/widgets/PrimaryBtn.dart';
import 'package:tionova/features/auth/presentation/view/widgets/ThemedTextFormField.dart';
import 'package:tionova/features/theme/presentation/widgets/theme_toggle_button.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [Colors.black, Colors.grey.shade900]
                  : [Colors.white, Colors.grey.shade100],
            ),
          ),
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
                      final isTablet = w > 600;
                      final isCompact = h < 650;
                      final logoWidth = w * 0.15;

                      // Dynamic spacing based on keyboard state
                      final containerPadding = keyboardHeight > 0
                          ? 16.0
                          : (isCompact ? 24.0 : 32.0);
                      final logoSize = keyboardHeight > 0
                          ? 50.0
                          : logoWidth.clamp(60.0, 80.0);
                      final topSpacing = keyboardHeight > 0
                          ? 4.0
                          : (isCompact ? 10.0 : 15.0);
                      final logoBottomSpacing = keyboardHeight > 0
                          ? 12.0
                          : (isCompact ? 20.0 : 25.0);
                      final sectionSpacing = keyboardHeight > 0 ? 12.0 : 24.0;
                      final fieldSpacing = keyboardHeight > 0 ? 12.0 : 16.0;

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
                                  // App Bar with back button and theme toggle
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
                                      ThemeToggleButton(),
                                    ],
                                  ),

                                  if (keyboardHeight == 0) const Spacer(),
                                  // Reset Password Form
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
                                            SizedBox(height: logoBottomSpacing),
                                            Icon(
                                              Icons.lock_rounded,
                                              size: 48,
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.black54,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Create New Password',
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
                                              'Your new password must be different from your\nprevious password.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isDark
                                                    ? Colors.white70
                                                    : Colors.black54,
                                              ),
                                            ),
                                            SizedBox(height: sectionSpacing),

                                            // New Password
                                            Text(
                                              'New Password',
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white70
                                                    : Colors.black54,
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
                                                    _obscurePassword =
                                                        !_obscurePassword;
                                                  });
                                                },
                                                child: Icon(
                                                  _obscurePassword
                                                      ? Icons
                                                            .visibility_off_rounded
                                                      : Icons
                                                            .visibility_rounded,
                                                  color: isDark
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                ),
                                              ),
                                              isDark: isDark,
                                              validator: Validators
                                                  .validatePasswordStrong,
                                            ),
                                            SizedBox(height: sectionSpacing),

                                            // Confirm Password
                                            Text(
                                              'Confirm Password',
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white70
                                                    : Colors.black54,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ThemedTextFormField(
                                              controller:
                                                  _confirmPasswordController,
                                              hintText: 'Confirm new password',
                                              prefixIcon: Icons.lock_rounded,
                                              obscureText:
                                                  _obscureConfirmPassword,
                                              suffixIcon: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _obscureConfirmPassword =
                                                        !_obscureConfirmPassword;
                                                  });
                                                },
                                                child: Icon(
                                                  _obscureConfirmPassword
                                                      ? Icons
                                                            .visibility_off_rounded
                                                      : Icons
                                                            .visibility_rounded,
                                                  color: isDark
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                ),
                                              ),
                                              isDark: isDark,
                                              validator:
                                                  Validators.validateConfirmPassword(
                                                    _passwordController.text,
                                                  ),
                                            ),
                                            SizedBox(height: fieldSpacing),

                                            // Password requirements
                                            if (keyboardHeight == 0)
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? Colors.white
                                                            .withOpacity(0.05)
                                                      : Colors.black
                                                            .withOpacity(0.02),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Password must contain:',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: isDark
                                                            ? Colors.white70
                                                            : Colors.black54,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.circle,
                                                          size: 6,
                                                          color: isDark
                                                              ? Colors.white70
                                                              : Colors.black54,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          'At least 8 characters',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: isDark
                                                                ? Colors.white70
                                                                : Colors
                                                                      .black54,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (keyboardHeight == 0)
                                              SizedBox(height: sectionSpacing),

                                            // Reset Password button
                                            BlocBuilder<AuthCubit, AuthState>(
                                              builder: (context, state) {
                                                final isLoading =
                                                    state is AuthLoading;
                                                return PrimaryBtn(
                                                  label: 'Reset Password',
                                                  isLoading: isLoading,
                                                  onPressed: _resetPassword,
                                                  buttonColor: isDark
                                                      ? Colors.white10
                                                      : Colors.black87,
                                                  textColor: Colors.white,
                                                );
                                              },
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
                // Bottom login link
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton.icon(
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
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
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
