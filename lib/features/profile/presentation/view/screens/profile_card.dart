import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/profile/data/models/profile_model.dart';
import 'package:tionova/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:tionova/features/profile/presentation/view/screens/edit_profile_screen.dart';

class ProfileCard extends StatelessWidget {
  final Profile profile;
  const ProfileCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color:
          theme.cardTheme.color ?? (isDark ? Colors.grey[900] : Colors.white),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.08),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: profile.profilePicture != null
                    ? Image.network(
                        profile.profilePicture!,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, size: 40),
                      )
                    : const Icon(Icons.person, size: 40),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              profile.username,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              profile.universityCollege ?? 'Student',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => getIt<ProfileCubit>(),
                        child: EditProfileScreen(profile: profile),
                      ),
                    ),
                  );
                  if (result == true) {
                    try {
                      await context.read<ProfileCubit>().refresh();
                    } catch (_) {}
                  }
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.colorScheme.onSurface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Stats grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatCard(
                        icon: Icons.local_fire_department,
                        label: 'Study Streak',
                        value: profile.streak.toString(),
                        sub: 'DAYS',
                      ),
                      const SizedBox(width: 14),
                      _StatCard(
                        icon: Icons.menu_book,
                        label: 'Chapters',
                        value: profile.totalChapters.toString(),
                        sub: 'TOTAL',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatCard(
                        icon: Icons.quiz,
                        label: 'Quizzes',
                        value: profile.totalQuizzesTaken.toString(),
                        sub: 'DONE',
                      ),
                      const SizedBox(width: 14),
                      _StatCard(
                        icon: Icons.percent,
                        label: 'Score',
                        value: profile.averageQuizScore.toStringAsFixed(0),
                        sub: 'AVG',
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
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.4),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.iconTheme.color, size: 26),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
