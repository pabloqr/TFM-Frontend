import 'package:flutter/material.dart';
import 'package:frontend/features/common/presentation/widgets/header.dart';

class ImageCarousel extends StatelessWidget {
  final bool isAdmin;

  const ImageCarousel({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isAdmin)
          Header.subheader(subheaderText: 'Gallery', showButton: true, buttonText: 'Manage gallery', onPressed: () {}),
        ConstrainedBox(
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
      ],
    );
  }
}
