import 'package:flutter/material.dart';

class CardInfoWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;

  const CardInfoWidget({super.key, required this.icon, required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      spacing: 8.0,
      children: [
        Icon(icon, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
            Text(text, style: textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}
