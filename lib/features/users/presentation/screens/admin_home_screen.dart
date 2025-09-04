import 'package:flutter/material.dart';
import 'package:frontend/data/providers/auth_provider.dart';
import 'package:frontend/features/common/presentation/widgets/expandable_fab.dart';
import 'package:frontend/features/common/presentation/widgets/list_tile_rounded.dart';
import 'package:frontend/features/common/presentation/widgets/side_sheet.dart';
import 'package:frontend/features/devices/data/models/weather_enum.dart';
import 'package:frontend/features/devices/presentation/widgets/weather_card.dart';
import 'package:frontend/features/users/presentation/screens/admin_dashboard_screen.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

class _Destinations {
  final String title;
  final Widget icon;
  final Widget selectedIcon;

  const _Destinations({required this.title, required this.icon, required this.selectedIcon});
}

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  late ScrollController _scrollController;
  bool _isAppBarCollapsed = false;

  static const List<_Destinations> _destinations = <_Destinations>[
    _Destinations(
      title: 'Dashboard',
      icon: Icon(Symbols.dashboard_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
      selectedIcon: Icon(Symbols.dashboard_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
    ),
    _Destinations(
      title: 'Reservations',
      icon: Icon(Symbols.calendar_month_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
      selectedIcon: Icon(Symbols.calendar_month_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
    ),
    _Destinations(
      title: 'Courts',
      icon: Icon(Symbols.sports_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
      selectedIcon: Icon(Symbols.sports_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
    ),
    _Destinations(
      title: 'Devices',
      icon: Icon(Symbols.lightbulb_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
      selectedIcon: Icon(Symbols.lightbulb_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
    ),
  ];

  late final List<Widget> _screens = <Widget>[
    AdminDashboardScreen(),
    Center(child: Text('Reservations Screen Content')),
    Center(child: Text('Courts Screen Content')),
    Center(child: Text('Devices Screen Content')),
  ];

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _needsScrollBehavior() {
    return _selectedIndex == 0;
  }

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  void _performSignOut() async {
    Navigator.of(context).pop();

    final authProvider = context.read<AuthProvider?>();
    if (authProvider == null) return;

    await authProvider.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return _needsScrollBehavior() ? _buildSliverScaffold(context) : _buildRegularScaffold(context);
  }

  Widget _buildSliverScaffold(BuildContext context) {
    final expandedHeight = 56.0 + 214;
    final collapsedHeight = kToolbarHeight;

    return Scaffold(
      drawer: _buildNavigationDrawer(context),
      floatingActionButton: _buildFloatingActionButton(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text(_destinations[_selectedIndex].title),
              floating: false,
              snap: false,
              pinned: true,
              expandedHeight: expandedHeight,
              actions: _buildAppBarActions(context),
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final isCollapsed = constraints.maxHeight <= collapsedHeight + MediaQuery.of(context).padding.top;

                  if (_isAppBarCollapsed != isCollapsed) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _isAppBarCollapsed = isCollapsed;
                        });
                      }
                    });
                  }

                  return FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 88.0),
                      child: WeatherCard.medium(title: 'ComplexName', temperature: 22.7, weather: Weather.lightRain),
                    ),
                  );
                },
              ),
            ),
          ];
        },
        body: _screens.elementAt(_selectedIndex),
      ),
    );
  }

  Widget _buildRegularScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_destinations[_selectedIndex].title), actions: [_buildAppBarTrailingIcon(context)]),
      floatingActionButton: _buildFloatingActionButton(),
      drawer: _buildNavigationDrawer(context),
      body: _screens.elementAt(_selectedIndex),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _isAppBarCollapsed
            ? SizedBox(
                height: 40.0,
                width: 88.0,
                child: WeatherCard.small(title: 'ComplexName', temperature: 22.7, weather: Weather.lightRain),
              )
            : const SizedBox.shrink(key: ValueKey('empty-space')),
      ),
      _buildAppBarTrailingIcon(context),
    ];
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Text('Header', style: Theme.of(context).textTheme.titleSmall),
        ),
        ..._destinations.map((destination) {
          return NavigationDrawerDestination(
            label: Text(destination.title),
            icon: destination.icon,
            selectedIcon: destination.selectedIcon,
          );
        }),
      ],
    );
  }

  Widget _buildAppBarTrailingIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(1000),
        onTap: () => showSideSheet(
          context,
          title: 'Account',
          content: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text('My account', style: textTheme.titleMedium),
            ),
            Column(
              children: [
                ListTileRounded(title: 'Edit profile', icon: Symbols.person_rounded, onTap: () {}),
                ListTileRounded(title: 'Notifications', icon: Symbols.notifications_rounded, onTap: () {}),
                ListTileRounded(title: 'Settings', icon: Symbols.settings_rounded, onTap: () {}),
              ],
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text('Support', style: textTheme.titleMedium),
            ),
            Column(
              children: [
                ListTileRounded(title: 'Help', icon: Symbols.help_rounded, onTap: () {}),
                ListTileRounded(title: 'FAQ', icon: Symbols.question_mark_rounded, onTap: () {}),
                ListTileRounded(title: 'About this app', icon: Symbols.info_rounded, onTap: () {}),
              ],
            ),
            Divider(),
            ListTileRounded(
              title: 'Sign out',
              icon: Symbols.logout_rounded,
              contentColor: colorScheme.error,
              onTap: _performSignOut,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: const CircleAvatar(
            radius: 16.0,
            // TODO: Replace with user's actual avatar or initials
            child: Icon(Icons.person_rounded, size: 18.0, opticalSize: 18.0),
          ),
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    return ExpandableFab(
      children: [
        ActionButton(icon: Symbols.lightbulb_rounded, label: 'Assign device', onPressed: () {}),
        ActionButton(icon: Symbols.domain_add_rounded, label: 'Create court', onPressed: () {}),
      ],
    );
  }
}
