import 'package:flutter/material.dart';
import 'package:frontend/features/common/data/models/widget_size.dart';
import 'package:frontend/features/devices/data/models/weather_enum.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class WeatherCard extends StatelessWidget {
  final WidgetSize size;

  final String title;
  final double temperature;
  final Weather weather;

  final bool isCelsius;

  const WeatherCard._(
    this.size, {
    required this.title,
    required this.temperature,
    required this.weather,
    required this.isCelsius,
  });

  factory WeatherCard.small({required String title, required double temperature, required Weather weather}) =>
      WeatherCard._(WidgetSize.small, title: title, temperature: temperature, weather: weather, isCelsius: true);

  factory WeatherCard.medium({required String title, required double temperature, required Weather weather}) =>
      WeatherCard._(WidgetSize.medium, title: title, temperature: temperature, weather: weather, isCelsius: true);

  factory WeatherCard.large({required String title, required double temperature, required Weather weather}) =>
      WeatherCard._(WidgetSize.large, title: title, temperature: temperature, weather: weather, isCelsius: true);

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.secondary,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (size != WidgetSize.small)
          Padding(padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0), child: _buildHeader(context))
        else
          Padding(padding: const EdgeInsets.all(8.0), child: _buildHeader(context)),
        if (size != WidgetSize.small) ...[
          Divider(color: Theme.of(context).colorScheme.onSecondary.withAlpha(200)),
          Padding(padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0), child: _buildBody(context)),
        ],
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: size != WidgetSize.small ? 16.0 : 8.0,
      children: [
        CircleAvatar(
          radius: size != WidgetSize.small ? 28 : 12,
          backgroundColor: weather.colorSurface(context),
          child: Icon(
            weather.icon,
            size: size != WidgetSize.small ? 32 : 16,
            fill: 0,
            weight: 400,
            grade: 0,
            opticalSize: size != WidgetSize.small ? 32 : 16,
            color: weather.colorOnSurface(context),
          ),
        ),
        Expanded(child: _buildTitle(context)),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2.0,
      children: [
        Text(
          size != WidgetSize.small ? title : '${temperature.toStringAsFixed(1)}º',
          style: size != WidgetSize.small
              ? textTheme.titleLarge?.copyWith(color: colorScheme.onSecondary)
              : textTheme.titleSmall?.copyWith(color: colorScheme.onSecondary),
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        if (size != WidgetSize.small)
          Text(
            'Updated 00/00 · 00:00',
            style: textTheme.labelSmall?.copyWith(color: colorScheme.onSecondary.withAlpha(200)),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16.0,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 16.0,
          children: [
            Expanded(
              child: Text(
                '${temperature.toStringAsFixed(1)}º ${isCelsius ? 'C' : 'F'}',
                style: textTheme.headlineLarge?.copyWith(color: colorScheme.onSecondary),
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('°C')),
                ButtonSegment(value: false, label: Text('°F')),
              ],
              selected: {isCelsius},
              onSelectionChanged: (s) {},
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                side: WidgetStatePropertyAll(BorderSide(color: colorScheme.onSecondary)),
                backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  return states.contains(WidgetState.selected) ? colorScheme.inverseSurface : null;
                }),
                foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  return states.contains(WidgetState.selected) ? colorScheme.onInverseSurface : colorScheme.onSecondary;
                }),
                padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8)),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildInfoPill(context, Symbols.thermometer_gain_rounded, 'Max', '00º${isCelsius ? 'C' : 'F'}'),
            _buildInfoPill(context, Symbols.thermometer_loss_rounded, 'Min', '00º${isCelsius ? 'C' : 'F'}'),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoPill(BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: ShapeDecoration(color: colorScheme.inverseSurface, shape: StadiumBorder()),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, fill: 0, weight: 400, grade: 0, opticalSize: 18, color: colorScheme.onInverseSurface),
          const SizedBox(width: 8),
          Text('$label · $value', style: textTheme.labelLarge?.copyWith(color: colorScheme.onInverseSurface)),
        ],
      ),
    );
  }
}
