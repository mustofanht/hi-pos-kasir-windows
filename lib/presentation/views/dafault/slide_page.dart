import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/controllers/default/slide_page_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';

class SlidePage extends GetView<SlidePageController> {
  const SlidePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);
    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    // );

    Widget _buildFullscreenImage() {
      return Image.asset(
        'assets/images/example-img.jpeg',
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      );
    }

    Widget _buildImage(String assetName, [double width = 350]) {
      return Image.asset('assets/images/$assetName', width: width);
    }

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: TextStyle(fontSize: 19.0),
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return GetBuilder(
      init: controller,
      tag: 'SlidePage',
      initState: (state) {},
      builder: (context) {
        return IntroductionScreen(
          key: GlobalKey<IntroductionScreenState>(),
          globalBackgroundColor: Colors.white,
          allowImplicitScrolling: true,
          autoScrollDuration: 3000,
          infiniteAutoScroll: true,
          // globalHeader: ,
          // globalFooter: ,
          pages: [
            PageViewModel(
              title: "Slide 1",
              body:
                  "Instead of having to buy an entire share, invest any amount you want.",
              // image: _buildImage('example-img.jpeg'),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Slide 2",
              body:
                  "Instead of having to buy an entire share, invest any amount you want.",
              // image: _buildImage('example-img.jpeg'),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Slide 3",
              body:
                  "Instead of having to buy an entire share, invest any amount you want.",
              // image: _buildImage('example-img.jpeg'),
              decoration: pageDecoration,
            ),
            // PageViewModel(
            //   title: "Full Screen Page",
            //   body:
            //       "Pages can be full screen as well.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc id euismod lectus, non tempor felis. Nam rutrum rhoncus est ac venenatis.",
            //   image: _buildFullscreenImage(),
            //   decoration: pageDecoration.copyWith(
            //     contentMargin: const EdgeInsets.symmetric(horizontal: 16),
            //     fullScreen: true,
            //     bodyFlex: 2,
            //     imageFlex: 3,
            //     safeArea: 100,
            //   ),
            // ),
          ],
          onDone: () => controller.checkIsLogin(),
          onSkip: () => controller.checkIsLogin(),
          showSkipButton: true,
          skipOrBackFlex: 0,
          nextFlex: 0,
          showBackButton: false,
          back: const Icon(Icons.arrow_back),
          skip:
              const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
          next: const Icon(Icons.arrow_forward),
          done:
              const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
          curve: Curves.fastLinearToSlowEaseIn,
          controlsMargin: const EdgeInsets.all(16),
          controlsPadding: kIsWeb
              ? const EdgeInsets.all(12.0)
              : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
          dotsDecorator: const DotsDecorator(
            size: Size(10.0, 10.0),
            color: Color(0xFFBDBDBD),
            activeSize: Size(22.0, 10.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
          ),
          dotsContainerDecorator: const ShapeDecoration(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
        );
      },
    );
  }
}
