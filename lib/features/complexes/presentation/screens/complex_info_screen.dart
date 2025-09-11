import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/data/providers/complex_provider.dart';
import 'package:frontend/data/providers/courts_provider.dart';
import 'package:frontend/data/services/utilities.dart';
import 'package:frontend/domain/usecases/auth_use_cases.dart';
import 'package:frontend/features/common/presentation/widgets/custom_filter_chip.dart';
import 'package:frontend/features/common/presentation/widgets/fake_item.dart';
import 'package:frontend/features/common/presentation/widgets/header.dart';
import 'package:frontend/features/common/presentation/widgets/image_carousel.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/common/presentation/widgets/meta_data_card.dart';
import 'package:frontend/features/common/presentation/widgets/sticky_header_delegate.dart';
import 'package:frontend/features/courts/data/models/court_model.dart';
import 'package:frontend/features/courts/presentation/widgets/court_list_tile.dart';
import 'package:frontend/features/users/data/models/user_model.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

class ComplexInfoScreen extends StatefulWidget {
  const ComplexInfoScreen({super.key});

  @override
  State<ComplexInfoScreen> createState() => _ComplexInfoScreenState();
}

class _ComplexInfoScreenState extends State<ComplexInfoScreen> {
  ComplexProvider? _complexProvider;
  CourtsProvider? _courtsProvider;
  VoidCallback? _providerListener;

  bool _loadingError = false;

  bool _sportSelected = false;
  bool _capacitySelected = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _complexProvider = context.read<ComplexProvider?>();
      _courtsProvider = context.read<CourtsProvider?>();

      if (_complexProvider != null && _courtsProvider != null) {
        if (_complexProvider!.state == ProviderState.initial) {
          _complexProvider!.getComplex(1);
        }

        if (_courtsProvider!.state == ProviderState.initial) {
          // TODO: Cange complex ID to real ID
          _courtsProvider!.getCourts(1);
        }

        _providerListener = () {
          if (mounted &&
              _complexProvider != null &&
              _complexProvider!.state == ProviderState.error &&
              _complexProvider!.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_complexProvider!.failure!.message), behavior: SnackBarBehavior.floating),
            );
          }

          if (mounted &&
              _courtsProvider != null &&
              _courtsProvider!.state == ProviderState.error &&
              _courtsProvider!.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_courtsProvider!.failure!.message), behavior: SnackBarBehavior.floating),
            );
          }
        };
        _complexProvider!.addListener(_providerListener!);
        _courtsProvider!.addListener(_providerListener!);
      }
    });
  }

  @override
  void dispose() {
    if (_complexProvider != null && _providerListener != null) {
      _complexProvider!.removeListener(_providerListener!);
    }
    if (_courtsProvider != null && _providerListener != null) {
      _courtsProvider!.removeListener(_providerListener!);
    }
    _providerListener = null;

    super.dispose();
  }

  Future<bool> _checkIfUserIsAdmin() async {
    final authUseCases = context.read<AuthUseCases?>();

    if (authUseCases == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _loadingError = true);
        }
      });

      return false;
    }

    final result = await authUseCases.getAuthenticatedUser();
    return result.fold((error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _loadingError = true);
        }
      });

      return false;
    }, (user) => user.role == Role.admin || user.role == Role.superadmin);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ComplexProvider?>(
      builder: (context, consumerProvider, _) {
        final currentProvider = consumerProvider ?? _complexProvider;

        if (currentProvider == null) return _buildLoadingState(context, true);

        switch (currentProvider.state) {
          case ProviderState.initial:
          case ProviderState.loading:
            if (currentProvider.complex.id == -1) return _buildLoadingState(context, true);
            return _buildLoadedState(context, currentProvider);
          case ProviderState.empty:
            return const Center(child: Text('No complexes found'));
          case ProviderState.error:
            if (currentProvider.complex.id != -1) {
              return _buildLoadedState(context, currentProvider);
            }
            return const Center(child: Text('Error loading complexes'));
          case ProviderState.loaded:
            return _buildLoadedState(context, currentProvider);
        }
      },
    );
  }

  Widget _buildLoadingState(BuildContext context, bool buildScaffold) {
    final colorScheme = Theme.of(context).colorScheme;
    Widget loadingWidget = Container(
      color: colorScheme.surface,
      child: Center(child: CircularProgressIndicator()),
    );

    return buildScaffold
        ? Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              title: const Text('Complex details'),
            ),
            body: SafeArea(child: loadingWidget),
          )
        : loadingWidget;
  }

  Widget _buildLoadedState(BuildContext context, ComplexProvider complexProvider) {
    return FutureBuilder<bool>(
      future: _checkIfUserIsAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(context, true);
        }

        if (snapshot.hasError || !snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _loadingError = true);
            }
          });

          return _buildScaffold(context, complexProvider, false);
        }

        final isAdmin = snapshot.data!;
        return _buildScaffold(context, complexProvider, isAdmin);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, ComplexProvider complexProvider, bool isAdmin) {
    if (_loadingError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load user data. Continuing with limited information.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }

    return isAdmin
        ? _buildContent(context, complexProvider, isAdmin)
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              title: const Text('Complex details'),
            ),
            body: _buildContent(context, complexProvider, isAdmin),
            floatingActionButton: _buildFloatingActionButton(context, isAdmin),
          );
  }

  Widget _buildContent(BuildContext context, ComplexProvider complexProvider, bool isAdmin) {
    return SafeArea(
      top: false,
      child: CustomScrollView(
        primary: !isAdmin,
        slivers: [
          _buildHeader(context, complexProvider, isAdmin),
          _buildPinnedHeader(context, isAdmin),
          _buildScrollableList(context, isAdmin),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ComplexProvider complexProvider, bool isAdmin) {
    final complex = complexProvider.complex;

    return SliverList(
      delegate: SliverChildListDelegate([
        if (isAdmin)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0),
            child: MetaDataCard(
              id: '00000000',
              createdAt: 'Mon, 00/00/0000, 00:00:00',
              updatedAt: 'Mon, 00/00/0000, 00:00:00',
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ImageCarousel(isAdmin: isAdmin),
        ),
        const SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8.0,
            children: [
              if (isAdmin)
                Header.subheader(subheaderText: 'ComplexName', showButton: false)
              else
                Header.subheader(
                  subheaderText: 'ComplexName',
                  showButton: true,
                  buttonText: 'Get directions',
                  onPressed: () {},
                ),
              InfoSectionWidget(
                leftChildren: [
                  if (complex.locLatitude != null && complex.locLongitude != null)
                    FutureBuilder(
                      future: WidgetUtilities.getAddressFromLatLng(complex.locLatitude!, complex.locLongitude!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting ||
                            snapshot.hasError ||
                            !snapshot.hasData) {
                          return LabeledInfoWidget(
                            icon: Symbols.location_on_rounded,
                            label: 'Address',
                            text: 'C/XXXXXXXX XXXXXXXX, 00',
                          );
                        }

                        final address = snapshot.data!;
                        return LabeledInfoWidget(icon: Symbols.location_on_rounded, label: 'Address', text: address);
                      },
                    )
                  else
                    LabeledInfoWidget(
                      icon: Symbols.location_on_rounded,
                      label: 'Address',
                      text: 'C/XXXXXXXX XXXXXXXX, 00',
                    ),
                ],
                rightChildren: [
                  LabeledInfoWidget(
                    icon: Symbols.schedule_rounded,
                    label: 'Schedule',
                    text: '${complexProvider.complex.timeIni} - ${complexProvider.complex.timeEnd}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildPinnedHeader(BuildContext context, bool isAdmin) {
    return Consumer<CourtsProvider?>(
      builder: (context, consumerCourtsProvider, _) {
        final currentCourtsProvider = consumerCourtsProvider ?? _courtsProvider;

        final nullProvider = currentCourtsProvider == null;
        final validStatus = currentCourtsProvider?.state == ProviderState.loaded;

        List<CourtModel> courts = currentCourtsProvider?.courts ?? [];
        final maxCapacity = courts.fold<int>(0, (prev, court) => court.maxPeople > prev ? court.maxPeople : prev);
        final minCapacity = courts.fold<int>(
          maxCapacity,
          (prev, court) => court.maxPeople < prev ? court.maxPeople : prev,
        );

        return SliverPersistentHeader(
          pinned: true,
          delegate: StickyHeaderDelegate(
            minHeight: isAdmin ? 184.0 : 171.0,
            maxHeight: isAdmin ? 184.0 : 171.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                spacing: 16.0,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isAdmin)
                        Header.subheader(
                          subheaderText: 'Courts',
                          showButton: true,
                          buttonText: 'Manage courts',
                          onPressed: () {},
                        )
                      else
                        Header.subheader(subheaderText: 'Courts', showButton: false),
                      if (!isAdmin) const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 8.0,
                        children: [
                          CustomFilterChip.dropDown('Sport', _sportSelected, (selected) {
                            setState(() => _sportSelected = selected);
                          }),
                          CustomFilterChip.dropDown('Capacity', _capacitySelected, (selected) {
                            setState(() => _capacitySelected = selected);
                          }),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      InfoSectionWidget(
                        leftChildren: [
                          LabeledInfoWidget(
                            icon: Symbols.tag_rounded,
                            label: 'Number of courts',
                            text: nullProvider || !validStatus || courts.isEmpty
                                ? '--'
                                : courts.length.toString().padLeft(2, '0'),
                          ),
                          LabeledInfoWidget(icon: Symbols.payments_rounded, label: 'Price per hour', text: '00.00 €'),
                        ],
                        rightChildren: [
                          LabeledInfoWidget(
                            icon: Symbols.groups_rounded,
                            label: 'Capacity',
                            text: nullProvider || !validStatus || courts.isEmpty
                                ? '--'
                                : '${minCapacity.toString().padLeft(2, '0')} - ${maxCapacity.toString().padLeft(2, '0')}',
                          ),
                          LabeledInfoWidget(
                            icon: Symbols.payments_rounded,
                            filledIcon: true,
                            label: 'Price per hour (with light)',
                            text: '00.00 €',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScrollableList(BuildContext context, bool isAdmin) {
    return Consumer<CourtsProvider?>(
      builder: (context, consumerCourtsProvider, _) {
        final currentCourtsProvider = consumerCourtsProvider ?? _courtsProvider;

        if (currentCourtsProvider == null) return _buildLoadingListTile(context);

        List<CourtModel> courts = currentCourtsProvider.courts;

        switch (currentCourtsProvider.state) {
          case ProviderState.initial:
          case ProviderState.loading:
            if (courts.isEmpty) return _buildLoadingListTile(context);
            return _buildListTile(context, courts, isAdmin);
          case ProviderState.empty:
            return const Center(child: Text('No complexes found'));
          case ProviderState.error:
            if (courts.isNotEmpty) {
              return _buildListTile(context, courts, isAdmin);
            }
            return const Center(child: Text('Error loading complexes'));
          case ProviderState.loaded:
            return _buildListTile(context, courts, isAdmin);
        }
      },
    );
  }

  Widget _buildLoadingListTile(BuildContext context) {
    return SliverList.separated(
      itemCount: 1,
      itemBuilder: (context, index) {
        return FakeItem(isBig: true);
      },
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
    );
  }

  Widget _buildListTile(BuildContext context, List<CourtModel> courts, bool isAdmin) {
    return SliverList.separated(
      itemCount: courts.length,
      itemBuilder: (context, index) {
        return CourtListTile.list(
          court: courts.elementAt(index),
          onTap: () => Navigator.of(context).pushNamed(AppConstants.courtInfoRoute),
          isAdmin: isAdmin,
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, bool isAdmin) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.of(context).pushNamed(AppConstants.reservationClientNewRoute),
      label: const Text('Book'),
      icon: const Icon(Symbols.calendar_add_on_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
    );
  }
}
