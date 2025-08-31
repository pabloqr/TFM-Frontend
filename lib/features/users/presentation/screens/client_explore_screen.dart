import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/data/providers/complexes_provider.dart';
import 'package:frontend/features/complexes/presentation/widgets/complex_card_widget.dart';
import 'package:frontend/features/courts/data/models/sport_enum.dart';
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

  Widget _buildLoadedState(BuildContext context, ComplexesProvider provider) {
    return ListView.builder(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 12.0, vertical: 12.0),
      itemCount: provider.complexes.length,
      itemBuilder: (context, index) {
        final random = Random();
        List<Sport> sports = Sport.values.toList();
        sports.remove(Sport.padel);
        sports.shuffle(random);

        final complex = provider.complexes[index];
        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 358.0),
          child: ComplexCardWidget.large(
            title: complex.complexName,
            rating: (random.nextInt(5) / 2.0) + 3.0,
            sports: sports.sublist(0, random.nextInt(sports.length) + 1).toSet(),
          ),
        );
      },
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
            return _buildLoadedState(context, provider);
        }
      },
    );
  }
}
