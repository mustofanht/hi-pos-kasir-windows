import 'package:flutter/material.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';

class DynamicDotLine extends StatelessWidget {
  final int dotCount;
  final double dotWidth;
  final double dotHeight;
  final double spacing;
  final EdgeInsetsGeometry? padding;
  final Color? dotColor;
  final Axis direction;

  DynamicDotLine({
    required this.dotCount,
    this.padding,
    this.dotWidth = 5.0,
    this.dotHeight = 1.0,
    this.spacing = 4.0,
    this.dotColor,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Flex(
        direction: direction,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(dotCount, (_) {
          return Container(
            width: dotWidth,
            height: dotHeight,
            margin: direction == Axis.horizontal
                ? EdgeInsets.only(right: spacing)
                : EdgeInsets.only(bottom: spacing),
            decoration: BoxDecoration(
              color: dotColor ?? colorStyle.grey.withOpacity(0.20),
            ),
          );
        }),
      ),
    );
  }
}
