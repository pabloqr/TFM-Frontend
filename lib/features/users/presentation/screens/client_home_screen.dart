import 'package:flutter/material.dart';
import 'package:frontend/features/common/presentation/widgets/custom_filter_chip.dart';
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
  bool _sportSelected = false;

  static const List<String> _titles = <String>['Dashboard', 'Reservations', 'Explore', 'Account'];

  // TODO: Replace these with your actual screen widgets
  static const List<Widget> _screens = <Widget>[
    ClientDashboardScreen(),
    Center(child: Text('Reservations Screen Content')),
    ClientExploreScreen(),
    Center(child: Text('Account Screen Content')),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool _shouldShowAvatar() {
    return _selectedIndex == 3;
  }

  bool _shouldShowFloatingActionButton() {
    return _selectedIndex == 0 || _selectedIndex == 1;
  }

  bool _needsScrollBehavior() {
    return _selectedIndex == 2;
  }

  bool _shouldShowSearchBar() {
    return _selectedIndex == 2;
  }

  Widget _buildAppBarTrailingIcon() {
    return _shouldShowAvatar()
        ? Padding(
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

  Widget _buildRegularScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex]), actions: [_buildAppBarTrailingIcon()]),
      body: _screens.elementAt(_selectedIndex),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSliverScaffold(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text(_titles[_selectedIndex]),
              floating: true,
              snap: true,
              pinned: true,
              expandedHeight: _shouldShowSearchBar() ? 178.0 : 56.0,
              actions: [_buildAppBarTrailingIcon()],
              flexibleSpace: _shouldShowSearchBar()
                  ? FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 88.0),
                            child: SearchBar(
                              padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 16.0)),
                              elevation: WidgetStateProperty.all(0),
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
                                Tooltip(
                                  message: 'Change brightness mode',
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Symbols.mic_rounded,
                                      size: 24,
                                      fill: 0,
                                      weight: 400,
                                      grade: 0,
                                      opticalSize: 24,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              children: [
                                CustomFilterChip.dropDown('Sport', _sportSelected, (selected) {
                                  setState(() {
                                    _sportSelected = selected;
                                  });
                                }),
                              ],
                            ),
                          ),
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

  @override
  Widget build(BuildContext context) {
    if (_needsScrollBehavior()) {
      return _buildSliverScaffold(context);
    } else {
      return _buildRegularScaffold(context);
    }
  }
}
