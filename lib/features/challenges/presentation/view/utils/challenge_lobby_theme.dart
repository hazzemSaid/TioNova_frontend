import 'package:flutter/material.dart';

class ChallengeLobbyTheme {
  static const Color bg = Color(0xFF000000);
  static const Color cardBg = Color(0xFF1C1C1E);
  static const Color panelBg = Color(0xFF0E0E10);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color brandGreen = Color.fromRGBO(0, 153, 102, 1);

  static double getResponsiveValue(
    BuildContext context, {
    required double mobile,
    required double tablet,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 600 ? tablet : mobile;
  }
}
