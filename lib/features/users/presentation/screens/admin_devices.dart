import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/features/devices/presentation/widgets/device_list_tile.dart';

class AdminDevices extends StatelessWidget {
  final bool isTelemetryView;

  const AdminDevices._(this.isTelemetryView);

  factory AdminDevices.telemetry() => const AdminDevices._(true);

  factory AdminDevices.list() => const AdminDevices._(false);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: 10,
      itemBuilder: (context, index) {
        return isTelemetryView
            ? DeviceListTile.telemetry(name: 'Court $index', onTap: () {})
            : DeviceListTile.list(
                name: 'Court $index',
                onTap: () => Navigator.of(context).pushNamed(AppConstants.courtInfoRoute),
              );
      },
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
    );
  }
}
