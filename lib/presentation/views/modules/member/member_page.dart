import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/member_page_controller.dart';

class MemberPage extends GetView<MemberPageController> {
  const MemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    return GetBuilder(
      init: controller,
      tag: 'MemberPage',
      initState: (state) {
        controller;
      },
      builder: (controller) {
        return FocusScope(
          child: controller.memberContent ?? Container(),
        );
      },
    );
  }
}
