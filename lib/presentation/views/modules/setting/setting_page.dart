import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/setting/setting_page_controller.dart';
import 'package:jaya_propertiy/presentation/views/modules/setting/customer_display.dart';
import 'package:jaya_propertiy/presentation/views/modules/setting/print_setting.dart';
import 'package:jaya_propertiy/presentation/views/modules/setting/server_info.dart';
import 'package:jaya_propertiy/presentation/views/modules/setting/user_info.dart';

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
        return Expanded(
          child: Column(
            children: <Widget>[
              Container(
                width: layoutStyle.screenWidth,
                color: colorStyle.lightGrey,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: layoutStyle.screenWidth / 6),
                  child: TabBar(
                    controller: controller.tabController,
                    indicator: BoxDecoration(
                        color: colorStyle.white,
                        border: Border(
                          bottom: BorderSide(
                            color: colorStyle.primary,
                            width: 1.0,
                          ),
                        )),
                    labelColor: colorStyle.primary,
                    unselectedLabelColor: colorStyle.black,
                    tabs: const [
                      Tab(text: 'User Info'),
                      Tab(text: 'Server Info'),
                      Tab(text: 'Customer Display'),
                      Tab(text: 'Print Setting'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: controller.tabController,
                  children: const [
                    UserInfo(),
                    ServerInfo(),
                    CustomerDisplay(),
                    PrintSetting(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
