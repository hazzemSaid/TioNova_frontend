import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/challenges/presentation/bloc/challenge_cubit.dart';

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
    print('WaitingLobbyScreen - Challenge code: ${widget.challengeCode}');

    // Get Firebase Database instance
    final database = FirebaseDatabase.instance;
    print('WaitingLobbyScreen - Firebase Database instance: $database');
    print('WaitingLobbyScreen - Firebase App name: ${database.app.name}');
    print('WaitingLobbyScreen - Firebase App options: ${database.app.options}');

    // Test basic connectivity first
    print('WaitingLobbyScreen - Testing basic Firebase connectivity...');
    database.ref('.info/connected').onValue.listen((event) {
      final connected = event.snapshot.value as bool?;
      print('WaitingLobbyScreen - Firebase connection status: $connected');
    });

    // Listen to challenge status to know when owner starts
    final statusPath = 'liveChallenges/${widget.challengeCode}/meta/status';
    print('WaitingLobbyScreen - Setting up status listener at: $statusPath');
    _statusRef = database.ref(statusPath);

    print('WaitingLobbyScreen - Status ref created: $_statusRef');

    // First, check current status in case challenge already started
    _statusRef!
        .once()
        .then((snapshot) {
          print('WaitingLobbyScreen - Initial status check completed');
          print(
            'WaitingLobbyScreen - Initial status exists: ${snapshot.snapshot.exists}',
          );
          print(
            'WaitingLobbyScreen - Initial status value: ${snapshot.snapshot.value}',
          );

          if (mounted) {
            final status = snapshot.snapshot.value as String?;
            if (status == 'in-progress' || status == 'progress') {
              print(
                'WaitingLobbyScreen - Challenge already in progress! Navigating immediately...',
              );
              context.read<ChallengeCubit>().setupParticipantListeners(
                widget.challengeCode,
              );
              _navigateToQuestions();
            }
          }
        })
        .catchError((error) {
          print('WaitingLobbyScreen - Initial status check ERROR: $error');
        });

    _statusSubscription = _statusRef!.onValue.listen(
      (event) {
        print('WaitingLobbyScreen - Status event received');
        print(
          'WaitingLobbyScreen - Status snapshot exists: ${event.snapshot.exists}',
        );
        print('WaitingLobbyScreen - Status value: ${event.snapshot.value}');
        print(
          'WaitingLobbyScreen - Status value type: ${event.snapshot.value.runtimeType}',
        );

        if (!mounted) return;

        final status = event.snapshot.value as String?;
        print('WaitingLobbyScreen - Parsed status: "$status"');

        // Check for both "in-progress" and "progress" (in case backend uses different format)
        if (status == 'in-progress' || status == 'progress') {
          print(
            'WaitingLobbyScreen - Challenge started! Navigating to questions...',
          );
          print('WaitingLobbyScreen - Challenge code: ${widget.challengeCode}');

          // Set up Firebase listeners in ChallengeCubit for real-time updates
          print(
            'WaitingLobbyScreen - Setting up participant listeners in cubit',
          );
          context.read<ChallengeCubit>().setupParticipantListeners(
            widget.challengeCode,
          );

          // Owner started the challenge, navigate to question screen
          _navigateToQuestions();
        } else {
          print(
            'WaitingLobbyScreen - Status is not in-progress/progress, waiting...',
          );
        }
      },
      onError: (error) {
        print('WaitingLobbyScreen - Status listener ERROR: $error');
        if (error.toString().contains('permission') ||
            error.toString().contains('PERMISSION_DENIED')) {
          print('WaitingLobbyScreen - PERMISSION DENIED on status path!');
        }
      },
      cancelOnError: false,
    );

    print('WaitingLobbyScreen - Status subscription created');

    // Listen to participants for live count
    final participantsPath =
        'liveChallenges/${widget.challengeCode}/participants';
    print(
      'WaitingLobbyScreen - Setting up participants listener at: $participantsPath',
    );
    _participantsRef = database.ref(participantsPath);

    print('WaitingLobbyScreen - Participants ref created: $_participantsRef');
    print('WaitingLobbyScreen - About to subscribe to onValue stream...');

    // First, try to fetch data once to verify connection
    _participantsRef!
        .once()
        .then((snapshot) {
          print('WaitingLobbyScreen - Initial fetch completed');
          print(
            'WaitingLobbyScreen - Initial snapshot exists: ${snapshot.snapshot.exists}',
          );
          print(
            'WaitingLobbyScreen - Initial snapshot value: ${snapshot.snapshot.value}',
          );
        })
        .catchError((error) {
          print('WaitingLobbyScreen - Initial fetch ERROR: $error');
        });

    _participantsSubscription = _participantsRef!.onValue.listen(
      (event) {
        print('WaitingLobbyScreen - Participants event received');
        print('WaitingLobbyScreen - Snapshot exists: ${event.snapshot.exists}');
        print(
          'WaitingLobbyScreen - Snapshot value type: ${event.snapshot.value.runtimeType}',
        );
        print('WaitingLobbyScreen - Snapshot value: ${event.snapshot.value}');

        if (!mounted) return;

        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          print('WaitingLobbyScreen - Processing ${data.length} participants');
          final participants = <Map<String, dynamic>>[];
          int activeCount = 0;

          data.forEach((userId, userData) {
            print(
              'WaitingLobbyScreen - Processing userId: $userId, data: $userData',
            );
            final participantData = Map<String, dynamic>.from(userData as Map);
            final isActive = participantData['active'] == true;
            final username = participantData['username'] ?? 'Unknown Player';

            print(
              'WaitingLobbyScreen - Username: $username, Active: $isActive',
            );

            participants.add({
              'userId': userId,
              'username': username,
              'active': isActive,
              'joinedAt': participantData['joinedAt'],
            });

            if (isActive) {
              activeCount++;
            }
          });

          setState(() {
            _participants = participants;
            _participantCount = activeCount;
          });

          print('WaitingLobbyScreen - setState COMPLETED');
          print(
            'WaitingLobbyScreen - _participantCount is now: $_participantCount',
          );
          print('WaitingLobbyScreen - _participants is now: $_participants');
          print(
            'WaitingLobbyScreen - _participants.length: ${_participants.length}',
          );

          // Force a rebuild check
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print(
              'WaitingLobbyScreen - POST FRAME: _participantCount: $_participantCount',
            );
            print(
              'WaitingLobbyScreen - POST FRAME: _participants.length: ${_participants.length}',
            );
          });

          print(
            'WaitingLobbyScreen - Participants updated: $activeCount active, names: ${participants.where((p) => p['active'] == true).map((p) => p['username']).toList()}',
          );
        } else {
          print('WaitingLobbyScreen - No participants data found');
          setState(() {
            _participants = [];
            _participantCount = 0;
          });
        }
      },
      onError: (error) {
        print('WaitingLobbyScreen - Firebase listener ERROR: $error');
        print('WaitingLobbyScreen - Error type: ${error.runtimeType}');
        if (error.toString().contains('permission') ||
            error.toString().contains('PERMISSION_DENIED')) {
          print(
            'WaitingLobbyScreen - PERMISSION DENIED! Check Firebase Security Rules!',
          );
        }
      },
      cancelOnError: false,
    );

    print(
      'WaitingLobbyScreen - Participants subscription created successfully',
    );
    print(
      'WaitingLobbyScreen - Subscription active: ${_participantsSubscription != null}',
    );
    print(
      'WaitingLobbyScreen - Subscription isPaused: ${_participantsSubscription?.isPaused}',
    );
    print('WaitingLobbyScreen - _setupFirebaseListeners COMPLETED');
  }

  void _navigateToQuestions() {
    print('WaitingLobbyScreen - _navigateToQuestions called');
    print('WaitingLobbyScreen - mounted: $mounted');

    if (!mounted) {
      print('WaitingLobbyScreen - Widget not mounted, aborting navigation');
      return;
    }

    print('WaitingLobbyScreen - Creating navigation to LiveQuestionScreen');
    print('WaitingLobbyScreen - Challenge code: ${widget.challengeCode}');
    print('WaitingLobbyScreen - Challenge name: ${widget.challengeName}');

    safeContext((ctx) {
      GoRouter.of(ctx).pushNamed(
        'challenge-live',
        pathParameters: {'code': widget.challengeCode},
        extra: {
          'challengeName': widget.challengeName,
          'challengeCubit': ctx.read<ChallengeCubit>(),
          'authCubit': ctx.read<AuthCubit>(),
        },
      );
    });

    print('WaitingLobbyScreen - Navigation initiated successfully');
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _participantsSubscription?.cancel();
    super.dispose();
  }

  Color get _bg => const Color(0xFF000000);
  Color get _cardBg => const Color(0xFF1C1C1E);
  Color get _panelBg => const Color(0xFF0E0E10);
  Color get _textPrimary => const Color(0xFFFFFFFF);
  Color get _textSecondary => const Color(0xFF8E8E93);
  Color get _green => const Color.fromRGBO(0, 153, 102, 1);

  /// Get responsive sizing based on screen dimensions
  double _getResponsiveValue(
    BuildContext context, {
    required double mobile,
    required double tablet,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 600 ? tablet : mobile;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showLeaveDialog();
        }
      },
      child: Scaffold(
        backgroundColor: _bg,
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
                  horizontal: _getResponsiveValue(
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
                    _buildTrophyIcon(context),
                    SizedBox(
                      height: _getResponsiveValue(
                        context,
                        mobile: 20,
                        tablet: 32,
                      ),
                    ),
                    _buildTitle(context),
                    SizedBox(
                      height: _getResponsiveValue(
                        context,
                        mobile: 12,
                        tablet: 16,
                      ),
                    ),
                    _buildParticipantCount(context),
                    SizedBox(
                      height: _getResponsiveValue(
                        context,
                        mobile: 20,
                        tablet: 32,
                      ),
                    ),
                    _buildWaitingMessage(context),
                    SizedBox(
                      height: _getResponsiveValue(
                        context,
                        mobile: 24,
                        tablet: 48,
                      ),
                    ),
                    _buildLoadingIndicator(context),
                    if (!isSmallScreen) const Spacer(flex: 1),
                    SizedBox(
                      height: _getResponsiveValue(
                        context,
                        mobile: 12,
                        tablet: 16,
                      ),
                    ),
                    _buildLeaveButton(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrophyIcon(BuildContext context) {
    final trophySize = _getResponsiveValue(context, mobile: 100, tablet: 120);
    final iconSize = _getResponsiveValue(context, mobile: 56, tablet: 64);

    return Container(
      width: trophySize,
      height: trophySize,
      decoration: BoxDecoration(
        color: _green.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.emoji_events_outlined, size: iconSize, color: _green),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final fontSize = _getResponsiveValue(context, mobile: 28, tablet: 32);

    return Text(
      'Get Ready!',
      style: TextStyle(
        color: _textPrimary,
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildParticipantCount(BuildContext context) {
    print('WaitingLobbyScreen - _buildParticipantCount called');
    print('WaitingLobbyScreen - _participantCount: $_participantCount');
    print('WaitingLobbyScreen - _participants: $_participants');
    print('WaitingLobbyScreen - _participants.length: ${_participants.length}');

    // Filter only active participants
    final activeParticipants = _participants
        .where((p) => p['active'] == true)
        .toList();

    print(
      'WaitingLobbyScreen - activeParticipants.length: ${activeParticipants.length}',
    );
    print('WaitingLobbyScreen - activeParticipants: $activeParticipants');

    final containerPadding = _getResponsiveValue(
      context,
      mobile: 16,
      tablet: 20,
    );
    final maxListHeight = MediaQuery.of(context).size.height * 0.25;
    final fontSize = _getResponsiveValue(context, mobile: 18, tablet: 20);

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_rounded, color: _green, size: 24),
              const SizedBox(width: 12),
              Text(
                '$_participantCount players',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _green,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          if (activeParticipants.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(maxHeight: maxListHeight),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _panelBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Players in Lobby',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: activeParticipants.map((participant) {
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
                              Flexible(
                                child: Text(
                                  participant['username'] ?? 'Unknown',
                                  style: TextStyle(
                                    color: _textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWaitingMessage(BuildContext context) {
    final titleFontSize = _getResponsiveValue(context, mobile: 16, tablet: 18);
    final subtitleFontSize = _getResponsiveValue(
      context,
      mobile: 13,
      tablet: 15,
    );

    return Column(
      children: [
        Text(
          widget.challengeName,
          style: TextStyle(
            color: _textPrimary,
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Waiting for the host to start the challenge...',
          style: TextStyle(color: _textSecondary, fontSize: subtitleFontSize),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    final loaderSize = _getResponsiveValue(context, mobile: 36, tablet: 40);
    final fontSize = _getResponsiveValue(context, mobile: 12, tablet: 14);

    return Column(
      children: [
        SizedBox(
          width: loaderSize,
          height: loaderSize,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(_green),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Connected',
          style: TextStyle(
            color: _green,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveButton(BuildContext context) {
    final buttonHeight = _getResponsiveValue(context, mobile: 48, tablet: 52);

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: OutlinedButton.icon(
        onPressed: () => _showLeaveDialog(),
        icon: const Icon(Icons.exit_to_app, size: 20),
        label: const Text(
          'Leave Challenge',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: _textSecondary,
          side: BorderSide(color: _cardBg, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showLeaveDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text('Leave Challenge?', style: TextStyle(color: _textPrimary)),
        content: Text(
          'Are you sure you want to leave this challenge?',
          style: TextStyle(color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: _textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              context.go('/challenges'); // Navigate back to challenges screen
            },
            child: Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
