import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/data/providers/complex_provider.dart';
import 'package:frontend/data/providers/court_provider.dart';
import 'package:frontend/data/providers/devices_list_provider.dart';
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
import 'package:frontend/features/complexes/data/models/complex_model.dart';
import 'package:frontend/features/courts/data/models/court_model.dart';
import 'package:frontend/features/devices/data/models/device_model.dart';
import 'package:frontend/features/devices/presentation/widgets/device_list_tile.dart';
import 'package:frontend/features/users/data/models/user_model.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

class CourtInfoScreen extends StatefulWidget {
  final int complexId;
  final int courtId;

  const CourtInfoScreen({super.key, required this.complexId, required this.courtId});

  @override
  State<CourtInfoScreen> createState() => _CourtInfoScreenState();
}

class _CourtInfoScreenState extends State<CourtInfoScreen> {
  ComplexProvider? _complexProvider;
  CourtProvider? _courtProvider;
  DevicesListProvider? _devicesListProvider;
  VoidCallback? _providerListener;

  bool _loadingError = false;

  bool _typeSelected = false;
  bool _statusSelected = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _complexProvider = context.read<ComplexProvider?>();
      _courtProvider = context.read<CourtProvider?>();
      _devicesListProvider = context.read<DevicesListProvider?>();

      if (_complexProvider != null && _courtProvider != null && _devicesListProvider != null) {
        if (_complexProvider!.state == ProviderState.initial) {
          _complexProvider!.getComplex(widget.complexId);
        }

        if (_courtProvider!.state == ProviderState.initial) {
          _courtProvider!.getCourt(widget.complexId, widget.courtId);
        }

        if (_devicesListProvider!.state == ProviderState.initial) {
          _devicesListProvider!.getCourtDevices(widget.complexId, widget.courtId);
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
              _courtProvider != null &&
              _courtProvider!.state == ProviderState.error &&
              _courtProvider!.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_courtProvider!.failure!.message), behavior: SnackBarBehavior.floating),
            );
          }

          if (mounted &&
              _devicesListProvider != null &&
              _devicesListProvider!.state == ProviderState.error &&
              _devicesListProvider!.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_devicesListProvider!.failure!.message), behavior: SnackBarBehavior.floating),
            );
          }
        };
        _complexProvider!.addListener(_providerListener!);
        _courtProvider!.addListener(_providerListener!);
        _devicesListProvider!.addListener(_providerListener!);
      }
    });
  }

  @override
  void dispose() {
    if (_complexProvider != null && _providerListener != null) {
      _complexProvider!.removeListener(_providerListener!);
    }
    if (_courtProvider != null && _providerListener != null) {
      _courtProvider!.removeListener(_providerListener!);
    }
    if (_devicesListProvider != null && _providerListener != null) {
      _devicesListProvider!.removeListener(_providerListener!);
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
    return FutureBuilder<bool>(
      future: _checkIfUserIsAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(context);
        }

        if (snapshot.hasError || !snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _loadingError = true);
            }
          });

          return _buildConsumer(context, false);
        }

        final isAdmin = snapshot.data!;
        return _buildConsumer(context, isAdmin);
      },
    );
  }

  Widget _buildConsumer(BuildContext context, bool isAdmin) {
    return Consumer<CourtProvider?>(
      builder: (context, consumerProvider, _) {
        final currentProvider = consumerProvider ?? _courtProvider;

        if (currentProvider == null) return _buildLoadingState(context);

        Widget emptyWidget = const Center(child: Text('No court found'));
        Widget errorWidget = const Center(child: Text('Error loading court'));

        switch (currentProvider.state) {
          case ProviderState.initial:
          case ProviderState.loading:
            if (currentProvider.court.id == -1) return _buildLoadingState(context);
            return _buildLoadedState(context, currentProvider, isAdmin);
          case ProviderState.empty:
            return _buildProvisionalScaffold(context, emptyWidget);
          case ProviderState.error:
            if (currentProvider.court.id != -1) {
              return _buildLoadedState(context, currentProvider, isAdmin);
            }
            return _buildProvisionalScaffold(context, errorWidget);
          case ProviderState.loaded:
            return _buildLoadedState(context, currentProvider, isAdmin);
        }
      },
    );
  }

  Widget _buildProvisionalScaffold(BuildContext context, Widget body) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded)),
        title: const Text('Court details'),
      ),
      body: SafeArea(top: false, child: body),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Widget loadingWidget = Container(
      color: colorScheme.surface,
      child: Center(child: CircularProgressIndicator()),
    );

    return _buildProvisionalScaffold(context, loadingWidget);
  }

  Widget _buildLoadedState(BuildContext context, CourtProvider courtProvider, bool isAdmin) {
    return isAdmin ? _buildScrollView(context, courtProvider) : _buildRegularView(context, courtProvider);
  }

  Widget _buildRegularView(BuildContext context, CourtProvider courtProvider) {
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

    return Scaffold(
      appBar: _buildAppBar(courtProvider.court),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageCarousel(isAdmin: false),
              _buildCourtInfoSubsection(courtProvider.court, false),
              const SizedBox(height: 16.0),
              _buildComplexInfoSubsection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.of(context).pushNamed(AppConstants.reservationNewRoute, arguments: {'isAdmin': false}),
        label: const Text('Book'),
        icon: const Icon(Symbols.calendar_add_on_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
      ),
    );
  }

  Widget _buildScrollView(BuildContext context, CourtProvider courtProvider) {
    final court = courtProvider.court;

    return Scaffold(
      appBar: _buildAppBar(court),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: MetaDataCard(
                    id: court.id.toString().padLeft(8, '0'),
                    createdAt: court.createdAt.toFormattedString(),
                    updatedAt: court.updatedAt.toFormattedString(),
                  ),
                ),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: ImageCarousel(isAdmin: true)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    spacing: 16.0,
                    children: [_buildCourtInfoSubsection(court, true), _buildComplexInfoSubsection()],
                  ),
                ),
              ]),
            ),
            _buildPinnedHeader(context),
            _buildScrollableList(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add logic to edit court info
        },
        label: Text('Edit court'),
        icon: const Icon(Symbols.edit_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(CourtModel court) {
    return AppBar(
      leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded)),
      title: const Text('Court details'),
      actions: _buildAppBarActions(court),
    );
  }

  List<Widget> _buildAppBarActions(CourtModel court) {
    return [_buildStatusChip(court)];
  }

  Widget _buildStatusChip(CourtModel court) {
    return Padding(padding: const EdgeInsets.only(right: 16.0), child: court.status.mediumStatusChip);
  }

  Widget _buildCourtInfoSubsection(CourtModel court, bool isAdmin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isAdmin) ...[
          const SizedBox(height: 16.0),
          Header.subheader(subheaderText: court.name, showButton: false, onPressed: () {}),
        ] else
          Header.subheader(subheaderText: court.name, showButton: true, buttonText: 'Get directions', onPressed: () {}),
        Text(court.description),
        const SizedBox(height: 8.0),
        InfoSectionWidget(
          leftChildren: [
            LabeledInfoWidget(icon: Symbols.sports_rounded, label: 'Sport', text: court.sport.name.toCapitalized()),
            LabeledInfoWidget(icon: Symbols.payments_rounded, label: 'Price per hour', text: '00.00 €'),
          ],
          rightChildren: [
            LabeledInfoWidget(
              icon: Symbols.groups_rounded,
              label: 'Capacity',
              text: court.maxPeople.toString().padLeft(2, '0'),
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
    );
  }

  Widget _buildComplexInfoSubsection() {
    return Consumer<ComplexProvider?>(
      builder: (context, consumerProvider, _) {
        final currentProvider = consumerProvider ?? _complexProvider;

        final nullProvider = currentProvider == null;
        final validStatus = currentProvider?.state == ProviderState.loaded;

        ComplexModel? complex = currentProvider?.complex;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.0,
          children: [
            Header.subheader(
              subheaderText: nullProvider || !validStatus || complex == null ? 'Complex' : complex.complexName,
              showButton: false,
            ),
            InfoSectionWidget(
              leftChildren: [
                if (nullProvider || !validStatus || complex == null)
                  LabeledInfoWidget(
                    icon: Symbols.location_on_rounded,
                    label: 'Address',
                    text: 'C/XXXXXXXX XXXXXXXX, 00',
                  )
                else
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
                  ),
              ],
              rightChildren: [
                LabeledInfoWidget(
                  icon: Symbols.schedule_rounded,
                  label: 'Schedule',
                  text: nullProvider || !validStatus || complex == null
                      ? '00:00 - 00:00'
                      : '${complex.timeIni} - ${complex.timeEnd}',
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildPinnedHeader(BuildContext context) {
    return Consumer<DevicesListProvider?>(
      builder: (context, consumerProvider, _) {
        final currentProvider = consumerProvider ?? _devicesListProvider;
        final validStatus = currentProvider?.state == ProviderState.loaded;

        List<DeviceModel> devices = currentProvider?.devices ?? [];
        final devicesOn = devices.fold<int>(0, (prev, device) => device.status != DeviceStatus.off ? prev + 1 : prev);
        final devicesNormal = devices.fold<int>(
          0,
          (prev, device) => device.status == DeviceStatus.normal ? prev + 1 : prev,
        );
        final devicesWarning = devices.fold<int>(
          0,
          (prev, device) =>
              device.status == DeviceStatus.battery || device.status == DeviceStatus.error ? prev + 1 : prev,
        );

        return SliverPersistentHeader(
          pinned: true,
          delegate: StickyHeaderDelegate(
            minHeight: 184.0,
            maxHeight: 184.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                spacing: 16.0,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Header.subheader(
                        subheaderText: 'Devices',
                        showButton: true,
                        buttonText: 'Manage devices',
                        onPressed: () {},
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 8.0,
                        children: [
                          CustomFilterChip.dropDown('Type', _typeSelected, (selected) {
                            setState(() => _typeSelected = selected);
                          }),
                          CustomFilterChip.dropDown('Status', _statusSelected, (selected) {
                            setState(() => _statusSelected = selected);
                          }),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      InfoSectionWidget(
                        leftChildren: [
                          LabeledInfoWidget(
                            icon: Symbols.tag_rounded,
                            label: 'Number of devices',
                            text: !validStatus || devices.isEmpty ? '--' : devices.length.toString().padLeft(2, '0'),
                          ),
                          LabeledInfoWidget(
                            icon: Symbols.mode_off_on_rounded,
                            label: 'Devices on',
                            text: !validStatus || devices.isEmpty ? '--' : devicesOn.toString().padLeft(2, '0'),
                          ),
                        ],
                        rightChildren: [
                          LabeledInfoWidget(
                            icon: Symbols.check_circle_rounded,
                            label: 'Normal operation',
                            text: !validStatus || devices.isEmpty ? '--' : devicesNormal.toString().padLeft(2, '0'),
                          ),
                          LabeledInfoWidget(
                            icon: Symbols.cancel_rounded,
                            label: 'Warning/Error',
                            text: !validStatus || devices.isEmpty ? '--' : devicesWarning.toString().padLeft(2, '0'),
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

  Widget _buildScrollableList(BuildContext context) {
    return Consumer<DevicesListProvider?>(
      builder: (context, consumerProvider, _) {
        final currentProvider = consumerProvider ?? _devicesListProvider;

        if (currentProvider == null) return _buildLoadingListTile(context);

        List<DeviceModel> devices = currentProvider.devices;

        switch (currentProvider.state) {
          case ProviderState.initial:
          case ProviderState.loading:
            if (devices.isEmpty) return _buildLoadingListTile(context);
            return _buildListTile(context, devices);
          case ProviderState.empty:
            return _buildErrorListTile(context);
          case ProviderState.error:
            if (devices.isNotEmpty) {
              return _buildListTile(context, devices);
            }
            return _buildErrorListTile(context);
          case ProviderState.loaded:
            return _buildListTile(context, devices);
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

  Widget _buildErrorListTile(BuildContext context) {
    return SliverList.separated(
      itemCount: 1,
      itemBuilder: (context, index) {
        return const Center(heightFactor: 4.0, child: Text('Error loading complexes'));
      },
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
    );
  }

  Widget _buildListTile(BuildContext context, List<DeviceModel> devices) {
    return SliverList.separated(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        return DeviceListTile.list(
          device: devices.elementAt(index),
          // TODO: Add device view navigation
          onTap: () => Navigator.of(context).pushNamed(AppConstants.courtInfoRoute),
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
    );
  }
}
