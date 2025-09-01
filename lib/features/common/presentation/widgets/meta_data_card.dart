import 'package:flutter/material.dart';
import 'package:frontend/features/common/presentation/widgets/labeled_info_widget.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class MetaDataCard extends StatelessWidget {
  final String id;
  final String createdAt;
  final String updatedAt;

  final List<LabeledInfoWidget>? additionalMetadata;

  const MetaDataCard({
    super.key,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.additionalMetadata,
  });

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.0,
          children: [
            LabeledInfoWidget(icon: Symbols.tag_rounded, label: 'Reference', text: id),
            ...?additionalMetadata,
            LabeledInfoWidget(icon: Symbols.calendar_add_on_rounded, label: 'Created at', text: createdAt),
            LabeledInfoWidget(icon: Symbols.edit_rounded, label: 'Updated at', text: updatedAt),
          ],
        ),
      ),
    );
  }
}
