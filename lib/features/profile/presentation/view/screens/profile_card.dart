import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/profile/data/models/profile_model.dart';
import 'package:tionova/features/profile/presentation/cubit/profile_cubit.dart';

class ProfileCard extends StatelessWidget {
  final Profile profile;
  const ProfileCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark ? colorScheme.surfaceContainerHighest : colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.1),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child:
                      profile.profilePicture != null &&
                          profile.profilePicture!.isNotEmpty
                      ? Image.network(
                          profile.profilePicture!,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultAvatar(colorScheme),
                        )
                      : _buildDefaultAvatar(colorScheme),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              profile.username,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                profile.universityCollege ?? 'Student',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 220,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final profileCubit = context.read<ProfileCubit>();
                  final result = await context.push<bool>(
                    '/profile/edit',
                    extra: {'profile': profile, 'profileCubit': profileCubit},
                  );
                  if (result == true) {
                    try {
                      await profileCubit.refresh();
                    } catch (_) {}
                  }
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Stats section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Streak',
                        value: '${profile.streak}',
                        sub: 'DAYS',
                        iconColor: Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.menu_book_rounded,
                        label: 'Chapters',
                        value: '${profile.totalChapters}',
                        sub: 'TOTAL',
                        iconColor: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.quiz_rounded,
                        label: 'Quizzes',
                        value: '${profile.totalQuizzesTaken}',
                        sub: 'DONE',
                        iconColor: Colors.purple,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.percent_rounded,
                        label: 'Score',
                        value: profile.averageQuizScore.toStringAsFixed(0),
                        sub: 'AVG',
                        iconColor: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.primary.withOpacity(0.1),
      child: Icon(
        Icons.person_outline_rounded,
        size: 40,
        color: colorScheme.primary,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color iconColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
