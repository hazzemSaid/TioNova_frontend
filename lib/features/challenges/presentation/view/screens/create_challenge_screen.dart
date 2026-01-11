import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/challenges/presentation/bloc/challenge_cubit.dart';
import 'package:tionova/features/challenges/presentation/services/firebase_challenge_helper.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';
import 'package:tionova/utils/widgets/custom_dialogs.dart';

class CreateChallengeScreen extends StatefulWidget {
  final String? challengeName;
  final int questionsCount;
  final int durationMinutes;
  final String inviteCode;
  final String? chapterName;
  final String? chapterDescription;

  const CreateChallengeScreen({
    super.key,
    this.challengeName,
    this.questionsCount = 10,
    this.durationMinutes = 15,
    this.inviteCode = 'Q4DRE9',
    this.chapterName,
    this.chapterDescription,
  });

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen>
    with SafeContextMixin {
  late TextEditingController _titleController;
  late int _questionsCount;
  late int _durationMinutes;
  String? _selectedChapterTitle; // for UI header and preview

  // Firebase real-time listeners
  StreamSubscription<DatabaseEvent>? _participantsSubscription;
  int _participantCount = 0;
  List<Map<String, dynamic>> _participants = [];

  @override
  void initState() {
    super.initState();
    _questionsCount = widget.questionsCount;
    _durationMinutes = widget.durationMinutes;
    _titleController = TextEditingController(text: widget.challengeName ?? '');
    _selectedChapterTitle = widget.challengeName;

    // Initialize Firebase listeners
    _setupFirebaseListeners();
  }

  void _setupFirebaseListeners() {
    // Validate inviteCode before setting up listeners
    if (widget.inviteCode.isEmpty) {
      print(
        'CreateChallengeScreen - ERROR: inviteCode is empty, cannot setup Firebase listeners',
      );
      if (mounted) {
        setState(() {
          _participantCount = 0;
          _participants = [];
        });
      }
      return;
    }

    final path = 'liveChallenges/${widget.inviteCode}/participants';
    print('CreateChallengeScreen - Setting up Firebase listener at: $path');

    try {
      // Use Safari-compatible helper with enhanced error handling
      _participantsSubscription = FirebaseChallengeHelper.listenToValue(
        path,
        onData: (snapshot) {
          print('CreateChallengeScreen - Firebase event received');
          print('CreateChallengeScreen - Snapshot exists: ${snapshot.exists}');
          print(
            'CreateChallengeScreen - Snapshot value type: ${snapshot.value.runtimeType}',
          );
          print('CreateChallengeScreen - Snapshot value: ${snapshot.value}');

          if (!mounted) return;

          try {
            // Use helper's parsing method for consistent data handling
            final participants = FirebaseChallengeHelper.parseParticipants(
              snapshot,
            );
            final activeCount = FirebaseChallengeHelper.countActiveParticipants(
              snapshot,
            );

            print(
              'CreateChallengeScreen - Participants updated: $activeCount active, names: ${participants.where((p) => p['active'] == true).map((p) => p['username']).toList()}',
            );

            setState(() {
              _participantCount = activeCount;
              _participants = participants
                  .where((p) => p['active'] == true)
                  .toList();
            });

            // Notify cubit of participant updates with validation
            final usernames = _participants
                .map((p) => p['username'] as String? ?? 'Unknown')
                .toList();
            context.read<ChallengeCubit>().updateParticipants(
              challengeId: widget.inviteCode,
              participants: usernames,
            );
          } catch (parseError) {
            print(
              'CreateChallengeScreen - Error parsing participants: $parseError',
            );
            // Don't crash, just log and continue with empty state
            if (mounted) {
              setState(() {
                _participantCount = 0;
                _participants = [];
              });
            }
          }
        },
        onError: (error) {
          print('CreateChallengeScreen - Firebase listener ERROR: $error');
          print('CreateChallengeScreen - Error type: ${error.runtimeType}');

          if (error.toString().contains('permission') ||
              error.toString().contains('PERMISSION_DENIED')) {
            print(
              'CreateChallengeScreen - PERMISSION DENIED! Check Firebase Security Rules!',
            );
          }

          // Handle Safari-specific errors gracefully
          if (mounted) {
            setState(() {
              _participantCount = 0;
              _participants = [];
            });
          }
        },
      );
    } catch (e) {
      print(
        'CreateChallengeScreen - Exception setting up Firebase listener: $e',
      );
      // Don't crash the app, just log the error
      if (mounted) {
        setState(() {
          _participantCount = 0;
          _participants = [];
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _participantsSubscription?.cancel();
    super.dispose();
  }

  Color get _bg => const Color(0xFF000000);
  Color get _cardBg => const Color(0xFF1C1C1E);
  Color get _panelBg => const Color(0xFF0E0E10);
  Color get _textPrimary => const Color(0xFFFFFFFF);
  Color get _textSecondary => const Color(0xFF8E8E93);
  Color get _divider => const Color(0xFF2C2C2E);
  Color get _green => const Color.fromRGBO(0, 153, 102, 1);

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChallengeCubit, ChallengeState>(
      listener: (context, state) {
        print('CreateChallengeScreen - BlocListener state: $state');

        if (state is ChallengeStarted) {
          print(
            'CreateChallengeScreen - Challenge started! Navigating to questions...',
          );
          print('CreateChallengeScreen - Challenge code: ${widget.inviteCode}');
          print(
            'CreateChallengeScreen - Questions count: ${state.questions.length}',
          );

          // Navigate to question screen using pushReplacement
          safeContext((ctx) {
            GoRouter.of(ctx).pushReplacementNamed(
              'challenge-live',
              pathParameters: {'code': widget.inviteCode},
              extra: {
                'challengeName': widget.challengeName ?? 'Challenge',
                'challengeCubit': ctx.read<ChallengeCubit>(),
                'authCubit': ctx.read<AuthCubit>(),
              },
            );
          });
        } else if (state is ChallengeError) {
          print('CreateChallengeScreen - Error: ${state.message}');
          safeContext((ctx) {
            // Show specific error message for insufficient participants
            if (state.message.contains('Need at least 2 participants')) {
              _showMinimumParticipantsError();
            } else {
              CustomDialogs.showErrorDialog(
                ctx,
                title: 'Error!',
                message: state.message,
              );
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ScrollConfiguration(
                  behavior: const NoGlowScrollBehavior(),
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            const SizedBox(height: 16),
                            _buildParticipantCountCard(),
                            const SizedBox(height: 16),
                            _buildChapterCard(),
                            const SizedBox(height: 16),
                            _buildChallengeTitleField(),
                            const SizedBox(height: 16),
                            _buildChallengePreviewCard(),
                            const SizedBox(height: 16),
                            _buildQRCodeSection(),
                            const SizedBox(height: 16),
                            _buildShareButtons(),
                            const SizedBox(height: 16),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildStartChallengeButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: _cardBg, shape: BoxShape.circle),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Share Challenge',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildChapterCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'CHAPTER',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Icon(Icons.check_circle, color: _green, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: _green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.chapterName?.isNotEmpty == true)
                      Text(
                        widget.chapterName!,
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedChapterTitle ??
                          widget.challengeName ??
                          'Selected Chapter',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.chapterDescription?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.chapterDescription!,
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeTitleField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHALLENGE TITLE',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            style: TextStyle(
              color: _textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Enter challenge title',
              hintStyle: TextStyle(
                color: _textPrimary.withOpacity(0.5),
                fontSize: 15,
              ),
              filled: true,
              fillColor: _panelBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengePreviewCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2DD881), Color(0xFF26B56A)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Content
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _titleController.text.isEmpty
                        ? (_selectedChapterTitle ?? 'Challenge')
                        : _titleController.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_questionsCount questions • $_durationMinutes minutes',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Ready to Start',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.qr_code_2_rounded, color: _textSecondary, size: 18),
              const SizedBox(width: 8),
              Text(
                'SCAN TO JOIN',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: widget.inviteCode,
              version: QrVersions.auto,
              size: 160,
              backgroundColor: Colors.white,
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'OR USE CODE',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: _panelBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.inviteCode,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: widget.inviteCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: _green,
                        content: const Text(
                          'Code copied to clipboard',
                          style: TextStyle(color: Colors.white),
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Icon(
                    Icons.copy_rounded,
                    color: _textSecondary,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  // TODO: Implement share functionality
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.ios_share, color: _textPrimary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Share',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  // TODO: Implement save QR functionality
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download_rounded, color: _textPrimary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Save QR',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartChallengeButton() {
    return BlocBuilder<ChallengeCubit, ChallengeState>(
      builder: (context, state) {
        final isLoading = state is ChallengeLoading;

        // Require at least 2 participants (admin + 1 other)
        final canStart = _participantCount >= 2 && !isLoading;
        final buttonText = _getStartButtonText();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: canStart ? _startChallenge : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canStart ? _green : _divider,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow_rounded, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          buttonText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  String _getStartButtonText() {
    if (_participantCount < 2) {
      return 'Waiting for participants...';
    }
    return 'Start Challenge';
  }

  Future<void> _startChallenge() async {
    if (_participantCount < 2) {
      _showMinimumParticipantsError();
      return;
    }

    print('CreateChallengeScreen - Start Challenge button pressed');
    print('CreateChallengeScreen - Participant count: $_participantCount');
    print('CreateChallengeScreen - Challenge code: ${widget.inviteCode}');

    print('CreateChallengeScreen - Calling startChallenge on cubit...');
    await context.read<ChallengeCubit>().startChallenge(
      challengeCode: widget.inviteCode,
    );
    print('CreateChallengeScreen - startChallenge call completed');
  }

  void _showMinimumParticipantsError() {
    CustomDialogs.showErrorDialog(
      context,
      title: 'Cannot Start Challenge',
      message:
          'You need at least one other participant to start the challenge.',
    );
  }

  Widget _buildParticipantCountCard() {
    final isWaitingForParticipants = _participantCount < 2;
    final statusText = isWaitingForParticipants
        ? 'waiting for more players'
        : 'joined and ready';
    final statusColor = isWaitingForParticipants ? _textSecondary : _green;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWaitingForParticipants ? _divider : _green.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isWaitingForParticipants
                      ? _textSecondary.withOpacity(0.15)
                      : _green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.people_rounded,
                  color: isWaitingForParticipants ? _textSecondary : _green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_participantCount players',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontSize: 14),
                    ),
                    if (isWaitingForParticipants) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Need at least 2 players to start',
                        style: TextStyle(
                          color: _textSecondary.withOpacity(0.8),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (_participantCount > 0 && !isWaitingForParticipants)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ready',
                        style: TextStyle(
                          color: _green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (_participants.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _panelBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: _green, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Participants in Lobby',
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _participants.map((participant) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _green.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              participant['username'] ?? 'Unknown',
                              style: TextStyle(
                                color: _textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
