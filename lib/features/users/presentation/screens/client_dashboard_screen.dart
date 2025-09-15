import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/data/providers/complexes_list_provider.dart';
import 'package:frontend/data/providers/reservations_list_provider.dart';
import 'package:frontend/data/services/utilities.dart';
import 'package:frontend/features/common/presentation/widgets/header.dart';
import 'package:frontend/features/complexes/data/models/complex_model.dart';
import 'package:frontend/features/complexes/presentation/widgets/complex_card.dart';
import 'package:frontend/features/news/presentation/widgets/news_card.dart';
import 'package:frontend/features/reservations/data/models/reservation_model.dart';
import 'package:frontend/features/reservations/presentation/widgets/reservation_card.dart';
import 'package:provider/provider.dart';

class ClientDashboardScreen extends StatefulWidget {
  final int userId;

  final VoidCallback onReservationPressed;
  final VoidCallback onDiscoverPressed;
  final VoidCallback onNewsPressed;

  const ClientDashboardScreen({
    super.key,
    required this.userId,
    required this.onReservationPressed,
    required this.onDiscoverPressed,
    required this.onNewsPressed,
  });

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  ComplexesListProvider? _complexesListProvider;
  ReservationsListProvider? _reservationsListProvider;
  VoidCallback? _providerListener;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _complexesListProvider = context.read<ComplexesListProvider?>();
      _reservationsListProvider = context.read<ReservationsListProvider?>();

      if (_complexesListProvider != null) {
        _complexesListProvider!.getComplexes();
      }
      if (_reservationsListProvider != null) {
        _reservationsListProvider!.getUserReservations(widget.userId);
      }

      _providerListener = () {
        if (mounted &&
            _complexesListProvider != null &&
            _complexesListProvider!.state == ProviderState.error &&
            _complexesListProvider!.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_complexesListProvider!.failure!.message), behavior: SnackBarBehavior.floating),
          );
        }

        if (mounted &&
            _reservationsListProvider != null &&
            _reservationsListProvider!.state == ProviderState.error &&
            _reservationsListProvider!.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_reservationsListProvider!.failure!.message), behavior: SnackBarBehavior.floating),
          );
        }
      };
      _complexesListProvider?.addListener(_providerListener!);
      _reservationsListProvider?.addListener(_providerListener!);
    });
  }

  @override
  void dispose() {
    if (_complexesListProvider != null && _providerListener != null) {
      _complexesListProvider!.removeListener(_providerListener!);
    }
    if (_reservationsListProvider != null && _providerListener != null) {
      _reservationsListProvider!.removeListener(_providerListener!);
    }
    _providerListener = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16.0,
          children: [
            _buildReservationSubsection(context),
            _buildDiscoverSubsection(context),
            _buildNewsSubsection(context),
            const SizedBox(height: 56.0),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationSubsection(BuildContext context) {
    return Consumer<ReservationsListProvider?>(
      builder: (context, consumerProvider, _) {
        final currentProvider = consumerProvider ?? _reservationsListProvider;
        List<ReservationModel> reservations = currentProvider?.reservations ?? [];

        if (reservations.isNotEmpty) {
          reservations.removeWhere(
            (reservation) =>
                reservation.reservationStatus == ReservationStatus.completed ||
                reservation.reservationStatus == ReservationStatus.cancelled,
          );
          reservations.sort((a, b) => a.dateIni.compareTo(b.dateIni));
        }

        final reservation = reservations.isNotEmpty ? reservations.first : null;

        return Column(
          spacing: 8.0,
          children: [
            Header.subheader(
              subheaderText: 'Upcoming reservation',
              showButton: true,
              buttonText: 'See all',
              onPressed: widget.onReservationPressed,
            ),
            if (reservation != null)
              ReservationCard(userId: widget.userId, reservation: reservation)
            else
              Center(heightFactor: 4.0, child: const Text('No upcoming reservations')),
          ],
        );
      },
    );
  }

  Widget _buildDiscoverSubsection(BuildContext context) {
    return Column(
      spacing: 8.0,
      children: [
        Header.subheader(
          subheaderText: 'Discover',
          showButton: true,
          buttonText: 'Explore complexes',
          onPressed: widget.onDiscoverPressed,
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 264.0),
          child: Consumer<ComplexesListProvider?>(
            builder: (context, consumerProvider, _) {
              final currentProvider = consumerProvider ?? _complexesListProvider;
              List<ComplexModel> complexes = currentProvider?.complexes ?? [];

              return CarouselView(
                itemExtent: 240.0,
                onTap: (index) => Navigator.of(
                  context,
                ).pushNamed(AppConstants.complexInfoRoute, arguments: {'complexId': complexes.elementAt(index).id}),
                children: List<Widget>.generate(complexes.isNotEmpty ? complexes.length : 10, (int index) {
                  if (complexes.isEmpty) {
                    return Container(color: Theme.of(context).colorScheme.surfaceContainer);
                  }

                  return FutureBuilder(
                    future: NetworkUtilities.getComplexSports(context, complexes.elementAt(index).id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(color: Theme.of(context).colorScheme.surfaceContainer);
                      }

                      if (snapshot.hasError || !snapshot.hasData) {
                        return Container(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          child: Center(child: Text('Error loading ${complexes.elementAt(index).complexName} data')),
                        );
                      }

                      final sports = snapshot.data!;

                      return ComplexCard.small(
                        userId: null,
                        complex: complexes.elementAt(index),
                        rating: Random().nextInt(11) / 2.0,
                        sports: sports,
                      );
                    },
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewsSubsection(BuildContext context) {
    return Column(
      spacing: 8.0,
      children: [
        Header.subheader(
          subheaderText: 'News',
          showButton: true,
          buttonText: 'More news',
          onPressed: widget.onNewsPressed,
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400.0),
          child: NewsCard(
            title: 'News title',
            date: DateTime.now().subtract(Duration(hours: Random().nextInt(8761))),
          ),
        ),
      ],
    );
  }
}
