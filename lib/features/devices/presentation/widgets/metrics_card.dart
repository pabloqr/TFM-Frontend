import 'package:flutter/material.dart';
import 'package:frontend/features/common/presentation/widgets/small_chip.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class MetricsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;

  const MetricsCard({super.key, required this.icon, required this.title, required this.subtitle, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // TODO: Colors based on data
    return Card.filled(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8.0,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 16.0,
                children: [
                  Icon(icon, size: 32, fill: 0, weight: 400, grade: 0, opticalSize: 32),
                  Expanded(child: Text(value, style: textTheme.displaySmall)),
                  SmallChip.success(icon: Symbols.trending_up_rounded),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.titleMedium),
                  Text(subtitle, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
