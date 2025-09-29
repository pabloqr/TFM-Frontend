import 'package:flutter/material.dart';

enum _HeaderType { subheader, subSubheader }

extension _HeaderTypeExtension on _HeaderType {
  TextStyle? textTheme(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    switch (this) {
      case _HeaderType.subheader:
        return textTheme.titleMedium?.copyWith(fontSize: 18.0);
      case _HeaderType.subSubheader:
        return textTheme.titleSmall;
    }
  }
}

class Header extends StatelessWidget {
  final String subheaderText;
  final bool showButton;
  final String? buttonText;
  final VoidCallback? onPressed;

  final _HeaderType _headerType;

  const Header._(
    this._headerType, {
    required this.subheaderText,
    required this.showButton,
    this.buttonText,
    this.onPressed,
  });

  factory Header.subheader({
    required String subheaderText,
    required bool showButton,
    String? buttonText,
    VoidCallback? onPressed,
  }) => Header._(
    _HeaderType.subheader,
    subheaderText: subheaderText,
    showButton: showButton,
    buttonText: buttonText,
    onPressed: onPressed,
  );

  factory Header.subSubheader({
    required String subheaderText,
    required bool showButton,
    String? buttonText,
    VoidCallback? onPressed,
  }) => Header._(
    _HeaderType.subSubheader,
    subheaderText: subheaderText,
    showButton: showButton,
    buttonText: buttonText,
    onPressed: onPressed,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(subheaderText, style: _headerType.textTheme(context)),
        if (showButton) TextButton(onPressed: onPressed, child: Text(buttonText!)),
      ],
    );
  }
}
