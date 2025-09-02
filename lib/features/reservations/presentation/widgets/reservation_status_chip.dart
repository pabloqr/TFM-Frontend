import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/constants/theme.dart';

class ReservationStatusChip extends StatefulWidget {
  final IconData icon;
  final String label;

  const ReservationStatusChip({super.key, required this.icon, required this.label});

  @override
  State<ReservationStatusChip> createState() => _ReservationStatusChipState();
}

class _ReservationStatusChipState extends State<ReservationStatusChip> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const animationDuration = Duration(milliseconds: 300);

    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();

        setState(() => _isExpanded = !_isExpanded);
      },
      child: AnimatedContainer(
        duration: animationDuration,
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 8.0 : 6.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: MaterialTheme.success.light.colorContainer,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 18,
              fill: 0,
              weight: 400,
              grade: 0,
              opticalSize: 18,
              color: MaterialTheme.success.light.onColorContainer,
            ),
            AnimatedSwitcher(
              duration: animationDuration,
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axis: Axis.horizontal,
                    axisAlignment: -1.0,
                    child: child,
                  ),
                );
              },
              layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: <Widget>[...previousChildren, if (currentChild != null) currentChild],
                );
              },
              child: _isExpanded
                  ? Row(
                      key: const ValueKey('expanded_label'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 4.0),
                        Text(
                          widget.label,
                          style: textTheme.labelSmall?.copyWith(color: MaterialTheme.success.light.onColorContainer),
                        ),
                        const SizedBox(width: 4.0),
                      ],
                    )
                  : const SizedBox(key: ValueKey('collapsed_label')),
            ),
          ],
        ),
      ),
    );
  }
}
