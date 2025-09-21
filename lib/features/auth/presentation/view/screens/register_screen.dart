import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/auth/presentation/view/widgets/ThemedTextFormField.dart';
import 'package:tionova/features/theme/presentation/widgets/theme_toggle_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  final formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                final logoWidth = isTablet ? w * 0.25 : w * 0.5;
                final isCompact = h < 700 || w < 360;
                return Form(
                  key: formKey,
                  child: CustomScrollView(
                    slivers: [
                      // Top bar
                      SliverToBoxAdapter(
                        child: Row(
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

                      // Registration Form
                      SliverToBoxAdapter(
                        child: SizedBox(height: isCompact ? h * 0.1 : h * 0.05),
                      ),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Image.asset(
                                          isDark
                                              ? 'assets/images/logo2.png'
                                              : 'assets/images/logo1.png',
                                          width: logoWidth.clamp(90.0, 100.0),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                        width: double.infinity,
                                      ),
                                      Text(
                                        'Create Account',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Join TioNova and start your learning journey',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.black54,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Username
                                  Text(
                                    'Username',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ThemedTextFormField(
                                    controller: _usernameController,
                                    hintText: 'Username',
                                    prefixIcon: Icons.person_rounded,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 16),

                                  // Email
                                  Text(
                                    'Email',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ThemedTextFormField(
                                    controller: _emailController,
                                    hintText: 'Email',
                                    prefixIcon: Icons.email_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 16),

                                  // Password
                                  Text(
                                    'Password',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ThemedTextFormField(
                                    controller: _passwordController,
                                    hintText: 'Password',
                                    prefixIcon: Icons.lock_rounded,
                                    obscureText: _obscure1,
                                    isDark: isDark,
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(
                                        () => _obscure1 = !_obscure1,
                                      ),
                                      icon: Icon(
                                        _obscure1
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.black54,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Confirm Password
                                  Text(
                                    'Confirm Password',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ThemedTextFormField(
                                    controller: _confirmController,
                                    hintText: 'Confirm Password',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    obscureText: _obscure2,
                                    isDark: isDark,
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(
                                        () => _obscure2 = !_obscure2,
                                      ),
                                      icon: Icon(
                                        _obscure2
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.black54,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (formKey.currentState!.validate()) {
                                          print(_usernameController.text);
                                          print(_emailController.text);
                                          print(_passwordController.text);
                                          print(_confirmController.text);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDark
                                            ? Colors.white10
                                            : Colors.black87,
                                        foregroundColor: isDark
                                            ? Colors.white
                                            : Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: !isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),
                                  Row(
                                    children: const [
                                      Expanded(
                                        child: Divider(color: Colors.white12),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.0,
                                        ),
                                        child: Text(
                                          'OR',
                                          style: TextStyle(
                                            color: Colors.white38,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(color: Colors.white12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: Image.asset(
                                        'assets/icons/google.png',
                                        width: 24,
                                        height: 24,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: isDark
                                              ? Colors.white12
                                              : Colors.black12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        foregroundColor: isDark
                                            ? Colors.white
                                            : Colors.black,
                                        backgroundColor: isDark
                                            ? Colors.black12
                                            : Colors.white10,
                                      ),
                                      label: Text(
                                        'Continue with Google',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Bottom sign in link
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => context.go('/auth/login'),
                              child: Text(
                                'Already have an account? Login here',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
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
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
