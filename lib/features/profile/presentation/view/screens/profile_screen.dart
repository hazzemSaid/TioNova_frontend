import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/profile/data/models/profile_model.dart';
import 'package:tionova/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:tionova/features/profile/presentation/cubit/profile_state.dart';
import 'package:tionova/features/profile/presentation/view/screens/profile_card.dart';
import 'package:tionova/features/profile/presentation/view/widgets/achievements_section.dart';
import 'package:tionova/features/profile/presentation/view/widgets/activity_tab.dart';
import 'package:tionova/features/profile/presentation/view/widgets/overview_tab.dart';
import 'package:tionova/features/profile/presentation/view/widgets/settings_section.dart';
import 'package:tionova/features/theme/presentation/bloc/theme_cubit.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';
import 'package:tionova/utils/widgets/page_header.dart';
import 'package:tionova/utils/widgets/sliver_app_bar_delegate.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileScreenContent();
  }
}

class _ProfileScreenContent extends StatefulWidget {
  const _ProfileScreenContent();

  @override
  State<_ProfileScreenContent> createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends State<_ProfileScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _processingImage = false;
  bool _uploadingImage = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Fetch profile data when screen loads
    Future.microtask(() {
      context.read<ProfileCubit>().fetchProfile();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshProfile() async {
    if (!mounted) return;
    await context.read<ProfileCubit>().fetchProfile();
  }

  Future<Uint8List> _cropCenterSquareAndResize(
    Uint8List bytes, {
    int targetSize = 512,
  }) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final w = image.width.toDouble();
    final h = image.height.toDouble();
    final size = w < h ? w : h;
    final left = (w - size) / 2;
    final top = (h - size) / 2;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final src = Rect.fromLTWH(left, top, size, size);
    final dst = Rect.fromLTWH(
      0,
      0,
      targetSize.toDouble(),
      targetSize.toDouble(),
    );
    canvas.drawImageRect(image, src, dst, Paint());
    final picture = recorder.endRecording();
    final cropped = await picture.toImage(targetSize, targetSize);
    final byteData = await cropped.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _pickAndUploadImageWeb(Profile profile) async {
    if (!kIsWeb) return;
    try {
      setState(() {
        _processingImage = true;
      });
      final picker = ImagePicker();
      final xfile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (xfile == null) {
        setState(() {
          _processingImage = false;
        });
        return;
      }
      final originalBytes = await xfile.readAsBytes();
      final croppedBytes = await _cropCenterSquareAndResize(
        originalBytes,
        targetSize: 512,
      );
      setState(() {
        _processingImage = false;
        _uploadingImage = true;
      });
      final data = {
        'username': profile.username,
        'universityCollege': profile.universityCollege ?? '',
        'profilePictureBytes': croppedBytes,
        'profilePictureName': xfile.name,
      };
      await context.read<ProfileCubit>().updateProfile(data);
      await _refreshProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile image updated'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploadingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isWeb = screenWidth > 800;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return RefreshIndicator(
              onRefresh: _refreshProfile,
              color: theme.colorScheme.primary,
              child: const CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            );
          } else if (state is ProfileError) {
            return RefreshIndicator(
              onRefresh: _refreshProfile,
              color: theme.colorScheme.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading profile',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<ProfileCubit>().retry();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is ProfileLoaded) {
            final profile = state.profile;
            return RefreshIndicator(
              onRefresh: _refreshProfile,
              color: theme.colorScheme.primary,
              child: isWeb
                  ? _buildWebLayout(context, profile)
                  : _buildMobileLayout(context, profile, screenHeight),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Web Layout
  Widget _buildWebLayout(BuildContext context, Profile profile) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxContentWidth = 1200.0;
    final horizontalPadding = screenWidth > maxContentWidth
        ? (screenWidth - maxContentWidth) / 2
        : 48.0;

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return ScrollConfiguration(
          behavior: const NoGlowScrollBehavior(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header Section
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    40,
                    horizontalPadding,
                    32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: colorScheme.onBackground,
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your personal study stats',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Profile Card and Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column - Profile Card (Sticky)
                      SizedBox(
                        width: 350,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ProfileCard(profile: profile),
                            const SizedBox(height: 12),
                            if (kIsWeb)
                              ElevatedButton.icon(
                                onPressed: _processingImage || _uploadingImage
                                    ? null
                                    : () => _pickAndUploadImageWeb(profile),
                                icon: const Icon(Icons.camera_alt, size: 18),
                                label: const Text('Change Photo'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  elevation: 0,
                                ),
                              ),
                            if (_processingImage || _uploadingImage)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _processingImage
                                          ? 'Processing image...'
                                          : 'Uploading...',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Right Column - Tabs and Content
                      Expanded(child: _buildWebTabs(context, profile)),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(child: const SizedBox(height: 48)),
            ],
          ),
        );
      },
    );
  }

  // Web Tabs
  Widget _buildWebTabs(BuildContext context, Profile profile) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            child: TabBar(
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Activity'),
                Tab(text: 'Achievements'),
                Tab(text: 'Settings'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 800,
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                SingleChildScrollView(
                  child: OverviewTab(
                    screenHeight: MediaQuery.of(context).size.height,
                    profile: profile,
                  ),
                ),
                SingleChildScrollView(
                  child: ActivityTab(
                    screenHeight: MediaQuery.of(context).size.height,
                    profile: profile,
                  ),
                ),
                SingleChildScrollView(
                  child: AchievementsSection(achievements: _getAchievements()),
                ),
                SingleChildScrollView(
                  child: SettingsSection(
                    notificationsEnabled: true,
                    darkModeEnabled:
                        context.read<ThemeCubit>().state == ThemeMode.dark,
                    changeTheme: () {
                      final themeCubit = context.read<ThemeCubit>();
                      if (themeCubit.state == ThemeMode.light) {
                        themeCubit.setTheme(ThemeMode.dark);
                      } else {
                        themeCubit.setTheme(ThemeMode.light);
                      }
                    },
                    onNotificationsToggle: () {},
                    onDarkModeToggle: () {},
                    onExportData: () {},
                    onShareProgress: () {},
                    onHelpSupport: () {},
                    onSignOut: () {
                      context.read<AuthCubit>().signOut();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Mobile Layout
  Widget _buildMobileLayout(
    BuildContext context,
    Profile profile,
    double screenHeight,
  ) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final currentTheme = Theme.of(context);
        return ScrollConfiguration(
          behavior: const NoGlowScrollBehavior(),
          child: NestedScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
                    child: Column(
                      children: [
                        const PageHeader(
                          title: 'Profile',
                          subtitle: 'Your personal study stats',
                        ),
                        ProfileCard(profile: profile),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  delegate: SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: currentTheme.colorScheme.primary,
                      unselectedLabelColor: currentTheme.hintColor,
                      indicatorColor: currentTheme.colorScheme.primary,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      dividerColor: Colors.transparent,
                      tabAlignment: TabAlignment.start,
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Activity'),
                        Tab(text: 'Achievements'),
                        Tab(text: 'Settings'),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildTabContent(0, screenHeight, profile),
                _buildTabContent(1, screenHeight, profile),
                _buildTabContent(2, screenHeight, profile),
                _buildTabContent(3, screenHeight, profile),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Achievement> _getAchievements() {
    return [
      Achievement(
        title: 'First Quiz',
        description: 'Completed your first quiz',
        isEarned: true,
        emoji: '🔥',
      ),
      Achievement(
        title: '7 Day Streak',
        description: '7 days in a row',
        isEarned: true,
        emoji: '🔥',
      ),
      Achievement(
        title: 'High Scorer',
        description: 'Scored 90%+ on 5 quizzes',
        isEarned: true,
        emoji: '⚡',
      ),
      Achievement(
        title: 'Speed Reader',
        description: 'Complete 10 chapters in a week',
        isEarned: false,
        emoji: '⚡',
      ),
      Achievement(
        title: 'Challenge Master',
        description: 'Win 3 challenges',
        isEarned: false,
        emoji: '🏆',
      ),
      Achievement(
        title: 'Study Buddy',
        description: 'Help 5 other students',
        isEarned: false,
        emoji: '🥇',
      ),
    ];
  }

  Widget _buildTabContent(int index, double screenHeight, Profile profile) {
    switch (index) {
      case 0:
        return OverviewTab(screenHeight: screenHeight, profile: profile);
      case 1:
        return ActivityTab(screenHeight: screenHeight, profile: profile);
      case 2:
        return SingleChildScrollView(
          child: AchievementsSection(achievements: _getAchievements()),
        );
      case 3:
        return SingleChildScrollView(
          child: SettingsSection(
            notificationsEnabled: true,
            darkModeEnabled: context.read<ThemeCubit>().state == ThemeMode.dark,
            changeTheme: () {
              final themeCubit = context.read<ThemeCubit>();
              if (themeCubit.state == ThemeMode.light) {
                themeCubit.setTheme(ThemeMode.dark);
              } else {
                themeCubit.setTheme(ThemeMode.light);
              }
            },
            onNotificationsToggle: () {},
            onDarkModeToggle: () {},
            onExportData: () {},
            onShareProgress: () {},
            onHelpSupport: () {},
            onSignOut: () {
              context.read<AuthCubit>().signOut();
            },
          ),
        );
      default:
        return const Center(child: Text("Content Not Found"));
    }
  }
}
