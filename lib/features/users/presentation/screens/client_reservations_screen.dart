import 'package:flutter/material.dart';
import 'package:frontend/features/reservations/presentation/widgets/reservation_card.dart';

class ClientReservationsScreen extends StatelessWidget {
  const ClientReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      itemCount: 10,
      itemBuilder: (context, index) {
        return ConstrainedBox(constraints: const BoxConstraints(maxHeight: 252.0), child: ReservationCard());
      },
    );
  }
}
