import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/create_member_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/inq_member_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/new_member_page_controller.dart';
import 'package:jaya_propertiy/presentation/views/modules/member/create_member_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/member/inq_member_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/member/new_member_page.dart';

class MemberPageController extends GetxController {
  MemberPageController();

  final menuMember = RxString('inq-member');

  gotTo(String pageName) {
    menuMember.value = pageName;
    update();
  }

  Widget? get memberContent {
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
        Get.lazyPut(() => CreateMemberPageController());
        return const CreateMemberPage();
      default:
        return common.underConstruction();
    }
  }
}

abstract class MemberRouteName {
  static const inqMember = 'inq-member';
  static const newMember = 'new-member';
  static const createMember = 'create-member';
}
