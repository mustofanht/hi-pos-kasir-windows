import 'package:flutter/material.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';

class CustomCardTransaction extends StatelessWidget {
  final bool? isSelected;
  const CustomCardTransaction({
    super.key,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: layoutStyle.defaultMargin / 2),
      padding: EdgeInsets.all(layoutStyle.defaultMargin),
      decoration: BoxDecoration(
        border: Border.all(
          color: colorStyle.primary,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(
          layoutStyle.defaultMargin / 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User 1',
                  style: textStyle.blackText.copyWith(
                    fontSize: fontSize.header,
                    fontWeight: fontWeight.bold,
                  ),
                ),
                Text(
                  'Lokasi : Spatan',
                  style: textStyle.blackText.copyWith(
                    color: colorStyle.grey,
                  ),
                ),
                Text(
                  'Product : Gazebo 2',
                  style: textStyle.blackText.copyWith(
                    color: colorStyle.grey,
                  ),
                ),
                SizedBox(
                  height: layoutStyle.defaultMargin,
                ),
                Text(
                  'Durasi Sewa : 3 Jam, 12:00 - 15:00',
                  style: textStyle.blackText,
                ),
              ],
            ),
          ),
          !isSelected!
              ? Text(
                  'Pilih',
                  style: textStyle.primaryColor.copyWith(
                    fontWeight: fontWeight.bold,
                    fontSize: fontSize.title,
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
