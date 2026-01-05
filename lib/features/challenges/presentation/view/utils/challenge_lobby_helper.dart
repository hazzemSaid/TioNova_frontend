import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/challenges/presentation/bloc/challenge_cubit.dart';

class ChallengeLobbyHelper {
  static List<Map<String, dynamic>> parseParticipants(
    Map<dynamic, dynamic> data,
  ) {
    final participants = <Map<String, dynamic>>[];

    data.forEach((userId, userData) {
      if (userData is Map) {
        final participantData = Map<String, dynamic>.from(userData);
        final isActive = participantData['active'] == true;
        final username = participantData['username'] ?? 'Unknown Player';

        participants.add({
          'userId': userId.toString(),
          'username': username,
          'active': isActive,
          'joinedAt': participantData['joinedAt'],
        });
      }
    });

    return participants;
  }

  static int getActiveCount(List<Map<String, dynamic>> participants) {
    return participants.where((p) => p['active'] == true).length;
  }

  static void navigateToLiveChallenge({
    required BuildContext context,
    required String challengeCode,
    required String challengeName,
  }) {
    context.read<ChallengeCubit>().setupParticipantListeners(challengeCode);

    GoRouter.of(context).pushNamed(
      'challenge-live',
      pathParameters: {'code': challengeCode},
      extra: {
        'challengeName': challengeName,
        'challengeCubit': context.read<ChallengeCubit>(),
      },
    );
  }
}
