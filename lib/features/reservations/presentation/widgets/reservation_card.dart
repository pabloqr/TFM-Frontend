import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/common/presentation/widgets/medium_chip.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ReservationCard extends StatelessWidget {
  const ReservationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card.filled(
      margin: const EdgeInsets.all(4.0),
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
                MediumChip.alert(label: 'Scheduled'),
                // SmallChip.alert('Scheduled'),
                // ReservationStatusChip(icon: Symbols.check_circle_rounded, label: 'Completed'),
              ],
            ),
            const InfoSectionWidget(
              leftChildren: [
                LabeledInfoWidget(icon: Symbols.location_on_rounded, label: 'Court', text: 'Court name'),
                LabeledInfoWidget(icon: Symbols.sports_rounded, label: 'Sport', text: 'Sport name'),
              ],
              rightChildren: [
                LabeledInfoWidget(icon: Symbols.calendar_month_rounded, label: 'Date', text: '00/00/0000'),
                LabeledInfoWidget(icon: Symbols.schedule_rounded, label: 'Time', text: '00:00 - 00:00'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 4.0,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pushNamed(AppConstants.reservationInfoRoute),
                  child: const Text('More info'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(AppConstants.reservationModifyRoute, arguments: {'isAdmin': false}),
                  child: const Text('Modify'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
