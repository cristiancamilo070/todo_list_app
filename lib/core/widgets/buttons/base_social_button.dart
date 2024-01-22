import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BaseSocialButton extends StatelessWidget {
  final double size;
  final String assetImage;
  final void Function() onPressed;

  const BaseSocialButton({
    Key? key,
    required this.size,
    required this.onPressed,
    required this.assetImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      splashRadius: 25,
      padding: EdgeInsets.zero,
      icon: SvgPicture.asset(
        assetImage,
        height: size,
      ),
    );
  }
}
