import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/auth/presentation/view/widgets/PrimaryBtn.dart';

class CheckEmailScreen extends StatefulWidget {
  final String email;

  const CheckEmailScreen({super.key, required this.email});

  @override
  State<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends State<CheckEmailScreen> {
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

                    // Main Content
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
                                // Email icon
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E3A2B),
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  child: const Icon(
                                    Icons.send_rounded,
                                    size: 32,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Title
                                Text(
                                  'Check Your Email',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Description
                                Text(
                                  'If an account with $maskedEmail exists,\nyou\'ll receive a password reset code shortly.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Check inbox button
                                PrimaryBtn(
                                  label: 'Check your inbox',
                                  onPressed: () {
                                    context.go(
                                      '/auth/verify-reset-code',
                                      extra: widget.email,
                                    );
                                  },
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
                                  'Didn\'t receive the email?',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                TextButton(
                                  onPressed: () {
                                    // Resend email logic
                                  },
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
                                    'Resend in 10:00',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.black38,
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

                    // Bottom back to login link
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
