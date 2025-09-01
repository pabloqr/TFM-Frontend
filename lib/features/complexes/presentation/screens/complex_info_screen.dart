import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/features/common/presentation/widgets/custom_filter_chip.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/common/presentation/widgets/meta_data_card.dart';
import 'package:frontend/features/common/presentation/widgets/sticky_header_delegate.dart';
import 'package:frontend/features/common/presentation/widgets/subheader.dart';
import 'package:frontend/features/courts/presentation/widgets/court_list_tile.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ComplexInfoScreen extends StatefulWidget {
  const ComplexInfoScreen({super.key});

  @override
  State<ComplexInfoScreen> createState() => _ComplexInfoScreenState();
}

class _ComplexInfoScreenState extends State<ComplexInfoScreen> {
  bool _isAdmin = false;

  bool _sportSelected = false;
  bool _capacitySelected = false;

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

  @override
  Widget build(BuildContext context) {
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
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                if (_isAdmin)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: MetaDataCard(
                      id: '00000000',
                      createdAt: 'Mon, 00/00/0000, 00:00:00',
                      updatedAt: 'Mon, 00/00/0000, 00:00:00',
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      if (_isAdmin)
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
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8.0,
                    children: [
                      if (_isAdmin)
                        Subheader(subheaderText: 'ComplexName', showButton: false)
                      else
                        Subheader(
                          subheaderText: 'ComplexName',
                          showButton: true,
                          buttonText: 'Get directions',
                          onPressed: () {},
                        ),
                      InfoSectionWidget(
                        leftChildren: [
                          LabeledInfoWidget(icon: Symbols.location_on_rounded, label: 'Address', text: 'C/XXXX, 00'),
                        ],
                        rightChildren: [
                          LabeledInfoWidget(icon: Symbols.schedule_rounded, label: 'Schedule', text: '00:00 - 00:00'),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyHeaderDelegate(
                minHeight: _isAdmin ? 184.0 : 170.0,
                maxHeight: _isAdmin ? 184.0 : 170.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    spacing: 16.0,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isAdmin)
                            Subheader(
                              subheaderText: 'Courts',
                              showButton: true,
                              buttonText: 'Manage courts',
                              onPressed: () {},
                            )
                          else
                            Subheader(subheaderText: 'Courts', showButton: false),
                          if (!_isAdmin) const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            spacing: 8.0,
                            children: [
                              CustomFilterChip.dropDown('Sport', _sportSelected, (selected) {
                                setState(() {
                                  _sportSelected = selected;
                                });
                              }),
                              CustomFilterChip.dropDown('Capacity', _capacitySelected, (selected) {
                                setState(() {
                                  _capacitySelected = selected;
                                });
                              }),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          const InfoSectionWidget(
                            leftChildren: [
                              LabeledInfoWidget(icon: Symbols.tag_rounded, label: 'Number of courts', text: '00'),
                              LabeledInfoWidget(
                                icon: Symbols.payments_rounded,
                                label: 'Price per hour',
                                text: '00.00 €',
                              ),
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverList.separated(
              itemCount: 10,
              itemBuilder: (context, index) {
                return CourtListTile(
                  name: 'Court $index',
                  onTap: () {
                    Navigator.of(context).pushNamed(AppConstants.courtInfoRoute);
                  },
                  isAdmin: _isAdmin,
                );
              },
              separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
            ),
          ],
        ),
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {},
              label: Text('Edit complex'),
              icon: const Icon(Symbols.edit_rounded, size: 24, fill: 1, weight: 400, grade: 0, opticalSize: 24),
            )
          : FloatingActionButton.extended(
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
            ),
    );
  }
}
