import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/features/challenges/presentation/services/firebase_challenge_helper.dart';
import 'package:tionova/features/challenges/presentation/view/utils/challenge_lobby_helper.dart';
import 'package:tionova/features/challenges/presentation/view/utils/challenge_lobby_theme.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/lobby_leave_button.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/lobby_player_list.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/lobby_status_section.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/lobby_trophy_icon.dart';

/// Waiting lobby screen for participants who joined via code
/// Shows participant count and waits for owner to start the challenge
class ChallengeWaitingLobbyScreen extends StatefulWidget {
  final String challengeCode;
  final String challengeName;

  const ChallengeWaitingLobbyScreen({
    super.key,
    required this.challengeCode,
    required this.challengeName,
  });

  @override
  State<ChallengeWaitingLobbyScreen> createState() =>
      _ChallengeWaitingLobbyScreenState();
}

class _ChallengeWaitingLobbyScreenState
    extends State<ChallengeWaitingLobbyScreen>
    with SafeContextMixin {
  DatabaseReference? _statusRef;
  DatabaseReference? _participantsRef;
  StreamSubscription<DatabaseEvent>? _statusSubscription;
  StreamSubscription<DatabaseEvent>? _participantsSubscription;

  int _participantCount = 0;
  List<Map<String, dynamic>> _participants = [];

  @override
  void initState() {
    super.initState();
    _setupFirebaseListeners();
  }

  void _setupFirebaseListeners() {
    // Use Safari-compatible Firebase helper

    // 1. Listen to challenge status to know when owner starts
    final statusPath = 'liveChallenges/${widget.challengeCode}/meta/status';
    _statusRef = FirebaseChallengeHelper.getRef(statusPath);

    // Initial check in case challenge already started
    FirebaseChallengeHelper.getOnce(statusPath).then((snapshot) {
      if (mounted && snapshot != null) {
        final status = snapshot.value as String?;
        if (status == 'in-progress' || status == 'progress') {
          _navigateToQuestions();
        }
      }
    });

    _statusSubscription = _statusRef!.onValue.listen((event) {
      if (!mounted) return;
      final status = event.snapshot.value as String?;
      if (status == 'in-progress' || status == 'progress') {
        _navigateToQuestions();
      }
    });

    // 2. Listen to participants for live count
    final participantsPath =
        'liveChallenges/${widget.challengeCode}/participants';
    _participantsRef = FirebaseChallengeHelper.getRef(participantsPath);

    _participantsSubscription = _participantsRef!.onValue.listen((event) {
      if (!mounted) return;

      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final parsed = ChallengeLobbyHelper.parseParticipants(data);
        setState(() {
          _participants = parsed;
          _participantCount = ChallengeLobbyHelper.getActiveCount(parsed);
        });
      } else {
        setState(() {
          _participants = [];
          _participantCount = 0;
        });
      }
    });
  }

  void _navigateToQuestions() {
    safeContext((ctx) {
      ChallengeLobbyHelper.navigateToLiveChallenge(
        context: ctx,
        challengeCode: widget.challengeCode,
        challengeName: widget.challengeName,
      );
    });
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _participantsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          LobbyLeaveButton.showLeaveDialog(context);
        }
      },
      child: Scaffold(
        backgroundColor: ChallengeLobbyTheme.bg,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    screenHeight -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ChallengeLobbyTheme.getResponsiveValue(
                    context,
                    mobile: 20,
                    tablet: 32,
                  ),
                  vertical: isSmallScreen ? 12 : 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (!isSmallScreen) const Spacer(flex: 1),
                    const LobbyTrophyIcon(),
                    SizedBox(
                      height: ChallengeLobbyTheme.getResponsiveValue(
                        context,
                        mobile: 20,
                        tablet: 32,
                      ),
                    ),
                    LobbyStatusSection(
                      challengeName: widget.challengeName,
                      isSmallScreen: isSmallScreen,
                    ),
                    SizedBox(
                      height: ChallengeLobbyTheme.getResponsiveValue(
                        context,
                        mobile: 20,
                        tablet: 32,
                      ),
                    ),
                    LobbyPlayerList(
                      participantCount: _participantCount,
                      participants: _participants,
                    ),
                    if (!isSmallScreen) const Spacer(flex: 1),
                    const SizedBox(height: 16),
                    const LobbyLeaveButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
