import 'package:flutter_svg/svg.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_dropdown_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
import 'package:jaya_propertiy/presentation/controllers/common/print_controller.dart';

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
      duration: const Duration(seconds: 3),
      icon: Icon(
        Icons.check_circle_rounded,
        color: colorStyle.white,
      ),
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
      duration: const Duration(seconds: 3),
      icon: Icon(
        Icons.check_circle_rounded,
        color: colorStyle.white,
      ),
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
      duration: const Duration(seconds: 3),
      icon: Icon(
        Icons.dangerous,
        color: colorStyle.white,
      ),
    );
  }

  dialogDelete({
    required String title,
    required String msg,
    required Function onYes,
  }) {
    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: layoutStyle.screenWidth / 2,
          height: layoutStyle.blockVertical * 30,
          decoration: BoxDecoration(
            color: colorStyle.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(50),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        assetsConstant.icInformationDialog,
                        alignment: Alignment.topCenter,
                        fit: BoxFit.fill,
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: fontSize.title,
                          fontWeight: fontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: layoutStyle.defaultMargin / 5,
                      ),
                      Flexible(
                        child: Text(
                          msg,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fontSize.body,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: layoutStyle.screenWidth,
                height: layoutStyle.blockVertical * 7,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: layoutStyle.screenWidth,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: colorStyle.grey.withOpacity(0.20),
                                width: 1.0,
                              ),
                              right: BorderSide(
                                color: colorStyle.grey.withOpacity(0.20),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Text(
                            'No',
                            style: TextStyle(
                              color: colorStyle.red,
                              fontSize: fontSize.subtitle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          onYes();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: layoutStyle.screenWidth,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: colorStyle.grey.withOpacity(0.20),
                                width: 1.0,
                              ),
                              left: BorderSide(
                                color: colorStyle.grey.withOpacity(0.20),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Text(
                            'Yes',
                            style: TextStyle(
                              color: colorStyle.blue,
                              fontSize: fontSize.subtitle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  dialogSuccess({
    required String title,
    required String msg,
    required Function onYes,
  }) {
    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: layoutStyle.screenWidth / 2,
          height: layoutStyle.blockVertical * 30,
          decoration: BoxDecoration(
            color: colorStyle.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(50),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        assetsConstant.icInformationDialog,
                        alignment: Alignment.topCenter,
                        fit: BoxFit.fill,
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: fontSize.title,
                          fontWeight: fontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: layoutStyle.defaultMargin / 5,
                      ),
                      Flexible(
                        child: Text(
                          msg,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fontSize.body,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: layoutStyle.screenWidth,
                height: layoutStyle.blockVertical * 7,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: layoutStyle.screenWidth,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: colorStyle.grey.withOpacity(0.20),
                                width: 1.0,
                              ),
                              right: BorderSide(
                                color: colorStyle.grey.withOpacity(0.20),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Text(
                            'No',
                            style: TextStyle(
                              color: colorStyle.red,
                              fontSize: fontSize.subtitle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          onYes();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: layoutStyle.screenWidth,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: colorStyle.grey.withOpacity(0.20),
                                width: 1.0,
                              ),
                              left: BorderSide(
                                color: colorStyle.grey.withOpacity(0.20),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Text(
                            'Yes',
                            style: TextStyle(
                              color: colorStyle.blue,
                              fontSize: fontSize.subtitle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  waitingPayment({
    required String title,
    required String msg,
    required Function onCheck,
    required Function onCancle,
  }) {
    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: layoutStyle.screenWidth / 2,
          height: layoutStyle.blockVertical * 30,
          decoration: BoxDecoration(
            color: colorStyle.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(50),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        assetsConstant.icInformationDialog,
                        alignment: Alignment.topCenter,
                        fit: BoxFit.fill,
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: fontSize.title,
                          fontWeight: fontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: layoutStyle.defaultMargin / 5,
                      ),
                      Flexible(
                        child: Text(
                          msg,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fontSize.body,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: layoutStyle.screenWidth,
                height: layoutStyle.blockVertical * 7,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          onCancle();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: layoutStyle.screenWidth,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: colorStyle.grey.withOpacity(0.20),
                                width: 1.0,
                              ),
                              right: BorderSide(
                                color: colorStyle.grey.withOpacity(0.20),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              color: colorStyle.red,
                              fontSize: fontSize.subtitle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          onCheck();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: layoutStyle.screenWidth,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: colorStyle.grey.withOpacity(0.20),
                                width: 1.0,
                              ),
                              left: BorderSide(
                                color: colorStyle.grey.withOpacity(0.20),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Text(
                            'Cek',
                            style: TextStyle(
                              color: colorStyle.blue,
                              fontSize: fontSize.subtitle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  paymentQrSuccess({
    required String title,
    required String msg,
    required Function onSendProofOfPayment,
    required Function onPrint,
  }) {
    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: layoutStyle.screenWidth / 2,
          height: layoutStyle.blockVertical * 50,
          decoration: BoxDecoration(
            color: colorStyle.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(50),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(layoutStyle.defaultMargin),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: layoutStyle.defaultMargin),
                          child: SvgPicture.asset(
                            assetsConstant.icPaymentSuccess,
                            alignment: Alignment.topCenter,
                            width: layoutStyle.blockHorizontal * 15,
                            height: layoutStyle.blockVertical * 15,
                          ),
                        ),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: fontSize.header,
                            fontWeight: fontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: layoutStyle.defaultMargin / 5,
                        ),
                        Flexible(
                          child: Text(
                            msg,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: fontSize.subtitle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: layoutStyle.screenWidth,
                  height: layoutStyle.blockVertical * 7,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            onPrint();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: layoutStyle.screenWidth,
                            padding:
                                EdgeInsets.all(layoutStyle.defaultMargin / 2),
                            margin: EdgeInsets.symmetric(
                                horizontal: layoutStyle.defaultMargin / 2),
                            decoration: BoxDecoration(
                              color: colorStyle.primary,
                              borderRadius: BorderRadius.circular(
                                layoutStyle.defaultMargin / 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.print,
                                  color: colorStyle.white,
                                  size: fontSize.title,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: layoutStyle.defaultMargin / 2,
                                  ),
                                  child: Text(
                                    'Cetak',
                                    style: TextStyle(
                                      color: colorStyle.white,
                                      fontSize: fontSize.subtitle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            onSendProofOfPayment();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: layoutStyle.screenWidth,
                            padding:
                                EdgeInsets.all(layoutStyle.defaultMargin / 2),
                            margin: EdgeInsets.symmetric(
                                horizontal: layoutStyle.defaultMargin / 2),
                            decoration: BoxDecoration(
                              color: colorStyle.primary,
                              borderRadius: BorderRadius.circular(
                                layoutStyle.defaultMargin / 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.send,
                                  color: colorStyle.white,
                                  size: fontSize.title,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: layoutStyle.defaultMargin / 2,
                                  ),
                                  child: Text(
                                    'Kirim Bukti Pembayaran',
                                    style: TextStyle(
                                      color: colorStyle.white,
                                      fontSize: fontSize.subtitle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  paymentSendProofOfPayment({
    required String title,
    required Function(String val) onSendEmail,
    required Function(String val) onSendWa,
    required Function onNewOrder,
  }) {
    final emailController = TextEditingController();
    final waController = TextEditingController();
    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: layoutStyle.screenWidth / 2,
          height: layoutStyle.blockVertical * 63,
          decoration: BoxDecoration(
            color: colorStyle.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(50),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(layoutStyle.defaultMargin),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: layoutStyle.defaultMargin),
                          child: SvgPicture.asset(
                            assetsConstant.icPaymentSuccess,
                            alignment: Alignment.topCenter,
                            width: layoutStyle.blockHorizontal * 15,
                            height: layoutStyle.blockVertical * 15,
                          ),
                        ),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: fontSize.header,
                            fontWeight: fontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: layoutStyle.defaultMargin / 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomTextBox(
                              width: layoutStyle.blockHorizontal * 25,
                              height: layoutStyle.blockVertical * 6.5,
                              margin: EdgeInsets.symmetric(
                                // horizontal: layoutStyle.defaultMargin,
                                vertical: layoutStyle.defaultMargin / 4,
                              ),
                              obscureText: false,
                              border: Border.all(
                                color: colorStyle.grey,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(
                                  layoutStyle.defaultMargin / 2,
                                ),
                                topLeft: Radius.circular(
                                  layoutStyle.defaultMargin / 2,
                                ),
                              ),
                              controller: emailController,
                              decoration: InputDecoration(
                                hintText: 'Email Receipt',
                                hintStyle: textStyle.greyText,
                                border: InputBorder.none,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                onSendEmail(emailController.text);
                              },
                              child: Container(
                                width: layoutStyle.blockHorizontal * 5,
                                height: layoutStyle.blockVertical * 6.5,
                                decoration: BoxDecoration(
                                  color: colorStyle.primary,
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(
                                      layoutStyle.defaultMargin / 2,
                                    ),
                                    topRight: Radius.circular(
                                      layoutStyle.defaultMargin / 2,
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Kirim',
                                    style: textStyle.whiteText,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: layoutStyle.defaultMargin / 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomTextBox(
                              width: layoutStyle.blockHorizontal * 25,
                              height: layoutStyle.blockVertical * 6.5,
                              margin: EdgeInsets.symmetric(
                                // horizontal: layoutStyle.defaultMargin,
                                vertical: layoutStyle.defaultMargin / 4,
                              ),
                              obscureText: false,
                              border: Border.all(
                                color: colorStyle.grey,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(
                                  layoutStyle.defaultMargin / 2,
                                ),
                                topLeft: Radius.circular(
                                  layoutStyle.defaultMargin / 2,
                                ),
                              ),
                              controller: waController,
                              decoration: InputDecoration(
                                hintText: 'Nomor Whatsapp',
                                hintStyle: textStyle.greyText,
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            GestureDetector(
                              onTap: () {
                                onSendEmail(waController.text);
                              },
                              child: Container(
                                width: layoutStyle.blockHorizontal * 5,
                                height: layoutStyle.blockVertical * 6.5,
                                decoration: BoxDecoration(
                                  color: colorStyle.primary,
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(
                                      layoutStyle.defaultMargin / 2,
                                    ),
                                    topRight: Radius.circular(
                                      layoutStyle.defaultMargin / 2,
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Kirim',
                                    style: textStyle.whiteText,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                CustomButton(
                  margin: EdgeInsets.symmetric(
                    vertical: layoutStyle.defaultMargin / 2,
                    horizontal: layoutStyle.defaultMargin,
                  ),
                  onPressed: () {
                    onNewOrder();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith(
                      (states) => colorStyle.white,
                    ),
                    overlayColor: MaterialStateProperty.resolveWith(
                      (states) => colorStyle.black.withOpacity(0.1),
                    ),
                    side: MaterialStateProperty.resolveWith(
                      (states) => BorderSide(
                        color: colorStyle.black,
                        width: 1.0,
                      ),
                    ),
                    shape: MaterialStateProperty.resolveWith(
                      (states) => RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          layoutStyle.defaultMargin / 2,
                        ),
                      ),
                    ),
                    elevation: const MaterialStatePropertyAll(0),
                  ),
                  label: Text(
                    'Order Baru',
                    style: textStyle.blackText,
                  ),
                  width: layoutStyle.blockHorizontal * 30,
                  height: layoutStyle.blockVertical * 6.5,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  waitingPaymentEdc({
    required String title,
    required String msg,
    required Function(String reffNo) onNext,
  }) {
    final reffNoController = TextEditingController();
    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: layoutStyle.screenWidth / 2,
          height: layoutStyle.blockVertical * 40,
          decoration: BoxDecoration(
            color: colorStyle.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(50),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                    vertical: layoutStyle.defaultMargin / 5,
                    horizontal: layoutStyle.defaultMargin,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        assetsConstant.icInformationDialog,
                        alignment: Alignment.topCenter,
                        fit: BoxFit.fill,
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: fontSize.title,
                          fontWeight: fontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: layoutStyle.defaultMargin / 5,
                      ),
                      Flexible(
                        child: Text(
                          msg,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fontSize.body,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: layoutStyle.defaultMargin / 5,
                      ),
                      CustomTextBox(
                        // width: layoutStyle.blockHorizontal * 25,
                        height: layoutStyle.blockVertical * 6.5,
                        margin: EdgeInsets.symmetric(
                          vertical: layoutStyle.defaultMargin / 2,
                          horizontal: layoutStyle.defaultMargin,
                        ),
                        obscureText: false,
                        border: Border.all(
                          color: colorStyle.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(
                          layoutStyle.defaultMargin / 2,
                        ),
                        controller: reffNoController,
                        decoration: InputDecoration(
                          hintText: 'Tulis Nomor Reference ID',
                          hintStyle: textStyle.greyText,
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: layoutStyle.screenWidth,
                padding: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 5,
                  horizontal: layoutStyle.defaultMargin,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomButton(
                        margin: EdgeInsets.symmetric(
                          vertical: layoutStyle.defaultMargin / 2,
                          horizontal: layoutStyle.defaultMargin,
                        ),
                        onPressed: () {
                          Get.back();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => colorStyle.red,
                          ),
                          overlayColor: MaterialStateProperty.resolveWith(
                            (states) => colorStyle.black.withOpacity(0.1),
                          ),
                          shape: MaterialStateProperty.resolveWith(
                            (states) => RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                layoutStyle.defaultMargin / 2,
                              ),
                            ),
                          ),
                          elevation: const MaterialStatePropertyAll(0),
                        ),
                        label: Text(
                          'Batal',
                          style: textStyle.whiteText,
                        ),
                        height: layoutStyle.blockVertical * 6.5,
                      ),
                    ),
                    Expanded(
                      child: CustomButton(
                        margin: EdgeInsets.symmetric(
                          vertical: layoutStyle.defaultMargin / 2,
                          horizontal: layoutStyle.defaultMargin,
                        ),
                        onPressed: () {
                          onNext(reffNoController.text);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => colorStyle.primary,
                          ),
                          overlayColor: MaterialStateProperty.resolveWith(
                            (states) => colorStyle.black.withOpacity(0.1),
                          ),
                          shape: MaterialStateProperty.resolveWith(
                            (states) => RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                layoutStyle.defaultMargin / 2,
                              ),
                            ),
                          ),
                          elevation: const MaterialStatePropertyAll(0),
                        ),
                        label: Text(
                          'Lanjutkan',
                          style: textStyle.whiteText,
                        ),
                        height: layoutStyle.blockVertical * 6.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  selectPrint({
    required String title,
    required String msg,
    required Function() onPrint,
  }) async {
    var printController = Get.put(PrintController());
    await printController.getBluetoots();
    final listPrinter = [
      CustomIdNameEntity(id: null, name: '--- Select Printer ---')
    ];
    listPrinter.addAll(printController.listBluetooth
        .map((element) =>
            CustomIdNameEntity(id: element.macAdress, name: element.name))
        .toList());
    printController.selectedPrinter.value = listPrinter.first;
    printController.update();

    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: layoutStyle.screenWidth / 2,
          height: layoutStyle.blockVertical * 40,
          decoration: BoxDecoration(
            color: colorStyle.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(50),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                    vertical: layoutStyle.defaultMargin / 5,
                    horizontal: layoutStyle.defaultMargin,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        assetsConstant.icInformationDialog,
                        alignment: Alignment.topCenter,
                        fit: BoxFit.fill,
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: fontSize.title,
                          fontWeight: fontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: layoutStyle.defaultMargin / 5,
                      ),
                      Flexible(
                        child: Text(
                          msg,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fontSize.body,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: layoutStyle.defaultMargin / 5,
                      ),
                      CustomDropdownButton<CustomIdNameEntity>(
                        height: layoutStyle.blockVertical * 6.5,
                        items: listPrinter
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text("${e.name}"),
                              ),
                            )
                            .toList(),
                        value: printController.selectedPrinter.value,
                        // label: Text(
                        //   'Pilih Printer',
                        //   style: textStyle.greyText.copyWith(
                        //     fontSize: fontSize.small,
                        //   ),
                        // ),
                        border: Border.all(
                          color: colorStyle.lightGrey,
                          width: 1,
                        ),
                        margin: EdgeInsets.symmetric(
                          vertical: layoutStyle.defaultMargin / 4,
                          horizontal: layoutStyle.defaultMargin,
                        ),
                        onChanged: (val) async {
                          printController.selectedPrinter.value = val;
                          printController.update();
                          if (val != null) {
                            await printController.connect(val.id!);
                            await onPrint();
                          } else {
                            alert.error('Print', 'Please selected printer');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

CustomAlert alert = new CustomAlert();
