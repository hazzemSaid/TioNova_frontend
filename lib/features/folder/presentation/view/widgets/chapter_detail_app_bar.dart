import 'package:flutter/material.dart';
import 'package:tionova/core/utils/safe_navigation.dart';

class ChapterDetailAppBar extends StatelessWidget {
  final String? title;
  const ChapterDetailAppBar({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverAppBar(
      backgroundColor: colorScheme.surface,
      pinned: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
        onPressed: () => context.safePop(fallback: '/'),
      ),
      title: Text(
        title ?? 'Chapter Preview',
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.share_outlined, color: colorScheme.onSurface),
          onPressed: () {},
        ),
      ],
    );
  }
}
