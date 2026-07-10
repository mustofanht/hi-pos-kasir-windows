import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/domain/entities/member/member_valid.dart';
import 'package:jaya_propertiy/domain/entities/member/membership.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/cart_member_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/create_member_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/inq_member_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/new_member_page_controller.dart';
import 'package:jaya_propertiy/presentation/views/modules/member/create_member_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/member/inq_member_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/member/new_member_page.dart';

class MemberPageController extends GetxController {
  MemberPageController();

  final RxList<String> pageHistory = <String>[MemberRouteName.inqMember].obs;
  final authToken = Get.arguments[argConstant.authToken];
  final menuMember = RxString('inq-member');
  Membership selectedMembership = Membership();
  MemberValid selectedMembervalid = MemberValid();

  gotTo(
    String pageName,
  ) {
    logger.safeLog('[MEMBER]: CURR  ${menuMember.value}');
    logger.safeLog('[MEMBER]: GO TO $pageName');
    if (menuMember.value != pageName) {
      String? existspage = pageHistory
          .firstWhereOrNull((element) => element == menuMember.value);
      if (existspage == null) {
        pageHistory.add(menuMember.value);
      }
      menuMember.value = pageName;
      update();
    }
  }

  void goBack() {
    logger.safeLog('[MEMBER]: CURR  ${menuMember.value}');
    if (pageHistory.isNotEmpty) {
      logger.safeLog('[MEMBER]: BACK TO ${pageHistory.last}');
      menuMember.value = pageHistory.last;
      if (pageHistory.length > 1) {
        pageHistory.removeLast();
      }
      update();
    }
  }

  Widget? get memberContent {
    logMenuMember();
    if (!Get.isRegistered<CartMemberController>()) {
      Get.lazyPut(() => CartMemberController());
    }

    callInqMembership();
    callNewMembership();

    Get.delete<InqMemberPageController>();
    Get.delete<NewMemberPageController>();
    Get.delete<CreateMemberPageController>();
    switch (menuMember.value) {
      case MemberRouteName.inqMember:
        Get.lazyPut(() => InqMemberPageController());
        return const InqMemberPage();
      case MemberRouteName.newMember:
        Get.lazyPut(() => NewMemberPageController());
        return const NewMemberPage();
      case MemberRouteName.createMember:
        Get.lazyPut(() => CreateMemberPageController(
              memberValid: selectedMembervalid,
              membership: selectedMembership,
            ));
        return CreateMemberPage(
          membership: selectedMembership,
        );
      default:
        return common.underConstruction();
    }
  }

  callInqMembership() {
    if (Get.isRegistered<InqMemberPageController>()) {
      final inqMemberController = Get.find<InqMemberPageController>();
      selectedMembervalid = inqMemberController.selectedMemberValid.value;
      if (inqMemberController.selectedMemberValid.value.mstMembership != null) {
        selectedMembership =
            inqMemberController.selectedMemberValid.value.mstMembership!;
      }
    }
  }

  callNewMembership() {
    if (Get.isRegistered<NewMemberPageController>()) {
      final newMemberController = Get.find<NewMemberPageController>();
      selectedMembership = newMemberController.selectedMembership.value;
    }
  }

  clearAndRefreshMenu() {
    Get.delete<CartMemberController>();
    Get.delete<InqMemberPageController>();
    Get.delete<NewMemberPageController>();
    Get.delete<CreateMemberPageController>();

    if (!Get.isRegistered<CartMemberController>()) {
      Get.lazyPut(() => CartMemberController());
    }
    Get.lazyPut(() => InqMemberPageController());
    pageHistory.clear();
    menuMember.value = MemberRouteName.inqMember;
    update();
  }

  clear() {
    Get.delete<CartMemberController>();
    Get.delete<InqMemberPageController>();
    Get.delete<NewMemberPageController>();
    Get.delete<CreateMemberPageController>();
    pageHistory.clear();
    menuMember.value = MemberRouteName.inqMember;
  }

  logMenuMember() {
    String path = '';
    for (var element in pageHistory) {
      path += '->$element';
    }
    logger.safeLog('Path Menu Member: $path');
  }
}

abstract class MemberRouteName {
  static const inqMember = 'inq-member';
  static const newMember = 'new-member';
  static const createMember = 'create-member';
}
