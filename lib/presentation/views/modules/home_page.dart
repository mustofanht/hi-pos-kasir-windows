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
    final key = GlobalKey<ScaffoldState>();

    return GetX(
      init: controller,
      tag: 'HomePage',
      initState: (state) {},
      builder: (context) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          key: key,
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
                // controller.toogleDrawer();
                key.currentState?.openDrawer();
              },
            ),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hi, ${controller.user.value.userName}',
                    style: TextStyle(fontSize: fontSize.title)),
                Text(
                  // '${dateTimeUtil.getFormattedDate(date: DateTime.now(), format: dateFormat.onlyDays)}, ${dateTimeUtil.getFormattedDate(
                  //   date: DateTime.now(),
                  //   format: dateFormat.dateWithoutTime,
                  // )}',
                  controller.timeString.value,
                  style: TextStyle(fontSize: fontSize.small),
                ),
              ],
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
                  child: FocusScope(
                    child: Container(
                      height: layoutStyle.screenHeight,
                      color: colorStyle.background,
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
