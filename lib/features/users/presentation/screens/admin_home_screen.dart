import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/data/providers/auth_provider.dart';
import 'package:frontend/features/common/presentation/widgets/custom_filter_chip.dart';
import 'package:frontend/features/common/presentation/widgets/expandable_fab.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/common/presentation/widgets/list_tile_rounded.dart';
import 'package:frontend/features/common/presentation/widgets/side_sheet.dart';
import 'package:frontend/features/complexes/presentation/screens/complex_info_screen.dart';
import 'package:frontend/features/devices/data/models/weather_enum.dart';
import 'package:frontend/features/devices/presentation/widgets/weather_card.dart';
import 'package:frontend/features/users/presentation/screens/admin_courts.dart';
import 'package:frontend/features/users/presentation/screens/admin_dashboard_screen.dart';
import 'package:frontend/features/users/presentation/screens/admin_devices.dart';
import 'package:frontend/features/users/presentation/screens/admin_reservations_screen.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

class _Destination {
  final String title;
  final Widget icon;
  final Widget selectedIcon;

  const _Destination({required this.title, required this.icon, required this.selectedIcon});
}

class AdminHomeScreen extends StatefulWidget {
  final int complexId;

  const AdminHomeScreen({super.key, required this.complexId});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> with SingleTickerProviderStateMixin {
  late int _complexId;

  int _selectedIndex = 0;
  int _selectedTabIndex = 0;

  bool _statusSelected = false;
  bool _sportSelected = false;
  bool _dateSelected = false;
  bool _timeIniSelected = false;
  bool _timeEndSelected = false;

  late ScrollController _scrollController;
  late TabController _tabController;

  bool _isAppBarCollapsed = false;

  static const List<_Destination> _destinations = <_Destination>[
    _Destination(
      title: 'Dashboard',
      icon: Icon(Symbols.dashboard_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
      selectedIcon: Icon(Symbols.dashboard_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
    ),
    _Destination(
      title: 'Reservations',
      icon: Icon(Symbols.calendar_month_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
      selectedIcon: Icon(Symbols.calendar_month_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
    ),
    _Destination(
      title: 'Courts',
      icon: Icon(Symbols.location_on_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
      selectedIcon: Icon(Symbols.location_on_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
    ),
    _Destination(
      title: 'Devices',
      icon: Icon(Symbols.lightbulb_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
      selectedIcon: Icon(Symbols.lightbulb_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
    ),
  ];

  static const List<_Destination> _subDestinations = [
    _Destination(
      title: 'Telemetry',
      icon: Icon(Symbols.timeline_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
      selectedIcon: Icon(Symbols.timeline_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
    ),
    _Destination(
      title: 'Courts',
      icon: Icon(Symbols.location_on_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
      selectedIcon: Icon(Symbols.location_on_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
    ),
    _Destination(
      title: 'Devices',
      icon: Icon(Symbols.lightbulb_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
      selectedIcon: Icon(Symbols.lightbulb_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
    ),
  ];

  late final List<Widget> _screens = <Widget>[
    AdminDashboardScreen(complexId: _complexId),
    AdminReservationsScreen(complexId: _complexId),
    Center(child: Text('Courts Screen Content')),
    Center(child: Text('Devices Screen Content')),
    ComplexInfoScreen(complexId: _complexId),
  ];

  late final List<List<Widget>> _subScreens = [
    [AdminCourts.telemetry(complexId: _complexId), AdminCourts.list(complexId: _complexId)],
    [AdminDevices.telemetry(complexId: _complexId), AdminDevices.list(complexId: _complexId)],
  ];

  @override
  void initState() {
    super.initState();

    _complexId = widget.complexId;

    _scrollController = ScrollController();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTabIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _shouldShowWeatherCard() {
    return _selectedIndex == 0;
  }

  bool _shouldShowFilterChips() {
    return _selectedIndex == 1 || _selectedIndex == 2 || _selectedIndex == 3;
  }

  bool _shouldShowInfoSection() {
    return _selectedIndex == 1 || _selectedIndex == 2 || _selectedIndex == 3;
  }

  bool _shouldShowTabs() {
    return _selectedIndex == 2 || _selectedIndex == 3;
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
    return _buildSliverScaffold(context);
  }

  Widget _buildSliverScaffold(BuildContext context) {
    return Scaffold(
      drawer: _buildNavigationDrawer(context),
      floatingActionButton: _buildFloatingActionButton(),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final weatherCardHeight = _shouldShowWeatherCard() ? 214.0 : 0.0;
    final filterChipsHeight = _shouldShowFilterChips() ? 58.0 : 0.0;
    final infoSectionHeight = _shouldShowInfoSection() ? 96.0 : 0.0;
    final tabsHeight = _shouldShowTabs() ? 82.0 : 0.0;
    final expandedHeight = 56.0 + weatherCardHeight + filterChipsHeight + infoSectionHeight + tabsHeight;
    final collapsedHeight = kToolbarHeight;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            title: Text(
              _selectedIndex < 4 ? _destinations[_selectedIndex].title : 'Complex',
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            floating: !_shouldShowWeatherCard(),
            snap: !_shouldShowWeatherCard(),
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
                    padding: const EdgeInsets.only(top: 88.0),
                    child: Column(
                      spacing: 8.0,
                      children: [
                        if (_shouldShowWeatherCard())
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: WeatherCard.medium(
                              title: 'ComplexName',
                              temperature: 22.7,
                              weather: Weather.lightRain,
                            ),
                          ),
                        if (_shouldShowTabs()) _buildTabBar(),
                        if (_shouldShowFilterChips())
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: _buildFilterChips()),
                        if (_shouldShowInfoSection()) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                            child: _buildInfoSection(),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ];
      },
      body: _shouldShowTabs() ? _buildTabBarView() : _screens.elementAt(_selectedIndex),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: !_shouldShowWeatherCard() || _isAppBarCollapsed
            ? _buildAppBarWeatherCard()
            : const SizedBox.shrink(key: ValueKey('empty-space')),
      ),
      _buildAppBarTrailingIcon(context),
    ];
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    return SafeArea(
      child: NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        children: [
          const SizedBox(height: 28.0),
          ..._destinations.map((destination) {
            return NavigationDrawerDestination(
              label: Text(destination.title),
              icon: destination.icon,
              selectedIcon: destination.selectedIcon,
            );
          }),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text('General', style: Theme.of(context).textTheme.titleSmall),
          ),
          NavigationDrawerDestination(
            label: Text('Complex'),
            icon: Icon(Symbols.apartment_rounded, size: 24, fill: 0, weight: 400, grade: 0, opticalSize: 24),
            selectedIcon: Icon(Symbols.apartment_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarWeatherCard() {
    return SizedBox(
      height: 40.0,
      width: 88.0,
      child: WeatherCard.small(title: 'ComplexName', temperature: 22.7, weather: Weather.lightRain),
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
                ListTileRounded(
                  title: 'Settings',
                  icon: Symbols.settings_rounded,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed(AppConstants.adminSettingsRoute);
                  },
                ),
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

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 8.0),
      child: Row(
        spacing: 4.0,
        children: [
          CustomFilterChip.dropDown('Status', _statusSelected, (selected) {
            setState(() => _statusSelected = selected);
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
  }

  Widget _buildInfoSection() {
    return InfoSectionWidget(
      leftChildren: [
        if (_selectedIndex == 1) ...[
          LabeledInfoWidget(icon: Symbols.tag_rounded, label: 'Number of reservations', text: '00'),
          LabeledInfoWidget(icon: Symbols.rainy_light_rounded, label: 'Weather alerts', text: '00'),
        ] else if (_selectedIndex == 2) ...[
          LabeledInfoWidget(icon: Symbols.tag_rounded, label: 'Number of courts', text: '00'),
          if (_selectedTabIndex == 0)
            LabeledInfoWidget(icon: Symbols.rainy_light_rounded, label: 'Weather alerts', text: '00')
          else
            LabeledInfoWidget(icon: Symbols.payments_rounded, label: 'Price per hour', text: '00.00 €'),
        ] else if (_selectedIndex == 3) ...[
          LabeledInfoWidget(icon: Symbols.tag_rounded, label: 'Number of devices', text: '00'),
          LabeledInfoWidget(icon: Symbols.mode_off_on_rounded, label: 'Devices on', text: '00'),
        ],
      ],
      rightChildren: [
        if (_selectedIndex == 1) ...[
          LabeledInfoWidget(icon: Symbols.check_circle_rounded, label: 'Completed', text: '00'),
          LabeledInfoWidget(icon: Symbols.cancel_rounded, label: 'Cancelled/Not occupied', text: '00'),
        ] else if (_selectedIndex == 2)
          if (_selectedTabIndex == 0) ...[
            LabeledInfoWidget(icon: Symbols.check_circle_rounded, label: 'Open', text: '00'),
            LabeledInfoWidget(icon: Symbols.cancel_rounded, label: 'Closed/Maintenance', text: '00'),
          ] else ...[
            LabeledInfoWidget(icon: Symbols.groups_rounded, label: 'Capacity', text: '00'),
            LabeledInfoWidget(
              icon: Symbols.payments_rounded,
              filledIcon: true,
              label: 'Price per hour (with light)',
              text: '00.00 €',
            ),
          ]
        else if (_selectedIndex == 3) ...[
          LabeledInfoWidget(icon: Symbols.check_circle_rounded, label: 'Normal operation', text: '00'),
          LabeledInfoWidget(icon: Symbols.cancel_rounded, label: 'Warnings/Errors', text: '00'),
        ],
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: List.generate(2, (index) {
        return Tab(
          text: _subDestinations.elementAt(index * (_selectedIndex - 1)).title,
          icon: _subDestinations.elementAt(index * (_selectedIndex - 1)).icon,
        );
      }),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(controller: _tabController, children: _subScreens.elementAt((_selectedIndex - 2) % 2));
  }

  Widget? _buildFloatingActionButton() {
    if (_selectedIndex == 1) {
      return FloatingActionButton.extended(
        onPressed: () =>
            Navigator.of(context).pushNamed(AppConstants.reservationNewRoute, arguments: {'isAdmin': true}),
        label: const Text('Book'),
        icon: const Icon(Symbols.calendar_add_on_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
      );
    }

    if (_selectedIndex == 4) {
      return FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Edit complex'),
        icon: const Icon(Symbols.edit_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
      );
    }

    return ExpandableFab(
      children: [
        if (_selectedIndex == 0)
          ActionButton(icon: Symbols.lightbulb_rounded, label: 'Assign device', onPressed: () {})
        else if (_selectedIndex == 2 || _selectedIndex == 3)
          ActionButton(icon: Symbols.timeline_rounded, label: 'Post telemetry', onPressed: () {}),
        if (_selectedIndex == 0 || _selectedIndex == 2)
          ActionButton(icon: Symbols.add_location_alt_rounded, label: 'Create court', onPressed: () {})
        else if (_selectedIndex == 3)
          ActionButton(icon: Symbols.lightbulb_rounded, label: 'Assign device', onPressed: () {}),
      ],
    );
  }
}
