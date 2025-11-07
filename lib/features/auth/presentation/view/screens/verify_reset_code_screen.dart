import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/auth/presentation/view/widgets/PrimaryBtn.dart';
import 'package:tionova/features/auth/presentation/view/widgets/auth_background.dart';

class VerifyResetCodeScreen extends StatefulWidget {
  final String email;

  const VerifyResetCodeScreen({super.key, required this.email});

  @override
  State<VerifyResetCodeScreen> createState() => _VerifyResetCodeScreenState();
}

class _VerifyResetCodeScreenState extends State<VerifyResetCodeScreen> {
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<String> _codeDigits = List.filled(6, '');
  bool _isResending = false;
  int _remainingSeconds = 600; // 10 minutes

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
            _startTimer();
          }
        });
      }
    });
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _resendCode() {
    if (_isResending) return;

    setState(() {
      _isResending = true;
    });

    // Here you would call the resend code function from your auth service
    // For demonstration, we'll just simulate a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isResending = false;
          _remainingSeconds = 600; // Reset timer to 10 minutes
          // Clear all code fields
          for (var i = 0; i < 6; i++) {
            _codeControllers[i].clear();
            _codeDigits[i] = '';
          }
          // Focus on first field
          _focusNodes[0].requestFocus();
        });
      }
    });
  }

  void _verifyCode() {
    final code = _codeDigits.join();
    if (code.length != 6) return;
    context.read<AuthCubit>().verifyCode(email: widget.email, code: code);
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maskedEmail = _maskEmail(widget.email);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is VerifyCodeSuccess) {
          // Verification successful, go to reset password screen
          context.go(
            '/auth/reset-password',
            extra: {'email': state.email, 'code': state.code},
          );
        } else if (state is VerifyCodeFailure) {
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
                                      // Logo
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
                                      // Title
                                      Text(
                                        'Verify Reset Code',
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
                                      // Description
                                      Text(
                                        'Enter the 6-digit code sent to\n$maskedEmail',
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

                                      // Code input fields
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(
                                            6,
                                            (index) => Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isCompact
                                                    ? 3.0
                                                    : 4.0,
                                              ),
                                              child: _buildCodeDigitField(
                                                index,
                                                isCompact,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        height: keyboardHeight > 0
                                            ? 8
                                            : (isCompact ? 12 : 16),
                                      ),

                                      // Progress indicator
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                          6,
                                          (index) => Container(
                                            width: 24,
                                            height: 3,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  _codeDigits[index].isNotEmpty
                                                  ? (isDark
                                                        ? Colors.white
                                                        : Colors.black87)
                                                  : (isDark
                                                        ? Colors.white24
                                                        : Colors.black26),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        height: keyboardHeight > 0
                                            ? 12
                                            : (isCompact ? 20 : 24),
                                      ),

                                      // Verify Code button with loading
                                      BlocBuilder<AuthCubit, AuthState>(
                                        builder: (context, state) {
                                          final isLoading =
                                              state is AuthLoading;
                                          return Column(
                                            children: [
                                              PrimaryBtn(
                                                label: isLoading
                                                    ? 'Verifying...'
                                                    : 'Verify Code',
                                                onPressed: isLoading
                                                    ? null
                                                    : _verifyCode,
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

                                      SizedBox(
                                        height: keyboardHeight > 0
                                            ? 12
                                            : (isCompact ? 16 : 24),
                                      ),

                                      // Didn't receive code
                                      Text(
                                        'Didn\'t receive the code?',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black54,
                                          fontSize: isCompact ? 13 : 14,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      TextButton(
                                        onPressed: _remainingSeconds > 0
                                            ? null
                                            : _resendCode,
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 16,
                                          ),
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          _isResending
                                              ? 'Sending...'
                                              : _remainingSeconds > 0
                                              ? 'Resend in $_formattedTime'
                                              : 'Resend Code',
                                          style: TextStyle(
                                            color: _remainingSeconds > 0
                                                ? isDark
                                                      ? Colors.white38
                                                      : Colors.black38
                                                : isDark
                                                ? Colors.white
                                                : Colors.black87,
                                            fontSize: isCompact ? 13 : 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        height: keyboardHeight > 0
                                            ? 8
                                            : (isCompact ? 12 : 16),
                                      ),

                                      // Check spam folder note
                                      Text(
                                        'Check your spam folder if you don\'t see the email.\nThe code will expire in 10 minutes.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: isCompact ? 11 : 12,
                                          color: isDark
                                              ? Colors.white38
                                              : Colors.black38,
                                        ),
                                      ),
                                    ],
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

  Widget _buildCodeDigitField(int index, bool isCompact) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasFocus = _focusNodes[index].hasFocus;
    final hasValue = _codeDigits[index].isNotEmpty;

    // Dynamic sizing based on screen - smaller for fitting all in one line
    final fieldWidth = isCompact ? 36.0 : 42.0;
    final fieldHeight = isCompact ? 52.0 : 60.0;
    final fontSize = isCompact ? 22.0 : 26.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: fieldWidth,
      height: fieldHeight,
      decoration: BoxDecoration(
        color: hasValue
            ? (isDark
                  ? Colors.white.withOpacity(0.15)
                  : Colors.black.withOpacity(0.08))
            : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFocus
              ? (isDark ? Colors.white : Colors.black87)
              : (hasValue
                    ? (isDark ? Colors.white30 : Colors.black26)
                    : Colors.transparent),
          width: hasFocus ? 2 : 1,
        ),
        boxShadow: hasFocus
            ? [
                BoxShadow(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(
                    0.2,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: TextField(
        controller: _codeControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
          letterSpacing: 0,
        ),
        decoration: const InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onChanged: (value) {
          setState(() {
            if (value.isNotEmpty) {
              _codeDigits[index] = value;
              if (index < 5) {
                _focusNodes[index + 1].requestFocus();
              } else {
                _focusNodes[index].unfocus();
                // Auto-verify when all digits are filled
                if (_codeDigits.every((digit) => digit.isNotEmpty)) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _verifyCode();
                  });
                }
              }
            } else {
              _codeDigits[index] = '';
              if (index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
            }
          });
        },
      ),
    );
  }

  String _maskEmail(String email) {
    if (email.isEmpty) return '';

    final parts = email.split('@');
    if (parts.length != 2) return email;

    final name = parts[0];
    final domain = parts[1];

    String maskedName;
    if (name.length <= 2) {
      maskedName = name[0] + '***';
    } else {
      maskedName = name[0] + '*' * (name.length - 2) + name[name.length - 1];
    }

    return '$maskedName@$domain';
  }
}
