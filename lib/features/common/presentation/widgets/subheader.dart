import 'package:flutter/material.dart';

class Subheader extends StatelessWidget {
  final String subheaderText;
  final bool showButton;
  final String? buttonText;
  final VoidCallback? onPressed;

  const Subheader({
    super.key,
    required this.subheaderText,
    required this.showButton,
    this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(subheaderText, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
        if (showButton) TextButton(onPressed: onPressed, child: Text(buttonText!)),
      ],
    );
  }
}
