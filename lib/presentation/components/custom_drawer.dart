import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/data/models/menu_item_model.dart';
import 'package:jaya_propertiy/domain/entities/auth/user_entity.dart';

import '../../app/utils/styles/theme_style.dart';

class CustomerDrawer extends StatefulWidget {
  final double widthSidebar;
  final List<MenuItem> listMenu;
  final int selectedMenu;
  final ValueChanged<MenuItem> onMenuSelected;
  final UserEntity userLogin;

  const CustomerDrawer({
    Key? key,
    required this.widthSidebar,
    required this.listMenu,
    required this.selectedMenu,
    required this.onMenuSelected,
    required this.userLogin,
  }) : super(key: key);
  @override
  State<CustomerDrawer> createState() => _CustomerDrawerState();
}

class _CustomerDrawerState extends State<CustomerDrawer> {
  @override
  Widget build(BuildContext context) {
    List<ListTile> listMenu() {
      return widget.listMenu
          .map((e) => ListTile(
                tileColor: e.id == widget.selectedMenu
                    ? colorStyle.primary
                    : colorStyle.white,
                title: Row(
                  children: [
                    Icon(
                      e.icon,
                      color: e.id == widget.selectedMenu
                          ? colorStyle.white
                          : colorStyle.primary,
                    ),
                    SizedBox(
                      width: layoutStyle.defaultMargin,
                    ),
                    Text(
                      e.name,
                      style: TextStyle(
                        color: e.id == widget.selectedMenu
                            ? colorStyle.white
                            : colorStyle.primary,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Get.back();
                  widget.onMenuSelected(e);
                },
              ))
          .toList();
    }

    return Drawer(
      child: ListView(
        // padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorStyle.primaryDark, colorStyle.primaryLight],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userLogin.userName ?? sessionUtil.getUserName(),
                    style: TextStyle(
                      color: colorStyle.white,
                    ),
                  ),
                  Text(
                    'Cashier',
                    style: TextStyle(
                      color: colorStyle.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...listMenu(),
        ],
      ),
    );
  }
}
