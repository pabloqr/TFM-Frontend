import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/features/common/presentation/widgets/header.dart';
import 'package:frontend/features/complexes/presentation/widgets/complex_card.dart';
import 'package:frontend/features/courts/data/models/sport_enum.dart';
import 'package:frontend/features/news/presentation/widgets/news_card.dart';
import 'package:frontend/features/reservations/presentation/widgets/reservation_card.dart';

class ClientDashboardScreen extends StatelessWidget {
  final VoidCallback onReservationPressed;
  final VoidCallback onDiscoverPressed;
  final VoidCallback onNewsPressed;

  const ClientDashboardScreen({
    super.key,
    required this.onReservationPressed,
    required this.onDiscoverPressed,
    required this.onNewsPressed,
  });

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
    return Column(
      spacing: 8.0,
      children: [
        Header.subheader(
          subheaderText: 'Upcoming reservation',
          showButton: true,
          buttonText: 'See all',
          onPressed: onReservationPressed,
        ),
        const ReservationCard(),
      ],
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
          onPressed: onDiscoverPressed,
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 264.0),
          child: CarouselView(
            itemExtent: 240.0,
            onTap: (index) => Navigator.of(context).pushNamed(AppConstants.complexInfoRoute),
            children: List<Widget>.generate(10, (int index) {
              final random = Random();
              List<Sport> sports = Sport.values.toList();
              sports.remove(Sport.padel);
              sports.shuffle(random);

              return ComplexCard.small(
                title: 'Complex $index',
                rating: random.nextInt(11) / 2.0,
                sports: sports.sublist(0, random.nextInt(sports.length) + 1).toSet(),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildNewsSubsection(BuildContext context) {
    return Column(
      spacing: 8.0,
      children: [
        Header.subheader(subheaderText: 'News', showButton: true, buttonText: 'More news', onPressed: onNewsPressed),
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
