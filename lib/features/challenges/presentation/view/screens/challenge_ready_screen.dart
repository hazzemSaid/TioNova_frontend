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

  Color get _bg => const Color(0xFF000000);
  Color get _cardBg => const Color(0xFF121314);
  Color get _chipBg => const Color(0xFF0F1A13);
  Color get _textPrimary => const Color(0xFFFFFFFF);
  Color get _textSecondary => const Color(0xFF8E8E93);
  Color get _divider => const Color(0xFF2C2C2E);
  Color get _green => const Color(0xFF30D158);

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
    return Scaffold(
      backgroundColor: _bg,
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
                    color: _chipBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: _divider),
                  ),
                  child: Icon(Icons.bolt, color: _green, size: 40),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _divider),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Get Ready!',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.challengeName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _textSecondary,
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
                          color: _chipBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _divider),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: _divider),
                              ),
                              child: Icon(
                                Icons.group_outlined,
                                size: 14,
                                color: _textSecondary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${widget.playersCount} players',
                              style: TextStyle(
                                color: _textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'joined and ready',
                              style: TextStyle(
                                color: _textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _RingLoader(color: _green),
                      const SizedBox(height: 16),
                      Text(
                        _seconds > 0
                            ? 'Starting in $_seconds seconds...'
                            : 'Starting...',
                        style: TextStyle(color: _textSecondary, fontSize: 13),
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
  const _RingLoader({required this.color});

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
            painter: _RingPainter(progress: _c.value, color: widget.color),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF1C1C1E);
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
      oldDelegate.progress != progress || oldDelegate.color != color;
}
