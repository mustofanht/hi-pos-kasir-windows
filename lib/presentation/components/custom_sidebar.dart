import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/data/models/menu_item_model.dart';
import 'package:flutter/material.dart';

class CustomSidebar extends StatefulWidget {
  final double widthSidebar;
  final List<MenuItem> listMenu;
  final int selectedMenu;
  final ValueChanged<MenuItem> onMenuSelected;

  const CustomSidebar({
    Key? key,
    required this.widthSidebar,
    required this.listMenu,
    required this.selectedMenu,
    required this.onMenuSelected,
  }) : super(key: key);

  @override
  State<CustomSidebar> createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: widget.widthSidebar,
      color: colorStyle.white,
      child: ListView(
        children: widget.listMenu
            .map((e) => GestureDetector(
                  onTap: () {
                    widget.onMenuSelected(e);
                  },
                  child: Container(
                      padding: const EdgeInsets.all(16),
                      color: e.id == widget.selectedMenu
                          ? colorStyle.primary
                          : colorStyle.white,
                      child: Column(
                        children: [
                          Icon(
                            e.icon,
                            color: e.id == widget.selectedMenu
                                ? colorStyle.white
                                : colorStyle.primary,
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: e.name,
                                style: TextStyle(
                                  fontSize: fontSize.small,
                                  color: e.id == widget.selectedMenu
                                      ? colorStyle.white
                                      : colorStyle.primary,
                                ),
                              ),
                            ),
                          )
                          // Text(
                          //   e.name,
                          //   style: TextStyle(
                          //     color: e.name == widget.selectedMenu
                          //         ? colorStyle.white
                          //         : colorStyle.primary,
                          //   ),
                          // ),
                        ],
                      )),
                ))
            .toList(),
      ),
    );
  }
}
