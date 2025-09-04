import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/features/common/data/models/widget_size.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/common/presentation/widgets/small_chip.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class CourtCard extends StatelessWidget {
  final WidgetSize size;

  final String title;
  final Set<TimeOfDay> times;

  final int? index;
  final ValueNotifier<int> selectedIndex;

  const CourtCard._(this.size, {required this.title, required this.times, this.index, required this.selectedIndex});

  factory CourtCard.small({
    required String title,
    required Set<TimeOfDay> times,
    int? index,
    ValueNotifier<int>? selectedIndex,
  }) {
    ValueNotifier<int> notifier = selectedIndex ?? ValueNotifier<int>(-1);
    return CourtCard._(WidgetSize.small, title: title, times: times, index: index, selectedIndex: notifier);
  }

  factory CourtCard.medium({
    required String title,
    required Set<TimeOfDay> times,
    int? index,
    ValueNotifier<int>? selectedIndex,
  }) {
    ValueNotifier<int> notifier = selectedIndex ?? ValueNotifier<int>(-1);
    return CourtCard._(WidgetSize.medium, title: title, times: times, index: index, selectedIndex: notifier);
  }

  factory CourtCard.large({
    required String title,
    required Set<TimeOfDay> times,
    int? index,
    ValueNotifier<int>? selectedIndex,
  }) {
    ValueNotifier<int> notifier = selectedIndex ?? ValueNotifier<int>(-1);
    return CourtCard._(WidgetSize.large, title: title, times: times, index: index, selectedIndex: notifier);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndex,
      builder: (context, currentIndex, _) {
        return index == currentIndex
            ? Card.outlined(
                margin: size == WidgetSize.small ? EdgeInsetsGeometry.zero : const EdgeInsets.all(4.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.0),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildContent(context),
              )
            : Card.filled(
                margin: size == WidgetSize.small ? EdgeInsetsGeometry.zero : const EdgeInsets.all(4.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                clipBehavior: Clip.antiAlias,
                child: _buildContent(context),
              );
      },
    );
  }

  Widget _buildTitle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Text(title, style: textTheme.titleLarge, softWrap: false);
  }

  Widget _buildHeader(BuildContext context) {
    if (size == WidgetSize.small) {
      return _buildTitle(context);
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 8.0,
        children: [
          _buildTitle(context),
          // TODO: substitute condition with real condition
          if (size != WidgetSize.small && true) SmallChip.success(label: 'Available'),
        ],
      );
    }
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16.0,
      children: [
        _buildHeader(context),
        if (size != WidgetSize.small)
          const InfoSectionWidget(
            leftChildren: [
              LabeledInfoWidget(icon: Symbols.sports_rounded, label: 'Sport', text: 'Sport'),
              LabeledInfoWidget(icon: Symbols.payments_rounded, label: 'Price per hour', text: '00.00 €'),
            ],
            rightChildren: [
              LabeledInfoWidget(icon: Symbols.groups_rounded, label: 'Capacity', text: '00'),
              LabeledInfoWidget(
                icon: Symbols.payments_rounded,
                filledIcon: true,
                label: 'Price per hour (with light)',
                text: '00.00 €',
              ),
            ],
          ),
        SizedBox(
          width: double.infinity,
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              maxWidth: double.infinity,
              fit: OverflowBoxFit.deferToChild,
              child: _buildTimesRow(context),
            ),
          ),
        ),
        if (size != WidgetSize.small)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 4.0,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamed(AppConstants.complexInfoRoute),
                child: const Text('More info'),
              ),
              FilledButton(onPressed: () {}, child: const Text('Book court')),
            ],
          ),
      ],
    );
  }

  Widget _buildTimesRow(BuildContext context) {
    return Row(
      spacing: 4.0,
      children: times.map((time) {
        return SmallChip.alert(label: time.format(context));
      }).toList(),
    );
  }

  Widget _buildContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double imageHeight = constraints.maxHeight;
        switch (size) {
          case WidgetSize.small:
            imageHeight *= 0.5;
            break;
          case WidgetSize.medium:
            imageHeight *= 0.4;
          case WidgetSize.large:
            imageHeight *= 0.3;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                'assets/images/placeholders/court.jpg',
                width: double.infinity,
                height: imageHeight,
                fit: BoxFit.none,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: size == WidgetSize.small
                    ? ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [colorScheme.surface, colorScheme.surface.withAlpha(0)],
                            stops: [0.85, 1.0],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.dstIn,
                        child: _buildBody(context),
                      )
                    : _buildBody(context),
              ),
            ),
          ],
        );
      },
    );
  }
}
