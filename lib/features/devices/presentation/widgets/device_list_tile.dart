import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/features/common/presentation/widgets/small_chip.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class DeviceListTile extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const DeviceListTile({super.key, required this.name, required this.onTap});

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
            // TODO: Chip based on device status
            children: [SmallChip.neutralSurface(label: 'Type'), SmallChip.alert(label: 'Warning')],
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
                icon: Symbols.timeline_rounded,
                label: 'Last telemetry',
                text: '${4 + Random().nextInt(8)}.${Random().nextInt(100)}',
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
