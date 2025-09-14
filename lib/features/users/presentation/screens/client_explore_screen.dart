import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/data/providers/complexes_list_provider.dart';
import 'package:frontend/domain/usecases/courts_use_cases.dart';
import 'package:frontend/features/complexes/presentation/widgets/complex_card.dart';
import 'package:frontend/features/courts/data/models/sport_enum.dart';
import 'package:provider/provider.dart';

class ClientExploreScreen extends StatefulWidget {
  const ClientExploreScreen({super.key});

  @override
  State<ClientExploreScreen> createState() => _ClientExploreScreenState();
}

class _ClientExploreScreenState extends State<ClientExploreScreen> {
  ComplexesListProvider? _complexesProvider;
  VoidCallback? _providerListener;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _complexesProvider = context.read<ComplexesListProvider?>();

      if (_complexesProvider != null) {
        _complexesProvider!.getComplexes();

        _providerListener = () {
          if (mounted &&
              _complexesProvider != null &&
              _complexesProvider!.state == ProviderState.error &&
              _complexesProvider!.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_complexesProvider!.failure!.message), behavior: SnackBarBehavior.floating),
            );
          }
        };
        _complexesProvider!.addListener(_providerListener!);
      }
    });
  }

  @override
  void dispose() {
    if (_complexesProvider != null && _providerListener != null) {
      _complexesProvider!.removeListener(_providerListener!);
    }
    _providerListener = null;

    super.dispose();
  }

  Future<Set<Sport>> _getComplexSports(int complexId) async {
    CourtsUseCases? courtsUseCases = context.read<CourtsUseCases?>();
    if (courtsUseCases == null) return {};

    final result = await courtsUseCases.getCourts(complexId);
    return result.fold((failure) => {}, (value) => value.map((court) => court.sport).toSet());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ComplexesListProvider?>(
      builder: (context, consumerComplexProvider, _) {
        final currentProvider = consumerComplexProvider ?? _complexesProvider;

        if (currentProvider == null) return _buildLoadingState(context);

        switch (currentProvider.state) {
          case ProviderState.initial:
          case ProviderState.loading:
            if (currentProvider.complexes.isEmpty) return _buildLoadingState(context);
            return _buildLoadedState(context, currentProvider);
          case ProviderState.empty:
            return const Center(child: Text('No complexes found'));
          case ProviderState.error:
            if (currentProvider.complexes.isNotEmpty) return _buildLoadedState(context, currentProvider);
            return const Center(child: Text('Error loading complexes'));
          case ProviderState.loaded:
            return _buildLoadedState(context, currentProvider);
        }
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildLoadedState(BuildContext context, ComplexesListProvider provider) {
    return SafeArea(
      top: false,
      child: ListView.builder(
        padding: const EdgeInsetsGeometry.only(left: 12.0, right: 12.0, bottom: 12.0),
        itemCount: provider.complexes.length,
        itemBuilder: (context, index) {
          final random = Random();
          List<Sport> sports = Sport.values.toList();
          sports.remove(Sport.padel);
          sports.shuffle(random);

          return FutureBuilder(
            future: _getComplexSports(provider.complexes.elementAt(index).id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 358.0),
                  child: Container(color: Theme.of(context).colorScheme.surfaceContainer),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 358.0),
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: Center(child: Text('Error loading ${provider.complexes.elementAt(index).complexName} data')),
                  ),
                );
              }

              final sports = snapshot.data!;

              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 358.0),
                child: ComplexCard.large(
                  complex: provider.complexes.elementAt(index),
                  rating: Random().nextInt(11) / 2.0,
                  sports: sports,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
