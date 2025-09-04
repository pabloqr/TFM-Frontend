import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/features/common/presentation/widgets/small_chip.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class CourtListTile extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  final bool isAdmin;

  const CourtListTile({super.key, required this.name, required this.onTap, required this.isAdmin});

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
            children: [
              if (isAdmin) SmallChip.neutralSurface(label: 'Sport') else SmallChip.alert(label: 'Sport'),
              if (isAdmin)
                SmallChip.error(label: 'Maintenance')
              else if (Random().nextBool())
                SmallChip.success(label: 'Available'),
            ],
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          spacing: 16.0,
          children: [
            Expanded(
              child: LabeledInfoWidget(
                icon: Symbols.groups_rounded,
                label: 'Capacity',
                text: '${4 + Random().nextInt(8)}',
              ),
            ),
          ],
        ),
      ),
      trailing: Icon(Symbols.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
