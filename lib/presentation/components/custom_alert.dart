import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAlert {
  SnackbarController success(String title, String msg) {
    return Get.snackbar(
      title,
      msg,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOut,
      snackPosition: SnackPosition.TOP,
      backgroundColor: colorStyle.green,
      colorText: colorStyle.white,
      duration: const Duration(seconds: 2),
      icon: Icon(
        Icons.check_circle_rounded,
        color: colorStyle.white,
      ),
      onTap: (snack) {
        Get.back();
      },
    );
  }

  SnackbarController warning(String title, String msg) {
    return Get.snackbar(
      title,
      msg,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOut,
      snackPosition: SnackPosition.TOP,
      backgroundColor: colorStyle.yellow,
      colorText: colorStyle.white,
      duration: const Duration(seconds: 2),
      icon: Icon(
        Icons.check_circle_rounded,
        color: colorStyle.white,
      ),
      onTap: (snack) {
        Get.back();
      },
    );
  }

  SnackbarController error(String title, String msg) {
    return Get.snackbar(
      title,
      msg,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOut,
      snackPosition: SnackPosition.TOP,
      backgroundColor: colorStyle.red,
      colorText: colorStyle.white,
      duration: const Duration(seconds: 2),
      icon: Icon(
        Icons.dangerous,
        color: colorStyle.white,
      ),
      onTap: (snack) {
        Get.back();
      },
    );
  }
}

CustomAlert alert = new CustomAlert();
