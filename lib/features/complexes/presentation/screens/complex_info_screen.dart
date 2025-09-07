import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/domain/usecases/auth_use_cases.dart';
import 'package:frontend/features/common/presentation/widgets/custom_filter_chip.dart';
import 'package:frontend/features/common/presentation/widgets/image_carousel.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/common/presentation/widgets/meta_data_card.dart';
import 'package:frontend/features/common/presentation/widgets/sticky_header_delegate.dart';
import 'package:frontend/features/common/presentation/widgets/header.dart';
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
  bool _loadingError = false;

  bool _sportSelected = false;
  bool _capacitySelected = false;

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

          return _buildScaffold(context, false);
        }

        final isAdmin = snapshot.data!;
        return _buildScaffold(context, isAdmin);
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

  Widget _buildScaffold(BuildContext context, bool isAdmin) {
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
        ? _buildContent(context, isAdmin)
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              title: const Text('Complex details'),
            ),
            body: _buildContent(context, isAdmin),
            floatingActionButton: _buildFloatingActionButton(context, isAdmin),
          );
  }

  Widget _buildContent(BuildContext context, bool isAdmin) {
    return SafeArea(
      top: false,
      child: CustomScrollView(
        primary: !isAdmin,
        slivers: [
          _buildHeader(context, isAdmin),
          _buildPinnedHeader(context, isAdmin),
          _buildScrollableList(context, isAdmin),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isAdmin) {
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
                  LabeledInfoWidget(icon: Symbols.location_on_rounded, label: 'Address', text: 'C/XXXX, 00'),
                ],
                rightChildren: [
                  LabeledInfoWidget(icon: Symbols.schedule_rounded, label: 'Schedule', text: '00:00 - 00:00'),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildPinnedHeader(BuildContext context, bool isAdmin) {
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
                  const InfoSectionWidget(
                    leftChildren: [
                      LabeledInfoWidget(icon: Symbols.tag_rounded, label: 'Number of courts', text: '00'),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableList(BuildContext context, bool isAdmin) {
    return SliverList.separated(
      itemCount: 10,
      itemBuilder: (context, index) {
        return CourtListTile.telemetry(
          name: 'Court $index',
          onTap: () => Navigator.of(context).pushNamed(AppConstants.courtInfoRoute),
          isAdmin: isAdmin,
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, bool isAdmin) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.of(context).pushNamed(AppConstants.reservationNewRoute),
      label: const Text('Book'),
      icon: const Icon(Symbols.calendar_add_on_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
    );
  }
}
