import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/data/services/utilities.dart';
import 'package:frontend/features/common/data/models/widget_size.dart';
import 'package:frontend/features/common/presentation/widgets/small_chip.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/complexes/data/models/complex_model.dart';
import 'package:frontend/features/courts/data/models/sport_enum.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ComplexCard extends StatelessWidget {
  final WidgetSize size;

  final ComplexModel complex;
  final double rating;
  final Set<Sport> sports;

  final int? index;
  final ValueNotifier<int> selectedIndex;

  const ComplexCard._(
    this.size, {
    required this.complex,
    required this.rating,
    required this.sports,
    this.index,
    required this.selectedIndex,
  });

  factory ComplexCard.small({
    required ComplexModel complex,
    required double rating,
    required Set<Sport> sports,
    int? index,
    ValueNotifier<int>? selectedIndex,
  }) {
    ValueNotifier<int> notifier = selectedIndex ?? ValueNotifier<int>(-1);
    return ComplexCard._(
      WidgetSize.small,
      complex: complex,
      rating: rating,
      sports: sports,
      index: index,
      selectedIndex: notifier,
    );
  }

  factory ComplexCard.medium({
    required ComplexModel complex,
    required double rating,
    required Set<Sport> sports,
    int? index,
    ValueNotifier<int>? selectedIndex,
  }) {
    ValueNotifier<int> notifier = selectedIndex ?? ValueNotifier<int>(-1);
    return ComplexCard._(
      WidgetSize.medium,
      complex: complex,
      rating: rating,
      sports: sports,
      index: index,
      selectedIndex: notifier,
    );
  }

  factory ComplexCard.large({
    required ComplexModel complex,
    required double rating,
    required Set<Sport> sports,
    int? index,
    ValueNotifier<int>? selectedIndex,
  }) {
    ValueNotifier<int> notifier = selectedIndex ?? ValueNotifier<int>(-1);
    return ComplexCard._(
      WidgetSize.large,
      complex: complex,
      rating: rating,
      sports: sports,
      index: index,
      selectedIndex: notifier,
    );
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(complex.complexName, style: textTheme.titleLarge, softWrap: false),
        const SizedBox(height: 4.0),
        ClipRect(
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            maxWidth: double.infinity,
            fit: OverflowBoxFit.deferToChild,
            child: Row(
              spacing: 4.0,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    IconData icon = Symbols.star_rounded;
                    double iconFill = 0.0;

                    if (rating >= index + 0.5) {
                      iconFill = 1.0;
                      icon = rating >= index + 1 ? icon : Symbols.star_half_rounded;
                    }

                    return Icon(
                      icon,
                      color: colorScheme.primary,
                      size: 18,
                      fill: iconFill,
                      weight: 400,
                      grade: 0,
                      opticalSize: 18,
                    );
                  }),
                ),
                Text(
                  rating.toString(),
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
                  softWrap: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
          InfoSectionWidget(
            leftChildren: [LabeledInfoWidget(icon: Symbols.location_on_rounded, label: 'Address', text: 'C/XXXX, 00')],
            rightChildren: [
              LabeledInfoWidget(
                icon: Symbols.schedule_rounded,
                label: 'Schedule',
                text: '${complex.timeIni} - ${complex.timeEnd}',
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
              child: _buildSportsRow(context),
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
              FilledButton(
                onPressed: () => Navigator.of(context).pushNamed(AppConstants.reservationClientNewRoute),
                child: const Text('Book court'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSportsRow(BuildContext context) {
    return Row(
      spacing: 4.0,
      children: sports.map((sport) {
        // return Icon(sport.icon, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24);
        return SmallChip.alert(label: sport.name.toCapitalized());
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
