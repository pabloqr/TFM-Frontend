import 'package:flutter/material.dart';
import 'package:frontend/features/common/data/models/widget_status.dart';

class CardChipWidget extends StatelessWidget {
  final WidgetStatus status;
  final String label;

  const CardChipWidget._({required this.status, required this.label});

  factory CardChipWidget.normal(String label) => CardChipWidget._(status: WidgetStatus.normal, label: label);

  factory CardChipWidget.alert(String label) => CardChipWidget._(status: WidgetStatus.alert, label: label);

  factory CardChipWidget.success(String label) => CardChipWidget._(status: WidgetStatus.success, label: label);

  factory CardChipWidget.error(String label) => CardChipWidget._(status: WidgetStatus.error, label: label);

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
