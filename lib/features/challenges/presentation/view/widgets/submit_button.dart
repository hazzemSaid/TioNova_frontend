import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final bool canSubmit;
  final bool hasAnswered;
  final VoidCallback? onSubmit;

  final Color cardBg;
  final Color textSecondary;
  final Color accentGreen;

  const SubmitButton({
    super.key,
    required this.canSubmit,
    required this.hasAnswered,
    required this.onSubmit,
    required this.cardBg,
    required this.textSecondary,
    required this.accentGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canSubmit ? onSubmit : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: canSubmit ? accentGreen : cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.send,
                color: canSubmit ? Colors.white : textSecondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                hasAnswered ? 'Submitted' : 'Submit Answer',
                style: TextStyle(
                  color: canSubmit ? Colors.white : textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
