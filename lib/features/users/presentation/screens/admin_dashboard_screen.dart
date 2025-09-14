import 'package:flutter/material.dart';
import 'package:frontend/features/common/presentation/widgets/header.dart';
import 'package:frontend/features/devices/presentation/widgets/metrics_card.dart';
import 'package:frontend/features/notifications/presentation/widgets/alerts_card.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AdminDashboardScreen extends StatefulWidget {
  final int complexId;

  const AdminDashboardScreen({super.key, required this.complexId});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
        child: Column(
          spacing: 16.0,
          children: [_buildAlertsSubsection(context), _buildMetricsSubsection(context), const SizedBox(height: 56.0)],
        ),
      ),
    );
  }

  Widget _buildAlertsSubsection(BuildContext context) {
    return Column(
      spacing: 8.0,
      children: [
        Header.subheader(subheaderText: 'Alerts', showButton: false),
        AlertsCard(
          alerts: [
            Alert.error(
              title: 'Devices with low battery',
              message: 'Multiple devices have low battery alerts. Verify its state and apply any required action.',
              date: DateTime.now(),
            ),
            Alert.alert(
              title: 'Courts warning',
              message: 'Multiple courts have ongoing weather alerts.',
              date: DateTime.now(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricsSubsection(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final paddingLeft = mediaQuery.padding.left;
    final paddingRight = mediaQuery.padding.right;

    const cardMaxWidth = 160.0;
    const spacing = 8.0;

    final neededWidth = cardMaxWidth * 3.0 + spacing * 2.0;
    final cardWidth = (screenWidth - 32.0 - (spacing * 2.0) - paddingLeft - paddingRight) / 3.0;

    final fitsThree = screenWidth >= neededWidth;

    return Column(
      spacing: 8.0,
      children: [
        Header.subheader(subheaderText: 'Metrics', showButton: false),
        Row(
          children: [
            if (fitsThree)
              Row(
                spacing: 8.0,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 120.0, maxWidth: cardWidth),
                    child: MetricsCard(
                      icon: Symbols.apartment_rounded,
                      title: 'Courts occupied',
                      subtitle: '/16 total',
                      value: '24',
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 120.0, maxWidth: cardWidth),
                    child: MetricsCard(
                      icon: Symbols.apartment_rounded,
                      title: 'Courts occupied',
                      subtitle: '/16 total',
                      value: '24',
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 120.0, maxWidth: cardWidth),
                    child: MetricsCard(
                      icon: Symbols.apartment_rounded,
                      title: 'Courts occupied',
                      subtitle: '/16 total',
                      value: '24',
                    ),
                  ),
                ],
              )
            else
              Column(
                spacing: 8.0,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 120.0, maxWidth: screenWidth - 32.0),
                    child: MetricsCard(
                      icon: Symbols.apartment_rounded,
                      title: 'Courts occupied',
                      subtitle: '/16 total',
                      value: '24',
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 120.0, maxWidth: screenWidth - 32.0),
                    child: MetricsCard(
                      icon: Symbols.apartment_rounded,
                      title: 'Courts occupied',
                      subtitle: '/16 total',
                      value: '24',
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 120.0, maxWidth: screenWidth - 32.0),
                    child: MetricsCard(
                      icon: Symbols.apartment_rounded,
                      title: 'Courts occupied',
                      subtitle: '/16 total',
                      value: '24',
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
