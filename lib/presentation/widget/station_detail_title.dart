import 'package:flutter/material.dart';
import 'package:gomdori_bus/core/constant/color.dart';
import 'package:gomdori_bus/core/constant/text_style.dart';
import 'package:gomdori_bus/domain/entity/station.dart';

class StationDetailTitle extends StatelessWidget {
  const StationDetailTitle({
    super.key,
    required this.station,
    required this.previousName,
    required this.nextName,
    this.size,
    this.onPreviousClick,
    this.onCurrentClick,
    this.onNextClick,
  });

  final Size? size;

  final Station station;
  final String? previousName;
  final String? nextName;

  final void Function()? onPreviousClick;
  final void Function()? onCurrentClick;
  final void Function()? onNextClick;

  Widget currentPoint(Size size) {
    final double width = size.width * currentWidthRatio;

    Widget child = Text(
      station.name,
      style: StationDetailTextStyle.currentTitle,
      textAlign: TextAlign.center,
    );
    if (onCurrentClick != null) {
      child = InkWell(onTap: onCurrentClick, child: child);
    }

    return Container(
      width: width,
      padding: EdgeInsets.only(top: 1.0, bottom: 8.0),
      decoration: ShapeDecoration(
        color: ThemeColor.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        shadows: [
          BoxShadow(
            color: ThemeColor.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget otherCircle() => Container(
    width: 24,
    height: 24,
    decoration: ShapeDecoration(color: ThemeColor.black, shape: OvalBorder()),
  );

  Widget otherPoint(
    String? name,
    TextStyle style,
    void Function()? onClick,
    Size size,
  ) {
    final double width = size.width * (1 - currentWidthRatio) / 2;
    final padding = EdgeInsets.only(top: 24, bottom: 6);
    return Container(
      padding: padding,
      width: width,
      child: name != null ? GestureDetector(
        onTap: onClick,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 3.0,
          children: [
            otherCircle(),
            Text(name, style: style, overflow: TextOverflow.ellipsis),
          ],
        ),
      ) : const SizedBox.shrink(),
    );
  }

  Widget divider(double width, double thickness) => SizedBox(
    width: width,
    height: thickness * 2,
    child: Divider(color: ThemeColor.primaryTextColor, thickness: thickness),
  );

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? MediaQuery.of(context).size;
    final width = size.width;

    return SizedBox(
      width: width,
      // height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 18.5, child: divider(width, 6.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              otherPoint(
                previousName,
                StationDetailTextStyle.previousTitle,
                onPreviousClick,
                size,
              ),
              currentPoint(size),
              otherPoint(
                nextName,
                StationDetailTextStyle.nextTitle,
                onNextClick,
                size,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const double currentWidthRatio = .45;
}
