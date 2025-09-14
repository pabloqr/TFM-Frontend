import 'package:flutter/material.dart';
import 'package:frontend/data/services/utilities.dart';
import 'package:frontend/features/common/data/models/availability_status.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/common/presentation/widgets/small_chip.dart';
import 'package:frontend/features/reservations/data/models/reservation_model.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ReservationListTile extends StatelessWidget {
  final ReservationModel reservation;
  final VoidCallback onTap;

  final bool isAdmin;

  const ReservationListTile({super.key, required this.reservation, required this.onTap, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      title: Row(
        spacing: 8.0,
        children: [
          Text(
            'Court ${reservation.courtId}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.end,
            children: [
              SmallChip.neutralSurface(label: 'Sport'),
              if (isAdmin) _buildStatusChip(),
              _buildReservationStatusChip(),
            ],
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: InfoSectionWidget(
          leftChildren: [
            LabeledInfoWidget(
              icon: Symbols.person_rounded,
              label: 'User',
              text: reservation.userId.toString().padLeft(8, '0'),
            ),
            LabeledInfoWidget(
              icon: Symbols.apartment_rounded,
              label: 'Complex',
              text: 'Complex ${reservation.complexId}',
            ),
          ],
          rightChildren: [
            LabeledInfoWidget(
              icon: Symbols.calendar_month_rounded,
              label: 'Date',
              text: reservation.dateIni.toFormattedDate(),
            ),
            LabeledInfoWidget(
              icon: Symbols.schedule_rounded,
              label: 'Time',
              text: reservation.dateIni.toFormattedTime(),
            ),
          ],
        ),
      ),
      trailing: Icon(Symbols.chevron_right_rounded),
      onTap: onTap,
    );
  }

  Widget _buildStatusChip() => reservation.status.smallStatusChip;

  Widget _buildReservationStatusChip() => reservation.reservationStatus.smallStatusChip;
}
