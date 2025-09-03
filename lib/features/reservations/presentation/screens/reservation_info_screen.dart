import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/core/constants/theme.dart';
import 'package:frontend/features/common/presentation/widgets/custom_dialog.dart';
import 'package:frontend/features/common/presentation/widgets/expandable_fab.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/common/presentation/widgets/medium_chip.dart';
import 'package:frontend/features/common/presentation/widgets/meta_data_card.dart';
import 'package:frontend/features/common/presentation/widgets/header.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ReservationInfoScreen extends StatefulWidget {
  const ReservationInfoScreen({super.key});

  @override
  State<ReservationInfoScreen> createState() => _ReservationInfoScreenState();
}

class _ReservationInfoScreenState extends State<ReservationInfoScreen> {
  bool _isAdmin = false;

  Widget _buildComplexInfoSubsection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.0,
      children: [
        if (_isAdmin)
          Header.subheader(subheaderText: 'ComplexName', showButton: false)
        else
          Header.subheader(
            subheaderText: 'ComplexName',
            showButton: true,
            buttonText: 'Get directions',
            onPressed: () {},
          ),
        InfoSectionWidget(
          leftChildren: [LabeledInfoWidget(icon: Symbols.location_on_rounded, label: 'Address', text: 'C/XXXX, 00')],
          rightChildren: [LabeledInfoWidget(icon: Symbols.schedule_rounded, label: 'Schedule', text: '00:00 - 00:00')],
        ),
      ],
    );
  }

  Widget _buildCourtInfoSubsection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.0,
      children: [
        Header.subheader(subheaderText: 'CourtName', showButton: false),
        InfoSectionWidget(
          leftChildren: [
            LabeledInfoWidget(icon: Symbols.sports_rounded, label: 'Sport', text: 'Sport'),
            LabeledInfoWidget(icon: Symbols.groups_rounded, label: 'Capacity', text: '00'),
          ],
          rightChildren: [
            LabeledInfoWidget(icon: Symbols.calendar_month_rounded, label: 'Date', text: 'Mon, 00/00/0000'),
            LabeledInfoWidget(icon: Symbols.schedule_rounded, label: 'Reservation time', text: '00:00 - 00:00'),
          ],
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Reservation'),
        actions: [Padding(padding: const EdgeInsets.only(right: 16.0), child: MediumChip.alert('Weather'))],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16.0,
            children: [
              MetaDataCard(
                id: '00000000',
                createdAt: 'Mon, 00/00/0000, 00:00:00',
                updatedAt: 'Mon, 00/00/0000, 00:00:00',
                additionalMetadata: _isAdmin
                    ? [LabeledInfoWidget(icon: Symbols.person_rounded, label: 'Created by', text: 'XXXX')]
                    : null,
              ),
              _buildComplexInfoSubsection(),
              _buildCourtInfoSubsection(),
              _buildReceiptInfoSubsection(),
            ],
          ),
        ),
      ),
      floatingActionButton: ExpandableFab(
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
                supportingText: 'You\'re about to cancel your reservation. This action is cost free but irreversible,',
                headerColor: headerColor,
                iconColor: iconColor,
                actions: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Go back')),
                  TextButton(onPressed: () {
                    // TODO: Cancel reservation
                  }, child: const Text('Yes, cancel')),
                ],
              );
            },
          ),
          ActionButton(
            icon: Symbols.edit_calendar_rounded,
            label: 'Modify reservation',
            onPressed: () => Navigator.of(context).pushNamed(AppConstants.reservationModifyRoute),
          ),
        ],
      ),
    );
  }
}
