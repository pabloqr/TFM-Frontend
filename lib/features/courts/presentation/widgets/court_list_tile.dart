import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/data/services/utilities.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/common/presentation/widgets/small_chip.dart';
import 'package:frontend/features/courts/data/models/court_model.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class CourtListTile extends StatelessWidget {
  final bool isTelemetryView;

  final CourtModel court;
  final VoidCallback onTap;

  final bool isAdmin;

  const CourtListTile._(this.isTelemetryView, {required this.court, required this.onTap, required this.isAdmin});

  factory CourtListTile.telemetry({required CourtModel court, required VoidCallback onTap, required bool isAdmin}) =>
      CourtListTile._(true, court: court, onTap: onTap, isAdmin: isAdmin);

  factory CourtListTile.list({required CourtModel court, required VoidCallback onTap, required bool isAdmin}) =>
      CourtListTile._(false, court: court, onTap: onTap, isAdmin: isAdmin);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      title: Row(
        spacing: 8.0,
        children: [
          Text(
            court.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.end,
            children: [
              if (isAdmin)
                SmallChip.neutralSurface(label: court.sport.name.toCapitalized())
              else
                SmallChip.alert(label: court.sport.name.toCapitalized()),
              if (isAdmin) _buildStatusChip() else if (Random().nextBool()) SmallChip.success(label: 'Available'),
            ],
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: InfoSectionWidget(
          leftChildren: isTelemetryView
              ? [
                  LabeledInfoWidget(icon: Symbols.timeline_rounded, label: 'Value', text: '00'),
                  LabeledInfoWidget(icon: Symbols.apartment_rounded, label: 'Complex', text: 'ComplexName'),
                ]
              : [
                  LabeledInfoWidget(
                    icon: Symbols.groups_rounded,
                    label: 'Capacity',
                    text: court.maxPeople.toString().padLeft(2, '0'),
                  ),
                ],
          rightChildren: isTelemetryView
              ? [
                  LabeledInfoWidget(icon: Symbols.calendar_month_rounded, label: 'Date', text: '00/00/0000'),
                  LabeledInfoWidget(icon: Symbols.schedule_rounded, label: 'Time', text: '00:00'),
                ]
              : [],
        ),
      ),
      trailing: isTelemetryView ? null : Icon(Symbols.chevron_right_rounded),
      onTap: onTap,
    );
  }

  Widget _buildStatusChip() {
    switch (court.status) {
      case CourtStatus.open:
        return SmallChip.success(label: 'Open');
      case CourtStatus.weather:
        return SmallChip.alert(label: 'Weather');
      case CourtStatus.blocked:
        return SmallChip.error(label: 'Closed');
      case CourtStatus.maintenance:
        return SmallChip.error(label: 'Maintenance');
    }
  }
}
