import 'dart:async';

import 'package:flutter/material.dart';

class ChallengeReadyScreen extends StatefulWidget {
  final String challengeName;
  final int playersCount;
  final int initialSeconds;

  const ChallengeReadyScreen({
    super.key,
    required this.challengeName,
    required this.playersCount,
    this.initialSeconds = 3,
  });

  @override
  State<ChallengeReadyScreen> createState() => _ChallengeReadyScreenState();
}

class _ChallengeReadyScreenState extends State<ChallengeReadyScreen> {
  late int _seconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _seconds = widget.initialSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _seconds -= 1;
        if (_seconds <= 0) {
          _seconds = 0;
          t.cancel();
          // TODO: Navigate to challenge game screen when ready
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = width > 900;
    final maxContentWidth = 420.0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bg = colorScheme.background;
    final cardBg = colorScheme.surface;
    final chipBg = colorScheme.surfaceVariant;
    final textPrimary = colorScheme.onSurface;
    final textSecondary = colorScheme.onSurfaceVariant;
    final divider = colorScheme.outlineVariant.withOpacity(0.6);
    final accent = colorScheme.primary;
    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWeb ? (width - maxContentWidth) / 2 : 20,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWeb ? maxContentWidth : double.infinity,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: chipBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: divider),
                  ),
                  child: Icon(Icons.bolt, color: accent, size: 40),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: divider),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Get Ready!',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.challengeName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: chipBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: divider),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withOpacity(0.6),
                                shape: BoxShape.circle,
                                border: Border.all(color: divider),
                              ),
                              child: Icon(
                                Icons.group_outlined,
                                size: 14,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${widget.playersCount} players',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'joined and ready',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _RingLoader(color: accent, backgroundColor: divider),
                      const SizedBox(height: 16),
                      Text(
                        _seconds > 0
                            ? 'Starting in $_seconds seconds...'
                            : 'Starting...',
                        style: TextStyle(color: textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingLoader extends StatefulWidget {
  final Color color;
  final Color backgroundColor;
  const _RingLoader({required this.color, required this.backgroundColor});

  @override
  State<_RingLoader> createState() => _RingLoaderState();
}

class _RingLoaderState extends State<_RingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          return CustomPaint(
            painter: _RingPainter(
              progress: _c.value,
              color: widget.color,
              backgroundColor: widget.backgroundColor,
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = backgroundColor;
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawCircle(center, radius, bg);
    final sweep = 2 * 3.1415926535 * progress * 0.85; // arc length
    final start = -3.1415926535 / 2; // top
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.backgroundColor != backgroundColor;
}
