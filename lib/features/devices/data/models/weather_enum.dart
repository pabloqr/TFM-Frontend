import 'package:flutter/material.dart';
import 'package:frontend/core/constants/theme.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

enum Weather { clear, lightRain, heavyRain }

extension WeatherExtension on Weather {
  Color colorSurface(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (this) {
      case Weather.clear:
        return colorScheme.primaryContainer;
      case Weather.lightRain:
        final brightness = Theme.of(context).brightness;

        return brightness == Brightness.light
            ? MaterialTheme.warning.light.colorContainer
            : MaterialTheme.warning.dark.colorContainer;
      case Weather.heavyRain:
        return colorScheme.errorContainer;
    }
  }

  Color colorOnSurface(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (this) {
      case Weather.clear:
        return colorScheme.onPrimaryContainer;
      case Weather.lightRain:
        final brightness = Theme.of(context).brightness;

        return brightness == Brightness.light
            ? MaterialTheme.warning.light.onColorContainer
            : MaterialTheme.warning.dark.onColorContainer;
      case Weather.heavyRain:
        return colorScheme.onErrorContainer;
    }
  }

  IconData get icon {
    switch (this) {
      case Weather.clear:
        return Symbols.sunny_rounded;
      case Weather.lightRain:
        return Symbols.rainy_light_rounded;
      case Weather.heavyRain:
        return Symbols.rainy_heavy_rounded;
    }
  }
}
