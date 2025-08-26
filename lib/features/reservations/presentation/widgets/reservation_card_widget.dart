import 'package:flutter/material.dart';
import 'package:frontend/features/common/presentation/widgets/card_info_widget.dart';
import 'package:frontend/features/common/presentation/widgets/status_chip_widget.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ReservationCardWidget extends StatelessWidget {
  const ReservationCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card.filled(
      margin: EdgeInsetsGeometry.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16.0,
          children: [
            Row(
              spacing: 8.0,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4.0,
                    children: [
                      Text('Complex name', style: textTheme.titleLarge),
                      Text(
                        'Complex address',
                        style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                StatusChipWidget(icon: Symbols.check_circle_rounded, label: 'Completed'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 8.0,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8.0,
                    children: [
                      const CardInfoWidget(icon: Symbols.location_on_rounded, label: 'Court', text: 'Court name'),
                      const CardInfoWidget(icon: Symbols.sports_rounded, label: 'Sport', text: 'Sport name'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8.0,
                    children: [
                      const CardInfoWidget(icon: Symbols.calendar_month_rounded, label: 'Date', text: '00/00/0000'),
                      const CardInfoWidget(icon: Symbols.schedule_rounded, label: 'Time', text: '00:00 - 00:00'),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 4.0,
              children: [
                OutlinedButton(onPressed: () {}, child: const Text('Modify')),
                FilledButton(onPressed: () {}, child: const Text('More info')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
