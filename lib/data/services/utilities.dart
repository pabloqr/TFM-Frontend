import 'package:flutter/material.dart';
import 'package:frontend/domain/usecases/courts_use_cases.dart';
import 'package:frontend/features/courts/data/models/sport_enum.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

extension DoubleExtension on double {
  DateTime toDateTime() {
    final date = DateTime.now();
    final hours = floor();
    final minutes = ((this - hours) * 60).round();
    return DateTime(date.year, date.month, date.day, hours, minutes);
  }

  String formatAsTime() {
    final hours = floor();
    final minutes = ((this - hours) * 60).round();
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}

extension StringExtension on String {
  String toCapitalized() => length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
}

extension DateTimeExtension on DateTime {
  static DateTime fromDouble(double value) {
    final date = DateTime.now();
    final hours = value.floor();
    final minutes = ((value - hours) * 60).round();
    return DateTime(date.year, date.month, date.day, hours, minutes);
  }

  bool isSameDay(DateTime other) => year == other.year && month == other.month && day == other.day;

  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }

  double toDouble() => hour + minute / 60.0;

  String toFormattedDate() => DateFormat("dd/MM/yyyy").format(this);

  String toFormattedTime() => DateFormat("HH:mm").format(this);

  String toFormattedString() => DateFormat("E, dd/MM/yyyy, HH:mm:ss").format(this);
}

extension RangeValuesExtension on RangeValues {
  Duration get duration {
    final duration = end - start;
    final hours = duration.floor();
    return Duration(hours: hours, minutes: ((duration - hours) * 60).round());
  }

  bool contains(double time) => time >= start && time <= end;

  bool overlaps(RangeValues other) => start <= other.end && end >= other.start;
}

class NetworkUtilities {
  static String? validateQueryValue({required Type type, required dynamic value}) {
    if (type == String) {
      if (value is String) return value;
    } else if (type == int) {
      if (value is int) {
        return value.toString();
      } else if (value is String && int.tryParse(value) != null) {
        return value;
      }
    } else if (type == double) {
      if (value is double) {
        return value.toString();
      } else if (value is int) {
        return value.toDouble().toString();
      } else if (value is String && double.tryParse(value) != null) {
        return value;
      }
    } else if (type == DateTime) {
      if (value is DateTime) {
        return value.toIso8601String();
      } else if (value is String && DateTime.tryParse(value) != null) {
        return value;
      }
    }
    return null;
  }

  static Future<Set<Sport>> getComplexSports(BuildContext context, int complexId) async {
    CourtsUseCases? courtsUseCases = context.read<CourtsUseCases?>();
    if (courtsUseCases == null) return {};

    final result = await courtsUseCases.getCourts(complexId);
    return result.fold((failure) => {}, (value) => value.map((court) => court.sport).toSet());
  }
}

class WidgetUtilities {
  static Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      Placemark place = placemarks.first;

      final parts = [place.street, place.name, place.locality];
      final address = parts.where((p) => p != null && p.trim().isNotEmpty).join(", ");

      return address.isNotEmpty ? address : 'C/XXXXXXXX XXXXXXXX, 00';
    } catch (e) {
      return 'C/XXXXXXXX XXXXXXXX, 00';
    }
  }
}
