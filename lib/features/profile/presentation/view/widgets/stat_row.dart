import 'package:flutter/material.dart';

class StatRow extends StatelessWidget {
  final String label1;
  final String value1;
  final String label2;
  final String value2;
  final String trailing;
  final String trailingLabel;

  const StatRow({
    super.key,
    required this.label1,
    required this.value1,
    required this.label2,
    required this.value2,
    required this.trailing,
    required this.trailingLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value1,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label1, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value2,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label2, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                trailing,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(trailingLabel, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
