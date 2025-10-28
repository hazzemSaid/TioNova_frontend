import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/challenges/presentation/bloc/challenge_cubit.dart';
import 'package:tionova/features/challenges/presentation/view/screens/challenge_waiting_lobby_screen.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';

class EntercodeScreen extends StatefulWidget {
  const EntercodeScreen({super.key});

  @override
  State<EntercodeScreen> createState() => _EntercodeScreenState();
}

class _EntercodeScreenState extends State<EntercodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocus = FocusNode();

  // Colors aligned with the app's dark theme
  Color get _bg => const Color(0xFF000000);
  Color get _cardBg => const Color(0xFF1C1C1E);
  Color get _panelBg => const Color(0xFF0E0E10);
  Color get _textPrimary => const Color(0xFFFFFFFF);
  Color get _textSecondary => const Color(0xFF8E8E93);
  Color get _divider => const Color(0xFF2C2C2E);
  Color get _blue => const Color(0xFF007AFF);

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = width > 900;
    final maxContentWidth = 520.0; // keeps a compact, focused panel on web

    return BlocListener<ChallengeCubit, ChallengeState>(
      listener: (context, state) {
        // Guard against reacting after this widget has been disposed.
        // Some bloc state changes can arrive while the widget is unmounted
        // (for example when navigating away), which causes ancestor lookups
        // like Navigator.of(context) or ScaffoldMessenger.of(context) to fail.
        if (!mounted) return;

        print('EnterCodeScreen - BlocListener state: $state');
        if (state is ChallengeJoined) {
          // Navigate to waiting lobby after successfully joining
          print('ChallengeJoined detected - navigating to waiting lobby');

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: context.read<ChallengeCubit>()),
                  BlocProvider.value(value: context.read<AuthCubit>()),
                ],
                child: ChallengeWaitingLobbyScreen(
                  challengeCode: _codeController.text.trim(),
                  challengeName: state.challengeName,
                ),
              ),
            ),
          );
        } else if (state is ChallengeError) {
          // Show error message
          print('ChallengeError detected: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: ScrollConfiguration(
            behavior: const NoGlowScrollBehavior(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWeb ? (width - maxContentWidth) / 2 : 16,
                      vertical: 16,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWeb ? maxContentWidth : double.infinity,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 12),
                          _buildHeroIcon(),
                          const SizedBox(height: 16),
                          _buildTitleSection(),
                          const SizedBox(height: 16),
                          _buildCodeInputCard(context),
                          const SizedBox(height: 16),
                          _buildRecentChallengesCard(context),
                        ],
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

  // Header with back button and title centered
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
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
          color: _blue.withOpacity(0.12),
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
        final isLoading = state is ChallengeLoading;
        
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
                  filled: true,
                  fillColor: _panelBg,
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
                  : SizedBox.shrink(),
              const SizedBox(height: 16),
              Align(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: (_codeController.text.trim().length == 6 && !isLoading)
                        ? _onJoinPressed
                        : null,
                    icon: isLoading 
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.bolt, size: 18),
                    label: Text(
                      isLoading ? 'Joining...' : 'Join Challenge',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
    print('_onJoinPressed called with code: $code');
    if (code.length != 6) {
      print('Code length invalid: ${code.length}');
      return;
    }
    
    // Unfocus keyboard
    _codeFocus.unfocus();
    
    // Get auth token
    final authState = context.read<AuthCubit>().state;
    print('Auth state: ${authState.runtimeType}');
    if (authState is! AuthSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    print('Calling joinChallenge with token and code: $code');
    // Call join challenge API
    await context.read<ChallengeCubit>().joinChallenge(
      token: authState.token,
      challengeCode: code,
    );
    print('joinChallenge call completed');
  }

  void _onTapRecent(String code) {
    _codeController.text = code;
    _onJoinPressed();
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
        border: Border.all(color: border.withOpacity(0.35)),
      ),
      child: const SizedBox(width: 8, height: 14),
    );
  }
}
