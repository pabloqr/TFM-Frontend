import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/data/services/utilities.dart';
import 'package:frontend/features/common/presentation/utilities/unavailable_range_painter.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/courts/data/models/court_availability_model.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

/// Manages the state for time range selection, including available and unavailable time slots.
///
/// This controller holds the logic for setting time periods (morning, afternoon, evening),
/// updating the selected time range, and managing ranges that are marked as unavailable.
/// It uses [ChangeNotifier] to alert listeners, typically UI components, about state changes.
///
/// Key properties include [currentTimeIni] and [currentTimeEnd] which define the current
/// viewable/selectable window, [currentRangeValues] for the user's selection, and
/// [unavailableRanges] for times that cannot be selected. It provides validation logic
/// in [_getValidRangeValues] to ensure selections respect unavailable times and boundaries,
/// and methods to update and manage these values.
class TimeRangeController extends ChangeNotifier {
  /// Defines the upper limit for the morning time slot.
  static const double morningLimit = 12.0;

  /// Defines the upper limit for the afternoon time slot.
  static const double afternoonLimit = 18.0;

  /// The complete schedule of the complex (opening and closing hours)
  RangeValues schedule = RangeValues(8.0, 24.0);

  /// The start of the current time window being displayed/selected.
  double currentTimeIni = 8.0;

  /// Defines the upper limit for the night time slot.
  double nightLimit = 24.0;

  /// The end of the current time window being displayed/selected.
  double currentTimeEnd = morningLimit;

  /// The currently selected range of values by the user.
  late RangeValues currentRangeValues;

  /// A list of time ranges that are not available for selection.
  List<RangeValues> unavailableRanges = [];

  /// Initializes the controller, setting the initial time to the morning slot.
  TimeRangeController() {
    setMorningTime();
  }

  /// Adjusts the provided [rangeValue] to ensure it's valid and does not improperly overlap with unavailable ranges.
  ///
  /// It clamps the start and end values to the current time window and schedule limits,
  /// and adjusts them if they intersect with any [unavailableRanges].
  RangeValues _getValidRangeValues(RangeValues rangeValue) {
    double start = rangeValue.start;
    double end = rangeValue.end;

    // First, ensure the range is within the schedule limits
    start = start.clamp(schedule.start, schedule.end - 1.0);
    end = end.clamp(start + 1.0, schedule.end);

    // Iterate through each restricted (unavailable) time range.
    for (final restricted in unavailableRanges) {
      if (restricted.overlaps(rangeValue)) {
        // If the selection starts before an unavailable range and ends within or after it.
        if (start < restricted.start && end > restricted.start) {
          end = restricted.start; // Snap the end to the start of the unavailable range.
        }
        // If the selection starts within an unavailable range and ends after it.
        else if (start < restricted.end && end > restricted.end) {
          start = restricted.end; // Snap the start to the end of the unavailable range.
        }
        // If the selection is entirely within an unavailable range.
        else if (start >= restricted.start && end <= restricted.end) {
          // Attempt to shift the selection to after the unavailable range, maintaining its duration.
          start = restricted.end;
          end = start + (rangeValue.end - rangeValue.start);
        }
      }
    }

    // Ensure the start and end are within the current active time window and schedule.
    // A minimum duration of 1.0 (1 hour) is enforced.
    final effectiveMin = [currentTimeIni, schedule.start].reduce((a, b) => a > b ? a : b);
    final effectiveMax = [currentTimeEnd, schedule.end].reduce((a, b) => a < b ? a : b);

    start = start.clamp(effectiveMin, effectiveMax - 1.0);
    end = end.clamp(start + 1.0, effectiveMax);

    return RangeValues(start, end);
  }

  /// Merges overlapping or contiguous [unavailableRanges] to simplify the list.
  ///
  /// For example, if `unavailableRanges` contains `(8-10)` and `(9-11)`,
  /// they will be merged into a single `(8-11)` range.
  void _mergeUnavailableRanges() {
    if (unavailableRanges.isEmpty) return;

    // Sort ranges by their start time to allow for efficient merging.
    unavailableRanges.sort((a, b) => a.start.compareTo(b.start));

    final merged = <RangeValues>[];
    var current = unavailableRanges.first;

    for (var i = 1; i < unavailableRanges.length; i++) {
      final next = unavailableRanges[i];

      // If the current range overlaps or is contiguous with the next range.
      if (current.end >= next.start) {
        // Merge them by extending the current range's end if the next range ends later.
        current = RangeValues(current.start, current.end > next.end ? current.end : next.end);
      } else {
        // If no overlap, add the current merged range to the list and start a new one.
        merged.add(current);
        current = next;
      }
    }

    merged.add(current); // Add the last processed range.
    unavailableRanges = merged;
  }

  /// Sets the schedule (opening and closing hours) for the complex.
  /// This affects all time periods and validates the current selection.
  void setSchedule(double timeIni, double timeEnd) {
    schedule = RangeValues(timeIni, timeEnd);

    // Update night limit to match schedule end if it was the default
    if (nightLimit == 24.0) {
      nightLimit = timeEnd;
    }

    // Re-validate current selection with new schedule
    currentRangeValues = _getValidRangeValues(currentRangeValues);

    // Ensure current time window is within schedule
    _adjustCurrentTimeWindow();

    notifyListeners();
  }

  /// Adjusts the current time window to fit within the schedule limits
  void _adjustCurrentTimeWindow() {
    // Ensure current time window doesn't exceed schedule
    currentTimeIni = currentTimeIni.clamp(schedule.start, schedule.end - 1.0);
    currentTimeEnd = currentTimeEnd.clamp(currentTimeIni + 1.0, schedule.end);
  }

  /// Sets the current time selection window to the morning period.
  /// Morning period: from schedule start to morningLimit (or schedule end if shorter)
  void setMorningTime() {
    currentTimeIni = schedule.start;
    currentTimeEnd = [morningLimit, schedule.end].reduce((a, b) => a < b ? a : b);

    // Ensure we have at least 1 hour window
    if (currentTimeEnd - currentTimeIni < 1.0) {
      currentTimeEnd = (currentTimeIni + 1.0).clamp(currentTimeIni + 1.0, schedule.end);
    }

    currentRangeValues = _getValidRangeValues(RangeValues(currentTimeIni, currentTimeIni + 1.0));
    notifyListeners();
  }

  /// Sets the current time selection window to the afternoon period.
  /// Afternoon period: from morningLimit to afternoonLimit (within schedule limits)
  void setAfternoonTime() {
    currentTimeIni = [morningLimit, schedule.start].reduce((a, b) => a > b ? a : b);
    currentTimeEnd = [afternoonLimit, schedule.end].reduce((a, b) => a < b ? a : b);

    // Ensure afternoon period is within schedule and has minimum duration
    if (currentTimeIni >= schedule.end || currentTimeEnd <= schedule.start) {
      // Fallback to available schedule range
      currentTimeIni = schedule.start;
      currentTimeEnd = schedule.end;
    }

    // Ensure we have at least 1 hour window
    if (currentTimeEnd - currentTimeIni < 1.0) {
      currentTimeEnd = (currentTimeIni + 1.0).clamp(currentTimeIni + 1.0, schedule.end);
    }

    currentRangeValues = _getValidRangeValues(RangeValues(currentTimeIni, currentTimeIni + 1.0));
    notifyListeners();
  }

  /// Sets the current time selection window to the evening period.
  /// Evening period: from afternoonLimit to schedule end
  void setEveningTime() {
    currentTimeIni = [afternoonLimit, schedule.start].reduce((a, b) => a > b ? a : b);
    currentTimeEnd = schedule.end;

    // Ensure evening period is within schedule
    if (currentTimeIni >= schedule.end) {
      // Fallback to last available hours of schedule
      currentTimeIni = (schedule.end - 1.0).clamp(schedule.start, schedule.end - 0.5);
    }

    // Ensure we have at least 1 hour window
    if (currentTimeEnd - currentTimeIni < 1.0) {
      currentTimeIni = (currentTimeEnd - 1.0).clamp(schedule.start, currentTimeEnd - 1.0);
    }

    currentRangeValues = _getValidRangeValues(RangeValues(currentTimeIni, currentTimeIni + 1.0));
    notifyListeners();
  }

  /// Updates the [currentRangeValues] based on user input from the slider.
  ///
  /// The [newValues] are validated using [_getValidRangeValues].
  void updateRangeValues(RangeValues newValues) {
    currentRangeValues = _getValidRangeValues(newValues);
    notifyListeners();
  }

  /// Adds a new [range] to the list of [unavailableRanges].
  ///
  /// After adding, it merges overlapping ranges and re-validates the [currentRangeValues].
  void addUnavailableRange(RangeValues range) {
    unavailableRanges.add(range);
    _mergeUnavailableRanges(); // Merge to keep the list clean.

    // Re-validate the current selection as it might now be invalid.
    currentRangeValues = _getValidRangeValues(currentRangeValues);
    notifyListeners();
  }

  /// Removes a given [toRemove] range from the [unavailableRanges].
  ///
  /// This method handles various overlap scenarios to correctly adjust the existing unavailable ranges.
  /// After removal, it merges any resulting contiguous ranges.
  void removeUnavailableRange(RangeValues toRemove) {
    final newRanges = <RangeValues>[];

    for (final range in unavailableRanges) {
      // Case 1: No overlap. The range to remove is completely outside the current unavailable range.
      if (toRemove.end <= range.start || toRemove.start >= range.end) {
        newRanges.add(range);
        continue;
      }

      // Case 2: Complete overlap. The range to remove completely covers the current unavailable range.
      if (toRemove.start <= range.start && toRemove.end >= range.end) {
        // The current unavailable range is effectively removed, so we do nothing here.
        continue;
      }

      // Case 3: Partial overlap at the start. The range to remove overlaps the beginning of the current unavailable range.
      if (toRemove.start <= range.start && toRemove.end < range.end) {
        // The current unavailable range is shortened from its start.
        newRanges.add(RangeValues(toRemove.end, range.end));
        continue;
      }

      // Case 4: Partial overlap at the end. The range to remove overlaps the end of the current unavailable range.
      if (toRemove.start > range.start && toRemove.end >= range.end) {
        // The current unavailable range is shortened from its end.
        newRanges.add(RangeValues(range.start, toRemove.start));
        continue;
      }

      // Case 5: Middle overlap. The range to remove is in the middle of the current unavailable range, splitting it.
      if (toRemove.start > range.start && toRemove.end < range.end) {
        // The current unavailable range is split into two new ranges.
        newRanges.add(RangeValues(range.start, toRemove.start));
        newRanges.add(RangeValues(toRemove.end, range.end));
        continue;
      }
    }

    unavailableRanges = newRanges;
    _mergeUnavailableRanges(); // Merge any newly adjacent ranges.
    notifyListeners();
  }

  /// Configures the unavailable time slots based on a list of [CourtAvailabilitySlot] for a specific [forDate].
  /// Only processes slots where available = false (unavailable slots).
  /// This method clears previous unavailable ranges, processes the new slots, merges them,
  /// re-validates the current selection, and notifies listeners once at the end.
  void setUnavailableSlotsFromAvailability(List<CourtAvailabilitySlot> availability, DateTime forDate) {
    unavailableRanges.clear(); // Clear previous unavailable ranges.

    for (var slot in availability) {
      // Only process slots that are unavailable and for the correct date
      if (!slot.available && slot.dateIni.isSameDay(forDate)) {
        final startTime = slot.dateIni.toDouble();
        final endTime = slot.dateEnd.toDouble();

        // Only add ranges that intersect with our schedule
        if (startTime < schedule.end && endTime > schedule.start) {
          // Clamp the unavailable range to schedule bounds
          final clampedStart = startTime.clamp(schedule.start, schedule.end);
          final clampedEnd = endTime.clamp(schedule.start, schedule.end);

          if (clampedStart < clampedEnd) {
            unavailableRanges.add(RangeValues(clampedStart, clampedEnd));
          }
        }
      }
    }

    _mergeUnavailableRanges(); // Merge once after adding all new ranges.

    // Re-validate the current selection as unavailable ranges might have affected it.
    currentRangeValues = _getValidRangeValues(currentRangeValues);

    notifyListeners(); // Notify listeners once after all changes are applied.
  }

  /// Checks if the current time periods (morning, afternoon, evening) are available
  /// based on the schedule
  bool get isMorningAvailable => schedule.start < morningLimit;

  bool get isAfternoonAvailable => schedule.start < afternoonLimit && schedule.end > morningLimit;

  bool get isEveningAvailable => schedule.end > afternoonLimit;

  /// Gets the effective min and max for the current slider
  double get effectiveMin => [currentTimeIni, schedule.start].reduce((a, b) => a > b ? a : b);

  double get effectiveMax => [currentTimeEnd, schedule.end].reduce((a, b) => a < b ? a : b);

  /// Resets the time range selector to the default morning time.
  void reset() => setMorningTime();
}

/// A widget that allows users to select a time range.
///
/// It uses a [TimeRangeController] to manage its state and provides
/// choice chips for selecting predefined periods (Morning, Afternoon, Evening)
/// and a [RangeSlider] for fine-grained time selection.
/// Unavailable time slots are visually indicated on the slider.
class TimeRangeSelector extends StatefulWidget {
  final RangeValues schedule;
  final DateTime date;
  final List<CourtAvailabilitySlot> availability;

  /// Creates a [TimeRangeSelector] widget.
  const TimeRangeSelector({super.key, required this.schedule, required this.date, required this.availability});

  @override
  State<TimeRangeSelector> createState() => _TimeRangeSelectorState();
}

class _TimeRangeSelectorState extends State<TimeRangeSelector> {
  late TimeRangeController _timeRangeController;

  @override
  void initState() {
    super.initState();
    _timeRangeController = context.read<TimeRangeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateControllerSchedule();
        _updateControllerUnavailableSlots();
      }
    });
  }

  @override
  void didUpdateWidget(TimeRangeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool availabilityChanged = !listEquals(widget.availability, oldWidget.availability);
    if (widget.date != oldWidget.date || availabilityChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateControllerSchedule();
          _updateControllerUnavailableSlots();
        }
      });
    }
  }

  void _updateControllerSchedule() {
    _timeRangeController.setSchedule(widget.schedule.start, widget.schedule.end);
  }

  void _updateControllerUnavailableSlots() {
    _timeRangeController.setUnavailableSlotsFromAvailability(widget.availability, widget.date);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Consumes the TimeRangeController to react to state changes.
    return Consumer<TimeRangeController>(
      builder: (context, controller, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16.0,
          children: [
            Wrap(
              spacing: 4.0,
              children: [
                if (controller.isMorningAvailable)
                  ChoiceChip(
                    label: const Text('Morning'),
                    selected:
                        controller.currentTimeEnd == TimeRangeController.morningLimit &&
                        controller.currentTimeIni == controller.schedule.start,
                    onSelected: (_) => controller.setMorningTime(),
                  ),
                if (controller.isAfternoonAvailable)
                  ChoiceChip(
                    label: const Text('Afternoon'),
                    selected:
                        controller.currentTimeIni == TimeRangeController.morningLimit &&
                        controller.currentTimeEnd == TimeRangeController.afternoonLimit,
                    onSelected: (_) => controller.setAfternoonTime(),
                  ),
                if (controller.isEveningAvailable)
                  ChoiceChip(
                    label: const Text('Evening'),
                    selected:
                        controller.currentTimeIni == TimeRangeController.afternoonLimit &&
                        controller.currentTimeEnd == controller.schedule.end,
                    onSelected: (_) => controller.setEveningTime(),
                  ),
              ],
            ),
            Stack(
              children: [
                SliderTheme(
                  data: SliderThemeData(trackHeight: 32.0),
                  child: RangeSlider(
                    year2023: false,
                    padding: EdgeInsets.zero,
                    values: controller.currentRangeValues,
                    min: controller.effectiveMin,
                    max: controller.effectiveMax,
                    divisions: ((controller.effectiveMax - controller.effectiveMin) * 2).toInt(),
                    labels: RangeLabels(
                      controller.currentRangeValues.start.formatAsTime(),
                      controller.currentRangeValues.end.formatAsTime(),
                    ),
                    onChanged: (values) {
                      final current = controller.currentRangeValues;
                      final difference = current.end - current.start;
                      double start = values.start;
                      double end = values.end;

                      if ((current.start - values.start) > 0.5) {
                        start = values.start;
                        end = values.start + difference;
                      } else if ((values.end - current.end) > 0.5) {
                        start = values.end;
                        end = values.end + difference;
                      }

                      controller.updateRangeValues(RangeValues(start, end));
                    },
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    // Makes the painter non-interactive.
                    child: CustomPaint(
                      painter: UnavailableRangesPainter(
                        unavailableRanges: controller.unavailableRanges,
                        minTime: controller.effectiveMin,
                        maxTime: controller.effectiveMax,
                        fillColor: colorScheme.errorContainer.withAlpha(150),
                        strokeColor: colorScheme.onErrorContainer.withAlpha(150),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            InfoSectionWidget(
              leftChildren: [
                LabeledInfoWidget(
                  icon: Symbols.timelapse_rounded,
                  label: 'Selected time',
                  text:
                      '${controller.currentRangeValues.duration.inHours}h ${controller.currentRangeValues.duration.inMinutes % 60}min',
                ),
              ],
              rightChildren: [LabeledInfoWidget(icon: Symbols.payments_rounded, label: 'Price', text: '00.00 €')],
            ),
          ],
        );
      },
    );
  }
}
