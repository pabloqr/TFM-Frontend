import 'package:flutter/material.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/data/providers/reservations_list_provider.dart';
import 'package:frontend/features/common/presentation/widgets/fake_item.dart';
import 'package:frontend/features/reservations/data/models/reservation_model.dart';
import 'package:frontend/features/reservations/presentation/widgets/reservation_card.dart';
import 'package:provider/provider.dart';

class ClientReservationsScreen extends StatefulWidget {
  final int userId;

  const ClientReservationsScreen({super.key, required this.userId});

  @override
  State<ClientReservationsScreen> createState() => _ClientReservationsScreenState();
}

class _ClientReservationsScreenState extends State<ClientReservationsScreen> {
  ReservationsListProvider? _reservationsListProvider;
  VoidCallback? _providerListener;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _reservationsListProvider = context.read<ReservationsListProvider?>();

      if (_reservationsListProvider != null) {
        _reservationsListProvider!.getUserReservations(widget.userId);

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
              return _buildEmptyListTile(context);
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
    return ListView.builder(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
      itemCount: 10,
      itemBuilder: (context, index) {
        return FakeItem(isBig: true);
      },
    );
  }

  Widget _buildEmptyListTile(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      itemCount: 1,
      itemBuilder: (context, index) {
        return const Center(heightFactor: 4.0, child: Text('No reservations found'));
      },
    );
  }

  Widget _buildErrorListTile(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      itemCount: 1,
      itemBuilder: (context, index) {
        return const Center(heightFactor: 4.0, child: Text('Error loading reservations'));
      },
    );
  }

  Widget _buildListTile(BuildContext context, List<ReservationModel> reservations) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 252.0),
          child: ReservationCard(userId: widget.userId, reservation: reservations.elementAt(index)),
        );
      },
    );
  }
}
