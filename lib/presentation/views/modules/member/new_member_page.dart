import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/new_member_page_controller.dart';

class NewMemberPage extends GetView<NewMemberPageController> {
  const NewMemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    return GetBuilder(
      init: controller,
      tag: 'NewMemberPage',
      initState: (state) {
        controller;
      },
      builder: (controller) {
        return Container(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      Text(
                        'Member',
                        style: textStyle.blackText.copyWith(
                          fontSize: fontSize.title,
                          fontWeight: fontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: layoutStyle.screenWidth / 3,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: colorStyle.grey,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
