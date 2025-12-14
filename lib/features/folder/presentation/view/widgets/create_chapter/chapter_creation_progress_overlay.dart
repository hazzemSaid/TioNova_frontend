import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tionova/features/folder/presentation/view/widgets/WavyProgressPainter.dart';

/// A widget that displays the chapter creation progress overlay with wavy animation.
class ChapterCreationProgressOverlay extends StatelessWidget {
  final int progressValue;
  final String statusMessage;
  final Animation<double> waveAnimation;
  final ColorScheme colorScheme;

  const ChapterCreationProgressOverlay({
    super.key,
    required this.progressValue,
    required this.statusMessage,
    required this.waveAnimation,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;

    return Container(
      color: colorScheme.scrim.withOpacity(0.55),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop
                ? 500
                : isTablet
                ? 440
                : 360,
          ),
          margin: EdgeInsets.symmetric(
            horizontal: isDesktop
                ? 0
                : isTablet
                ? 0
                : 24,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop
                ? 32
                : isTablet
                ? 28
                : 24,
            vertical: isDesktop
                ? 36
                : isTablet
                ? 32
                : 28,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(
              isDesktop
                  ? 36
                  : isTablet
                  ? 32
                  : 28,
            ),
            border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: isDesktop ? 40 : 30,
                offset: Offset(0, isDesktop ? 24 : 20),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitle(isDesktop, isTablet),
                SizedBox(
                  height: isDesktop
                      ? 8
                      : isTablet
                      ? 6
                      : 6,
                ),
                _buildSubtitle(isDesktop, isTablet),
                SizedBox(
                  height: isDesktop
                      ? 28
                      : isTablet
                      ? 24
                      : 20,
                ),
                _buildProgressContainer(isDesktop, isTablet),
                SizedBox(
                  height: isDesktop
                      ? 28
                      : isTablet
                      ? 24
                      : 20,
                ),
                _buildStatusMessage(isDesktop, isTablet),
                SizedBox(height: isDesktop ? 20 : 18),
                _buildTipContainer(isDesktop, isTablet),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(bool isDesktop, bool isTablet) {
    return Text(
      'Creating Your Chapter',
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: isDesktop
            ? 26
            : isTablet
            ? 24
            : 20,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle(bool isDesktop, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 16
            : isTablet
            ? 8
            : 4,
      ),
      child: Text(
        "We're processing your materials and generating AI-powered content",
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: isDesktop
              ? 17
              : isTablet
              ? 16
              : 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildProgressContainer(bool isDesktop, bool isTablet) {
    return Container(
      width: isDesktop
          ? 240
          : isTablet
          ? 220
          : 200,
      height: isDesktop
          ? 280
          : isTablet
          ? 260
          : 230,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(isDesktop ? 32 : 28),
        border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: isDesktop ? 20 : 18,
            offset: Offset(0, isDesktop ? 16 : 14),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Percentage and Processing text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$progressValue%',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: isDesktop
                      ? 40
                      : isTablet
                      ? 36
                      : 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isDesktop ? 8 : 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: isDesktop ? 18 : 16,
                    height: isDesktop ? 18 : 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(width: isDesktop ? 8 : 6),
                  Text(
                    'Processing',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: isDesktop
                          ? 15
                          : isTablet
                          ? 14
                          : 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Animated wavy progress bar at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(isDesktop ? 32 : 28),
                bottomRight: Radius.circular(isDesktop ? 32 : 28),
              ),
              child: AnimatedBuilder(
                animation: waveAnimation,
                builder: (context, child) {
                  return SizedBox(
                    width: isDesktop
                        ? 220
                        : isTablet
                        ? 200
                        : 180,
                    height: isDesktop
                        ? 260
                        : isTablet
                        ? 240
                        : 210,
                    child: CustomPaint(
                      painter: WavyProgressPainter(
                        progress: progressValue / 100.0,
                        waveOffset: waveAnimation.value * 2 * math.pi,
                        color: colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage(bool isDesktop, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 16
            : isTablet
            ? 8
            : 0,
      ),
      child: Text(
        statusMessage,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: isDesktop
              ? 17
              : isTablet
              ? 16
              : 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTipContainer(bool isDesktop, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 20
            : isTablet
            ? 16
            : 14,
        vertical: isDesktop ? 14 : 12,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(isDesktop ? 18 : 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.tips_and_updates,
            color: colorScheme.primary,
            size: isDesktop ? 20 : 18,
          ),
          SizedBox(width: isDesktop ? 10 : 8),
          Flexible(
            child: Text(
              'Tip: You can add multiple PDFs and videos to each chapter',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: isDesktop
                    ? 14
                    : isTablet
                    ? 13
                    : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
