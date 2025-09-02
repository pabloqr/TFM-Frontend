import 'package:flutter/material.dart';
import 'package:frontend/data/services/utilities.dart';
import 'package:frontend/features/courts/data/models/sport_enum.dart';

class SportCard extends StatelessWidget {
  final Sport sport;
  final VoidCallback? onTap;

  final int? index;
  final ValueNotifier<int> selectedIndex;

  const SportCard({super.key, required this.sport, this.onTap, this.index, required this.selectedIndex});

  Widget _buildContent(BuildContext context, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 8.0,
          children: [
            Icon(
              sport.icon,
              size: 24,
              fill: 0,
              weight: 400,
              grade: 0,
              opticalSize: 24,
              color: isSelected ? colorScheme.primary : null,
            ),
            Text(
              sport.name.toCapitalized(),
              style: textTheme.bodyMedium?.copyWith(
                color: isSelected ? colorScheme.primary : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndex,
      builder: (context, currentIndex, _) {
        final isSelected = index == currentIndex;

        return isSelected
            ? Card.outlined(
                margin: EdgeInsetsGeometry.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildContent(context, isSelected),
              )
            : Card.filled(
                margin: EdgeInsetsGeometry.zero,
                clipBehavior: Clip.antiAlias,
                child: _buildContent(context, isSelected),
              );
      },
    );
  }
}
