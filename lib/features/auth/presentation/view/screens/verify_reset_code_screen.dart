import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/auth/presentation/view/widgets/PrimaryBtn.dart';

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

    // Here you would call the verify code function from your auth service
    // After verification, navigate to the reset password screen
    // In a real app, you would verify the code with your backend first
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Code verified successfully! Please create a new password.',
        ),
        backgroundColor: Colors.green,
      ),
    );
    context.go('/auth/reset-password', extra: widget.email);
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
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maskedEmail = _maskEmail(widget.email);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF121212), const Color(0xFF000000)]
                : [const Color(0xFFE0E0E0), const Color(0xFFBDBDBD)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                final isTablet = w >= 800;
                final isCompact = h < 700 || w < 360;
                return CustomScrollView(
                  slivers: [
                    // Top bar
                    SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Spacing
                    SliverToBoxAdapter(
                      child: SizedBox(height: isCompact ? h * 0.03 : h * 0.05),
                    ),

                    // Verify Code Form
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

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Shield icon
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E3A2B),
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  child: const Icon(
                                    Icons.shield_outlined,
                                    size: 32,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Title
                                Text(
                                  'Verify Reset Code',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Description
                                Text(
                                  'Enter the 6-digit code sent to\n$maskedEmail',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Code input fields
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(
                                    6,
                                    (index) => _buildCodeDigitField(index),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Verify Code button
                                PrimaryBtn(
                                  label: 'Verify Code',
                                  onPressed: _verifyCode,
                                  buttonColor: isDark
                                      ? Colors.white10
                                      : Colors.black87,
                                  textColor: isDark
                                      ? Colors.white
                                      : Colors.white,
                                ),

                                const SizedBox(height: 24),

                                // Didn't receive code
                                Text(
                                  'Didn\'t receive the code?',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                    fontSize: 14,
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
                                        : 'Resend in ${_formattedTime}',
                                    style: TextStyle(
                                      color: _remainingSeconds > 0
                                          ? isDark
                                                ? Colors.white38
                                                : Colors.black38
                                          : isDark
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Check spam folder note
                                Text(
                                  'Check your spam folder if you don\'t see the email.\nThe code will expire in 10 minutes.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Back to Login button
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).viewInsets.bottom + 16,
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
      ),
    );
  }

  Widget _buildCodeDigitField(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 40,
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withAlpha(5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            _codeDigits[index] = value;
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
              // Check if all digits are filled
              if (_codeDigits.every((digit) => digit.isNotEmpty)) {
                _verifyCode();
              }
            }
          } else {
            _codeDigits[index] = '';
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
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
