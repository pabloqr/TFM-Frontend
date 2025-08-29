import 'package:flutter/material.dart';
import 'package:frontend/features/users/presentation/screens/client_dashboard_screen.dart';
import 'package:frontend/features/users/presentation/screens/client_explore_screen.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _selectedIndex = 0;

  static const List<String> _titles = <String>['Dashboard', 'Reservations', 'Explore', 'Account'];

  // TODO: Replace these with your actual screen widgets
  static const List<Widget> _screens = <Widget>[
    ClientDashboardScreen(),
    Center(child: Text('Reservations Screen Content')),
    // Center(child: Text('Explore Screen Content')),
    ClientExploreScreen(),
    Center(child: Text('Account Screen Content')),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          if (_selectedIndex == 3)
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: GestureDetector(
                onTap: () {
                  // TODO: Implement account action / navigation
                },
                child: const CircleAvatar(
                  radius: 24,
                  // TODO: Replace with user's actual avatar or initials
                  child: Icon(Icons.person),
                ),
              ),
            )
          else
            IconButton(
              onPressed: () {
                // TODO: Implement notifications action
              },
              icon: const Icon(Icons.notifications_rounded),
            ),
        ],
      ),
      body: _screens.elementAt(_selectedIndex),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                // TODO: Implement booking action
              },
              label: const Text('Book'),
              icon: const Icon(
                Symbols.calendar_add_on_rounded,
                size: 24,
                fill: 1,
                weight: 400,
                grade: 0,
                opticalSize: 24,
              ),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Symbols.home_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
            selectedIcon: Icon(Symbols.home_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Symbols.calendar_month_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
            selectedIcon: Icon(
              Symbols.calendar_month_rounded,
              size: 24,
              fill: 1,
              weight: 400,
              grade: 0,
              opticalSize: 24,
            ),
            label: 'Reservations',
          ),
          NavigationDestination(
            icon: Icon(Symbols.search_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
            selectedIcon: Icon(Symbols.search_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Symbols.account_circle_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
            selectedIcon: Icon(
              Symbols.account_circle_rounded,
              size: 24,
              fill: 1,
              weight: 400,
              grade: 0,
              opticalSize: 24,
            ),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
