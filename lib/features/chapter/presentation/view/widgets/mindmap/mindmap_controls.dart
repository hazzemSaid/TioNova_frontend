import 'package:flutter/material.dart';

class MindmapControls extends StatelessWidget {
  final double zoomLevel;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFitToScreen;

  const MindmapControls({
    Key? key,
    required this.zoomLevel,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFitToScreen, // Centers on root node
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D3250)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom percentage
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E27),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(zoomLevel * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Zoom in button
          _ControlButton(icon: Icons.add, onPressed: onZoomIn),
          const SizedBox(height: 4),

          // Zoom out button
          _ControlButton(icon: Icons.remove, onPressed: onZoomOut),
          const SizedBox(height: 8),

          // Center on root button
          Tooltip(
            message: 'Center on Root',
            child: _ControlButton(
              icon: Icons.center_focus_strong,
              onPressed: onFitToScreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ControlButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E27),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2D3250)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
