import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/challenges/presentation/bloc/challenge_cubit.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';

class ChallengeViewHelper {
  static void navigateToCreateChallenge(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    router?.pushNamed(
      'challenge-select',
      extra: {
        'folderCubit': context.read<FolderCubit>(),
        'chapterCubit': context.read<ChapterCubit>(),
        'authCubit': context.read<AuthCubit>(),
        'challengeCubit': context.read<ChallengeCubit>(),
      },
    );
  }
}
