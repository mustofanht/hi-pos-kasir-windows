import 'package:flutter/material.dart';
import 'package:jaya_propertiy/app/utils/constant/filter_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';

class CustomRadioButton extends StatelessWidget {
  final Axis direction;
  final dynamic groupValue;
  final List<dynamic> items;
  final Function(dynamic)? onChanged;

  const CustomRadioButton({
    Key? key,
    required this.direction,
    required this.groupValue,
    required this.items,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (direction == Axis.horizontal) {
      // for radio horizontal
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: items
            .map(
              (e) => Row(
                children: [
                  Radio<dynamic>(
                    value: e,
                    groupValue: groupValue,
                    onChanged: (dynamic value) {
                      onChanged!(value as dynamic);
                    },
                  ),
                  Text(
                    (e is SortType) ? e.label.toString() : e.toString(),
                    style:
                        textStyle.blackText.copyWith(fontSize: fontSize.small),
                  )
                ],
              ),
            )
            .toList(),
      );
    } else {
      // for radio vertical
      return Column(
        children: items
            .map(
              (e) => ListTile(
                title: Text(
                  (e is SortType) ? e.label.toString() : e.toString(),
                  style: textStyle.blackText.copyWith(fontSize: fontSize.small),
                ),
                contentPadding: EdgeInsets.zero,
                horizontalTitleGap: 0,
                leading: Radio<dynamic>(
                  value: e,
                  groupValue: groupValue,
                  onChanged: (dynamic value) {
                    onChanged!(value as dynamic);
                  },
                ),
              ),
            )
            .toList(),
      );
    }
  }
}
