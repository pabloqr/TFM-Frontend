import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/features/complexes/presentation/widgets/complex_card_widget.dart';
import 'package:frontend/features/courts/data/models/sport_enum.dart';
import 'package:frontend/features/news/presentation/widgets/news_card_widget.dart';
import 'package:frontend/features/reservations/presentation/widgets/reservation_card_widget.dart';

class ClientDashboardScreen extends StatelessWidget {
  const ClientDashboardScreen({super.key});

  Widget _buildSubheader(
    BuildContext context, {
    required String title,
    required String buttonText,
    required void Function() onPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
        TextButton(onPressed: onPressed, child: Text(buttonText)),
      ],
    );
  }

  Widget _buildReservationSubsection(BuildContext context) {
    return Column(
      spacing: 8.0,
      children: [
        _buildSubheader(context, title: 'Upcoming reservation', buttonText: 'See all', onPressed: () {}),
        const ReservationCardWidget(),
      ],
    );
  }

  Widget _buildDiscoverSubsection(BuildContext context) {
    return Column(
      spacing: 8.0,
      children: [
        _buildSubheader(context, title: 'Discover', buttonText: 'Explore complexes', onPressed: () {}),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 264.0),
          child: CarouselView(
            itemExtent: 240.0,
            children: List<Widget>.generate(10, (int index) {
              final random = Random();
              List<Sport> sports = Sport.values.toList();
              sports.remove(Sport.padel);
              sports.shuffle(random);

              return SmallComplexCardWidget(
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
        _buildSubheader(context, title: 'News', buttonText: 'More news', onPressed: () {}),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400.0),
          child: NewsCardWidget(
            title: 'News title',
            date: DateTime.now().subtract(Duration(hours: Random().nextInt(8761))),
          ),
        ),
      ],
    );
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
}
