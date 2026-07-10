import 'package:flutter/material.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';

class CustomBadge extends StatelessWidget {
  final String label;
  final Color colorLabel;
  final Color colorBox;
  final EdgeInsetsGeometry? margin;
  const CustomBadge({
    super.key,
    required this.label,
    required this.colorLabel,
    required this.colorBox,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.all(layoutStyle.defaultMargin / 2),
      padding: EdgeInsets.all(
        layoutStyle.defaultMargin / 2,
      ),
      decoration: BoxDecoration(
        color: colorBox,
        borderRadius: BorderRadius.circular(
          layoutStyle.defaultMargin / 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: colorLabel,
          fontSize: fontSize.small,
        ),
      ),
    );
  }
}
