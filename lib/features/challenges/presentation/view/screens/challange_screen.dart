import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/challenges/presentation/bloc/challenge_cubit.dart';
import 'package:tionova/features/challenges/presentation/view/screens/select_chapter_screen.dart';
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

class _ChallangeScreenState extends State<ChallangeScreen> {
  var boolean = true;
  @override
  Widget build(BuildContext context) {
    final verticalSpacing = MediaQuery.of(context).size.height * 0.02;

    return Scaffold(
      backgroundColor: Colors.black,

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
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFF2C2C2E),
                      width: 1,
                    ),
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
                        backgroundColor: const Color(0xFF0F0F0F),
                        icon: Icons.qr_code_scanner,
                        iconGradient: const [
                          Color(0x3300C46A),
                          Color(0x1A00C46A),
                        ],
                        title: 'Scan QR Code',
                        subtitle: 'Quick access with your camera',
                        actionLabel: 'Scan',
                        onTap: () {
                          // TODO: Implement Scan QR Code action
                        },
                      ),
                      const SizedBox(height: 16),
                      OptionCard(
                        gradientColors: const [
                          Color(0xFF0035D4),
                          Color(0xFF0066FF),
                        ],
                        backgroundColor: Colors.transparent,
                        icon: Icons.person_add_alt_1_outlined,
                        iconGradient: const [
                          Color(0x330066FF),
                          Color(0x1A0066FF),
                        ],
                        title: 'Have an invite code?',
                        subtitle: 'Enter code manually to join',
                        actionLabel: 'Enter Code',
                        onTap: () {
                          if (!mounted) return;
                          // Use GoRouter safely with mounted check
                          final router = GoRouter.maybeOf(context);
                          router?.go('/enter-code');
                        },
                        outlined: true,
                      ),
                      const SizedBox(height: 16),
                      OptionCard(
                        gradientColors: const [
                          Color(0xFF006B54),
                          Color(0xFF00C46A),
                        ],
                        backgroundColor: const Color(0xFF0F0F0F),
                        leading: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF00C46A),
                          ),
                        ),
                        title: 'Live Challenge Active!',
                        subtitle: '"Quick BST Quiz" - 23 participants online',
                        actionLabel: 'Join Now',
                        onTap: () {
                          // TODO: Implement Join Now action
                        },
                      ),
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
                    //rgb(20, 20, 20)
                    color: const Color.fromARGB(255, 20, 20, 20),
                    borderRadius: BorderRadius.circular(24),
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

                            //rgb(0, 153, 102)
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Create Challenge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          letterSpacing: 0.2,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a new challenge and challenge your friends',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 18),
                      InkWell(
                        onTap: () {
                          // TODO: Implement Create Challenge action
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
                              // Navigate to chapter selection screen first
                              Navigator.of(context, rootNavigator: false).push(
                                MaterialPageRoute(
                                  builder: (_) => MultiBlocProvider(
                                    providers: [
                                      BlocProvider.value(
                                        value: context.read<FolderCubit>(),
                                      ),
                                      BlocProvider.value(
                                        value: context.read<ChapterCubit>(),
                                      ),
                                      BlocProvider.value(
                                        value: context.read<AuthCubit>(),
                                      ),
                                      BlocProvider.value(
                                        value: context.read<ChallengeCubit>(),
                                      ),
                                    ],
                                    child: const SelectChapterScreen(),
                                  ),
                                ),
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
                                  const Text(
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
