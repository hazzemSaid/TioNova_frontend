import 'package:flutter/material.dart';

class PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color buttonColor;
  final Color textColor;
  final IconData? icon;
  final bool isLoading;

  const PrimaryBtn({
    super.key,
    required this.label,
    required this.onPressed,
    this.buttonColor = Colors.black,
    this.textColor = Colors.white,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    // Responsive button height
    final buttonHeight = isTablet ? 56.0 : 52.0;
    final fontSize = isTablet ? 17.0 : 16.0;
    final loadingSize = isTablet ? 22.0 : 20.0;

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isLoading ? 0.8 : 1.0,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: textColor,
            disabledBackgroundColor: buttonColor.withOpacity(0.7),
            disabledForegroundColor: textColor.withOpacity(0.7),
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? 18 : 16,
              horizontal: isTablet ? 28 : 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: isLoading ? 0 : 2,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isLoading
                ? SizedBox(
                    key: const ValueKey('loading'),
                    width: loadingSize,
                    height: loadingSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Row(
                    key: const ValueKey('content'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: textColor, size: fontSize + 4),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
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
