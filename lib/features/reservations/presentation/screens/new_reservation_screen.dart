import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/theme.dart';
import 'package:frontend/features/common/presentation/widgets/custom_dialog.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/common/presentation/widgets/header.dart';
import 'package:frontend/features/common/presentation/widgets/time_range_selector.dart';
import 'package:frontend/features/complexes/presentation/widgets/complex_card.dart';
import 'package:frontend/features/courts/data/models/sport_enum.dart';
import 'package:frontend/features/courts/presentation/widgets/court_card.dart';
import 'package:frontend/features/courts/presentation/widgets/sport_card.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

/// A screen for creating a new reservation through a step-by-step process.
///
/// This screen guides the user through selecting a complex, sport, court,
/// date, and time, and finally shows a summary before confirmation.
class NewReservationScreen extends StatefulWidget {
  /// Creates a [NewReservationScreen].
  const NewReservationScreen({super.key});

  @override
  State<NewReservationScreen> createState() => _NewReservationScreenState();
}

/// The state for the [NewReservationScreen].
///
/// Manages the current step of the reservation process and the user's selections.
class _NewReservationScreenState extends State<NewReservationScreen> {
  /// The current active step in the stepper.
  int _currentStep = 0;

  /// Defines the steps in the reservation process.
  List<Step> get _steps => [
    Step(
      title: const Text('Select complex'),
      subtitle: const Text('Select a complex to book a court'),
      content: _buildComplexSelector(),
      isActive: _currentStep >= 0,
      state: _getStepState(0),
    ),
    Step(
      title: const Text('Select sport'),
      subtitle: const Text('Select a sport to book a court'),
      content: _buildSportSelector(),
      isActive: _currentStep >= 1,
      state: _getStepState(1),
    ),
    Step(
      title: const Text('Select court'),
      subtitle: const Text('Select a court to book'),
      content: _buildCourtSelector(),
      isActive: _currentStep >= 2,
      state: _getStepState(2),
    ),
    Step(
      title: const Text('Select date and time'),
      subtitle: const Text('Select date and time to complete your reservation'),
      content: _buildDateAndTimeSelector(),
      isActive: _currentStep >= 3,
      state: _getStepState(3),
    ),
    Step(
      title: const Text('Summary'),
      subtitle: const Text('Check your selection and confirm your reservation'),
      content: _buildSummary(),
      isActive: _currentStep >= 4,
      state: _getStepState(4),
    ),
  ];

  /// Notifier for the index of the selected complex.
  final ValueNotifier<int> _selectedComplexIndex = ValueNotifier(-1);

  /// Notifier for the index of the selected sport.
  final ValueNotifier<int> _selectedSportIndex = ValueNotifier(-1);

  /// Notifier for the index of the selected court.
  final ValueNotifier<int> _selectedCourtIndex = ValueNotifier(-1);

  /// The selected start date for the reservation.
  DateTime? _selectedDateIni;

  /// The selected end date for the reservation.
  DateTime? _selectedDateEnd;

  /// Determines the maximum step the user is allowed to navigate to.
  ///
  /// This is based on which steps have been completed.
  int get _maxAllowedStep {
    for (int i = 0; i < _steps.length; i++) {
      // If a step is disabled, the previous step is the maximum allowed.
      if (_isStepDisabled(i)) return i - 1;
    }
    // If all steps are enabled, the last step is the maximum.
    return _steps.length - 1;
  }

  /// Checks if a specific step should be disabled.
  ///
  /// A step is disabled if any of the preceding steps are not yet completed.
  bool _isStepDisabled(int step) {
    switch (step) {
      case 0:
        // First step is always enabled.
        return false;
      case 1:
        // Depends on complex selection.
        return !_isStepCompleted(0);
      case 2:
        // Depends on complex and sport selection.
        return !_isStepCompleted(0) || !_isStepCompleted(1);
      case 3:
        // Depends on complex, sport, and court selection.
        return !_isStepCompleted(0) || !_isStepCompleted(1) || !_isStepCompleted(2);
      case 4:
        // Depends on all previous selections.
        return !_isStepCompleted(0) || !_isStepCompleted(1) || !_isStepCompleted(2) || !_isStepCompleted(3);
      default:
        // Any other step index is considered disabled.
        return true;
    }
  }

  /// Checks if a specific step has been completed.
  bool _isStepCompleted(int step) {
    switch (step) {
      case 0:
        return _selectedComplexIndex.value != -1;
      case 1:
        return _selectedSportIndex.value != -1;
      case 2:
        return _selectedCourtIndex.value != -1;
      case 3:
        return _selectedDateIni != null && _selectedDateEnd != null;
      case 4:
        return true; // Summary step is always considered completed if reached.
      default:
        return false;
    }
  }

  /// Determines the [StepState] for a given step index.
  StepState _getStepState(int step) {
    if (_isStepDisabled(step)) return StepState.disabled;
    // If the step is completed and it's not the current step, mark as complete.
    if (_isStepCompleted(step) && _currentStep > step) return StepState.complete;
    // If it's the current step, mark as indexed (currently active).
    if (_currentStep == step) return StepState.indexed;

    // Default to disabled if none of the above (should not be reached if logic is correct).
    return StepState.disabled;
  }

  /// Handles tap events on a step header, allowing navigation.
  void _onStepTapped(int step) {
    // Allow navigation only to steps that are not disabled and are at or before the current step.
    if (step <= _maxAllowedStep && step <= _currentStep) {
      setState(() {
        _currentStep = step;
      });
    }
  }

  /// Callback for when a complex is selected.
  ///
  /// Resets subsequent selections and moves to the next step if appropriate.
  void _onComplexSelected(int index) {
    setState(() {
      _selectedComplexIndex.value = index;
      // Reset selections for subsequent steps.
      _selectedSportIndex.value = -1;
      _selectedCourtIndex.value = -1;
      _selectedDateIni = null;
      _selectedDateEnd = null;

      // If currently on the complex selection step, move to the sport selection step.
      if (_currentStep == 0) _currentStep = 1;
    });
  }

  /// Callback for when a sport is selected.
  ///
  /// Resets subsequent selections and moves to the next step if appropriate.
  void _onSportSelected(int index) {
    setState(() {
      _selectedSportIndex.value = index;
      // Reset selections for subsequent steps.
      _selectedCourtIndex.value = -1;
      _selectedDateIni = null;
      _selectedDateEnd = null;

      // If currently on the sport selection step, move to the court selection step.
      if (_currentStep == 1) _currentStep = 2;
    });
  }

  /// Callback for when a court is selected.
  ///
  /// Resets subsequent selections and moves to the next step if appropriate.
  void _onCourtSelected(int index) {
    setState(() {
      _selectedCourtIndex.value = index;
      // Reset selections for subsequent steps.
      _selectedDateIni = null;
      _selectedDateEnd = null;

      // If currently on the court selection step, move to the date/time selection step.
      if (_currentStep == 2) _currentStep = 3;
    });
  }

  /// Opens a date picker to allow the user to select a date.
  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)), // Default to tomorrow.
      firstDate: DateTime.now(), // Cannot select past dates.
      lastDate: DateTime.now().add(const Duration(days: 30)), // Allow selection up to 30 days in the future.
    );

    if (date != null) _onDateSelected(date);
  }

  /// Callback for when a date is selected from the date picker.
  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDateIni = date;
      _selectedDateEnd = date; // Assuming reservation is for a single day for now.

      // If currently on the court selection step (before date/time), move to date/time selection.
      // This condition might need adjustment based on flow, as date selection is part of step 3.
      if (_currentStep == 2) _currentStep = 3;
    });
  }

  /// Shows a confirmation dialog for the reservation.
  ///
  /// Navigates back twice on confirmation: once to close the dialog,
  /// and once to pop the new reservation screen.
  void _confirmReservation() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Handles the cancellation of the reservation.
  ///
  /// Shows a confirmation dialog before canceling the reservation.
  void _cancelReservation() {
    final brightness = Theme.of(context).brightness;
    final headerColor = brightness == Brightness.light
        ? MaterialTheme.warning.light.colorContainer
        : MaterialTheme.success.dark.colorContainer;
    final iconColor = brightness == Brightness.light
        ? MaterialTheme.warning.light.onColorContainer
        : MaterialTheme.success.dark.onColorContainer;

    showCustomAlertDialog(
      context,
      icon: Symbols.warning_rounded,
      headline: 'Leave reservation creation?',
      supportingText: 'You are about to exit the reservation creation process. All unsaved changes will be lost.',
      headerColor: headerColor,
      iconColor: iconColor,
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Stay')),
        TextButton(
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: const Text('Leave'),
        ),
      ],
    );
  }

  /// Builds the widget for selecting a complex.
  Widget _buildComplexSelector() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 264.0),
      child: CarouselView(
        onTap: _onComplexSelected,
        itemExtent: 240.0,
        children: List.generate(10, (int index) {
          final random = Random();
          List<Sport> sports = Sport.values.toList();
          sports.shuffle(random);

          return ComplexCard.small(
            title: 'Complex $index',
            rating: random.nextInt(11) / 2.0,
            sports: sports.sublist(0, random.nextInt(sports.length) + 1).toSet(),
            index: index,
            selectedIndex: _selectedComplexIndex,
          );
        }),
      ),
    );
  }

  /// Builds the widget for selecting a sport.
  Widget _buildSportSelector() {
    if (_selectedComplexIndex.value == -1) {
      return const Center(child: Text('You must select a complex first'));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 4 / 2,
      ),
      itemCount: Sport.values.length,
      itemBuilder: (context, index) {
        Sport sport = Sport.values[index];

        return SportCard(
          sport: sport,
          onTap: () => _onSportSelected(index),
          index: index,
          selectedIndex: _selectedSportIndex,
        );
      },
    );
  }

  /// Builds the widget for selecting a court.
  Widget _buildCourtSelector() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 264.0),
      child: CarouselView(
        onTap: _onCourtSelected,
        itemExtent: 240.0,
        children: List.generate(10, (int index) {
          final random = Random();
          List<TimeOfDay> times = List.generate(random.nextInt(3) + 1, (i) {
            return TimeOfDay(hour: random.nextInt(15) + 9, minute: 0);
          });
          List<Sport> sports = Sport.values.toList();
          sports.remove(Sport.padel);
          sports.shuffle(random);

          return CourtCard.small(
            title: 'Court $index',
            times: times.toSet(),
            index: index,
            selectedIndex: _selectedCourtIndex,
          );
        }),
      ),
    );
  }

  /// Builds the widget for selecting the date and time range.
  Widget _buildDateAndTimeSelector() {
    final controller = Provider.of<TimeRangeController>(context, listen: false);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 8.0,
      children: [
        Column(
          spacing: 8.0,
          children: [
            Header.subSubheader(subheaderText: 'Select date', showButton: false),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 8.0,
              children: [
                Expanded(
                  child: LabeledInfoWidget(icon: Symbols.calendar_month_rounded, label: 'Date', text: '01/01/2023'),
                ),
                if (_selectedDateIni == null || _selectedDateEnd == null)
                  FilledButton.icon(
                    onPressed: () async => await _selectDate(),
                    label: const Text('Select'),
                    icon: Icon(
                      Symbols.edit_calendar_rounded,
                      size: 18,
                      fill: 1,
                      weight: 400,
                      grade: 0,
                      opticalSize: 18,
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () async => await _selectDate(),
                    label: const Text('Modify'),
                    icon: Icon(
                      Symbols.edit_calendar_rounded,
                      size: 18,
                      fill: 1,
                      weight: 400,
                      grade: 0,
                      opticalSize: 18,
                    ),
                  ),
              ],
            ),
          ],
        ),
        Column(
          children: [
            Header.subSubheader(
              subheaderText: 'Select time range',
              showButton: true,
              buttonText: 'Reset',
              onPressed: controller.reset,
            ),
            TimeRangeSelector(),
          ],
        ),
      ],
    );
  }

  /// Builds the summary widget displaying all selected reservation details.
  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.0,
      children: [_buildComplexInfoSubsection(), _buildCourtInfoSubsection(), _buildReceiptInfoSubsection()],
    );
  }

  /// Builds the subsection of the summary for complex information.
  Widget _buildComplexInfoSubsection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.0,
      children: [
        Header.subSubheader(subheaderText: 'ComplexName', showButton: false),
        InfoSectionWidget(
          leftChildren: [LabeledInfoWidget(icon: Symbols.location_on_rounded, label: 'Address', text: 'C/XXXX, 00')],
          rightChildren: [LabeledInfoWidget(icon: Symbols.schedule_rounded, label: 'Schedule', text: '00:00 - 00:00')],
        ),
      ],
    );
  }

  /// Builds the subsection of the summary for court information.
  Widget _buildCourtInfoSubsection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.0,
      children: [
        Header.subSubheader(subheaderText: 'CourtName', showButton: false),
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

  /// Builds the subsection of the summary for receipt information.
  Widget _buildReceiptInfoSubsection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.0,
      children: [
        Header.subSubheader(subheaderText: 'Receipt', showButton: false),
        InfoSectionWidget(
          leftChildren: [LabeledInfoWidget(icon: Symbols.payments_rounded, label: 'Price', text: '00.00 €')],
          rightChildren: [LabeledInfoWidget(icon: Symbols.credit_card_clock, label: 'Payment status', text: 'Paid')],
        ),
      ],
    );
  }

  /// Builds the control buttons for the stepper (Previous, Next, Confirm).
  Widget _buildStepControls(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8.0,
        children: [
          if (details.stepIndex > 0)
            TextButton(
              onPressed: () {
                setState(() => _currentStep = details.stepIndex - 1);
              },
              child: const Text('Previous'),
            ),
          if (_isStepCompleted(details.stepIndex) && details.stepIndex < _steps.length - 1)
            FilledButton(
              onPressed: () {
                setState(() => _currentStep = details.stepIndex + 1);
              },
              child: const Text('Next'),
            ),
          if (details.stepIndex == _steps.length - 1)
            FilledButton(onPressed: () => _confirmReservation(), child: const Text('Confirm reservation')),
        ],
      ),
    );
  }

  /// Builds the main widget tree for the screen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: _cancelReservation, icon: const Icon(Icons.arrow_back_rounded)),
        title: const Text('New Reservation'),
      ),
      body: SafeArea(
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: _onStepTapped,
          controlsBuilder: (context, details) => _buildStepControls(context, details),
          steps: _steps,
        ),
      ),
    );
  }
}
