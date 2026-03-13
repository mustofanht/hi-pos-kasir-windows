import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/components/custom_drawer.dart';
import 'package:jaya_propertiy/presentation/components/custom_sidebar.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/home_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends GetView<HomePageController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    return GetX(
      init: controller,
      tag: 'HomePage',
      initState: (state) {},
      builder: (context) {
        return Scaffold(
          // resizeToAvoidBottomInset: false,
          resizeToAvoidBottomInset: true,
          key: controller.scaffoldKey,
          appBar: AppBar(
            toolbarHeight: layoutStyle.blockVertical * 10,
            backgroundColor: colorStyle.primary,
            foregroundColor: colorStyle.white,
            shadowColor: colorStyle.transparent,
            elevation: layoutStyle.defaultMargin,
            leadingWidth: 100,
            leading: IconButton(
              icon: Icon(Icons.menu, size: fontSize.header * 2),
              onPressed: () {
                controller.toggleDrawer();
              },
            ),
            title: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: layoutStyle.defaultMargin),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${controller.user.value.userName}',
                          style: TextStyle(
                            fontSize: fontSize.title,
                          ),
                        ),
                        Text(
                          controller.timeString.value,
                          style: TextStyle(
                            fontSize: fontSize.small,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        controller.user.value.locationName ?? '',
                        style: textStyle.whiteText.copyWith(
                          fontSize: fontSize.title,
                          fontWeight: fontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: colorStyle.white,
          drawerEnableOpenDragGesture: true,
          drawer: CustomerDrawer(
            userLogin: controller.user.value,
            listMenu: controller.menuItems,
            widthSidebar: controller.widthSidebar,
            selectedMenu: controller.selectedMenu.value,
            onMenuSelected: controller.onSelectedMenu,
          ),
          body: SizedBox(
            height: layoutStyle.screenHeight,
            width: layoutStyle.screenWidth,
            child: Row(
              children: [
                CustomSidebar(
                  listMenu: controller.menuItems,
                  widthSidebar: controller.widthSidebar,
                  selectedMenu: controller.selectedMenu.value,
                  onMenuSelected: controller.onSelectedMenu,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: layoutStyle.screenHeight,
                    color: colorStyle.background,
                    child: FocusScope(
                      child: controller.selectedContent ?? Container(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
