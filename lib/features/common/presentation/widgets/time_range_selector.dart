import 'package:flutter/material.dart';
import 'package:frontend/data/services/utilities.dart';
import 'package:frontend/features/common/presentation/utilities/unavailable_range_painter.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

/// Manages the state for the time range selection.
///
/// This includes the current time range, unavailable time slots,
/// and methods to update and manage these values.
class TimeRangeController extends ChangeNotifier {
  /// Defines the upper limit for the morning time slot.
  static const double morningLimit = 12.0;

  /// Defines the upper limit for the afternoon time slot.
  static const double afternoonLimit = 18.0;

  /// Defines the upper limit for the night time slot.
  static const double nightLimit = 24.0;

  /// The start of the current time window being displayed/selected.
  double currentTimeIni = 8.0;

  /// The end of the current time window being displayed/selected.
  double currentTimeEnd = morningLimit;

  /// The currently selected range of values by the user.
  late RangeValues currentRangeValues;

  /// A list of time ranges that are not available for selection.
  List<RangeValues> unavailableRanges = [
    RangeValues(8.0, 9.0),
    // RangeValues(10.0, 11.0),
    RangeValues(10.0, 13.0),
    RangeValues(15.0, 16.0),
    RangeValues(18.0, 19.0),
  ];

  /// Initializes the controller, setting the initial time to the morning slot.
  TimeRangeController() {
    setMorningTime();
  }

  /// Adjusts the provided [rangeValue] to ensure it's valid and does not improperly overlap with unavailable ranges.
  ///
  /// It clamps the start and end values to the current time window and adjusts them
  /// if they intersect with any [unavailableRanges].
  RangeValues _getValidRangeValues(RangeValues rangeValue) {
    double start = rangeValue.start;
    double end = rangeValue.end;

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

    // Ensure the start and end are within the current active time window (currentTimeIni, currentTimeEnd).
    // A minimum duration of 0.5 (30 minutes) is enforced.
    start = start.clamp(currentTimeIni, currentTimeEnd - 0.5);
    end = end.clamp(start + 0.5, currentTimeEnd);

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

  /// Sets the current time selection window to the morning period (8:00 AM - 12:00 PM).
  ///
  /// Initializes [currentRangeValues] to a default 1-hour slot at the beginning of this period.
  void setMorningTime() {
    currentTimeIni = 8.0;
    currentTimeEnd = morningLimit;
    currentRangeValues = _getValidRangeValues(RangeValues(currentTimeIni, currentTimeIni + 1.0));
    notifyListeners();
  }

  /// Sets the current time selection window to the afternoon period (12:00 PM - 6:00 PM).
  ///
  /// Initializes [currentRangeValues] to a default 1-hour slot at the beginning of this period.
  void setAfternoonTime() {
    currentTimeIni = morningLimit;
    currentTimeEnd = afternoonLimit;
    currentRangeValues = _getValidRangeValues(RangeValues(currentTimeIni, currentTimeIni + 1.0));
    notifyListeners();
  }

  /// Sets the current time selection window to the evening period (6:00 PM - 12:00 AM).
  ///
  /// Initializes [currentRangeValues] to a default 1-hour slot at the beginning of this period.
  void setEveningTime() {
    currentTimeIni = afternoonLimit;
    currentTimeEnd = nightLimit;
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

  /// Resets the time range selector to the default morning time.
  void reset() => setMorningTime();
}

/// A widget that allows users to select a time range.
///
/// It uses a [TimeRangeController] to manage its state and provides
/// choice chips for selecting predefined periods (Morning, Afternoon, Evening)
/// and a [RangeSlider] for fine-grained time selection.
/// Unavailable time slots are visually indicated on the slider.
class TimeRangeSelector extends StatelessWidget {
  /// Creates a [TimeRangeSelector] widget.
  const TimeRangeSelector({super.key});

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
                ChoiceChip(
                  label: const Text('Morning'),
                  selected: controller.currentTimeEnd == TimeRangeController.morningLimit,
                  onSelected: (_) => controller.setMorningTime(),
                ),
                ChoiceChip(
                  label: const Text('Afternoon'),
                  selected: controller.currentTimeEnd == TimeRangeController.afternoonLimit,
                  onSelected: (_) => controller.setAfternoonTime(),
                ),
                ChoiceChip(
                  label: const Text('Evening'),
                  selected: controller.currentTimeEnd == TimeRangeController.nightLimit,
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
                    min: controller.currentTimeIni,
                    max: controller.currentTimeEnd,
                    divisions: ((controller.currentTimeEnd - controller.currentTimeIni) * 2).toInt(),
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
                        minTime: controller.currentTimeIni,
                        maxTime: controller.currentTimeEnd,
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
