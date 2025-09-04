import 'package:flutter/material.dart';
import 'package:frontend/features/common/data/models/widget_status.dart';

class AlertsCard extends StatelessWidget {
  final List<Alert> alerts;

  const AlertsCard({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card.filled(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: List.generate(alerts.length * 2 - 1, (index) {
            if (index.isEven) {
              final alert = alerts[index ~/ 2];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  spacing: 16.0,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: alert.status.colorSurface(context),
                      child: Icon(
                        alert.status.icon,
                        size: 24,
                        fill: 0,
                        weight: 400,
                        grade: 0,
                        opticalSize: 24,
                        color: alert.status.colorOnSurface(context),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(alert.title, style: textTheme.titleMedium),
                          Text(
                            alert.message,
                            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${alert.date.hour}:${alert.date.minute}',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            } else {
              return const Divider();
            }
          }),
        ),
      ),
    );
  }
}

class Alert {
  final String title;
  final String message;
  final DateTime date;
  final WidgetStatus status;

  Alert._({required this.title, required this.message, required this.date, required this.status});

  factory Alert.neutralSurface({required String title, required String message, required DateTime date}) =>
      Alert._(title: title, message: message, date: date, status: WidgetStatus.neutralSurface);

  factory Alert.neutralCard({required String title, required String message, required DateTime date}) =>
      Alert._(title: title, message: message, date: date, status: WidgetStatus.neutralCard);

  factory Alert.alert({required String title, required String message, required DateTime date}) =>
      Alert._(title: title, message: message, date: date, status: WidgetStatus.alert);

  factory Alert.success({required String title, required String message, required DateTime date}) =>
      Alert._(title: title, message: message, date: date, status: WidgetStatus.success);

  factory Alert.error({required String title, required String message, required DateTime date}) =>
      Alert._(title: title, message: message, date: date, status: WidgetStatus.error);
}
