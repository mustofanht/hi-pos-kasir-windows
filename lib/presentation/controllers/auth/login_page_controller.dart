import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jaya_propertiy/app/main/app_route.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/message_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/auth/sign_in_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:get/get.dart';

class LoginPageController extends GetxController {
  final _service = MainService();
  final isProcessing = false.obs;
  final inpUsername = TextEditingController();
  final inpPassword = TextEditingController();
  final isLoading = false.obs;
  final isSaved = false.obs;

  final showPassword = false.obs;

  doShowPassword() {
    showPassword.value = !showPassword.value;
    update();
  }

  doLogin({
    bool firstLogin = true,
    bool fromSplash = false,
  }) async {
    isLoading.value = true;
    bool isValid = true;
    try {
      // if (sessionUtil.isActive()) {
      //   isValid = true;
      // } else {
      //   isValid = doVerifyRequest();
      // }
      isValid = doVerifyRequest();

      if (isValid) {
        SignInModel requestData = SignInModel(
          username: inpUsername.text,
          password: inpPassword.text,
        );

        logger.safeLog(requestData.toJson());

        final result = await _service.auth.signIn(requestData: requestData);

        result.fold((l) {
          alert.error("Terjadi Kesalahan", l);
          isLoading.value = false;
          if (fromSplash) {
            Timer(const Duration(milliseconds: 2000), () {
              Get.offAllNamed(
                RouteName.splashPage,
              );
            });
          }
        }, (r) async {
          isLoading.value = true;
          if (isSaved.value) {
            sessionUtil.save(requestData);
          }
          sessionUtil.updateToken(r);
          // await notificationEngine.getPermission();
          await common.doRefreshAds(r);
          // await common.getImagePromo(r);
          // displayUtil.displayCustomer(null);
          // displayUtil.updateSecondDisplay(constant.refreshAds);
          Get.offAllNamed(
            RouteName.homePage,
            arguments: {
              argConstant.authToken: r,
              "first_login": firstLogin,
            },
          );
          alert.success(
              "Success", "Selamat Datang ${sessionUtil.getUserName()}!");
        });
      }
    } catch (e) {
      alert.error("invalid request", 'invalid request');
      logger.safeLog(e);
    }
    isLoading.value = false;
    update();
  }

  bool doVerifyRequest() {
    bool isValid = true;
    logger.safeLog('inpUsername.text ${inpUsername.text}');
    if (inpUsername.text.isEmpty) {
      isLoading.value = false;
      isValid = false;
      alert.error(
          "Terjadi Kesalahan!", messagesConstant.requiredField("Username"));
    }

    if (isValid && inpPassword.text.isEmpty) {
      isLoading.value = false;
      isValid = false;
      alert.error(
          "Terjadi Kesalahan!", messagesConstant.requiredField("Password"));
    }

    return isValid;
  }

  redirectToHomePage() {
    Get.offAllNamed(
      RouteName.homePage,
      arguments: {},
    );
    alert.success("Success", "Welcome");
  }
}
