import 'package:flutter/material.dart';
import 'package:gomdori_bus/core/constant/color.dart';


class FloatingButton extends StatelessWidget {
  final Size size;
  final Widget icon;
  final void Function() onPressed;

  const FloatingButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = const Size(75, 75),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.all(14),
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          color: ThemeColor.hightlightTextColor,
          shadows: [
            BoxShadow(
              color: ThemeColor.shadowColor,
              blurRadius: 4,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: icon,
      ),
    );
  }
}
