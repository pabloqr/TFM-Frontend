import 'package:flutter/material.dart';
import 'package:frontend/features/common/data/models/widget_status.dart';

class LargeChip extends StatelessWidget {
  final WidgetStatus status;
  final String label;

  const LargeChip._({required this.status, required this.label});

  factory LargeChip.neutralSurface(String label) => LargeChip._(status: WidgetStatus.neutralSurface, label: label);

  factory LargeChip.neutralCard(String label) => LargeChip._(status: WidgetStatus.neutralCard, label: label);

  factory LargeChip.alert(String label) => LargeChip._(status: WidgetStatus.alert, label: label);

  factory LargeChip.success(String label) => LargeChip._(status: WidgetStatus.success, label: label);

  factory LargeChip.error(String label) => LargeChip._(status: WidgetStatus.error, label: label);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(color: status.colorSurface(context), borderRadius: BorderRadius.circular(8.0)),
      child: Text(label, style: textTheme.labelLarge?.copyWith(color: status.colorOnSurface(context))),
    );
  }
}
