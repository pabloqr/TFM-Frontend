import 'package:flutter/material.dart';
import 'package:frontend/features/common/presentation/widgets/custom_filter_chip.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/common/presentation/widgets/medium_chip.dart';
import 'package:frontend/features/common/presentation/widgets/sticky_header_delegate.dart';
import 'package:frontend/features/common/presentation/widgets/subheader.dart';
import 'package:frontend/features/devices/presentation/widgets/device_list_tile.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class CourtInfoScreen extends StatefulWidget {
  const CourtInfoScreen({super.key});

  @override
  State<CourtInfoScreen> createState() => _CourtInfoScreenState();
}

class _CourtInfoScreenState extends State<CourtInfoScreen> {
  bool _isAdmin = true;

  bool _typeSelected = false;
  bool _statusSelected = false;

  Widget _buildCarouselView() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 200.0),
      child: CarouselView(
        itemExtent: 200.0,
        children: List<Widget>.generate(10, (int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.asset('assets/images/placeholders/court.jpg', fit: BoxFit.cover),
          );
        }),
      ),
    );
  }

  Widget _buildCourtInfoSubsection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Subheader(subheaderText: 'CourtName', showButton: true, buttonText: 'Get directions', onPressed: () {}),
        const Text(
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis in ligula purus. Ut mattis ut dolor quis porta. Phasellus rutrum arcu tortor, sed placerat lectus vestibulum eget.',
        ),
        const SizedBox(height: 8.0),
        InfoSectionWidget(
          leftChildren: [
            LabeledInfoWidget(icon: Symbols.sports_rounded, label: 'Sport', text: 'Sport'),
            LabeledInfoWidget(icon: Symbols.payments_rounded, label: 'Price per hour', text: '00.00 €'),
          ],
          rightChildren: [
            LabeledInfoWidget(icon: Symbols.groups_rounded, label: 'Capacity', text: '00'),
            LabeledInfoWidget(
              icon: Symbols.payments_rounded,
              filledIcon: true,
              label: 'Price per hour (with light)',
              text: '00.00 €',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComplexInfoSubsection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.0,
      children: [
        Subheader(subheaderText: 'ComplexName', showButton: false),
        InfoSectionWidget(
          leftChildren: [LabeledInfoWidget(icon: Symbols.location_on_rounded, label: 'Address', text: 'C/XXXX, 00')],
          rightChildren: [LabeledInfoWidget(icon: Symbols.schedule_rounded, label: 'Schedule', text: '00:00 - 00:00')],
        ),
      ],
    );
  }

  Widget _buildRegularView() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Complex details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCarouselView(),
              _buildCourtInfoSubsection(),
              const SizedBox(height: 16.0),
              _buildComplexInfoSubsection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrollView() {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              title: const Text('Court details'),
              actions: [Padding(padding: const EdgeInsets.only(right: 16.0), child: MediumChip.alert('Weather'))],
              pinned: true,
              expandedHeight: 598.0,
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 48.0),
                      child: Column(
                        children: [
                          Subheader(
                            subheaderText: 'Gallery',
                            showButton: true,
                            buttonText: 'Manage gallery',
                            onPressed: () {},
                          ),
                          _buildCarouselView(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        spacing: 16.0,
                        children: [_buildCourtInfoSubsection(), _buildComplexInfoSubsection()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyHeaderDelegate(
                minHeight: 216.0,
                maxHeight: 216.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    spacing: 16.0,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Subheader(
                            subheaderText: 'Devices',
                            showButton: true,
                            buttonText: 'Manage devices',
                            onPressed: () {},
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            spacing: 8.0,
                            children: [
                              CustomFilterChip.dropDown('Type', _typeSelected, (selected) {
                                setState(() {
                                  _typeSelected = selected;
                                });
                              }),
                              CustomFilterChip.dropDown('Status', _statusSelected, (selected) {
                                setState(() {
                                  _statusSelected = selected;
                                });
                              }),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          const InfoSectionWidget(
                            leftChildren: [
                              LabeledInfoWidget(icon: Symbols.tag_rounded, label: 'Number of devices', text: '00'),
                              LabeledInfoWidget(icon: Symbols.mode_off_on_rounded, label: 'Devices on', text: '00'),
                            ],
                            rightChildren: [
                              LabeledInfoWidget(
                                icon: Symbols.check_circle_rounded,
                                label: 'Normal operation',
                                text: '00',
                              ),
                              LabeledInfoWidget(icon: Symbols.cancel_rounded, label: 'Warning/Error', text: '00'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: ListView.separated(
            separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
            itemCount: 10,
            itemBuilder: (context, index) {
              return DeviceListTile(name: 'Device $index', onTap: () {});
            },
          ),
        ),
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {},
              label: Text('Edit court'),
              icon: const Icon(Symbols.edit_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return _buildRegularView();
    } else {
      return _buildScrollView();
    }
  }
}
