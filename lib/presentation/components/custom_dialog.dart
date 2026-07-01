import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/data/models/cart/cart_rent_model.dart';
import 'package:jaya_propertiy/domain/entities/auth/auth_token.dart';
import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
import 'package:jaya_propertiy/domain/entities/member/member_list.dart';
import 'package:jaya_propertiy/domain/entities/member/member_valid.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/domain/entities/transaction/transaction_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_dropdown_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_list_transaction.dart';
import 'package:jaya_propertiy/presentation/components/custom_select_hours_rent.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
import 'package:jaya_propertiy/presentation/views/modules/member/membership_payment.dart';

class CustomDialog {
  Future<bool> dialog({
    String? imgIcon,
    required String title,
    required String msg,
    required Function onYes,
  }) {
    return Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: layoutStyle.screenWidth,
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
                        imgIcon ?? assetsConstant.icInformationDialog,
                        alignment: Alignment.topCenter,
                        width: layoutStyle.safeBlockHorizontal * 14,
                        height: layoutStyle.safeBlockHorizontal * 14,
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
    ).then((value) => value ?? false);
  }

  dialogCustomerLeftRight({
    String? imgIcon,
    required String title,
    required String msg,
    required String labelLeft,
    required String labelRight,
    required Function onLeft,
    required Function onRight,
  }) {
    return Get.dialog(
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
                child: Padding(
                  padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        imgIcon ?? assetsConstant.icInformationDialog,
                        alignment: Alignment.topCenter,
                        width: layoutStyle.blockHorizontal * 8,
                        height: layoutStyle.blockVertical * 8,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
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
                            Text(
                              msg,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: fontSize.body,
                              ),
                            ),
                          ],
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
                          onLeft();
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
                            labelLeft,
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
                          onRight();
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
                            labelRight,
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

  waitingPaymentWithQr({
    required String title,
    required String msg,
    String? qrCode,
    required Function onCheck,
    required Function onCancle,
  }) {
    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: layoutStyle.screenWidth / 2,
          height: layoutStyle.blockVertical * 45,
          decoration: BoxDecoration(
            color: colorStyle.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(50),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
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
                    Expanded(
                      child: Container(
                        child: common.getQrImg(
                          qrCode!,
                        ),
                      ),
                    ),
                  ],
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
    required Function() onSendProofOfPayment,
    required Function() onPrint,
  }) {
    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: layoutStyle.screenWidth / 2 + 50,
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
                          onTap: onPrint,
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
                          onTap: onSendProofOfPayment,
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
    String? orderEmailValue,
    String? orderNoWaValue,
    required Function(String val) onSendEmail,
    required Function(String val) onSendWa,
    required Function onNewOrder,
    String? labelButton,
  }) {
    final emailController = TextEditingController();
    final waController = TextEditingController();
    if (orderEmailValue != null) {
      emailController.text = orderEmailValue;
    }
    if (orderNoWaValue != null) {
      waController.text = orderNoWaValue;
    }
    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: layoutStyle.screenWidth / 2,
          height: layoutStyle.blockVertical * 68,
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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
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
                                  onSendWa(waController.text);
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
                    labelButton ?? 'Order Baru',
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
  }) async {
    final reffNoController = TextEditingController();
    await Get.dialog(
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
                        maxLength: 30,
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

  dialogActiovcationTicket({
    required String title,
    required String msg,
    required Function(String reffNo) onNext,
  }) {
    final reasonController = TextEditingController();
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
                        height: layoutStyle.blockVertical * 12,
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
                        controller: reasonController,
                        decoration: InputDecoration(
                          hintText: 'Tulis Alasan',
                          hintStyle: textStyle.greyText,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(
                            layoutStyle.defaultMargin * 4,
                          ),
                        ),
                        maxLine: 5,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: layoutStyle.screenWidth,
                padding: EdgeInsets.symmetric(
                  // vertical: layoutStyle.defaultMargin / 5,
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
                          vertical: layoutStyle.defaultMargin / 5,
                          horizontal: layoutStyle.defaultMargin,
                        ),
                        onPressed: () => onNext(reasonController.text),
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

  dialogVoidTicket({
    required String title,
    required String msg,
    required List<CustomIdNameEntity> listReason,
    required Rxn<CustomIdNameEntity> selectReason,
    required RxBool etcReason,
    required Function(String reffNo) onNext,
  }) {
    final reasonController = TextEditingController();
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
          child: Column(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                    vertical: layoutStyle.defaultMargin / 5,
                    horizontal: layoutStyle.defaultMargin,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
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
                      Text(
                        msg,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSize.body,
                        ),
                      ),
                      SizedBox(
                        height: layoutStyle.defaultMargin / 5,
                      ),
                      Obx(
                        () => CustomDropdownButton<CustomIdNameEntity>(
                          height: layoutStyle.blockVertical * 6.5,
                          items: listReason
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text("${e.name}"),
                                ),
                              )
                              .toList(),
                          value: selectReason.value,
                          label: Text(
                            'Pilih Alasan',
                            style: textStyle.greyText.copyWith(
                              fontSize: fontSize.small,
                            ),
                          ),
                          border: Border.all(
                            color: colorStyle.lightGrey,
                            width: 1,
                          ),
                          margin: EdgeInsets.symmetric(
                            vertical: layoutStyle.defaultMargin / 4,
                            horizontal: layoutStyle.defaultMargin,
                          ),
                          onChanged: (CustomIdNameEntity? reasonVal) {
                            selectReason.value = reasonVal;
                            etcReason.value = reasonVal?.id == 'LN';
                          },
                        ),
                      ),
                      SizedBox(
                        height: layoutStyle.defaultMargin / 2,
                      ),
                      Obx(
                        () => !etcReason.value
                            ? Container()
                            : CustomTextBox(
                                height: layoutStyle.blockVertical * 6.5,
                                margin: EdgeInsets.symmetric(
                                  horizontal: layoutStyle.defaultMargin,
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
                                controller: reasonController,
                                decoration: InputDecoration(
                                  hintText: 'Alasan',
                                  hintStyle: textStyle.greyText,
                                  border: InputBorder.none,
                                ),
                              ),
                      )
                    ],
                  ),
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
                          if (selectReason.value?.id == null) {
                            alert.error('Error', 'please select reason void');
                          } else {
                            if (selectReason.value?.id == 'LN') {
                              if (reasonController.text.isEmpty) {
                                alert.error(
                                  'Error',
                                  'Alasan tidak boleh kosong!',
                                );
                              } else {
                                onNext(reasonController.text);
                              }
                            } else {
                              onNext(selectReason.value!.name!);
                            }
                          }
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

  selectHourRent({
    required Function(CartRentModel cartRentModel) onNext,
    required AddonEntity entitiy,
    required AuthToken authToken,
    bool isExtraTime = false,
    CartRentModel? detailModel,
  }) async {
    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: layoutStyle.screenWidth / 2,
          height: layoutStyle.blockVertical * 70,
          decoration: BoxDecoration(
            color: colorStyle.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(50),
            ),
          ),
          child: CustomSelectHoursRent(
            onNext: onNext,
            entitiy: entitiy,
            detailModel: detailModel,
            authToken: authToken,
            isExtraTime: isExtraTime,
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  selectListTransaction({
    required Function(TransactionEntity selected) onNext,
    required AddonEntity entitiy,
    required AuthToken authToken,
  }) async {
    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: layoutStyle.screenWidth / 3,
          height: layoutStyle.blockVertical * 70,
          decoration: BoxDecoration(
            color: colorStyle.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(50),
            ),
          ),
          child: CustomListTransaction(
            onNext: onNext,
            entitiy: entitiy,
            authToken: authToken,
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  dialodExtraTimeOrClosedRent({
    required Function() onExtraTime,
    required Function() onClosed,
  }) {
    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: layoutStyle.screenWidth / 2.5,
          height: layoutStyle.blockVertical * 35,
          decoration: BoxDecoration(
            color: colorStyle.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(50),
            ),
          ),
          child: Stack(
            children: [
              Column(
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
                            'Extra Time / Akhiri Sewa',
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
                              'Apakah anda akan melakukan Extra Time Atau Mengakhiri Sewa ?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: fontSize.body,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: layoutStyle.defaultMargin / 5,
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
                              onExtraTime();
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
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
                              'Tambah Sesi',
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
                              Get.back();
                              onClosed();
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
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
                              'Akhiri Sewa',
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
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(
                    Icons.close,
                    color: colorStyle.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  closedRent({
    required Function() onNext,
    required AddonEntity entitiy,
    required AuthToken authToken,
    CartRentModel? detailModel,
  }) async {
    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: layoutStyle.screenWidth / 2.5,
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
                        'Akhiri Sewa',
                        style: TextStyle(
                          fontSize: fontSize.title,
                          fontWeight: fontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: layoutStyle.defaultMargin / 5,
                      ),
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                            text:
                                'Apakah anda yakin akan mengakhiri sesi sewa item ',
                            style: TextStyle(
                              fontSize: fontSize.body,
                            ),
                            children: [
                              TextSpan(
                                text: '${entitiy.productName}',
                                style: TextStyle(
                                  fontWeight: fontWeight.bold,
                                  fontSize: fontSize.body,
                                ),
                              ),
                              TextSpan(
                                text: ' ?',
                                style: textStyle.blackText,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: layoutStyle.defaultMargin / 5,
                      ),
                      // Container(
                      //   width: layoutStyle.safeBlockHorizontal * 30,
                      //   padding: EdgeInsets.symmetric(
                      //       vertical: layoutStyle.defaultMargin),
                      //   child: Column(
                      //     children: [
                      //       Row(
                      //         children: [
                      //           Expanded(
                      //             child: Text(
                      //               'Item Name',
                      //               style: textStyle.blackText,
                      //             ),
                      //           ),
                      //           Text(
                      //             ' : ',
                      //             style: textStyle.blackText,
                      //           ),
                      //           Expanded(
                      //             child: Text(
                      //               entitiy.productName ?? '',
                      //               style: textStyle.blackText,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //       SizedBox(
                      //         height: layoutStyle.defaultMargin / 5,
                      //       ),
                      //       Row(
                      //         children: [
                      //           Expanded(
                      //             child: Text(
                      //               'Jumlah Sewa',
                      //               style: textStyle.blackText,
                      //             ),
                      //           ),
                      //           Text(
                      //             ' : ',
                      //             style: textStyle.blackText,
                      //           ),
                      //           Expanded(
                      //             child: Text(
                      //               detailModel?.totalHours.toString() ?? '',
                      //               style: textStyle.blackText,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //       SizedBox(
                      //         height: layoutStyle.defaultMargin / 5,
                      //       ),
                      //       Row(
                      //         children: [
                      //           Expanded(
                      //             child: Text(
                      //               'Waktu Mulai',
                      //               style: textStyle.blackText,
                      //             ),
                      //           ),
                      //           Text(
                      //             ' : ',
                      //             style: textStyle.blackText,
                      //           ),
                      //           Expanded(
                      //             child: Text(
                      //               detailModel?.startDate.toString() ?? '',
                      //               style: textStyle.blackText,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //       SizedBox(
                      //         height: layoutStyle.defaultMargin / 5,
                      //       ),
                      //       Row(
                      //         children: [
                      //           Expanded(
                      //             child: Text(
                      //               'Waktu Berakhir',
                      //               style: textStyle.blackText,
                      //             ),
                      //           ),
                      //           Text(
                      //             ' : ',
                      //             style: textStyle.blackText,
                      //           ),
                      //           Expanded(
                      //             child: Text(
                      //               detailModel?.endDate.toString() ?? '',
                      //               style: textStyle.blackText,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),
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
                        onPressed: () => onNext(),
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
                          'Akhiri',
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

  paymentMember({
    required Function(List<MemberListResponse> selectedMemberAnggota) onNext,
    required AuthToken authToken,
    required MemberValid memberValid,
    required String memberNo,
  }) async {
    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: MembershipPayment(
          onNext: onNext,
          authToken: authToken,
          memberValid: memberValid,
          memberNo: memberNo,
        ),
      ),
      barrierDismissible: false,
    );
  }
}

CustomDialog dialog = CustomDialog();
