import 'package:flutter/material.dart';
import 'package:frontend/core/constants/theme.dart';

enum WidgetStatus { normal, alert, success, error }

extension WidgetStatusColor on WidgetStatus {
  Color colorSurface(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    
    switch (this) {
      case WidgetStatus.normal:
        return colorScheme.surface;
      case WidgetStatus.alert:
        if (brightness == Brightness.light) {
          return MaterialTheme.warning.light.colorContainer;
        } else {
          return MaterialTheme.warning.dark.colorContainer;
        }
      case WidgetStatus.success:
        if (brightness == Brightness.light) {
          return MaterialTheme.success.light.colorContainer;
        } else {
          return MaterialTheme.success.dark.colorContainer;
        }
      case WidgetStatus.error:
        return colorScheme.errorContainer;
    }
  }

  Color colorOnSurface(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;

    switch (this) {
      case WidgetStatus.normal:
        return colorScheme.onSurface;
      case WidgetStatus.alert:
        if (brightness == Brightness.light) {
          return MaterialTheme.warning.light.onColorContainer;
        } else {
          return MaterialTheme.warning.dark.onColorContainer;
        }
      case WidgetStatus.success:
        if (brightness == Brightness.light) {
          return MaterialTheme.success.light.onColorContainer;
        } else {
          return MaterialTheme.success.dark.onColorContainer;
        }
      case WidgetStatus.error:
        return colorScheme.onErrorContainer;
    }
  }
}
