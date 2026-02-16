import 'package:flutter/material.dart';
import 'package:tionova/features/chapter/data/models/nodeModel.dart';

class MindmapConnectionsPainter extends CustomPainter {
  final List<NodeModel> nodes;
  final Map<String, Offset> nodePositions;

  MindmapConnectionsPainter({required this.nodes, required this.nodePositions});

  @override
  void paint(Canvas canvas, Size size) {
    // Find all parent-child relationships and draw connections
    for (var node in nodes) {
      final parentPosition = nodePositions[node.id];
      if (parentPosition == null) continue;

      final children = node.children ?? [];
      for (var childId in children) {
        final childPosition = nodePositions[childId];
        if (childPosition == null) continue;

        _drawConnection(canvas, parentPosition, childPosition);
      }
    }
  }

  void _drawConnection(Canvas canvas, Offset start, Offset end) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Create a curved path using quadratic bezier
    final path = Path();
    path.moveTo(start.dx, start.dy);

    // Calculate control point for curve
    final midX = (start.dx + end.dx) / 2;
    final midY = (start.dy + end.dy) / 2;
    final controlPoint = Offset(midX, midY);

    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);

    // Draw dashed line
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 8.0;
    const dashSpace = 5.0;

    final pathMetrics = path.computeMetrics();
    for (var pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final nextDistance = distance + dashWidth;
        final extractPath = pathMetric.extractPath(
          distance,
          nextDistance > pathMetric.length ? pathMetric.length : nextDistance,
        );
        canvas.drawPath(extractPath, paint);
        distance = nextDistance + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(MindmapConnectionsPainter oldDelegate) {
    return oldDelegate.nodePositions != nodePositions ||
        oldDelegate.nodes != nodes;
  }
}
