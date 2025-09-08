import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/domain/usecases/auth_use_cases.dart';
import 'package:frontend/features/common/presentation/widgets/custom_filter_chip.dart';
import 'package:frontend/features/common/presentation/widgets/header.dart';
import 'package:frontend/features/common/presentation/widgets/image_carousel.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/common/presentation/widgets/medium_chip.dart';
import 'package:frontend/features/common/presentation/widgets/meta_data_card.dart';
import 'package:frontend/features/common/presentation/widgets/sticky_header_delegate.dart';
import 'package:frontend/features/devices/presentation/widgets/device_list_tile.dart';
import 'package:frontend/features/users/data/models/user_model.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

class CourtInfoScreen extends StatefulWidget {
  const CourtInfoScreen({super.key});

  @override
  State<CourtInfoScreen> createState() => _CourtInfoScreenState();
}

class _CourtInfoScreenState extends State<CourtInfoScreen> {
  bool _loadingError = false;

  bool _typeSelected = false;
  bool _statusSelected = false;

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

          return _buildRegularView(context);
        }

        final isAdmin = snapshot.data!;
        return isAdmin ? _buildScrollView(context) : _buildRegularView(context);
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded)),
        title: const Text('Complex details'),
      ),
      body: SafeArea(
        child: Container(
          color: colorScheme.surface,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildRegularView(BuildContext context) {
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
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded)),
        title: const Text('Court details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageCarousel(isAdmin: false),
              _buildCourtInfoSubsection(),
              const SizedBox(height: 16.0),
              _buildComplexInfoSubsection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(AppConstants.reservationClientNewRoute),
        label: const Text('Book'),
        icon: const Icon(Symbols.calendar_add_on_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
      ),
    );
  }

  Widget _buildScrollView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded)),
        title: const Text('Court details'),
        actions: [Padding(padding: const EdgeInsets.only(right: 16.0), child: MediumChip.alert('Weather'))],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: MetaDataCard(
                    id: '00000000',
                    createdAt: 'Mon, 00/00/0000, 00:00:00',
                    updatedAt: 'Mon, 00/00/0000, 00:00:00',
                  ),
                ),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: ImageCarousel(isAdmin: true)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(spacing: 16.0, children: [_buildCourtInfoSubsection(), _buildComplexInfoSubsection()]),
                ),
              ]),
            ),
            SliverPersistentHeader(
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
                          const InfoSectionWidget(
                            leftChildren: [
                              LabeledInfoWidget(icon: Symbols.tag_rounded, label: 'Number of devices', text: '00'),
                              LabeledInfoWidget(icon: Symbols.mode_off_on_rounded, label: 'Devices on', text: '00'),
                            ],
                            rightChildren: [
                              LabeledInfoWidget(
                                icon: Symbols.check_circle_rounded,
                                label: 'Normal operation',
                                text: '00',
                              ),
                              LabeledInfoWidget(icon: Symbols.cancel_rounded, label: 'Warning/Error', text: '00'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverList.separated(
              itemCount: 10,
              itemBuilder: (context, index) {
                return DeviceListTile.list(name: 'Device $index', onTap: () {});
              },
              separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
            ),
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

  Widget _buildCourtInfoSubsection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Header.subheader(subheaderText: 'CourtName', showButton: true, buttonText: 'Get directions', onPressed: () {}),
        const Text(
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis in ligula purus. Ut mattis ut dolor quis porta. Phasellus rutrum arcu tortor, sed placerat lectus vestibulum eget.',
        ),
        const SizedBox(height: 8.0),
        InfoSectionWidget(
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
      ],
    );
  }

  Widget _buildComplexInfoSubsection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.0,
      children: [
        Header.subheader(subheaderText: 'ComplexName', showButton: false),
        InfoSectionWidget(
          leftChildren: [LabeledInfoWidget(icon: Symbols.location_on_rounded, label: 'Address', text: 'C/XXXX, 00')],
          rightChildren: [LabeledInfoWidget(icon: Symbols.schedule_rounded, label: 'Schedule', text: '00:00 - 00:00')],
        ),
      ],
    );
  }
}
