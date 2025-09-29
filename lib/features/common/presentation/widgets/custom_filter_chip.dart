import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

enum _FilterChipType { normal, dropDown }

class CustomFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  final _FilterChipType _type;

  const CustomFilterChip._(this._type, {required this.label, required this.selected, required this.onSelected});

  factory CustomFilterChip.normal(String label, bool selected, ValueChanged<bool> onSelected) =>
      CustomFilterChip._(_FilterChipType.normal, label: label, selected: selected, onSelected: onSelected);

  factory CustomFilterChip.dropDown(String label, bool selected, ValueChanged<bool> onSelected) =>
      CustomFilterChip._(_FilterChipType.dropDown, label: label, selected: selected, onSelected: onSelected);

  Widget _buildLabel() {
    switch (_type) {
      case _FilterChipType.normal:
        return Text(label);
      case _FilterChipType.dropDown:
        return Row(
          spacing: 8.0,
          children: [
            Text(label),
            Icon(Symbols.arrow_drop_down_rounded, size: 18, fill: 0, weight: 400, grade: 0, opticalSize: 18),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: _buildLabel(),
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 8.0),
      selected: selected,
      onSelected: onSelected,
    );
  }
}
