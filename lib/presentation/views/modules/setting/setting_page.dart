import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/setting/setting_page_controller.dart';

class SettingPage extends GetView<SettingPageController> {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    return GetBuilder(
      init: controller,
      tag: 'SettingPage',
      initState: (state) {
        controller;
      },
      builder: (controller) {
        // return Column(
        //   children: <Widget>[
        //     Container(
        //       width: layoutStyle.screenWidth,
        //       color: colorStyle.lightGrey,
        //       child: Container(
        //         padding: EdgeInsets.symmetric(
        //           horizontal: layoutStyle.screenWidth / 4,
        //         ),
        //         child: TabBar(
        //           controller: controller.tabController,
        //           indicator: BoxDecoration(
        //               color: colorStyle.white,
        //               border: Border(
        //                 bottom: BorderSide(
        //                   color: colorStyle.primary,
        //                   width: 1.0,
        //                 ),
        //               )),
        //           labelColor: colorStyle.primary,
        //           unselectedLabelColor: colorStyle.black,
        //           tabs: const [
        //             Tab(text: 'User Info'),
        //             Tab(text: 'Server Info'),
        //             Tab(text: 'Customer Display'),
        //             Tab(text: 'Print Setting'),
        //           ],
        //         ),
        //       ),
        //     ),
        //     Expanded(
        //       child: TabBarView(
        //         controller: controller.tabController,
        //         children: const [
        //           UserInfo(),
        //           ServerInfo(),
        //           CustomerDisplay(),
        //           PrintSetting(),
        //         ],
        //       ),
        //     ),
        //   ],
        // );
        return Container(
          width: layoutStyle.screenWidth,
          height: layoutStyle.screenHeight,
          padding: EdgeInsets.all(layoutStyle.defaultMargin),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Information',
                      style: textStyle.blackText.copyWith(
                        fontSize: fontSize.header,
                      ),
                    ),
                    Container(
                      width: layoutStyle.screenWidth,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: colorStyle.grey,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: layoutStyle.defaultMargin,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CustomTextBox(
                            height: layoutStyle.blockVertical * 5,
                            obscureText: false,
                            margin: EdgeInsets.symmetric(
                              horizontal: layoutStyle.defaultMargin,
                              vertical: layoutStyle.defaultMargin / 4,
                            ),
                            border: Border.all(
                              color: colorStyle.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(
                              layoutStyle.defaultMargin / 2,
                            ),
                            label: Text(
                              'Unit',
                              style: textStyle.greyText.copyWith(
                                fontSize: fontSize.small,
                              ),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Unit',
                              hintStyle: textStyle.greyText,
                              border: InputBorder.none,
                            ),
                            controller: controller.unitController,
                            isDisabled: true,
                          ),
                        ),
                        Expanded(
                          child: CustomTextBox(
                            height: layoutStyle.blockVertical * 5,
                            obscureText: false,
                            margin: EdgeInsets.symmetric(
                              horizontal: layoutStyle.defaultMargin,
                              vertical: layoutStyle.defaultMargin / 4,
                            ),
                            border: Border.all(
                              color: colorStyle.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(
                              layoutStyle.defaultMargin / 2,
                            ),
                            label: Text(
                              'Last Login',
                              style: textStyle.greyText.copyWith(
                                fontSize: fontSize.small,
                              ),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Last Login',
                              hintStyle: textStyle.greyText,
                              border: InputBorder.none,
                            ),
                            controller: controller.lastLoginController,
                            isDisabled: true,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CustomTextBox(
                            height: layoutStyle.blockVertical * 5,
                            obscureText: false,
                            margin: EdgeInsets.symmetric(
                              horizontal: layoutStyle.defaultMargin,
                              vertical: layoutStyle.defaultMargin / 4,
                            ),
                            border: Border.all(
                              color: colorStyle.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(
                              layoutStyle.defaultMargin / 2,
                            ),
                            label: Text(
                              'Nama',
                              style: textStyle.greyText.copyWith(
                                fontSize: fontSize.small,
                              ),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Nama',
                              hintStyle: textStyle.greyText,
                              border: InputBorder.none,
                            ),
                            controller: controller.nameController,
                            isDisabled: true,
                          ),
                        ),
                        Expanded(
                          child: CustomTextBox(
                            height: layoutStyle.blockVertical * 5,
                            obscureText: false,
                            margin: EdgeInsets.symmetric(
                              horizontal: layoutStyle.defaultMargin,
                              vertical: layoutStyle.defaultMargin / 4,
                            ),
                            border: Border.all(
                              color: colorStyle.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(
                              layoutStyle.defaultMargin / 2,
                            ),
                            label: Text(
                              'Role',
                              style: textStyle.greyText.copyWith(
                                fontSize: fontSize.small,
                              ),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Role',
                              hintStyle: textStyle.greyText,
                              border: InputBorder.none,
                            ),
                            controller: controller.roleController,
                            isDisabled: true,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CustomTextBox(
                            height: layoutStyle.blockVertical * 5,
                            obscureText: false,
                            margin: EdgeInsets.symmetric(
                              horizontal: layoutStyle.defaultMargin,
                              vertical: layoutStyle.defaultMargin / 4,
                            ),
                            border: Border.all(
                              color: colorStyle.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(
                              layoutStyle.defaultMargin / 2,
                            ),
                            label: Text(
                              'No Telepon',
                              style: textStyle.greyText.copyWith(
                                fontSize: fontSize.small,
                              ),
                            ),
                            decoration: InputDecoration(
                              hintText: 'No Telepon',
                              hintStyle: textStyle.greyText,
                              border: InputBorder.none,
                            ),
                            controller: controller.noTelpController,
                            isDisabled: true,
                          ),
                        ),
                        Expanded(
                          child: CustomTextBox(
                            height: layoutStyle.blockVertical * 5,
                            obscureText: false,
                            margin: EdgeInsets.symmetric(
                              horizontal: layoutStyle.defaultMargin,
                              vertical: layoutStyle.defaultMargin / 4,
                            ),
                            border: Border.all(
                              color: colorStyle.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(
                              layoutStyle.defaultMargin / 2,
                            ),
                            label: Text(
                              'Email',
                              style: textStyle.greyText.copyWith(
                                fontSize: fontSize.small,
                              ),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: textStyle.greyText,
                              border: InputBorder.none,
                            ),
                            controller: controller.emailController,
                            isDisabled: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
