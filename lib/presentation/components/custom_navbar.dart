import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:floating_bottom_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class CustomNavbar extends StatefulWidget {
  const CustomNavbar({super.key});

  @override
  State<CustomNavbar> createState() => _CustomNavbarState();
}

class _CustomNavbarState extends State<CustomNavbar> {
  int index = 3;
  @override
  Widget build(BuildContext context) {
    return AnimatedBottomNavigationBar(
      barColor: colorStyle.white,
      controller: FloatingBottomBarController(initialIndex: 1),
      bottomBar: [
        BottomBarItem(
          icon: Icon(
            Icons.home,
            color: colorStyle.grey,
          ),
          iconSelected: Icon(
            Icons.home,
            color: colorStyle.blue,
          ),
          title: 'Home',
          titleStyle: TextStyle(color: colorStyle.grey),
          dotColor: colorStyle.blue,
          onTap: (value) {
            index = value;
          },
        ),
        BottomBarItem(
          icon: Icon(
            Icons.photo,
            color: colorStyle.grey,
          ),
          iconSelected: Icon(
            Icons.photo,
            color: colorStyle.blue,
          ),
          title: 'Photo',
          titleStyle: TextStyle(color: colorStyle.grey),
          dotColor: colorStyle.blue,
          onTap: (value) {
            index = value;
          },
        ),
        BottomBarItem(
          icon: Icon(
            Icons.person,
            color: colorStyle.grey,
          ),
          iconSelected: Icon(
            Icons.person,
            color: colorStyle.blue,
          ),
          title: 'person',
          titleStyle: TextStyle(color: colorStyle.grey),
          dotColor: colorStyle.blue,
          onTap: (value) {
            index = value;
          },
        ),
        BottomBarItem(
          icon: Icon(
            Icons.settings,
            color: colorStyle.grey,
          ),
          iconSelected: Icon(
            Icons.settings,
            color: colorStyle.blue,
          ),
          title: 'settings',
          titleStyle: TextStyle(color: colorStyle.grey),
          dotColor: colorStyle.blue,
          onTap: (value) {
            index = value;
          },
        ),
      ],
      bottomBarCenterModel: BottomBarCenterModel(
        centerBackgroundColor: colorStyle.blue,
        centerIcon: const FloatingCenterButton(
          child: Icon(
            Icons.add,
            color: AppColors.white,
          ),
        ),
        centerIconChild: [
          FloatingCenterButtonChild(
            child: const Icon(
              Icons.request_page,
              color: AppColors.white,
            ),
            onTap: () => {},
          ),
          FloatingCenterButtonChild(
            child: const Icon(
              Icons.sync_problem,
              color: AppColors.white,
            ),
            onTap: () => {},
          ),
        ],
      ),
    );
  }
}
