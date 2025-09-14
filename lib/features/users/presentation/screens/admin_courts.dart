import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/data/providers/courts_list_provider.dart';
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
  CourtsListProvider? _courtsListProvider;
  VoidCallback? _providerListener;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _courtsListProvider = context.read<CourtsListProvider?>();

      if (_courtsListProvider != null) {
        if (_courtsListProvider!.state == ProviderState.initial) {
          _courtsListProvider!.getCourts(widget.complexId);
        }

        _providerListener = () {
          if (mounted &&
              _courtsListProvider != null &&
              _courtsListProvider!.state == ProviderState.error &&
              _courtsListProvider!.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_courtsListProvider!.failure!.message), behavior: SnackBarBehavior.floating),
            );
          }
        };
        _courtsListProvider!.addListener(_providerListener!);
      }
    });
  }

  @override
  void dispose() {
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
      child: Consumer<CourtsListProvider?>(
        builder: (context, consumerProvider, _) {
          final currentProvider = consumerProvider ?? _courtsListProvider;

          if (currentProvider == null) return _buildLoadingListTile(context);

          List<CourtModel> courts = currentProvider.courts;

          switch (currentProvider.state) {
            case ProviderState.initial:
            case ProviderState.loading:
              if (courts.isEmpty) return _buildLoadingListTile(context);
              return _buildListTile(context, courts);
            case ProviderState.empty:
              return _buildErrorListTile(context);
            case ProviderState.error:
              if (courts.isNotEmpty) {
                return _buildListTile(context, courts);
              }
              return _buildErrorListTile(context);
            case ProviderState.loaded:
              return _buildListTile(context, courts);
          }
        },
      ),
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

  Widget _buildListTile(BuildContext context, List<CourtModel> courts) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: courts.length,
      itemBuilder: (context, index) {
        return widget.isTelemetryView
            ? CourtListTile.telemetry(court: courts.elementAt(index), onTap: () {}, isAdmin: true)
            : CourtListTile.list(
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
