import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/features/courts/presentation/widgets/court_list_tile.dart';

class AdminCourts extends StatelessWidget {
  final bool isTelemetryView;

  const AdminCourts._(this.isTelemetryView);

  factory AdminCourts.telemetry() => const AdminCourts._(true);

  factory AdminCourts.list() => const AdminCourts._(false);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: 10,
      itemBuilder: (context, index) {
        return isTelemetryView
            ? CourtListTile.telemetry(name: 'Court $index', onTap: () {}, isAdmin: true)
            : CourtListTile.list(
                name: 'Court $index',
                onTap: () => Navigator.of(context).pushNamed(AppConstants.courtInfoRoute),
                isAdmin: true,
              );
      },
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
    );
  }
}
