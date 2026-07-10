import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/controllers/default/splash_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SplashPage extends GetView<SplashPageController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);
    return GetBuilder(
      init: controller,
      tag: 'SplashPage',
      // initState: (state) {
      //   controller.sessionCheck();
      // },
      builder: (controller) {
        return Scaffold(
          body: SizedBox(
            width: layoutStyle.screenWidth,
            height: layoutStyle.screenHeight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/hipos.png',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 40),
                  LoadingAnimationWidget.discreteCircle(
                    color: colorStyle.dark_blue,
                    size: 100,
                    secondRingColor: colorStyle.blue,
                    thirdRingColor: colorStyle.hawkes_blue,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
