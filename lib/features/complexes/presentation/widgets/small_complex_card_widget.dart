import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class SmallComplexCardWidget extends StatelessWidget {
  const SmallComplexCardWidget({super.key});

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
                        Text('Card Title', style: textTheme.titleLarge, overflow: TextOverflow.clip, softWrap: false),
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
                                  children: [
                                    Icon(
                                      Symbols.star_rounded,
                                      color: colorScheme.primary,
                                      size: 18,
                                      fill: 1,
                                      weight: 400,
                                      grade: 0,
                                      opticalSize: 18,
                                    ),
                                    Icon(
                                      Symbols.star_rounded,
                                      color: colorScheme.primary,
                                      size: 18,
                                      fill: 1,
                                      weight: 400,
                                      grade: 0,
                                      opticalSize: 18,
                                    ),
                                    Icon(
                                      Symbols.star_rounded,
                                      color: colorScheme.primary,
                                      size: 18,
                                      fill: 1,
                                      weight: 400,
                                      grade: 0,
                                      opticalSize: 18,
                                    ),
                                    Icon(
                                      Symbols.star_rounded,
                                      color: colorScheme.primary,
                                      size: 18,
                                      fill: 1,
                                      weight: 400,
                                      grade: 0,
                                      opticalSize: 18,
                                    ),
                                    Icon(
                                      Symbols.star_rounded,
                                      color: colorScheme.primary,
                                      size: 18,
                                      fill: 0,
                                      weight: 400,
                                      grade: 0,
                                      opticalSize: 18,
                                    ),
                                  ],
                                ),
                                Text(
                                  '4.0',
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
                          children: [
                            Icon(Symbols.sports_tennis_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
                            Icon(Symbols.sports_soccer_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
                            Icon(
                              Symbols.sports_volleyball_rounded,
                              size: 24,
                              fill: 0,
                              weight: 400,
                              grade: 0,
                              opticalSize: 24,
                            ),
                          ],
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
