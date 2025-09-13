import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/features/courts/data/models/court_model.dart';
import 'package:frontend/features/courts/data/models/sport_enum.dart';
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
            ? CourtListTile.telemetry(
                court: CourtModel(
                  id: 0,
                  complexId: 0,
                  sport: Sport.tennis,
                  name: 'Court $index',
                  description: 'Lorem ipsum',
                  maxPeople: 0,
                  status: CourtStatus.open,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
                onTap: () {},
                isAdmin: true,
              )
            : CourtListTile.list(
                court: CourtModel(
                  id: 0,
                  complexId: 0,
                  sport: Sport.tennis,
                  name: 'Court $index',
                  description: 'Lorem ipsum',
                  maxPeople: 0,
                  status: CourtStatus.open,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
                onTap: () => Navigator.of(context).pushNamed(AppConstants.courtInfoRoute),
                isAdmin: true,
              );
      },
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
    );
  }
}
