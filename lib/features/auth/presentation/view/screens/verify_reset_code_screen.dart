import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
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

  Widget _buildFormContent(bool isDark, bool isDesktop) {
    final maskedEmail = _maskEmail(widget.email);
    final isCompact = MediaQuery.of(context).size.height < 650;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          'Verify Reset Code',
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

        // Description
        Text(
          'Enter the 6-digit code sent to\n$maskedEmail',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            color: isDesktop
                ? Colors.white70
                : (isDark ? Colors.white70 : Colors.black54),
          ),
        ),
        SizedBox(height: isDesktop ? 32 : 24),

        // Code input fields
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                (index) => Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 3.0 : 4.0,
                  ),
                  child: _buildCodeDigitField(index, isCompact),
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: isDesktop ? 20 : 16),

        // Progress indicator
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              6,
              (index) => Container(
                width: 24,
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: _codeDigits[index].isNotEmpty
                      ? (isDesktop
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black87))
                      : (isDesktop
                            ? Colors.white24
                            : (isDark ? Colors.white24 : Colors.black26)),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: isDesktop ? 24 : 20),

        // Verify Code button
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _verifyCode,
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
                        'Verify Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            );
          },
        ),

        SizedBox(height: isDesktop ? 20 : 16),

        // Didn't receive code
        Text(
          'Didn\'t receive the code?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDesktop
                ? Colors.white70
                : (isDark ? Colors.white70 : Colors.black54),
            fontSize: isDesktop ? 16 : 14,
          ),
        ),

        const SizedBox(height: 8),

        // Resend button
        Center(
          child: TextButton(
            onPressed: _remainingSeconds > 0 ? null : _resendCode,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _isResending
                  ? 'Sending...'
                  : _remainingSeconds > 0
                  ? 'Resend in $_formattedTime'
                  : 'Resend Code',
              style: TextStyle(
                color: _remainingSeconds > 0
                    ? (isDesktop
                          ? Colors.white38
                          : (isDark ? Colors.white38 : Colors.black38))
                    : (isDesktop
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black87)),
                fontSize: isDesktop ? 16 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        SizedBox(height: isDesktop ? 20 : 16),

        // Check spam folder note
        Center(
          child: Text(
            'Check your spam folder if you don\'t see the email.\nThe code will expire in 10 minutes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: isDesktop
                  ? Colors.white38
                  : (isDark ? Colors.white38 : Colors.black38),
            ),
          ),
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
    );
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
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 800;
    final effectiveIsDark = kIsWeb ? true : isDark;

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
