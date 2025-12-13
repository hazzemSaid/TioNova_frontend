import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/auth/presentation/view/widgets/auth_background.dart';

class CheckEmailScreen extends StatefulWidget {
  final String email;

  const CheckEmailScreen({super.key, required this.email});

  @override
  State<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends State<CheckEmailScreen> {
  Widget _buildFormContent(bool isDark, bool isDesktop) {
    final maskedEmail = _maskEmail(widget.email);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          'Check Your Email',
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
          'If an account with $maskedEmail exists, you\'ll receive a password reset code shortly.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            color: isDesktop
                ? Colors.white70
                : (isDark ? Colors.white70 : Colors.black54),
          ),
        ),
        const SizedBox(height: 32),

        // Check inbox button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              context.go('/auth/verify-reset-code', extra: widget.email);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Check Your Inbox',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Didn't receive code
        Center(
          child: Text(
            'Didn\'t receive the email?',
            style: TextStyle(
              color: isDesktop
                  ? Colors.white70
                  : (isDark ? Colors.white70 : Colors.black54),
              fontSize: 14,
            ),
          ),
        ),

        const SizedBox(height: 8),

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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final effectiveIsDark = kIsWeb ? true : true;

    return Scaffold(
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
