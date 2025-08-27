import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:frontend/features/courts/data/models/sport_enum.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class SmallComplexCardWidget extends StatelessWidget {
  final String title;
  final double rating;
  final Set<Sport> sports;

  const SmallComplexCardWidget({super.key, required this.title, required this.rating, required this.sports});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card.filled(
      margin: EdgeInsetsGeometry.zero,
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final imageHeight = constraints.maxHeight * 0.5;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16.0,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: textTheme.titleLarge, overflow: TextOverflow.clip, softWrap: false),
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
                                  overflow: TextOverflow.clip,
                                  softWrap: false,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.centerLeft,
                        maxWidth: double.infinity,
                        fit: OverflowBoxFit.deferToChild,
                        child: Row(
                          spacing: 8.0,
                          children: sports.map((sport) {
                            return Icon(
                              sport.icon,
                              size: 24,
                              fill: 0,
                              weight: 400,
                              grade: 0,
                              opticalSize: 24,
                            );
                          }).toList(),
                          // children: [
                          //   Icon(
                          //     Symbols.sports_tennis_rounded,
                          //     size: 24,
                          //     fill: 0,
                          //     weight: 400,
                          //     grade: 0,
                          //     opticalSize: 24,
                          //   ),
                          //   Icon(
                          //     Symbols.sports_soccer_rounded,
                          //     size: 24,
                          //     fill: 0,
                          //     weight: 400,
                          //     grade: 0,
                          //     opticalSize: 24,
                          //   ),
                          //   Icon(
                          //     Symbols.sports_volleyball_rounded,
                          //     size: 24,
                          //     fill: 0,
                          //     weight: 400,
                          //     grade: 0,
                          //     opticalSize: 24,
                          //   ),
                          // ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
