import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/local_storage_util.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
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
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  await controller.pickImage();
                },
                child: Text('Pick Images'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (controller.images.isNotEmpty) {
                    localStorage.saveImages(controller.images);
                    // await controller.saveImages(controller.images);
                  }
                },
                child: Text('Save Images'),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: controller.images.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Image.file(controller.images[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
