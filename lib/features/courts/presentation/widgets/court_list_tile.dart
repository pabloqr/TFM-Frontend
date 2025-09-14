import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/data/providers/complex_provider.dart';
import 'package:frontend/data/services/utilities.dart';
import 'package:frontend/features/common/data/models/telemetry_model.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/common/presentation/widgets/small_chip.dart';
import 'package:frontend/features/complexes/data/models/complex_model.dart';
import 'package:frontend/features/courts/data/models/court_model.dart';
import 'package:frontend/features/devices/data/models/device_model.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

class CourtListTile extends StatefulWidget {
  final bool isTelemetryView;

  final TelemetryModel? telemetry;
  final CourtModel court;
  final VoidCallback onTap;

  final bool isAdmin;

  const CourtListTile._(
    this.isTelemetryView, {
    this.telemetry,
    required this.court,
    required this.onTap,
    required this.isAdmin,
  });

  factory CourtListTile.telemetry({
    TelemetryModel? telemetry,
    required CourtModel court,
    required VoidCallback onTap,
    required bool isAdmin,
  }) => CourtListTile._(true, telemetry: telemetry, court: court, onTap: onTap, isAdmin: isAdmin);

  factory CourtListTile.list({required CourtModel court, required VoidCallback onTap, required bool isAdmin}) =>
      CourtListTile._(false, court: court, onTap: onTap, isAdmin: isAdmin);

  @override
  State<CourtListTile> createState() => _CourtListTileState();
}

class _CourtListTileState extends State<CourtListTile> {
  ComplexProvider? _complexProvider;
  VoidCallback? _providerListener;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _complexProvider = context.read<ComplexProvider?>();

      if (widget.isTelemetryView && _complexProvider != null) {
        _complexProvider!.getComplex(widget.court.complexId);

        _providerListener = () {
          if (mounted &&
              _complexProvider != null &&
              _complexProvider!.state == ProviderState.error &&
              _complexProvider!.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_complexProvider!.failure!.message), behavior: SnackBarBehavior.floating),
            );
          }
        };
        _complexProvider!.addListener(_providerListener!);
      }
    });
  }

  @override
  void dispose() {
    if (_complexProvider != null && _providerListener != null) {
      _complexProvider!.removeListener(_providerListener!);
    }
    _providerListener = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      title: Row(
        spacing: 8.0,
        children: [
          Text(
            widget.court.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.end,
            children: [
              SmallChip.neutralSurface(label: widget.court.sport.name.toCapitalized()),
              if (widget.isAdmin && widget.isTelemetryView)
                SmallChip.neutralSurface(label: widget.telemetry!.type!.name.toCapitalized()),
              if (widget.isAdmin)
                _buildStatusChip()
              // TODO: Get real availability
              else if (Random().nextBool())
                SmallChip.success(label: 'Available'),
            ],
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: InfoSectionWidget(
          leftChildren: widget.isTelemetryView
              ? [
                  LabeledInfoWidget(
                    icon: Symbols.timeline_rounded,
                    label: 'Value',
                    text: widget.telemetry == null
                        ? '--'
                        : widget.telemetry!.type != DeviceType.presence
                        ? widget.telemetry!.value.toString()
                        : widget.telemetry!.toAvailabilityStatus().name.toCapitalized(),
                  ),
                  Consumer<ComplexProvider?>(
                    builder: (context, nestedConsumerProvider, _) {
                      final currentProvider = nestedConsumerProvider ?? _complexProvider;
                      final validStatus = currentProvider?.state == ProviderState.loaded;

                      ComplexModel? complex = currentProvider?.complex;

                      return LabeledInfoWidget(
                        icon: Symbols.apartment_rounded,
                        label: 'Complex',
                        text: !validStatus || complex == null ? 'Complex' : complex.complexName,
                      );
                    },
                  ),
                ]
              : [
                  LabeledInfoWidget(
                    icon: Symbols.groups_rounded,
                    label: 'Capacity',
                    text: widget.court.maxPeople.toString().padLeft(2, '0'),
                  ),
                ],
          rightChildren: widget.isTelemetryView
              ? [
                  LabeledInfoWidget(
                    icon: Symbols.calendar_month_rounded,
                    label: 'Date',
                    text: widget.telemetry == null || widget.telemetry!.createdAt == null
                        ? '--/--/----'
                        : widget.telemetry!.createdAt!.toLocal().toFormattedDate(),
                  ),
                  LabeledInfoWidget(
                    icon: Symbols.schedule_rounded,
                    label: 'Time',
                    text: widget.telemetry == null || widget.telemetry!.createdAt == null
                        ? '--:--'
                        : widget.telemetry!.createdAt!.toLocal().toFormattedTime(),
                  ),
                ]
              : [],
        ),
      ),
      trailing: widget.isTelemetryView ? null : Icon(Symbols.chevron_right_rounded),
      onTap: widget.onTap,
    );
  }

  Widget _buildStatusChip() => widget.court.status.smallStatusChip;
}
