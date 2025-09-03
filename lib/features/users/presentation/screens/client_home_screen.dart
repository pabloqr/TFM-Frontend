import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/features/common/presentation/widgets/custom_filter_chip.dart';
import 'package:frontend/features/users/presentation/screens/client_dashboard_screen.dart';
import 'package:frontend/features/users/presentation/screens/client_explore_screen.dart';
import 'package:frontend/features/users/presentation/screens/client_reservations_screen.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _selectedIndex = 0;

  bool _complexSelected = false;
  bool _sportSelected = false;
  bool _statusSelected = false;
  bool _dateSelected = false;
  bool _timeIniSelected = false;
  bool _timeEndSelected = false;

  static const List<String> _titles = <String>['Dashboard', 'Reservations', 'Explore', 'Account'];

  // TODO: Replace these with your actual screen widgets
  late final List<Widget> _screens = <Widget>[
    ClientDashboardScreen(
      onReservationPressed: () {
        _onDestinationSelected(1);
      },
      onDiscoverPressed: () {
        _onDestinationSelected(2);
      },
      onNewsPressed: () {},
    ),
    const ClientReservationsScreen(),
    const ClientExploreScreen(),
    const Center(child: Text('Account Screen Content')),
  ];

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  bool _shouldShowAvatar() {
    return _selectedIndex == 3;
  }

  bool _shouldShowFloatingActionButton() {
    return _selectedIndex == 0 || _selectedIndex == 1;
  }

  bool _needsScrollBehavior() {
    return _selectedIndex == 1 || _selectedIndex == 2;
  }

  bool _shouldShowSearchBar() {
    return _selectedIndex == 2;
  }

  bool _shouldShowFilterChips() {
    return _selectedIndex == 1 || _selectedIndex == 2;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsScrollBehavior()) {
      return _buildSliverScaffold(context);
    } else {
      return _buildRegularScaffold(context);
    }
  }

  Widget _buildAppBarTrailingIcon() {
    return _shouldShowAvatar()
        ? Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                // TODO: Implement account action / navigation
              },
              child: const CircleAvatar(
                radius: 24.0,
                // TODO: Replace with user's actual avatar or initials
                child: Icon(Icons.person),
              ),
            ),
          )
        : IconButton(
            onPressed: () {
              // TODO: Implement notifications action
            },
            icon: const Icon(Icons.notifications_rounded),
          );
  }

  Widget? _buildFloatingActionButton() {
    return _shouldShowFloatingActionButton()
        ? FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).pushNamed(AppConstants.reservationNewRoute),
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
        : null;
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
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
          selectedIcon: Icon(Symbols.calendar_month_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
          label: 'Reservations',
        ),
        NavigationDestination(
          icon: Icon(Symbols.search_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
          selectedIcon: Icon(Symbols.search_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
          label: 'Explore',
        ),
        NavigationDestination(
          icon: Icon(Symbols.account_circle_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
          selectedIcon: Icon(Symbols.account_circle_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
          label: 'Account',
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 88.0),
      child: SearchBar(
        padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 16.0)),
        elevation: WidgetStateProperty.all(0),
        hintText: 'Search complexes...',
        leading: Icon(
          Symbols.search_rounded,
          size: 24,
          fill: 0,
          weight: 400,
          grade: 0,
          opticalSize: 24,
          color: colorScheme.onSurface,
        ),
        trailing: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Symbols.mic_rounded,
              size: 24,
              fill: 1,
              weight: 400,
              grade: 0,
              opticalSize: 24,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildFilterChips() {
    if (_selectedIndex == 1) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16.0, 88.0, 16.0, 8.0),
        child: Row(
          spacing: 4.0,
          children: [
            CustomFilterChip.dropDown('Status', _statusSelected, (selected) {
              setState(() => _statusSelected = selected);
            }),
            CustomFilterChip.dropDown('Complex', _complexSelected, (selected) {
              setState(() => _complexSelected = selected);
            }),
            CustomFilterChip.dropDown('Sport', _sportSelected, (selected) {
              setState(() => _sportSelected = selected);
            }),
            CustomFilterChip.dropDown('Date', _dateSelected, (selected) {
              setState(() => _dateSelected = selected);
            }),
            CustomFilterChip.dropDown('Start time', _timeIniSelected, (selected) {
              setState(() => _timeIniSelected = selected);
            }),
            CustomFilterChip.dropDown('End time', _timeEndSelected, (selected) {
              setState(() => _timeEndSelected = selected);
            }),
          ],
        ),
      );
    } else if (_selectedIndex == 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            CustomFilterChip.dropDown('Sport', _sportSelected, (selected) {
              setState(() => _sportSelected = selected);
            }),
          ],
        ),
      );
    }
    return null;
  }

  Widget _buildRegularScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex]), actions: [_buildAppBarTrailingIcon()]),
      body: _screens.elementAt(_selectedIndex),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSliverScaffold(BuildContext context) {
    final searchBarHeight = _shouldShowSearchBar() ? 64.0 : 0.0;
    final filterChipsHeight = _shouldShowFilterChips() ? 58.0 : 0.0;
    final expandedHeight = 56.0 + searchBarHeight + filterChipsHeight;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text(_titles[_selectedIndex]),
              floating: true,
              snap: true,
              pinned: true,
              expandedHeight: expandedHeight,
              actions: [_buildAppBarTrailingIcon()],
              flexibleSpace: _shouldShowSearchBar() || _shouldShowFilterChips()
                  ? FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: Column(
                        children: [
                          if (_shouldShowSearchBar()) _buildSearchBar(context),
                          if (_shouldShowFilterChips()) _buildFilterChips()!,
                        ],
                      ),
                    )
                  : null,
            ),
          ];
        },
        body: _screens.elementAt(_selectedIndex),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
