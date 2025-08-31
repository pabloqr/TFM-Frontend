import 'package:flutter/material.dart';
import 'package:frontend/features/common/data/models/widget_status.dart';

class SmallChip extends StatelessWidget {
  final WidgetStatus status;
  final String label;

  const SmallChip._({required this.status, required this.label});

  factory SmallChip.neutralSurface(String label) =>
      SmallChip._(status: WidgetStatus.neutralSurface, label: label);

  factory SmallChip.neutralCard(String label) => SmallChip._(status: WidgetStatus.neutralCard, label: label);

  factory SmallChip.alert(String label) => SmallChip._(status: WidgetStatus.alert, label: label);

  factory SmallChip.success(String label) => SmallChip._(status: WidgetStatus.success, label: label);

  factory SmallChip.error(String label) => SmallChip._(status: WidgetStatus.error, label: label);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(6.0),
      decoration: BoxDecoration(color: status.colorSurface(context), borderRadius: BorderRadius.circular(8.0)),
      child: Text(label, style: textTheme.labelSmall?.copyWith(color: status.colorOnSurface(context))),
    );
  }
}
