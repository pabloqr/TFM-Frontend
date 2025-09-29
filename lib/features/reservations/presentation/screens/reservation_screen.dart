import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/theme.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/data/providers/availability_provider.dart';
import 'package:frontend/data/providers/complexes_list_provider.dart';
import 'package:frontend/data/providers/courts_list_provider.dart';
import 'package:frontend/data/services/utilities.dart';
import 'package:frontend/domain/usecases/reservations_use_cases.dart';
import 'package:frontend/features/common/data/models/availability_status.dart';
import 'package:frontend/features/common/presentation/widgets/custom_dialog.dart';
import 'package:frontend/features/common/presentation/widgets/header.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/common/presentation/widgets/time_range_selector.dart';
import 'package:frontend/features/complexes/data/models/complex_model.dart';
import 'package:frontend/features/complexes/presentation/widgets/complex_card.dart';
import 'package:frontend/features/courts/data/models/court_model.dart';
import 'package:frontend/features/courts/data/models/sport_enum.dart';
import 'package:frontend/features/courts/presentation/widgets/court_card.dart';
import 'package:frontend/features/courts/presentation/widgets/sport_card.dart';
import 'package:frontend/features/reservations/data/models/reservation_model.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

/// A screen for creating a new reservation through a step-by-step process.
///
/// This screen guides the user through selecting a complex, sport, court,
/// date, and time, and finally shows a summary before confirmation.
class ReservationScreen extends StatefulWidget {
  final bool isNew;
  final bool isAdmin;
  final int? userId;

  /// Creates a [ReservationScreen].
  const ReservationScreen._(this.isNew, {required this.isAdmin, this.userId});

  factory ReservationScreen.create({required bool isAdmin, int? userId}) =>
      ReservationScreen._(true, isAdmin: isAdmin, userId: userId);

  factory ReservationScreen.modify({required bool isAdmin, int? userId}) =>
      ReservationScreen._(false, isAdmin: isAdmin, userId: userId);

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

/// The state for the [ReservationScreen].
///
/// Manages the current step of the reservation process and the user's selections.
class _ReservationScreenState extends State<ReservationScreen> {
  ComplexesListProvider? _complexesListProvider;
  CourtsListProvider? _courtsListProvider;
  AvailabilityProvider? _availabilityProvider;
  VoidCallback? _providerListener;

  TimeRangeController? _timeRangeController;

  /// The current active step in the stepper.
  int _currentStep = 0;

  String _selectedComplexName = '--';
  String _selectedComplexAddress = 'C/XXXXXXXX XXXXXXXX, 00';
  String _selectedComplexSchedule = '--:-- - --:--';
  String _selectedSportName = '--';
  String _selectedCourtName = '--';
  String _selectedCourtCapacity = '--';

  /// The model for the current reservation.
  final ReservationModel _reservationModel = ReservationModel(
    id: -1,
    userId: -1,
    complexId: -1,
    courtId: -1,
    dateIni: DateTime.now(),
    dateEnd: DateTime.now(),
    status: AvailabilityStatus.empty,
    reservationStatus: ReservationStatus.scheduled,
    timeFilter: TimeFilter.upcoming,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  /// A map of sport indices to lists of sports.
  final Map<int, List<Sport>> _sports = {};

  /// Defines the steps in the reservation process.
  List<Step> get _steps => [
    if (widget.isAdmin)
      Step(
        title: const Text('Select user'),
        subtitle: const Text('Select the user to assign the reservation to'),
        content: _buildUserSelector(),
        isActive: _currentStep >= 0,
        state: _getStepState(0),
      ),
    Step(
      title: const Text('Select complex'),
      subtitle: const Text('Select a complex to book a court'),
      content: _buildComplexSelector(),
      isActive: _currentStep >= 0,
      state: _getStepState(_stepOffset),
    ),
    Step(
      title: const Text('Select sport'),
      subtitle: const Text('Select a sport to book a court'),
      content: _buildSportSelector(),
      isActive: _currentStep >= 1,
      state: _getStepState(1 + _stepOffset),
    ),
    Step(
      title: const Text('Select court'),
      subtitle: const Text('Select a court to book'),
      content: _buildCourtSelector(),
      isActive: _currentStep >= 2,
      state: _getStepState(2 + _stepOffset),
    ),
    Step(
      title: const Text('Select date and time'),
      subtitle: const Text('Select date and time to complete your reservation'),
      content: _buildDateAndTimeSelector(context),
      isActive: _currentStep >= 3,
      state: _getStepState(3 + _stepOffset),
    ),
    Step(
      title: const Text('Summary'),
      subtitle: const Text('Check your selection and confirm your reservation'),
      content: _buildSummary(),
      isActive: _currentStep >= 4,
      state: _getStepState(4 + _stepOffset),
    ),
  ];

  /// Form key for user validation
  final GlobalKey<FormState> _userFormKey = GlobalKey<FormState>();

  /// Controller for the user input field
  final TextEditingController _userIdController = TextEditingController();

  /// Notifier for the selected user ID.
  // final ValueNotifier<String?> _selectedUserId = ValueNotifier(null);

  /// Notifier for the index of the selected complex.
  final ValueNotifier<int> _selectedComplexIndex = ValueNotifier(-1);

  /// Notifier for the index of the selected sport.
  final ValueNotifier<int> _selectedSportIndex = ValueNotifier(-1);

  /// Notifier for the index of the selected court.
  final ValueNotifier<int> _selectedCourtIndex = ValueNotifier(-1);

  bool _selectedDate = false;

  /// The selected start date for the reservation.
  DateTime _selectedDateIni = DateTime.now();

  /// The selected end date for the reservation.
  late DateTime _selectedDateEnd;

  @override
  void initState() {
    super.initState();

    _reservationModel.userId = widget.userId ?? -1;
    _selectedDateEnd = _selectedDateIni.add(const Duration(hours: 1));
    _reservationModel.dateIni = _selectedDateIni;
    _reservationModel.dateEnd = _selectedDateEnd;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _complexesListProvider = context.read<ComplexesListProvider?>();
      _courtsListProvider = context.read<CourtsListProvider?>();
      _availabilityProvider = context.read<AvailabilityProvider?>();

      _timeRangeController = context.read<TimeRangeController?>();

      if (_complexesListProvider != null) {
        _complexesListProvider!.getComplexes();
      }

      _providerListener = () {
        if (mounted &&
            _complexesListProvider != null &&
            _complexesListProvider!.state == ProviderState.error &&
            _complexesListProvider!.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_complexesListProvider!.failure!.message), behavior: SnackBarBehavior.floating),
          );
        }
      };
      _complexesListProvider?.addListener(_providerListener!);
      _timeRangeController?.addListener(_onTimeRangeChanged);
    });
  }

  @override
  void dispose() {
    if (_complexesListProvider != null && _providerListener != null) {
      _complexesListProvider!.removeListener(_providerListener!);
    }
    if (_courtsListProvider != null && _providerListener != null) {
      _courtsListProvider!.removeListener(_providerListener!);
    }
    if (_availabilityProvider != null && _providerListener != null) {
      _availabilityProvider!.removeListener(_providerListener!);
    }
    _providerListener = null;

    _userIdController.dispose();
    // _selectedUserId.dispose();
    _selectedComplexIndex.dispose();
    _selectedSportIndex.dispose();
    _selectedCourtIndex.dispose();

    super.dispose();
  }

  /// Dynamic offset based on admin status
  int get _stepOffset => widget.isAdmin ? 1 : 0;

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
    if (widget.isAdmin) {
      switch (step) {
        case 0: // User selection
          return false;
        case 1: // Complex selection
          return !_isStepCompleted(0);
        case 2: // Sport selection
          return !_isStepCompleted(0) || !_isStepCompleted(1);
        case 3: // Court selection
          return !_isStepCompleted(0) || !_isStepCompleted(1) || !_isStepCompleted(2);
        case 4: // Date and time selection
          return !_isStepCompleted(0) || !_isStepCompleted(1) || !_isStepCompleted(2) || !_isStepCompleted(3);
        case 5: // Summary
          return !_isStepCompleted(0) ||
              !_isStepCompleted(1) ||
              !_isStepCompleted(2) ||
              !_isStepCompleted(3) ||
              !_isStepCompleted(4);
        default:
          return true;
      }
    } else {
      switch (step) {
        case 0: // Complex selection
          return false;
        case 1: // Sport selection
          return !_isStepCompleted(0);
        case 2: // Court selection
          return !_isStepCompleted(0) || !_isStepCompleted(1);
        case 3: // Date and time selection
          return !_isStepCompleted(0) || !_isStepCompleted(1) || !_isStepCompleted(2);
        case 4: // Summary
          return !_isStepCompleted(0) || !_isStepCompleted(1) || !_isStepCompleted(2) || !_isStepCompleted(3);
        default:
          return true;
      }
    }
  }

  /// Checks if a specific step has been completed.
  bool _isStepCompleted(int step) {
    if (widget.isAdmin) {
      switch (step) {
        case 0: // User selection
          return _userIdController.text.isNotEmpty;
        case 1: // Complex selection
          return _selectedComplexIndex.value != -1;
        case 2: // Sport selection
          return _selectedSportIndex.value != -1;
        case 3: // Court selection
          return _selectedCourtIndex.value != -1;
        case 4: // Date and time selection
        case 5: // Summary
          return true;
        default:
          return false;
      }
    } else {
      switch (step) {
        case 0: // Complex selection
          return _selectedComplexIndex.value != -1;
        case 1: // Sport selection
          return _selectedSportIndex.value != -1;
        case 2: // Court selection
          return _selectedCourtIndex.value != -1;
        case 3: // Date and time selection
        case 4: // Summary
          return true;
        default:
          return false;
      }
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

  void _onTimeRangeChanged() {
    if (mounted && _timeRangeController != null) {
      DateTime date = _timeRangeController!.currentRangeValues.start.toDateTime();
      _selectedDateIni = _selectedDateIni.copyWith(hour: date.hour, minute: date.minute);
      _reservationModel.dateIni = _selectedDateIni;
      date = _timeRangeController!.currentRangeValues.end.toDateTime();
      _selectedDateEnd = _selectedDateEnd.copyWith(hour: date.hour, minute: date.minute);
      _reservationModel.dateEnd = _selectedDateEnd;
    }
  }

  /// Handles tap events on a step header, allowing navigation.
  void _onStepTapped(int step) {
    // Allow navigation only to steps that are not disabled and are at or before the current step.
    if (step <= _maxAllowedStep && step <= _currentStep) {
      setState(() => _currentStep = step);
    }
  }

  /// Validates email format
  bool _isValidEmail(String email) {
    return RegExp(r"^((?!\.)[\w\-_.]*[^.])(@\w+)(\.\w+(\.\w+)?[^.\W])$").hasMatch(email);
  }

  /// Validates phone format (basic validation)
  bool _isValidPhone(String phone) {
    return RegExp(r'^[+]?[0-9]{9,15}$').hasMatch(phone.replaceAll(' ', ''));
  }

  /// Validates user input (email or phone)
  void _validateUser() {
    if (_userFormKey.currentState!.validate()) {
      String input = _userIdController.text.trim();
      // Generate a mock user ID based on input
      String userId = 'user_${input.hashCode.abs()}';
      _onUserValidated(userId);
    }
  }

  /// Callback for when a user is validated and selected.
  void _onUserValidated(String userId) {
    setState(() {
      // _selectedUserId.value = userId;
      // If currently on the user selection step, move to the complex selection step.
      if (_currentStep == 0) _currentStep = 1;
    });
  }

  /// Callback for when a complex is selected.
  ///
  /// Resets subsequent selections and moves to the next step if appropriate.
  void _onComplexSelected(int index, int complexId, String complexName, String complexAddress, String complexSchedule) {
    setState(() {
      _selectedComplexName = complexName;
      _selectedComplexAddress = complexAddress;
      _selectedComplexSchedule = complexSchedule;

      // Se actualiza el modelo de reserva con el id del complejo seleccionado
      _reservationModel.complexId = complexId;

      _selectedComplexIndex.value = index;
      // Reset selections for subsequent steps.
      _selectedSportIndex.value = -1;
      _selectedCourtIndex.value = -1;
      _selectedDate = false;
      _selectedDateIni = DateTime.now();
      _selectedDateEnd = _selectedDateIni.add(const Duration(hours: 1));

      // If currently on the complex selection step, move to the sport selection step.
      if (_currentStep == _stepOffset) _currentStep = 1 + _stepOffset;
    });
  }

  /// Callback for when a sport is selected.
  ///
  /// Resets subsequent selections and moves to the next step if appropriate.
  void _onSportSelected(int index) {
    // Se obtienen las pistas del complejo seleccionado, para el deporte seleccionado
    _courtsListProvider?.getCourts(
      _reservationModel.complexId,
      query: {'sport': _sports[_reservationModel.complexId]?.elementAt(index).name.toUpperCase()},
    );

    setState(() {
      _selectedSportName = _sports[_reservationModel.complexId]?.elementAt(index).name.toCapitalized() ?? '--';

      _selectedSportIndex.value = index;
      // Reset selections for subsequent steps.
      _selectedCourtIndex.value = -1;
      _selectedDate = false;
      _selectedDateIni = DateTime.now();
      _selectedDateEnd = _selectedDateIni.add(const Duration(hours: 1));

      // If currently on the sport selection step, move to the court selection step.
      if (_currentStep == 1 + _stepOffset) _currentStep = 2 + _stepOffset;
    });
  }

  /// Callback for when a court is selected.
  ///
  /// Resets subsequent selections and moves to the next step if appropriate.
  void _onCourtSelected(int index, int courtId, String courtName, String courtCapacity) {
    _availabilityProvider?.getCourtAvailability(_reservationModel.complexId, courtId);

    setState(() {
      _selectedCourtName = courtName;
      _selectedCourtCapacity = courtCapacity;

      _reservationModel.courtId = courtId;

      _selectedCourtIndex.value = index;
      _selectedDate = false;
      _selectedDateIni = DateTime.now();
      _selectedDateEnd = _selectedDateIni.add(const Duration(hours: 1));

      // If currently on the court selection step, move to the date/time selection step.
      if (_currentStep == 2 + _stepOffset) _currentStep = 3 + _stepOffset;
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
      _selectedDate = true;
      _selectedDateIni = _selectedDateIni.copyWith(year: date.year, month: date.month, day: date.day);
      _reservationModel.dateIni = _selectedDateIni;
      _selectedDateEnd = _selectedDateEnd.copyWith(year: date.year, month: date.month, day: date.day);
      _reservationModel.dateEnd = _selectedDateEnd;

      // If currently on the court selection step (before date/time), move to date/time selection.
      // This condition might need adjustment based on flow, as date selection is part of step 3.
      if (_currentStep == 2 + _stepOffset) _currentStep = 3 + _stepOffset;
    });
  }

  void _showErrorDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    showCustomAlertDialog(
      context,
      icon: Symbols.error_outline_rounded,
      headline: 'Try again?',
      supportingText:
          'There was a problem with the reservation creation process. If you exit now all unsaved changes will be lost.',
      headerColor: colorScheme.errorContainer,
      iconColor: colorScheme.onErrorContainer,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: const Text('Leave'),
        ),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Try again')),
      ],
    );
  }

  /// Shows a confirmation dialog for the reservation.
  ///
  /// Navigates back twice on confirmation: once to close the dialog,
  /// and once to pop the new reservation screen.
  void _confirmReservation() async {
    ReservationsUseCases? useCases = context.read<ReservationsUseCases?>();
    if (useCases == null) _showErrorDialog();

    final result = await useCases!.createReservation(_reservationModel);
    result.fold(
      // (failure) => _showErrorDialog(),
      (failure) => Navigator.of(context).popUntil((route) => route.isFirst),
      (reservation) => Navigator.of(context).popUntil((route) => route.isFirst),
    );
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

    final String text = widget.isNew ? 'Creation' : 'Modification';

    showCustomAlertDialog(
      context,
      icon: Symbols.warning_rounded,
      headline: 'Leave reservation ${text.toLowerCase()}?',
      supportingText:
          'You are about to exit the reservation ${text.toLowerCase()} process. All unsaved changes will be lost.',
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

  /// Builds the main widget tree for the screen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: _cancelReservation, icon: const Icon(Icons.arrow_back_rounded)),
        title: Text(widget.isNew ? 'New reservation' : 'Modify reservation'),
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

  /// Builds the widget for selecting/validating a user.
  Widget _buildUserSelector() {
    return Form(
      key: _userFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16.0,
        children: [
          const SizedBox(height: 2.0),
          TextFormField(
            controller: _userIdController,
            decoration: InputDecoration(labelText: 'Mail or Phone number', border: OutlineInputBorder()),
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter an email or a phone number';
              }

              String trimmed = value.trim();
              if (!_isValidEmail(trimmed) && !_isValidPhone(trimmed)) {
                return 'Please enter a valid email or phone number';
              }

              return null;
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8.0,
            children: [
              FilledButton.icon(
                onPressed: _validateUser,
                icon: Icon(Symbols.check_circle_rounded, size: 18, fill: 0, weight: 400, grade: 0, opticalSize: 18),
                label: Text('Validate User'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the widget for selecting a complex.
  Widget _buildComplexSelector() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 264.0),
      child: Consumer<ComplexesListProvider?>(
        builder: (context, consumerProvider, _) {
          final currentProvider = consumerProvider ?? _complexesListProvider;
          List<ComplexModel> complexes = currentProvider?.complexes ?? [];

          return CarouselView(
            onTap: (index) async {
              final complex = complexes.elementAt(index);
              final address = complex.locLatitude != null && complex.locLongitude != null
                  ? await WidgetUtilities.getAddressFromLatLng(complex.locLatitude!, complex.locLongitude!)
                  : 'C/XXXXXXXX XXXXXXXX, 00';

              _onComplexSelected(
                index,
                complex.id,
                complex.complexName,
                address,
                '${complex.timeIni} - ${complex.timeEnd}',
              );
            },
            itemExtent: 240.0,
            children: List.generate(complexes.isNotEmpty ? complexes.length : 10, (int index) {
              if (complexes.isEmpty) {
                return Container(color: Theme.of(context).colorScheme.surfaceContainer);
              }

              return FutureBuilder(
                future: NetworkUtilities.getComplexSports(context, complexes.elementAt(index).id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(color: Theme.of(context).colorScheme.surfaceContainer);
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return Container(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      child: Center(child: Text('Error loading ${complexes.elementAt(index).complexName} data')),
                    );
                  }

                  final sports = snapshot.data!;
                  _sports[complexes.elementAt(index).id] = sports.toList();

                  return ComplexCard.small(
                    userId: null,
                    complex: complexes.elementAt(index),
                    rating: Random().nextInt(11) / 2.0,
                    sports: sports,
                    index: index,
                    selectedIndex: _selectedComplexIndex,
                  );
                },
              );
            }),
          );
        },
      ),
    );
  }

  /// Builds the widget for selecting a sport.
  Widget _buildSportSelector() {
    if (_selectedComplexIndex.value == -1) {
      return const Center(child: Text('You must select a complex first'));
    }

    final sports = _sports[_reservationModel.complexId];

    if (sports == null) {
      return const Center(
        heightFactor: 2.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16.0,
          children: [
            SizedBox(width: 24.0, height: 24.0, child: CircularProgressIndicator()),
            Text('Loading sports...'),
          ],
        ),
      );
    }

    if (sports.isEmpty) {
      return const Center(child: Text('No sports available for this complex'));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: sports.length / 2,
      ),
      itemCount: sports.length,
      itemBuilder: (context, index) {
        final sport = sports[index];
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
      child: Consumer<CourtsListProvider?>(
        builder: (context, consumerProvider, _) {
          final currentProvider = consumerProvider ?? _courtsListProvider;
          final validState = currentProvider?.state == ProviderState.loaded;
          List<CourtModel> courts = currentProvider?.courts ?? [];

          return CarouselView(
            onTap: (index) {
              final court = courts.elementAt(index);
              _onCourtSelected(index, court.id, court.name, court.maxPeople.toString().padLeft(2, '0'));
            },
            itemExtent: 240.0,
            children: List.generate(validState && courts.isNotEmpty ? courts.length : 10, (int index) {
              final random = Random();
              List<TimeOfDay> times = List.generate(random.nextInt(3) + 1, (i) {
                return TimeOfDay(hour: random.nextInt(15) + 9, minute: 0);
              });
              List<Sport> sports = Sport.values.toList();
              sports.remove(Sport.padel);
              sports.shuffle(random);

              return CourtCard.small(
                title: validState && courts.isNotEmpty ? courts.elementAt(index).name : 'Court $index',
                times: times.toSet(),
                index: index,
                selectedIndex: _selectedCourtIndex,
              );
            }),
          );
        },
      ),
    );
  }

  /// Builds the widget for selecting the date and time range.
  Widget _buildDateAndTimeSelector(BuildContext context) {
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
                  child: LabeledInfoWidget(
                    icon: Symbols.calendar_month_rounded,
                    label: 'Date',
                    text: _selectedDateIni.toFormattedDate(),
                  ),
                ),
                if (!_selectedDate)
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
              onPressed: _timeRangeController?.reset,
            ),
            Consumer<AvailabilityProvider?>(
              builder: (context, consumerProvider, _) {
                final currentProvider = consumerProvider ?? _availabilityProvider;
                final validState = currentProvider?.state == ProviderState.loaded;
                final courtAvailability = currentProvider?.availability;

                RangeValues schedule = RangeValues(8.0, 24.0); // Default schedule

                final parts = _selectedComplexSchedule.split(' - ');
                if (parts.length == 2) {
                  final timeIni = parts[0];
                  final timeIniParts = timeIni.split(':');

                  double timeIniDouble = 8.0;
                  if (timeIniParts.length == 2) {
                    final timeIniHour = int.tryParse(timeIniParts[0]) ?? 8.0;
                    final timeIniMinute = int.tryParse(timeIniParts[1]) ?? 0.0;
                    timeIniDouble = timeIniHour + (timeIniMinute / 60.0);
                  }

                  final timeEnd = parts[1];
                  final timeEndParts = timeEnd.split(':');

                  double timeEndDouble = 24.0;
                  if (timeEndParts.length == 2) {
                    final timeEndHour = int.tryParse(timeEndParts[0]) ?? 24.0;
                    final timeEndMinute = int.tryParse(timeEndParts[1]) ?? 0.0;
                    timeEndDouble = timeEndHour + (timeEndMinute / 60.0);
                  }

                  schedule = RangeValues(timeIniDouble, timeEndDouble);
                }

                return TimeRangeSelector(
                  schedule: schedule,
                  date: DateTime.now(),
                  availability: validState && courtAvailability != null ? courtAvailability.availability : [],
                );
              },
            ),
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
        Header.subSubheader(subheaderText: _selectedComplexName, showButton: false),
        InfoSectionWidget(
          leftChildren: [
            LabeledInfoWidget(icon: Symbols.location_on_rounded, label: 'Address', text: _selectedComplexAddress),
          ],
          rightChildren: [
            LabeledInfoWidget(icon: Symbols.schedule_rounded, label: 'Schedule', text: _selectedComplexSchedule),
          ],
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
        Header.subSubheader(subheaderText: _selectedCourtName, showButton: false),
        InfoSectionWidget(
          leftChildren: [
            LabeledInfoWidget(icon: Symbols.sports_rounded, label: 'Sport', text: _selectedSportName),
            LabeledInfoWidget(icon: Symbols.groups_rounded, label: 'Capacity', text: _selectedCourtCapacity),
          ],
          rightChildren: [
            LabeledInfoWidget(
              icon: Symbols.calendar_month_rounded,
              label: 'Date',
              text: _reservationModel.dateIni.toFormattedDate(),
            ),
            LabeledInfoWidget(
              icon: Symbols.schedule_rounded,
              label: 'Reservation time',
              text: '${_reservationModel.dateIni.toFormattedTime()} - ${_reservationModel.dateEnd.toFormattedTime()}',
            ),
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
    return SizedBox(
      width: double.infinity,
      child: Padding(
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
      ),
    );
  }
}
