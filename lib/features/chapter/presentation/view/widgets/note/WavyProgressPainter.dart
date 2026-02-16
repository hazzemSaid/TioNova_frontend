import 'dart:math';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class WavyProgressPainter extends CustomPainter {
  final double progress;
  final double waveOffset;
  final Color color;

  WavyProgressPainter({
    required this.progress,
    required this.waveOffset,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final waveHeight = 12.0;
    final waveLength = size.width / 1.5;
    // Calculate the height of the filled area from bottom
    final progressHeight = size.height * progress.clamp(0.0, 1.0);

    if (progressHeight <= 0) return;

    // Create gradient paint for the liquid effect
    final gradientPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withOpacity(0.6), color.withOpacity(0.9), color],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(
            Rect.fromLTWH(
              0,
              size.height - progressHeight,
              size.width,
              progressHeight,
            ),
          );

    final path = Path();

    // Start from bottom left
    path.moveTo(0, size.height);

    // Create wavy pattern along the top edge of the progress
    for (double x = 0; x <= size.width; x += 1) {
      final normalizedX = x / waveLength;
      // Create smooth wave using sine function
      final waveY =
          waveHeight * math.sin(normalizedX * 2 * math.pi + waveOffset);
      final y = size.height - progressHeight + waveY;
      path.lineTo(x, y);
    }

    // Close the path to bottom right, then back to bottom left
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, gradientPaint);

    // Add a subtle highlight on top of the wave for depth
    final highlightPath = Path();
    highlightPath.moveTo(0, size.height - progressHeight);
    for (double x = 0; x <= size.width; x += 1) {
      final normalizedX = x / waveLength;
      final waveY =
          waveHeight * math.sin(normalizedX * 2 * math.pi + waveOffset);
      final y = size.height - progressHeight + waveY;
      highlightPath.lineTo(x, y);
    }

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(WavyProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.waveOffset != waveOffset ||
        oldDelegate.color != color;
  }
}
