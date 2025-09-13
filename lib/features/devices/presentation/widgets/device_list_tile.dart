import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/data/services/utilities.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/small_chip.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/devices/data/models/device_model.dart';
import 'package:frontend/features/devices/data/models/device_status_enum.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class DeviceListTile extends StatelessWidget {
  final bool isTelemetryView;

  final DeviceModel device;
  final VoidCallback onTap;

  const DeviceListTile._(this.isTelemetryView, {required this.device, required this.onTap});

  factory DeviceListTile.telemetry({required DeviceModel device, required VoidCallback onTap}) =>
      DeviceListTile._(true, device: device, onTap: onTap);

  factory DeviceListTile.list({required DeviceModel device, required VoidCallback onTap}) =>
      DeviceListTile._(false, device: device, onTap: onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      title: Row(
        spacing: 8.0,
        children: [
          Text(
            'Device ${device.id}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.end,
            children: [
              SmallChip.neutralSurface(label: device.type.name.toCapitalized()),
              _buildStatusChip(),
            ],
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: InfoSectionWidget(
          leftChildren: [
            LabeledInfoWidget(
              icon: Symbols.timeline_rounded,
              label: 'Last telemetry',
              text: '${4 + Random().nextInt(8)}.${Random().nextInt(100)}',
            ),
            if (isTelemetryView)
              LabeledInfoWidget(icon: Symbols.location_on_rounded, label: 'Court', text: 'CourtName'),
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
    switch (device.status) {
      case DeviceStatus.normal:
        return SmallChip.success(label: 'Normal');
      case DeviceStatus.off:
        return SmallChip.neutralSurface(label: 'Off');
      case DeviceStatus.battery:
        return SmallChip.alert(label: 'Low Battery');
      case DeviceStatus.error:
        return SmallChip.error(label: 'Error');
    }
  }
}
