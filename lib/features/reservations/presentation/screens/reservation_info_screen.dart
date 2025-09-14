import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/core/constants/theme.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/data/providers/complex_provider.dart';
import 'package:frontend/data/providers/court_provider.dart';
import 'package:frontend/data/providers/reservation_provider.dart';
import 'package:frontend/data/services/utilities.dart';
import 'package:frontend/domain/usecases/auth_use_cases.dart';
import 'package:frontend/features/common/presentation/widgets/custom_dialog.dart';
import 'package:frontend/features/common/presentation/widgets/expandable_fab.dart';
import 'package:frontend/features/common/presentation/widgets/header.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/common/presentation/widgets/meta_data_card.dart';
import 'package:frontend/features/complexes/data/models/complex_model.dart';
import 'package:frontend/features/courts/data/models/court_model.dart';
import 'package:frontend/features/reservations/data/models/reservation_model.dart';
import 'package:frontend/features/users/data/models/user_model.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

class ReservationInfoScreen extends StatefulWidget {
  final int complexId;
  final int courtId;
  final int reservationId;

  const ReservationInfoScreen({super.key, required this.complexId, required this.courtId, required this.reservationId});

  @override
  State<ReservationInfoScreen> createState() => _ReservationInfoScreenState();
}

class _ReservationInfoScreenState extends State<ReservationInfoScreen> {
  ComplexProvider? _complexProvider;
  CourtProvider? _courtProvider;
  ReservationProvider? _reservationProvider;
  VoidCallback? _providerListener;

  bool _loadingError = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _complexProvider = context.read<ComplexProvider?>();
      _courtProvider = context.read<CourtProvider?>();
      _reservationProvider = context.read<ReservationProvider?>();

      if (_complexProvider != null && _courtProvider != null && _reservationProvider != null) {
        if (_complexProvider!.state == ProviderState.initial) {
          _complexProvider!.getComplex(widget.complexId);
        }

        if (_courtProvider!.state == ProviderState.initial) {
          _courtProvider!.getCourt(widget.complexId, widget.courtId);
        }

        if (_reservationProvider!.state == ProviderState.initial) {
          _reservationProvider!.getReservation(widget.reservationId);
        }

        _providerListener = () {
          if (mounted &&
              _reservationProvider != null &&
              _reservationProvider!.state == ProviderState.error &&
              _reservationProvider!.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_reservationProvider!.failure!.message), behavior: SnackBarBehavior.floating),
            );
          }
        };
        _reservationProvider!.addListener(_providerListener!);
      }
    });
  }

  @override
  void dispose() {
    if (_reservationProvider != null && _providerListener != null) {
      _reservationProvider!.removeListener(_providerListener!);
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
    return Consumer<ReservationProvider?>(
      builder: (context, consumerProvider, _) {
        final currentProvider = consumerProvider ?? _reservationProvider;

        if (currentProvider == null) return _buildLoadingState(context);

        Widget emptyWidget = const Center(child: Text('No reservation found'));
        Widget errorWidget = const Center(child: Text('Error loading reservation'));

        switch (currentProvider.state) {
          case ProviderState.initial:
          case ProviderState.loading:
            if (currentProvider.reservation.id == -1) return _buildLoadingState(context);
            return _buildLoadedState(context, currentProvider, isAdmin);
          case ProviderState.empty:
            return _buildProvisionalScaffold(context, emptyWidget);
          case ProviderState.error:
            if (currentProvider.reservation.id != -1) {
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
        title: const Text('Reservation details'),
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

  Widget _buildLoadedState(BuildContext context, ReservationProvider reservationProvider, bool isAdmin) {
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
        title: const Text('Reservation details'),
        actions: [
          if (isAdmin) _buildStatusChip(reservationProvider.reservation),
          _buildReservationStatusChip(reservationProvider.reservation),
        ],
      ),
      body: SafeArea(child: _buildContent(context, reservationProvider.reservation, isAdmin)),
      floatingActionButton: _buildFloatingActionButton(context, isAdmin),
    );
  }

  Widget _buildStatusChip(ReservationModel reservation) {
    return Padding(padding: const EdgeInsets.only(right: 8.0), child: reservation.status.mediumStatusChip);
  }

  Widget _buildReservationStatusChip(ReservationModel reservation) {
    return Padding(padding: const EdgeInsets.only(right: 16.0), child: reservation.reservationStatus.mediumStatusChip);
  }

  Widget _buildContent(BuildContext context, ReservationModel reservation, bool isAdmin) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16.0,
        children: [
          MetaDataCard(
            id: reservation.id.toString().padLeft(8, '0'),
            createdAt: reservation.createdAt.toLocal().toFormattedString(),
            updatedAt: reservation.updatedAt.toLocal().toFormattedString(),
            additionalMetadata: isAdmin
                ? [
                    LabeledInfoWidget(
                      icon: Symbols.person_rounded,
                      label: 'Created by',
                      text: reservation.userId.toString().padLeft(8, '0'),
                    ),
                  ]
                : null,
          ),
          _buildComplexInfoSubsection(isAdmin),
          _buildCourtInfoSubsection(context, reservation),
          _buildReceiptInfoSubsection(),
        ],
      ),
    );
  }

  Widget _buildComplexInfoSubsection(bool isAdmin) {
    return Consumer<ComplexProvider?>(
      builder: (context, consumerProvider, _) {
        final currentComplexProvider = consumerProvider ?? _complexProvider;
        final validStatus = currentComplexProvider?.state == ProviderState.loaded;

        ComplexModel? complex = currentComplexProvider?.complex;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.0,
          children: [
            if (isAdmin)
              Header.subheader(
                subheaderText: !validStatus || complex == null || complex.id == -1 ? 'Complex' : complex.complexName,
                showButton: false,
              )
            else
              Header.subheader(
                subheaderText: !validStatus || complex == null || complex.id == -1 ? 'Complex' : complex.complexName,
                showButton: true,
                buttonText: 'Get directions',
                onPressed: () {},
              ),
            InfoSectionWidget(
              leftChildren: [
                if (validStatus &&
                    complex != null &&
                    complex.id != -1 &&
                    complex.locLatitude != null &&
                    complex.locLongitude != null)
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
                  text: !validStatus || complex == null || complex.id == -1
                      ? '--:-- - --:--'
                      : '${complex.timeIni} - ${complex.timeEnd}',
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCourtInfoSubsection(BuildContext context, ReservationModel reservation) {
    return Consumer<CourtProvider?>(
      builder: (context, consumerProvider, _) {
        final currentCourtProvider = consumerProvider ?? _courtProvider;
        final validStatus = currentCourtProvider?.state == ProviderState.loaded;

        CourtModel? court = currentCourtProvider?.court;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.0,
          children: [
            Header.subheader(
              subheaderText: !validStatus || court == null || court.id == -1 ? 'Court' : court.name,
              showButton: false,
            ),
            InfoSectionWidget(
              leftChildren: [
                LabeledInfoWidget(
                  icon: Symbols.sports_rounded,
                  label: 'Sport',
                  text: !validStatus || court == null || court.id == -1 ? 'Sport' : court.sport.name.toCapitalized(),
                ),
                LabeledInfoWidget(
                  icon: Symbols.groups_rounded,
                  label: 'Capacity',
                  text: !validStatus || court == null || court.id == -1 ? '--' : court.maxPeople.toString(),
                ),
              ],
              rightChildren: [
                LabeledInfoWidget(
                  icon: Symbols.calendar_month_rounded,
                  label: 'Date',
                  text: reservation.dateIni.toFormattedDate(),
                ),
                LabeledInfoWidget(
                  icon: Symbols.schedule_rounded,
                  label: 'Reservation time',
                  text: '${reservation.dateIni.toFormattedTime()} - ${reservation.dateEnd.toFormattedTime()}',
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildReceiptInfoSubsection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.0,
      children: [
        Header.subheader(subheaderText: 'Receipt', showButton: true, buttonText: 'Get full receipt', onPressed: () {}),
        InfoSectionWidget(
          leftChildren: [LabeledInfoWidget(icon: Symbols.payments_rounded, label: 'Price', text: '00.00 €')],
          rightChildren: [LabeledInfoWidget(icon: Symbols.credit_card_clock, label: 'Payment status', text: 'Paid')],
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, bool isAdmin) {
    return isAdmin
        ? FloatingActionButton.extended(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppConstants.reservationModifyRoute, arguments: {'isAdmin': true}),
            label: const Text('Modify reservation'),
            icon: const Icon(Symbols.edit_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
          )
        : ExpandableFab(
            children: [
              ActionButton(
                icon: Symbols.free_cancellation_rounded,
                label: 'Cancel reservation',
                onPressed: () {
                  final brightness = Theme.of(context).brightness;
                  final headerColor = brightness == Brightness.light
                      ? MaterialTheme.warning.light.colorContainer
                      : MaterialTheme.warning.dark.colorContainer;
                  final iconColor = brightness == Brightness.light
                      ? MaterialTheme.warning.light.onColorContainer
                      : MaterialTheme.warning.dark.onColorContainer;

                  showCustomAlertDialog(
                    context,
                    icon: Symbols.warning_rounded,
                    headline: 'Cancel reservation?',
                    supportingText:
                        'You\'re about to cancel your reservation. This action is cost free but irreversible,',
                    headerColor: headerColor,
                    iconColor: iconColor,
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Go back')),
                      TextButton(
                        onPressed: () {
                          // TODO: Cancel reservation
                        },
                        child: const Text('Yes, cancel'),
                      ),
                    ],
                  );
                },
              ),
              ActionButton(
                icon: Symbols.edit_calendar_rounded,
                label: 'Modify reservation',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppConstants.reservationModifyRoute, arguments: {'isAdmin': false}),
              ),
            ],
          );
  }
}
