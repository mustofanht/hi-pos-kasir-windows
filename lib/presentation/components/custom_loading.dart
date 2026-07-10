import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomLoading {
  popUpLoading() {
    Get.defaultDialog(
      title: "",
      titlePadding: EdgeInsets.zero,
      radius: layoutStyle.defaultMargin / 2,
      barrierDismissible: false,
      backgroundColor: colorStyle.transparent,
      contentPadding: EdgeInsets.zero,
      content: Center(
        child: CupertinoActivityIndicator(
          color: colorStyle.white,
          radius: layoutStyle.defaultMargin,
        ),
      ),
    );
  }

  Widget simpleLoading() {
    return Container(
      color: colorStyle.transparent,
      child: Center(
        child: SizedBox(
          width: layoutStyle.blockHorizontal * 5,
          height: layoutStyle.blockHorizontal * 5,
          child: CircularProgressIndicator(
            color: colorStyle.primary,
            strokeWidth: 4,
          ),
        ),
      ),
    );
  }

  Widget buttonLoading() {
    return Row(
      children: [
        SizedBox(
          height: layoutStyle.blockVertical * 2.5,
          width: layoutStyle.blockVertical * 2.5,
          child: CircularProgressIndicator(
            color: colorStyle.white,
            strokeWidth: 3,
          ),
        ),
        SizedBox(
          width: layoutStyle.defaultMargin / 2,
        ),
        Text(
          'Loading...',
          style: textStyle.whiteText,
        )
      ],
    );
  }
}

CustomLoading loading = new CustomLoading();
