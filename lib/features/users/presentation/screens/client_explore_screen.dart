import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/theme.dart';
import 'package:frontend/data/providers/complexes_provider.dart';
import 'package:frontend/features/complexes/presentation/widgets/complex_card_widget.dart';
import 'package:frontend/features/courts/data/models/sport_enum.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

class ClientExploreScreen extends StatefulWidget {
  const ClientExploreScreen({super.key});

  @override
  State<ClientExploreScreen> createState() => _ClientExploreScreenState();
}

class _ClientExploreScreenState extends State<ClientExploreScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ComplexesProvider? provider = context.read<ComplexesProvider?>();
      provider?.getComplexes();
      provider?.addListener(() {
        if (provider.state == ComplexesState.error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(provider.failure!.message), behavior: SnackBarBehavior.floating));
        }
      });
    });
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ComplexesProvider?>(
      builder: (context, provider, _) {
        if (provider == null) return _buildLoadingState(context);

        switch (provider.state) {
          case ComplexesState.initial:
          case ComplexesState.loading:
            return _buildLoadingState(context);
          case ComplexesState.empty:
            return const Center(child: Text('No complexes found'));
          case ComplexesState.error:
            return const Center(child: Text('Error loading complexes'));
          case ComplexesState.loaded:
            return ListView.builder(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 16.0),
              itemCount: provider.complexes.length,
              itemBuilder: (context, index) {
                final random = Random();
                List<Sport> sports = Sport.values.toList();
                sports.remove(Sport.padel);
                sports.shuffle(random);

                final complex = provider.complexes[index];
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 350.0),
                  child: ComplexCardWidget.large(
                    title: complex.complexName,
                    rating: random.nextInt(11) / 2.0,
                    sports: sports.sublist(0, random.nextInt(sports.length) + 1).toSet(),
                  ),
                );
                // return ComplexListItem(
                //   name: complex.complexName,
                //   address: 'C/XXXX, 00',
                //   sports: sports.sublist(0, random.nextInt(sports.length) + 1).map((sport) => sport.name).toList(),
                //   rating: random.nextInt(11) / 2.0,
                //   pricePerHour: 5.0,
                // );
              },
            );
        }
      },
    );
  }
}

class ComplexListItem extends StatelessWidget {
  final String name;
  final String address;
  final List<String> sports;
  final double rating;
  final double pricePerHour;

  const ComplexListItem({
    super.key,
    required this.name,
    required this.address,
    required this.sports,
    required this.rating,
    required this.pricePerHour,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Navegar a detalles del complejo
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del complejo
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.secondary]),
                  ),
                  child: Icon(Symbols.sports, color: colorScheme.onPrimary, size: 32),
                ),
              ),
              const SizedBox(width: 16),

              // Información del complejo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y disponibilidad
                    Row(
                      spacing: 8.0,
                      children: [
                        Expanded(
                          child: Text(name, style: textTheme.titleLarge, overflow: TextOverflow.fade, softWrap: false),
                        ),
                        // if (isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: MaterialTheme.success.light.colorContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Disponible',
                            style: textTheme.labelSmall?.copyWith(color: MaterialTheme.success.light.onColorContainer),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Dirección
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            address,
                            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Deportes, rating y precio
                    Row(
                      children: [
                        // Deportes
                        Expanded(
                          child: Wrap(
                            spacing: 4,
                            children: sports
                                .take(2)
                                .map(
                                  (sport) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: MaterialTheme.warning.light.colorContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      sport,
                                      style: textTheme.labelSmall?.copyWith(
                                        color: MaterialTheme.warning.light.onColorContainer,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                        // Rating
                        Row(
                          children: [
                            Icon(Symbols.star_rounded, color: colorScheme.primary),
                            const SizedBox(width: 2),
                            Text(rating.toString(), style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(width: 12),

                        // Precio
                        Text(
                          '€${pricePerHour.toInt()}/h',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
