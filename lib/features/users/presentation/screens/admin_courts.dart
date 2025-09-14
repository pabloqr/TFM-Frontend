import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/data/providers/courts_list_provider.dart';
import 'package:frontend/data/providers/telemetry_provider.dart';
import 'package:frontend/features/common/data/models/telemetry_model.dart';
import 'package:frontend/features/common/presentation/widgets/fake_item.dart';
import 'package:frontend/features/courts/data/models/court_model.dart';
import 'package:frontend/features/courts/presentation/widgets/court_list_tile.dart';
import 'package:provider/provider.dart';

class AdminCourts extends StatefulWidget {
  final int complexId;

  final bool isTelemetryView;

  const AdminCourts._(this.isTelemetryView, {required this.complexId});

  factory AdminCourts.telemetry({required int complexId}) => AdminCourts._(true, complexId: complexId);

  factory AdminCourts.list({required int complexId}) => AdminCourts._(false, complexId: complexId);

  @override
  State<AdminCourts> createState() => _AdminCourtsState();
}

class _AdminCourtsState extends State<AdminCourts> {
  TelemetryProvider? _telemetryProvider;
  CourtsListProvider? _courtsListProvider;
  VoidCallback? _providerListener;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _telemetryProvider = context.read<TelemetryProvider?>();
      _courtsListProvider = context.read<CourtsListProvider?>();

      if (widget.isTelemetryView && _telemetryProvider != null) {
        _telemetryProvider!.getDevicesTelemetry(widget.complexId);
      }

      if (_courtsListProvider != null) {
        _courtsListProvider!.getCourts(widget.complexId);
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
            _courtsListProvider != null &&
            _courtsListProvider!.state == ProviderState.error &&
            _courtsListProvider!.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_courtsListProvider!.failure!.message), behavior: SnackBarBehavior.floating),
          );
        }
      };
      _telemetryProvider?.addListener(_providerListener!);
      _courtsListProvider?.addListener(_providerListener!);
    });
  }

  @override
  void dispose() {
    if (_telemetryProvider != null && _providerListener != null) {
      _telemetryProvider!.removeListener(_providerListener!);
    }
    if (_courtsListProvider != null && _providerListener != null) {
      _courtsListProvider!.removeListener(_providerListener!);
    }
    _providerListener = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: widget.isTelemetryView ? _buildTelemetryTab(context) : _buildCourtListTab(context),
    );
  }

  Widget _buildTelemetryTab(BuildContext context) {
    return Consumer2<TelemetryProvider?, CourtsListProvider?>(
      builder: (context, consumerProvider1, consumerProvider2, _) {
        final currentTelemetryProvider = consumerProvider1 ?? _telemetryProvider;
        final currentCourtsListProvider = consumerProvider2 ?? _courtsListProvider;

        if (currentTelemetryProvider == null || currentCourtsListProvider == null) {
          return _buildLoadingListTile(context);
        }

        List<int> ids = currentTelemetryProvider.ids;
        List<CourtModel> courts = currentCourtsListProvider.courts;

        if (currentTelemetryProvider.state == ProviderState.initial ||
            currentCourtsListProvider.state == ProviderState.initial) {
          return _buildLoadingListTile(context);
        } else if (currentTelemetryProvider.state == ProviderState.loading ||
            currentCourtsListProvider.state == ProviderState.loading) {
          if (ids.isNotEmpty && courts.isNotEmpty) {
            return _buildTelemetryListTile(context, currentTelemetryProvider, ids, courts);
          }
          return _buildLoadingListTile(context);
        } else if (currentTelemetryProvider.state == ProviderState.empty ||
            currentCourtsListProvider.state == ProviderState.empty) {
          return _buildErrorListTile(context);
        } else if (currentTelemetryProvider.state == ProviderState.error ||
            currentCourtsListProvider.state == ProviderState.error) {
          if (ids.isNotEmpty && courts.isNotEmpty) {
            return _buildTelemetryListTile(context, currentTelemetryProvider, ids, courts);
          }
          return _buildErrorListTile(context);
        }

        return _buildTelemetryListTile(context, currentTelemetryProvider, ids, courts);
      },
    );
  }

  Widget _buildCourtListTab(BuildContext context) {
    return Consumer<CourtsListProvider?>(
      builder: (context, consumerProvider, _) {
        final currentProvider = consumerProvider ?? _courtsListProvider;

        if (currentProvider == null) return _buildLoadingListTile(context);

        List<CourtModel> courts = currentProvider.courts;

        switch (currentProvider.state) {
          case ProviderState.initial:
          case ProviderState.loading:
            if (courts.isEmpty) return _buildLoadingListTile(context);
            return _buildCourtListTile(context, courts);
          case ProviderState.empty:
            return _buildErrorListTile(context);
          case ProviderState.error:
            if (courts.isNotEmpty) {
              return _buildCourtListTile(context, courts);
            }
            return _buildErrorListTile(context);
          case ProviderState.loaded:
            return _buildCourtListTile(context, courts);
        }
      },
    );
  }

  Widget _buildLoadingListTile(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: 1,
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
        return const Center(heightFactor: 4.0, child: Text('Error loading courts'));
      },
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
    );
  }

  Widget _buildTelemetryListTile(
    BuildContext context,
    TelemetryProvider telemetryProvider,
    List<int> ids,
    List<CourtModel> courts,
  ) {
    final List<TelemetryModel> telemetry = [];
    for (var id in ids) {
      final state = telemetryProvider.getDataState(id);
      final telemetryData = telemetryProvider.getDataTelemetry(id);

      if (state == ProviderState.loaded) {
        for (var element in telemetryData) {
          telemetry.add(element);
        }
      }
    }
    telemetry.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: telemetry.length,
      itemBuilder: (context, index) {
        return CourtListTile.telemetry(
          telemetry: telemetry.elementAt(index),
          court: courts.elementAt(index),
          onTap: () {},
          isAdmin: true,
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
    );
  }

  Widget _buildCourtListTile(BuildContext context, List<CourtModel> courts) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: courts.length,
      itemBuilder: (context, index) {
        return CourtListTile.list(
          court: courts.elementAt(index),
          onTap: () => Navigator.of(context).pushNamed(
            AppConstants.courtInfoRoute,
            arguments: {'complexId': widget.complexId, 'courtId': courts.elementAt(index).id},
          ),
          isAdmin: true,
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
    );
  }
}
