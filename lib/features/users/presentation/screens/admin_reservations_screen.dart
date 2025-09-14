import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/data/providers/reservations_list_provider.dart';
import 'package:frontend/features/common/presentation/widgets/fake_item.dart';
import 'package:frontend/features/reservations/data/models/reservation_model.dart';
import 'package:frontend/features/reservations/presentation/widgets/reservation_list_tile.dart';
import 'package:provider/provider.dart';

class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({super.key});

  @override
  State<AdminReservationsScreen> createState() => _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen> {
  ReservationsListProvider? _reservationsListProvider;
  VoidCallback? _providerListener;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _reservationsListProvider = context.read<ReservationsListProvider?>();

      if (_reservationsListProvider != null) {
        if (_reservationsListProvider!.state == ProviderState.initial) {
          _reservationsListProvider!.getComplexReservations(1);
        }

        _providerListener = () {
          if (mounted &&
              _reservationsListProvider != null &&
              _reservationsListProvider!.state == ProviderState.error &&
              _reservationsListProvider!.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_reservationsListProvider!.failure!.message), behavior: SnackBarBehavior.floating),
            );
          }
        };
      }
      _reservationsListProvider!.addListener(_providerListener!);
    });
  }

  @override
  void dispose() {
    if (_reservationsListProvider != null && _providerListener != null) {
      _reservationsListProvider!.removeListener(_providerListener!);
    }
    _providerListener = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Consumer<ReservationsListProvider?>(
        builder: (context, consumerProvider, _) {
          final currentProvider = consumerProvider ?? _reservationsListProvider;

          if (currentProvider == null) return _buildLoadingListTile(context);

          List<ReservationModel> reservations = currentProvider.reservations;

          switch (currentProvider.state) {
            case ProviderState.initial:
            case ProviderState.loading:
              if (reservations.isEmpty) return _buildLoadingListTile(context);
              return _buildListTile(context, reservations);
            case ProviderState.empty:
              return _buildErrorListTile(context);
            case ProviderState.error:
              if (reservations.isNotEmpty) {
                return _buildListTile(context, reservations);
              }
              return _buildErrorListTile(context);
            case ProviderState.loaded:
              return _buildListTile(context, reservations);
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
        return const Center(heightFactor: 4.0, child: Text('Error loading complexes'));
      },
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
    );
  }

  Widget _buildListTile(BuildContext context, List<ReservationModel> reservations) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        return ReservationListTile(
          reservation: reservations.elementAt(index),
          onTap: () {
            final reservation = reservations.elementAt(index);

            Navigator.of(context).pushNamed(
              AppConstants.reservationInfoRoute,
              arguments: {
                'complexId': reservation.complexId,
                'courtId': reservation.courtId,
                'reservationId': reservation.id,
              },
            );
          },
          isAdmin: true,
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
    );
  }
}
