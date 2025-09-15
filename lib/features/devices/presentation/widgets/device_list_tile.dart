import 'package:flutter/material.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/data/providers/device_courts_provider.dart';
import 'package:frontend/data/services/utilities.dart';
import 'package:frontend/features/common/data/models/telemetry_model.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/common/presentation/widgets/small_chip.dart';
import 'package:frontend/features/devices/data/models/device_model.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

class DeviceListTile extends StatefulWidget {
  final bool isTelemetryView;

  final TelemetryModel? telemetry;
  final DeviceModel device;
  final VoidCallback onTap;

  const DeviceListTile._(this.isTelemetryView, {required this.telemetry, required this.device, required this.onTap});

  factory DeviceListTile.telemetry({
    required TelemetryModel? telemetry,
    required DeviceModel device,
    required VoidCallback onTap,
  }) => DeviceListTile._(true, telemetry: telemetry, device: device, onTap: onTap);

  factory DeviceListTile.list({
    required TelemetryModel? telemetry,
    required DeviceModel device,
    required VoidCallback onTap,
  }) => DeviceListTile._(false, telemetry: telemetry, device: device, onTap: onTap);

  @override
  State<DeviceListTile> createState() => _DeviceListTileState();
}

class _DeviceListTileState extends State<DeviceListTile> {
  DeviceCourtsProvider? _deviceCourtsProvider;
  VoidCallback? _providerListener;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _deviceCourtsProvider = context.read<DeviceCourtsProvider?>();

      if (widget.isTelemetryView && _deviceCourtsProvider != null) {
        _deviceCourtsProvider!.getDeviceCourts(widget.device.complexId, widget.device.id);
      }

      _providerListener = () {
        if (mounted &&
            _deviceCourtsProvider != null &&
            _deviceCourtsProvider!.getDataState(widget.device.id) == ProviderState.error &&
            _deviceCourtsProvider!.getDataFailure(widget.device.id) != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_deviceCourtsProvider!.getDataFailure(widget.device.id)!.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      };
      _deviceCourtsProvider?.addListener(_providerListener!);
    });
  }

  @override
  void dispose() {
    if (_deviceCourtsProvider != null && _providerListener != null) {
      _deviceCourtsProvider!.removeListener(_providerListener!);
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
            'Device ${widget.device.id}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            overflow: TextOverflow.fade,
          ),
          Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.end,
            children: [
              SmallChip.neutralSurface(label: widget.device.type.name.toCapitalized()),
              _buildStatusChip(),
            ],
          ),
        ],
      ),
      subtitle: Padding(padding: const EdgeInsets.only(top: 8.0), child: _buildSubtitleContent(context)),
      trailing: widget.isTelemetryView ? null : Icon(Symbols.chevron_right_rounded),
      onTap: widget.onTap,
    );
  }

  Widget _buildStatusChip() => widget.device.status.smallStatusChip;

  Widget _buildSubtitleContent(BuildContext context) {
    return widget.isTelemetryView ? _buildSubtitleTelemetryContent(context) : _buildSubtitleListContent(context);
  }

  Widget _buildSubtitleTelemetryContent(BuildContext context) {
    return InfoSectionWidget(
      leftChildren: [
        _buildTelemetryInfoWidget(context),
        Consumer<DeviceCourtsProvider?>(
          builder: (context, nestedConsumerProvider, _) {
            final currentDeviceCourtsProvider = nestedConsumerProvider ?? _deviceCourtsProvider;
            final validState = currentDeviceCourtsProvider?.getDataState(widget.device.id) == ProviderState.loaded;
            final courts = currentDeviceCourtsProvider?.getDataCourts(widget.device.id);

            return LabeledInfoWidget(
              icon: Symbols.location_on_rounded,
              label: 'Court',
              text: !validState || courts == null || courts.isEmpty
                  ? 'Not assigned to any courts'
                  : courts.map((court) => '${court.sport.name.toCapitalized()} ${court.name}').join(', '),
            );
          },
        ),
      ],
      rightChildren: [
        LabeledInfoWidget(
          icon: Symbols.calendar_month_rounded,
          label: 'Date',
          text: widget.telemetry == null || widget.telemetry!.createdAt == null
              ? '--/--/----'
              : widget.telemetry!.createdAt!.toFormattedDate(),
        ),
        LabeledInfoWidget(
          icon: Symbols.schedule_rounded,
          label: 'Time',
          text: widget.telemetry == null || widget.telemetry!.createdAt == null
              ? '--:--'
              : widget.telemetry!.createdAt!.toFormattedTime(),
        ),
      ],
    );
  }

  Widget _buildSubtitleListContent(BuildContext context) {
    return InfoSectionWidget(leftChildren: [_buildTelemetryInfoWidget(context)], rightChildren: []);
  }

  Widget _buildTelemetryInfoWidget(BuildContext context) {
    return LabeledInfoWidget(
      icon: Symbols.timeline_rounded,
      label: widget.isTelemetryView ? 'Value' : 'Last telemetry',
      text: widget.telemetry == null || widget.telemetry!.createdAt == null
          ? '--'
          : widget.telemetry!.type != DeviceType.presence
          ? widget.telemetry!.value.toString()
          : widget.telemetry!.toAvailabilityStatus().name.toCapitalized(),
    );
  }
}
