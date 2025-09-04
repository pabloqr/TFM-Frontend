import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class _Destinations {
  final String label;
  final Widget icon;
  final Widget selectedIcon;

  const _Destinations({required this.label, required this.icon, required this.selectedIcon});
}

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  static const List<_Destinations> _destinations = <_Destinations>[
    _Destinations(
      label: 'Dashboard',
      icon: Icon(Symbols.dashboard_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
      selectedIcon: Icon(Symbols.dashboard_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
    ),
    _Destinations(
      label: 'Reservations',
      icon: Icon(Symbols.calendar_month_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
      selectedIcon: Icon(Symbols.calendar_month_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
    ),
    _Destinations(
      label: 'Courts',
      icon: Icon(Symbols.sports_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
      selectedIcon: Icon(Symbols.sports_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
    ),
    _Destinations(
      label: 'Devices',
      icon: Icon(Symbols.devices_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
      selectedIcon: Icon(Symbols.devices_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
    ),
  ];

  late final List<Widget> _screens = <Widget>[
    Center(child: Text('Dashboard Screen Content')),
    Center(child: Text('Reservations Screen Content')),
    Center(child: Text('Courts Screen Content')),
    Center(child: Text('Devices Screen Content')),
  ];

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_destinations[_selectedIndex].label), actions: []),
      body: _screens.elementAt(_selectedIndex),
      floatingActionButton: _buildFloatingActionButton(),
      drawer: NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text('Header', style: Theme.of(context).textTheme.titleSmall),
          ),
          ..._destinations.map((destination) {
            return NavigationDrawerDestination(
              label: Text(destination.label),
              icon: destination.icon,
              selectedIcon: destination.selectedIcon,
            );
          }),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    return FloatingActionButton(
      // TODO: Substitute by FAB Menu
      onPressed: () {},
      child: const Icon(Symbols.edit_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
    );
  }
}
