import 'package:flutter/material.dart';

class NoGlowScrollBehavior extends ScrollBehavior {
  const NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // Remove overscroll glow/bounce visuals
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Use clamping physics (no bounce at top/bottom)
    return const ClampingScrollPhysics();
  }
}
