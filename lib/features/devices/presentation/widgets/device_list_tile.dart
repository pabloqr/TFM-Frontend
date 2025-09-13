import 'package:flutter/material.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/data/providers/telemetry_provider.dart';
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

  final DeviceModel device;
  final VoidCallback onTap;

  const DeviceListTile._(this.isTelemetryView, {required this.device, required this.onTap});

  factory DeviceListTile.telemetry({required DeviceModel device, required VoidCallback onTap}) =>
      DeviceListTile._(true, device: device, onTap: onTap);

  factory DeviceListTile.list({required DeviceModel device, required VoidCallback onTap}) =>
      DeviceListTile._(false, device: device, onTap: onTap);

  @override
  State<DeviceListTile> createState() => _DeviceListTileState();
}

class _DeviceListTileState extends State<DeviceListTile> {
  TelemetryProvider? _telemetryProvider;
  VoidCallback? _providerListener;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _telemetryProvider = context.read<TelemetryProvider?>();

      if (_telemetryProvider != null) {
        if (_telemetryProvider!.getProviderState(widget.device.id) == ProviderState.initial) {
          _telemetryProvider!.getDeviceTelemetry(widget.device.complexId, widget.device.id, query: {'last': true});
        }
      }

      if (_telemetryProvider != null) {
        _providerListener = () {
          if (mounted &&
              _telemetryProvider != null &&
              _telemetryProvider!.getProviderState(widget.device.id) == ProviderState.error &&
              _telemetryProvider!.getProviderFailure(widget.device.id) != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_telemetryProvider!.getProviderFailure(widget.device.id)!.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        };
        _telemetryProvider!.addListener(_providerListener!);
      }
    });
  }

  @override
  void dispose() {
    if (_telemetryProvider != null && _providerListener != null) {
      _telemetryProvider!.removeListener(_providerListener!);
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
            overflow: TextOverflow.ellipsis,
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

  Widget _buildStatusChip() {
    switch (widget.device.status) {
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

  Widget _buildSubtitleContent(BuildContext context) {
    return widget.isTelemetryView ? _buildSubtitleTelemetryContent(context) : _buildSubtitleListContent(context);
  }

  Widget _buildSubtitleTelemetryContent(BuildContext context) {
    return Consumer<TelemetryProvider?>(
      builder: (context, consumerProvider, _) {
        final currentProvider = consumerProvider ?? _telemetryProvider;
        final validStatus = currentProvider?.getProviderState(widget.device.id) == ProviderState.loaded;
        final telemetry = currentProvider?.getProviderTelemetry(widget.device.id);

        return InfoSectionWidget(
          leftChildren: [
            _buildLastTelemetryInfoWidget(context, validStatus, telemetry),
            LabeledInfoWidget(icon: Symbols.location_on_rounded, label: 'Court', text: 'CourtName'),
          ],
          rightChildren: [
            LabeledInfoWidget(
              icon: Symbols.calendar_month_rounded,
              label: 'Date',
              text: !validStatus || telemetry == null || telemetry.isEmpty || telemetry.elementAt(0).createdAt == null
                  ? '--/--/----'
                  : telemetry.elementAt(0).createdAt!.toFormattedDate(),
            ),
            LabeledInfoWidget(
              icon: Symbols.schedule_rounded,
              label: 'Time',
              text: !validStatus || telemetry == null || telemetry.isEmpty || telemetry.elementAt(0).createdAt == null
                  ? '--:--'
                  : telemetry.elementAt(0).createdAt!.toFormattedTime(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubtitleListContent(BuildContext context) {
    return Consumer<TelemetryProvider?>(
      builder: (context, consumerProvider, _) {
        final currentProvider = consumerProvider ?? _telemetryProvider;
        final validStatus = currentProvider?.getProviderState(widget.device.id) == ProviderState.loaded;
        final telemetry = currentProvider?.getProviderTelemetry(widget.device.id);

        return InfoSectionWidget(
          leftChildren: [_buildLastTelemetryInfoWidget(context, validStatus, telemetry)],
          rightChildren: [],
        );
      },
    );
  }

  Widget _buildLastTelemetryInfoWidget(BuildContext context, bool validStatus, List<TelemetryModel>? telemetry) {
    return LabeledInfoWidget(
      icon: Symbols.timeline_rounded,
      label: 'Last telemetry',
      text: !validStatus || telemetry == null || telemetry.isEmpty || telemetry.elementAt(0).createdAt == null
          ? '--'
          : telemetry.elementAt(0).value.toString(),
    );
  }
}
