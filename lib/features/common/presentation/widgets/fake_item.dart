import 'package:flutter/material.dart';

class FakeItem extends StatelessWidget {
  const FakeItem({super.key, required this.isBig});

  final bool isBig;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      height: isBig ? 128 : 36,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
    );
  }
}