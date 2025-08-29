import 'package:flutter/material.dart';
import 'package:frontend/core/constants/theme.dart';

class NewsStatusChipWidget extends StatelessWidget {
  const NewsStatusChipWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: MaterialTheme.warning.light.colorContainer,
        borderRadius: BorderRadius.circular(1000.0),
      ),
      child: Text('NEW', style: textTheme.labelSmall?.copyWith(color: MaterialTheme.warning.light.onColorContainer)),
    );
  }
}
