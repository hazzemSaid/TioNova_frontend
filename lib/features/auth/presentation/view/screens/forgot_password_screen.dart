import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/auth/presentation/view/widgets/PrimaryBtn.dart';
import 'package:tionova/features/auth/presentation/view/widgets/ThemedTextFormField.dart';
import 'package:tionova/features/auth/presentation/view/widgets/auth_background.dart';

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
        resizeToAvoidBottomInset: true,
        body: AuthBackground(
          isDark: isDark,
          child: SafeArea(
            child: Column(
              children: [
                // Main content - centered and scrollable
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final keyboardHeight = MediaQuery.of(
                        context,
                      ).viewInsets.bottom;
                      final w = MediaQuery.of(context).size.width;
                      final h = MediaQuery.of(context).size.height;
                      final isTablet = w >= 800;
                      final isCompact = h < 650;
                      final logoWidth = isTablet ? w * 0.15 : w * 0.25;

                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: keyboardHeight > 0 ? 8 : 16,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                                constraints.maxHeight -
                                (keyboardHeight > 0 ? 16 : 32),
                            maxWidth: isTablet ? 520 : double.infinity,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Add flexible space on top when keyboard is closed
                                if (keyboardHeight == 0) const Spacer(),

                                // Form Container
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(
                                    keyboardHeight > 0
                                        ? 16
                                        : (isCompact ? 24 : 32),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: isDark
                                        ? const Color(0xFF1E1E1E)
                                        : Colors.white.withOpacity(0.95),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 30,
                                        offset: const Offset(0, 10),
                                        spreadRadius: 0,
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                        spreadRadius: -5,
                                      ),
                                    ],
                                  ),
                                  child: Form(
                                    key: formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: keyboardHeight > 0
                                              ? 4
                                              : (isCompact ? 8 : 15),
                                        ),
                                        Center(
                                          child: Image.asset(
                                            isDark
                                                ? 'assets/images/logo2.png'
                                                : 'assets/images/logo1.png',
                                            width: keyboardHeight > 0
                                                ? 50
                                                : (isCompact
                                                      ? 60
                                                      : logoWidth.clamp(
                                                          60.0,
                                                          80.0,
                                                        )),
                                          ),
                                        ),
                                        SizedBox(
                                          height: keyboardHeight > 0
                                              ? 8
                                              : (isCompact ? 16 : 25),
                                        ),
                                        Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            fontSize: isCompact ? 20 : 24,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        SizedBox(
                                          height: keyboardHeight > 0
                                              ? 6
                                              : (isCompact ? 8 : 12),
                                        ),
                                        Text(
                                          'Enter your email and we\'ll send you a code\nto reset your password',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: isCompact ? 13 : 14,
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.black54,
                                          ),
                                        ),
                                        SizedBox(
                                          height: keyboardHeight > 0
                                              ? 16
                                              : (isCompact ? 24 : 32),
                                        ),

                                        // Email
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Email',
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.black54,
                                            ),
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
                                        SizedBox(
                                          height: keyboardHeight > 0
                                              ? 12
                                              : (isCompact ? 20 : 24),
                                        ),

                                        // Send Reset Code button with loading
                                        BlocBuilder<AuthCubit, AuthState>(
                                          builder: (context, state) {
                                            final isLoading =
                                                state is AuthLoading;
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

                                // Add flexible space on bottom when keyboard is closed
                                if (keyboardHeight == 0) const Spacer(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Back to Login button - fixed at bottom
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextButton.icon(
                    onPressed: () => context.go('/auth/login'),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: 16,
                      color: Colors.white70,
                    ),
                    label: const Text(
                      'Back to Login',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
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
