import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/auth/presentation/view/widgets/PrimaryBtn.dart';
import 'package:tionova/features/auth/presentation/view/widgets/ThemedTextFormField.dart';
import 'package:tionova/features/theme/presentation/widgets/theme_toggle_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

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
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset successful! Please login with your new password.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to login screen
      context.go('/auth/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final isTablet = w > 600;
    final isCompact = h < 700;
    final logoWidth = w * 0.15;

    return Scaffold(
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CustomScrollView(
                slivers: [
                  // App Bar with back button and theme toggle
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    pinned: false,
                    title: Row(
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
                    child: SizedBox(height: isCompact ? h * 0.03 : h * 0.05),
                  ),

                  // Reset Password Form
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
                                    color: isDark ? Colors.white : Colors.black,
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
                                const SizedBox(height: 32),

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
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    child: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                  isDark: isDark,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a password';
                                    }
                                    if (value.length < 8) {
                                      return 'Password must be at least 8 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),

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
                                  controller: _confirmPasswordController,
                                  hintText: 'Confirm new password',
                                  prefixIcon: Icons.lock_rounded,
                                  obscureText: _obscureConfirmPassword,
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
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),

                                  isDark: isDark,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Password requirements
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.05)
                                        : Colors.black.withOpacity(0.02),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Password must contain:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
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
                                          const SizedBox(width: 8),
                                          Text(
                                            'At least 8 characters',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Reset Password button
                                PrimaryBtn(
                                  label: 'Reset Password',
                                  onPressed: _resetPassword,
                                  buttonColor: isDark
                                      ? Colors.white10
                                      : Colors.black87,
                                  textColor: Colors.white,
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
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom + 16,
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
    );
  }
}
