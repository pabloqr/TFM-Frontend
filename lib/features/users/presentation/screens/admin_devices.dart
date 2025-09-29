import 'package:flutter/material.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/data/providers/devices_list_provider.dart';
import 'package:frontend/data/providers/telemetry_provider.dart';
import 'package:frontend/features/common/data/models/telemetry_model.dart';
import 'package:frontend/features/common/presentation/widgets/fake_item.dart';
import 'package:frontend/features/devices/data/models/device_model.dart';
import 'package:frontend/features/devices/presentation/widgets/device_list_tile.dart';
import 'package:provider/provider.dart';

class AdminDevices extends StatefulWidget {
  final int complexId;

  final bool isTelemetryView;

  const AdminDevices._(this.isTelemetryView, {required this.complexId});

  factory AdminDevices.telemetry({required int complexId}) => AdminDevices._(true, complexId: complexId);

  factory AdminDevices.list({required int complexId}) => AdminDevices._(false, complexId: complexId);

  @override
  State<AdminDevices> createState() => _AdminDevicesState();
}

class _AdminDevicesState extends State<AdminDevices> {
  TelemetryProvider? _telemetryProvider;
  DevicesListProvider? _devicesListProvider;
  VoidCallback? _providerListener;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _telemetryProvider = context.read<TelemetryProvider?>();
      _devicesListProvider = context.read<DevicesListProvider?>();

      if (_telemetryProvider != null) {
        if (widget.isTelemetryView) {
          _telemetryProvider!.getComplexDevicesTelemetry(widget.complexId);
        } else {
          _telemetryProvider!.getComplexDevicesTelemetry(widget.complexId, query: {'last': true});
        }
      }

      if (_devicesListProvider != null) {
        _devicesListProvider!.getDevices(widget.complexId);
      }

      _providerListener = () {
        if (mounted &&
            _telemetryProvider != null &&
            _telemetryProvider!.state == ProviderState.error &&
            _telemetryProvider!.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_telemetryProvider!.failure!.message), behavior: SnackBarBehavior.floating),
          );
        }

        if (mounted &&
            _devicesListProvider != null &&
            _devicesListProvider!.state == ProviderState.error &&
            _devicesListProvider!.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_devicesListProvider!.failure!.message), behavior: SnackBarBehavior.floating),
          );
        }
      };
      _telemetryProvider?.addListener(_providerListener!);
      _devicesListProvider?.addListener(_providerListener!);
    });
  }

  @override
  void dispose() {
    if (_telemetryProvider != null && _providerListener != null) {
      _telemetryProvider!.removeListener(_providerListener!);
    }
    if (_devicesListProvider != null && _providerListener != null) {
      _devicesListProvider!.removeListener(_providerListener!);
    }
    _providerListener = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Consumer<TelemetryProvider?>(
        builder: (context, consumerProvider, _) {
          final currentProvider = consumerProvider ?? _telemetryProvider;

          if (currentProvider == null) {
            return _buildLoadingListTile(context);
          }

          final List<MapEntry<int, TelemetryModel>> telemetry = [];
          for (var id in currentProvider.ids) {
            final state = currentProvider.getDataState(id);
            final telemetryData = currentProvider.getDataTelemetry(id);

            if (state == ProviderState.loaded) {
              for (var element in telemetryData) {
                telemetry.add(MapEntry(id, element));
              }
            }
          }
          telemetry.sort((a, b) => b.value.createdAt!.compareTo(a.value.createdAt!));

          return _buildTabs(context, telemetry);
        },
      ),
    );
  }

  Widget _buildTabs(BuildContext context, List<MapEntry<int, TelemetryModel>> telemetry) {
    return Consumer<DevicesListProvider?>(
      builder: (context, consumerProvider, _) {
        final currentProvider = consumerProvider ?? _devicesListProvider;

        if (currentProvider == null) return _buildLoadingListTile(context);

        List<DeviceModel> devices = currentProvider.devices;

        switch (currentProvider.state) {
          case ProviderState.initial:
          case ProviderState.loading:
            if (devices.isEmpty) return _buildLoadingListTile(context);
            return widget.isTelemetryView
                ? _buildTelemetryListTile(context, telemetry, devices)
                : _buildDeviceListTile(context, telemetry, devices);
          case ProviderState.empty:
            return _buildErrorListTile(context);
          case ProviderState.error:
            if (devices.isNotEmpty) {
              return widget.isTelemetryView
                  ? _buildTelemetryListTile(context, telemetry, devices)
                  : _buildDeviceListTile(context, telemetry, devices);
            }
            return _buildErrorListTile(context);
          case ProviderState.loaded:
            return widget.isTelemetryView
                ? _buildTelemetryListTile(context, telemetry, devices)
                : _buildDeviceListTile(context, telemetry, devices);
        }
      },
    );
  }

  Widget _buildLoadingListTile(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: 10,
      itemBuilder: (context, index) {
        return FakeItem(isBig: true);
      },
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
    );
  }

  Widget _buildErrorListTile(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: 1,
      itemBuilder: (context, index) {
        return const Center(heightFactor: 4.0, child: Text('Error loading devices'));
      },
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
    );
  }

  Widget _buildTelemetryListTile(
    BuildContext context,
    List<MapEntry<int, TelemetryModel>> telemetry,
    List<DeviceModel> devices,
  ) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: telemetry.length,
      itemBuilder: (context, index) {
        // TODO: Add device view navigation
        return DeviceListTile.telemetry(
          telemetry: telemetry.elementAt(index).value,
          device: devices.elementAt(index),
          onTap: () {},
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
    );
  }

  Widget _buildDeviceListTile(
    BuildContext context,
    List<MapEntry<int, TelemetryModel>> telemetry,
    List<DeviceModel> devices,
  ) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final i = telemetry.indexWhere((t) => t.key == devices.elementAt(index).id);

        // TODO: Add device view navigation
        return DeviceListTile.list(
          telemetry: i != -1 ? telemetry.elementAt(i).value : null,
          device: devices.elementAt(index),
          onTap: () {},
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
    );
  }
}
