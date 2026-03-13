import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';

class UserInfo extends GetView {
  const UserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    return Container(
      width: layoutStyle.screenWidth,
      child: Text('User Info'),
    );
  }
}
