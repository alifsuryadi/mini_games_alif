import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/styles/app_sizes.dart';
import '../../core/styles/card_colors/card_color_model.dart';

class CardWidget extends StatelessWidget {
  final bool isMoved;
  final bool isHovered;
  final double? paddingShadow;
  final CardColorModel cardColor;
  final BorderRadius? radius;
  final int? duration;
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const CardWidget({
    super.key,
    required this.isMoved,
    required this.isHovered,
    required this.cardColor,
    required this.child,
    this.paddingShadow,
    this.radius,
    this.duration,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    double paddingShadowValue = paddingShadow ?? 6.w;
    final radiusValue = radius ?? AppSizes.radiusSmall;

    return AnimatedContainer(
      margin: EdgeInsets.only(
          right: paddingShadowValue, bottom: paddingShadowValue),
      duration: Duration(milliseconds: duration ?? 300),
      transform: Matrix4.translationValues(
          isMoved ? (paddingShadowValue / 2) : 0,
          isMoved ? (paddingShadowValue / 2) : 0,
          0),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isHovered ? cardColor.hover.card : cardColor.card,
        borderRadius: radiusValue,
        border: Border.all(
          color: isHovered ? cardColor.hover.shadow : cardColor.shadow,
          width: paddingShadowValue / 2,
        ),
      ),
      child: Container(
        width: width,
        height: height,
        padding: padding,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
