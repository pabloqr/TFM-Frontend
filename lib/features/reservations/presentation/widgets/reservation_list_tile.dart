import 'package:flutter/material.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/common/presentation/widgets/small_chip.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ReservationListTile extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const ReservationListTile({super.key, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      title: Row(
        spacing: 8.0,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.end,
            children: [SmallChip.alert(label: 'Sport')],
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: InfoSectionWidget(
          leftChildren: [
            LabeledInfoWidget(icon: Symbols.person_rounded, label: 'User', text: 'XXXX'),
            LabeledInfoWidget(icon: Symbols.apartment_rounded, label: 'Complex', text: 'ComplexName'),
          ],
          rightChildren: [
            LabeledInfoWidget(icon: Symbols.calendar_month_rounded, label: 'Date', text: 'Mon, 00/00/0000'),
            LabeledInfoWidget(icon: Symbols.schedule_rounded, label: 'Time', text: '00:00'),
          ],
        ),
      ),
      trailing: Icon(Symbols.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
