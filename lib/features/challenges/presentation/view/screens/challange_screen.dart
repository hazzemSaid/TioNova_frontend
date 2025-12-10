import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/challenges/presentation/bloc/challenge_cubit.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/OptionCard.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/features/folder/presentation/view/widgets/BuildTap.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';
import 'package:tionova/utils/widgets/page_header.dart';

class ChallangeScreen extends StatefulWidget {
  const ChallangeScreen({super.key});

  @override
  State<ChallangeScreen> createState() => _ChallangeScreenState();
}

class _ChallangeScreenState extends State<ChallangeScreen>
    with SafeContextMixin {
  var boolean = true;
  @override
  Widget build(BuildContext context) {
    final verticalSpacing = MediaQuery.of(context).size.height * 0.02;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,

      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const NoGlowScrollBehavior(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      SizedBox(height: verticalSpacing * 1.5),
                      const PageHeader(
                        title: 'Challenges',
                        subtitle: 'Challenge your self and improve your skills',
                      ),
                      SizedBox(height: verticalSpacing * 1.5),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withOpacity(0.6),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: BuildTab(
                          label: 'Active Challenges',
                          icon: Icons.quiz_outlined,
                          isActive: boolean,
                          onTap: () {
                            setState(() {
                              boolean = true;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: BuildTab(
                          label: 'Leaderboard',
                          icon: Icons.leaderboard_outlined,
                          isActive: !boolean,
                          onTap: () {
                            setState(() {
                              boolean = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: verticalSpacing * 1.5),
              ),
              // Option Cards Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      OptionCard(
                        gradientColors: const [
                          Color(0xFF006B54),
                          Color(0xFF00C46A),
                        ],
                        icon: Icons.qr_code_scanner,
                        iconGradient: const [
                          Color(0x3300C46A),
                          Color(0x1A00C46A),
                        ],
                        title: 'Scan QR Code',
                        subtitle: 'Quick access with your camera',
                        actionLabel: 'Scan',
                        onTap: () {
                          context.push('/challenges/scan-qr');
                        },
                      ),
                      const SizedBox(height: 16),
                      OptionCard(
                        gradientColors: const [
                          Color(0xFF0035D4),
                          Color(0xFF0066FF),
                        ],
                        icon: Icons.person_add_alt_1_outlined,
                        iconGradient: const [
                          Color(0x330066FF),
                          Color(0x1A0066FF),
                        ],
                        title: 'Have an invite code?',
                        subtitle: 'Enter code manually to join',
                        actionLabel: 'Enter Code',
                        onTap: () {
                          // Use push instead of go to maintain navigation stack
                          context.push('/enter-code');
                        },
                        outlined: true,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: verticalSpacing * 1.5),
              ),
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.07),
                        blurRadius: 16,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              //rgb(0, 153, 102)
                              Color.fromRGBO(0, 153, 102, 0.2),
                              Color.fromRGBO(0, 153, 102, 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                //rgb(0, 153, 102)
                                Color.fromRGBO(0, 153, 102, 0.2),
                                Color.fromRGBO(0, 153, 102, 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.emoji_events_outlined,
                            color: Color.fromRGBO(0, 153, 102, 1),
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Create Challenge',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 15,
                          letterSpacing: 0.2,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a new challenge and challenge your friends',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 18),
                      InkWell(
                        onTap: () {
                          if (!mounted) return;
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
                        },
                        borderRadius: BorderRadius.circular(60),
                        child: Container(
                          width: double.infinity,
                          height: 35,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF006B54), // Darker green
                                Color(0xFF00C46A), // Brighter green
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [0.1, 0.9],
                            ),
                            borderRadius: BorderRadius.circular(60),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF00C46A).withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              if (!mounted) return;
                              final router = GoRouter.maybeOf(context);
                              router?.pushNamed(
                                'challenge-select',
                                extra: {
                                  'folderCubit': context.read<FolderCubit>(),
                                  'chapterCubit': context.read<ChapterCubit>(),
                                  'authCubit': context.read<AuthCubit>(),
                                  'challengeCubit': context
                                      .read<ChallengeCubit>(),
                                },
                              );
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.black,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Create Challenge',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.1,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black12,
                                          blurRadius: 2,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
