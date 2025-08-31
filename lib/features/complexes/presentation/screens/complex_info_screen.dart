import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/features/common/presentation/widgets/card_chip_widget.dart';
import 'package:frontend/features/common/presentation/widgets/info_section_widget.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:frontend/features/common/presentation/widgets/sticky_header_delegate.dart';
import 'package:frontend/features/common/presentation/widgets/subheader_widget.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ComplexInfoScreen extends StatefulWidget {
  const ComplexInfoScreen({super.key});

  @override
  State<ComplexInfoScreen> createState() => _ComplexInfoScreenState();
}

class _ComplexInfoScreenState extends State<ComplexInfoScreen> {
  bool _sportSelected = false;

  @override
  Widget build(BuildContext context) {
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
              title: const Text('Complex details'),
              pinned: true,
              expandedHeight: 348.0,
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 56.0),
                      child: ConstrainedBox(
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
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8.0,
                        children: [
                          SubheaderWidget(
                            subheaderText: 'ComplexName',
                            showButton: true,
                            buttonText: 'Get directions',
                            onPressed: () {},
                          ),
                          InfoSectionWidget(
                            leftChildren: [
                              LabeledInfoWidget(
                                icon: Symbols.location_on_rounded,
                                label: 'Address',
                                text: 'C/XXXX, 00',
                              ),
                            ],
                            rightChildren: [
                              LabeledInfoWidget(
                                icon: Symbols.schedule_rounded,
                                label: 'Schedule',
                                text: '00:00 - 00:00',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyHeaderDelegate(
                minHeight: 210.0,
                maxHeight: 210.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    spacing: 16.0,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8.0,
                        children: [
                          SubheaderWidget(subheaderText: 'Courts', showButton: false),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            spacing: 8.0,
                            children: [
                              FilterChip(
                                label: Row(
                                  spacing: 8.0,
                                  children: [
                                    Text('Sport'),
                                    Icon(
                                      Symbols.arrow_drop_down_rounded,
                                      size: 18,
                                      fill: 0,
                                      weight: 400,
                                      grade: 0,
                                      opticalSize: 18,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 8.0),
                                selected: _sportSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _sportSelected = selected;
                                  });
                                },
                              ),
                            ],
                          ),
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
          ],
          body: ListView.separated(
            separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                title: Row(
                  spacing: 8.0,
                  children: [
                    Text(
                      'Court $index',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Wrap(
                      spacing: 4.0,
                      runSpacing: 4.0,
                      alignment: WrapAlignment.end,
                      children: [
                        CardChipWidget.alert('Sport'),
                        if (Random().nextBool()) CardChipWidget.success('Available'),
                      ],
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    spacing: 16.0,
                    children: [
                      Expanded(
                        child: LabeledInfoWidget(
                          icon: Symbols.groups_rounded,
                          label: 'Capacity',
                          text: '${4 + Random().nextInt(8)}',
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: Icon(Symbols.chevron_right_rounded),
                onTap: () {},
              );
            },
          ),
        ),
      ),
    );
  }
}
