import 'package:flutter/material.dart';
import 'package:frontend/features/complexes/presentation/widgets/small_complex_card_widget.dart';
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
          constraints: const BoxConstraints(maxHeight: 260.0),
          child: CarouselView(
            itemExtent: 240.0,
            children: List<Widget>.generate(10, (int index) {
              return SmallComplexCardWidget();
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
        const ReservationCardWidget(),
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
          ],
        ),
      ),
    );
  }
}
