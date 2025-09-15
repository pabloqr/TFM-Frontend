import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/data/providers/complex_provider.dart';
import 'package:frontend/data/providers/court_provider.dart';
import 'package:frontend/data/services/utilities.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/common/presentation/widgets/marquee_widget.dart';
import 'package:frontend/features/reservations/data/models/reservation_model.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

class ReservationCard extends StatefulWidget {
  final ReservationModel? reservation;

  const ReservationCard({super.key, required this.reservation});

  @override
  State<ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends State<ReservationCard> {
  ComplexProvider? _complexProvider;
  CourtProvider? _courtProvider;
  VoidCallback? _providerListener;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _complexProvider = context.read<ComplexProvider?>();
      _courtProvider = context.read<CourtProvider?>();

      if (_complexProvider != null) {
        if (widget.reservation != null) _complexProvider!.getComplex(widget.reservation!.complexId);
        if (widget.reservation != null) {
          _courtProvider!.getCourt(widget.reservation!.complexId, widget.reservation!.courtId);
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
        };
        _complexProvider!.addListener(_providerListener!);
        _courtProvider!.addListener(_providerListener!);
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
    _providerListener = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card.filled(
      margin: const EdgeInsets.all(4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16.0,
          children: [
            Consumer<ComplexProvider?>(
              builder: (context, consumerProvider, _) {
                final currentProvider = consumerProvider ?? _complexProvider;
                final validStatus = currentProvider?.state == ProviderState.loaded;
                final complex = currentProvider?.complex;

                return Row(
                  spacing: 8.0,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4.0,
                        children: [
                          Text(
                            validStatus && complex != null ? complex.complexName : 'Complex',
                            style: textTheme.titleLarge,
                          ),
                          if (validStatus &&
                              complex != null &&
                              complex.locLatitude != null &&
                              complex.locLongitude != null)
                            FutureBuilder(
                              future: WidgetUtilities.getAddressFromLatLng(complex.locLatitude!, complex.locLongitude!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting ||
                                    snapshot.hasError ||
                                    !snapshot.hasData) {
                                  return MarqueeWidget(
                                    child: Text(
                                      'C/XXXXXXXX, XXXXXXXX, XXXXXXXX, 00',
                                      style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                      overflow: TextOverflow.fade,
                                    ),
                                  );
                                }

                                final address = snapshot.data!;
                                return MarqueeWidget(
                                  child: Text(
                                    address,
                                    style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                    overflow: TextOverflow.fade,
                                  ),
                                );
                              },
                            )
                          else
                            MarqueeWidget(
                              child: Text(
                                'C/XXXXXXXX, XXXXXXXX, XXXXXXXX, 00',
                                style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                overflow: TextOverflow.fade,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (widget.reservation != null) widget.reservation!.reservationStatus.mediumStatusChip,
                  ],
                );
              },
            ),
            Consumer<CourtProvider?>(
              builder: (context, consumerProvider, _) {
                final currentProvider = consumerProvider ?? _courtProvider;
                final validStatus = currentProvider?.state == ProviderState.loaded;
                final court = currentProvider?.court;

                return InfoSectionWidget(
                  leftChildren: [
                    LabeledInfoWidget(
                      icon: Symbols.location_on_rounded,
                      label: 'Court',
                      text: validStatus && court != null ? court.name : 'Court',
                    ),
                    LabeledInfoWidget(
                      icon: Symbols.sports_rounded,
                      label: 'Sport',
                      text: validStatus && court != null ? court.sport.name.toCapitalized() : 'Sport',
                    ),
                  ],
                  rightChildren: [
                    LabeledInfoWidget(
                      icon: Symbols.calendar_month_rounded,
                      label: 'Date',
                      text: widget.reservation != null ? widget.reservation!.dateIni.toFormattedDate() : '--/--/----',
                    ),
                    LabeledInfoWidget(
                      icon: Symbols.schedule_rounded,
                      label: 'Time',
                      text: widget.reservation != null
                          ? '${widget.reservation!.dateIni.toFormattedTime()} - ${widget.reservation!.dateEnd.toFormattedTime()}'
                          : '--:-- - --:--',
                    ),
                  ],
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 4.0,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppConstants.reservationInfoRoute,
                    arguments: {
                      'complexId': widget.reservation?.complexId ?? 0,
                      'courtId': widget.reservation?.courtId ?? 0,
                      'reservationId': widget.reservation?.id ?? 0,
                    },
                  ),
                  child: const Text('More info'),
                ),
                if (widget.reservation != null &&
                    (widget.reservation!.reservationStatus == ReservationStatus.scheduled ||
                        widget.reservation!.reservationStatus == ReservationStatus.weather))
                  FilledButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamed(AppConstants.reservationModifyRoute, arguments: {'isAdmin': false}),
                    child: const Text('Modify'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
