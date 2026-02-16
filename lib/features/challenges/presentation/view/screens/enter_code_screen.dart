import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/core/utils/safe_navigation.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/challenges/presentation/bloc/challenge_cubit.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';
import 'package:tionova/utils/widgets/custom_dialogs.dart';

class EntercodeScreen extends StatefulWidget {
  const EntercodeScreen({super.key});

  @override
  State<EntercodeScreen> createState() => _EntercodeScreenState();
}

class _EntercodeScreenState extends State<EntercodeScreen>
    with SafeContextMixin {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocus = FocusNode();
  bool _hasNavigated = false; // Track if we've already navigated
  bool _isJoining = false; // Track joining state separately from cubit loading
  String?
  _lastAttemptedCode; // Track last attempted code for better error handling

  // Colors aligned with the app's dark theme
  Color get _bg => const Color(0xFF000000);
  Color get _cardBg => const Color(0xFF1C1C1E);
  Color get _panelBg => const Color(0xFF0E0E10);
  Color get _textPrimary => const Color(0xFFFFFFFF);
  Color get _textSecondary => const Color(0xFF8E8E93);
  Color get _divider => const Color(0xFF2C2C2E);
  Color get _blue => const Color(0xFF007AFF);
  Color get _red => const Color(0xFFFF3B30);

  // Mock recent challenges (replace with real data when wired)
  final List<Map<String, String>> _recentChallenges = const [
    {'code': 'XYZ789', 'title': 'Data Structures Quiz'},
    {'code': 'DEF456', 'title': 'Data Structures Quiz'},
  ];

  @override
  void initState() {
    super.initState();
    // Nothing extra: TextField.onChanged will trigger rebuilds immediately
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocus.dispose();
    // Reset navigation flag and joining state on disposal
    _hasNavigated = false;
    _isJoining = false;
    _lastAttemptedCode = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isWeb = width > 900;
    final isTablet = width > 600 && width <= 900;

    // Responsive max width
    late double maxContentWidth;
    late double horizontalPadding;

    if (isWeb) {
      maxContentWidth = 500;
      horizontalPadding = 24;
    } else if (isTablet) {
      maxContentWidth = 450;
      horizontalPadding = 20;
    } else {
      maxContentWidth = double.infinity;
      horizontalPadding = 16;
    }

    return BlocListener<ChallengeCubit, ChallengeState>(
      listener: (context, state) {
        // Prevent multiple navigations or actions after disposal
        if (_hasNavigated || !contextIsValid) return;

        if (kDebugMode) {
          print('EnterCodeScreen - BlocListener state: $state');
        }

        // Use SafeContextMixin to prevent "deactivated widget" errors
        if (state is ChallengeJoined) {
          // Navigate to waiting lobby after successfully joining
          if (kDebugMode) {
            print('ChallengeJoined detected - navigating to waiting lobby');
          }

          _hasNavigated = true; // Mark as navigated
          _isJoining = false; // Reset joining state

          safeContext((ctx) {
            GoRouter.of(ctx).pushReplacementNamed(
              'challenge-lobby',
              pathParameters: {'code': _codeController.text.trim()},
              extra: {
                'challengeName': state.challengeName,
                'challengeCubit': ctx.read<ChallengeCubit>(),
                'authCubit': ctx.read<AuthCubit>(),
              },
            );
          });
        } else if (state is ChallengeError) {
          // Reset joining state on error
          setState(() {
            _isJoining = false;
          });

          // Show enhanced error dialog with specific error messages
          if (kDebugMode) {
            print('ChallengeError detected: ${state.message}');
          }

          safeContext((ctx) {
            _showEnhancedErrorDialog(ctx, state.message);
          });
        } else if (state is ChallengeLoading) {
          // Update joining state when loading starts
          if (!_isJoining) {
            setState(() {
              _isJoining = true;
            });
          }
        }
      },
      child: PopScope(
        canPop: true, // Allow normal pop behavior for stack navigation
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            // Reset navigation flag and state when popping
            _hasNavigated = false;
            _isJoining = false;
            _lastAttemptedCode = null;
          }
        },
        child: Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: ScrollConfiguration(
              behavior: const NoGlowScrollBehavior(),
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          height -
                          (MediaQuery.of(context).padding.top +
                              MediaQuery.of(context).padding.bottom),
                      maxWidth: maxContentWidth,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 20),
                          _buildHeroIcon(),
                          const SizedBox(height: 24),
                          _buildTitleSection(),
                          const SizedBox(height: 32),
                          _buildCodeInputCard(context),
                          const SizedBox(height: 20),
                          _buildRecentChallengesCard(context),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Header with back button and title centered
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            safeContext((ctx) {
              // Use safe navigation to handle cases where there's no history
              ctx.safePop(fallback: '/challenges');
            });
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _panelBg,
              shape: BoxShape.circle,
              border: Border.all(color: _divider),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
        const Spacer(),
        Text(
          'Join Challenge',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        // placeholder to balance the row
        const SizedBox(width: 32, height: 32),
      ],
    );
  }

  // Circle hero icon
  Widget _buildHeroIcon() {
    return Center(
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: _blue.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: _divider),
        ),
        child: Icon(Icons.person_add_alt_1, color: _blue, size: 28),
      ),
    );
  }

  // Title + subtitle
  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          'Enter Invite Code',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Got an invite code from a friend? Enter it below to join their challenge",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // Input Card
  Widget _buildCodeInputCard(BuildContext context) {
    return BlocBuilder<ChallengeCubit, ChallengeState>(
      builder: (context, state) {
        final isLoading = _isJoining || state is ChallengeLoading;

        return Container(
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _divider),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '6-Character Code',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _codeController,
                focusNode: _codeFocus,
                enabled: !isLoading,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 6,
                ),
                cursorColor: _blue,
                decoration: InputDecoration(
                  hintText: 'ABC123',
                  hintStyle: TextStyle(
                    color: _textSecondary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 6,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _panelBg),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _blue),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _divider.withValues(alpha: 0.5),
                    ),
                  ),
                  filled: true,
                  fillColor: isLoading
                      ? _panelBg.withValues(alpha: 0.5)
                      : _panelBg,
                ),
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _onJoinPressed(),
                onChanged: (_) =>
                    setState(() {}), // rebuild chips and button immediately
                inputFormatters: [
                  LengthLimitingTextInputFormatter(6),
                  // Allow letters, digits, and the symbols shown in design: @ # /
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@#/]')),
                  _UpperCaseTextFormatter(),
                ],
              ),
              const SizedBox(height: 12),
              // Six fixed slots like the design: filled with typed chars or empty placeholders
              _codeController.text.isEmpty != true
                  ? Align(
                      alignment: Alignment.center,
                      child: Wrap(
                        spacing: 10,
                        children: List.generate(6, (i) {
                          final txt = _codeController.text;
                          if (i < txt.length) {
                            return _KeyChip(
                              label: txt[i],
                              onTap: () {},
                              border: _blue,
                              fg: _textPrimary,
                            );
                          }
                          return _EmptyKey(border: _divider);
                        }),
                      ),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 16),
              Align(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed:
                        (_codeController.text.trim().length == 6 && !isLoading)
                        ? _onJoinPressed
                        : null,
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.bolt, size: 18),
                    label: Text(
                      _getJoinButtonText(isLoading),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _panelBg,
                      disabledForegroundColor: _textSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ),
              // Show validation feedback
              if (_codeController.text.isNotEmpty &&
                  _codeController.text.length < 6)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Code must be exactly 6 characters',
                    style: TextStyle(color: _textSecondary, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Note: keypad insertion removed; chips now mirror typed characters with 6 fixed slots

  // Recent challenges
  Widget _buildRecentChallengesCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _divider),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Challenges',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _recentChallenges.length; i++) ...[
            _RecentChallengeTile(
              code: _recentChallenges[i]['code']!,
              title: _recentChallenges[i]['title']!,
              onTap: () => _onTapRecent(_recentChallenges[i]['code']!),
              cardBg: _panelBg,
              divider: _divider,
              textPrimary: _textPrimary,
              textSecondary: _textSecondary,
            ),
            if (i != _recentChallenges.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  void _onJoinPressed() async {
    final code = _codeController.text.trim();
    if (kDebugMode) {
      print('_onJoinPressed called with code: $code');
    }

    // Validate code length
    if (code.length != 6) {
      if (kDebugMode) {
        print('Code length invalid: ${code.length}');
      }
      _showValidationError('Please enter a 6-character code');
      return;
    }

    // Validate code format (alphanumeric with allowed symbols)
    if (!RegExp(r'^[a-zA-Z0-9@#/]{6}$').hasMatch(code)) {
      _showValidationError('Code contains invalid characters');
      return;
    }

    // Unfocus keyboard
    _codeFocus.unfocus();

    // Check if widget is still mounted before accessing context
    if (!contextIsValid) return;

    // Set joining state and track attempted code
    setState(() {
      _isJoining = true;
      _lastAttemptedCode = code;
    });

    if (kDebugMode) {
      print('Calling joinChallenge with code: $code');
    }

    // Call join challenge API
    await context.read<ChallengeCubit>().joinChallenge(challengeCode: code);

    if (kDebugMode) {
      print('joinChallenge call completed');
    }
  }

  void _onTapRecent(String code) {
    if (_isJoining) return; // Prevent action while joining

    _codeController.text = code;
    _onJoinPressed();
  }

  /// Get appropriate button text based on loading state
  String _getJoinButtonText(bool isLoading) {
    if (isLoading) {
      return 'Joining...';
    }

    final codeLength = _codeController.text.trim().length;
    if (codeLength == 0) {
      return 'Enter Code';
    } else if (codeLength < 6) {
      return 'Enter ${6 - codeLength} More';
    } else {
      return 'Join Challenge';
    }
  }

  /// Show validation error as a snackbar
  void _showValidationError(String message) {
    if (!contextIsValid) return;

    safeContext((ctx) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    });
  }

  /// Show enhanced error dialog with specific error messages
  void _showEnhancedErrorDialog(BuildContext context, String errorMessage) {
    String title = 'Unable to Join Challenge';
    String message = errorMessage;
    String buttonText = 'Try Again';

    // Customize error messages based on error type
    if (errorMessage.toLowerCase().contains('not found') ||
        errorMessage.toLowerCase().contains('invalid') ||
        errorMessage.toLowerCase().contains('does not exist')) {
      title = 'Challenge Not Found';
      message = _lastAttemptedCode != null
          ? 'The challenge code "$_lastAttemptedCode" is not valid. Please check the code and try again.'
          : 'The challenge code you entered is not valid. Please check the code and try again.';
    } else if (errorMessage.toLowerCase().contains('full') ||
        errorMessage.toLowerCase().contains('capacity')) {
      title = 'Challenge Full';
      message =
          'This challenge has reached its maximum number of participants. Please try joining a different challenge.';
    } else if (errorMessage.toLowerCase().contains('ended') ||
        errorMessage.toLowerCase().contains('finished') ||
        errorMessage.toLowerCase().contains('completed')) {
      title = 'Challenge Ended';
      message =
          'This challenge has already ended. Please try joining a different challenge.';
    } else if (errorMessage.toLowerCase().contains('network') ||
        errorMessage.toLowerCase().contains('connection') ||
        errorMessage.toLowerCase().contains('timeout')) {
      title = 'Connection Problem';
      message =
          'Unable to connect to the challenge server. Please check your internet connection and try again.';
      buttonText = 'Retry';
    } else if (errorMessage.toLowerCase().contains('already joined') ||
        errorMessage.toLowerCase().contains('duplicate')) {
      title = 'Already Joined';
      message =
          'You have already joined this challenge. Please wait for the host to start the challenge.';
      buttonText = 'OK';
    }

    CustomDialogs.showErrorDialog(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: () {
        // Clear the code field if it's an invalid code error
        if (title == 'Challenge Not Found') {
          _codeController.clear();
          _codeFocus.requestFocus();
        }
      },
    );
  }
}

// Uppercase formatter
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}

class _RecentChallengeTile extends StatelessWidget {
  final String code;
  final String title;
  final VoidCallback onTap;
  final Color cardBg;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;

  const _RecentChallengeTile({
    required this.code,
    required this.title,
    required this.onTap,
    required this.cardBg,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                shape: BoxShape.circle,
                border: Border.all(color: divider),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color border;
  final Color fg;

  const _KeyChip({
    required this.label,
    required this.onTap,
    required this.border,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EmptyKey extends StatelessWidget {
  final Color border;
  const _EmptyKey({required this.border});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border.withValues(alpha: 0.35)),
      ),
      child: const SizedBox(width: 8, height: 14),
    );
  }
}
