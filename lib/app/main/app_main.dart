
import 'package:jaya_propertiy/app/main/app_route.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/app/utils/translation/app_translation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

class AppMain extends StatefulWidget {
  const AppMain({super.key});

  @override
  State<AppMain> createState() => _AppMainState();
}

class _AppMainState extends State<AppMain> {
  @override
  void initState() {
    logger.safeLog('APP MAIN');
    common.globalInitialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Jaya Propertiy',
      debugShowCheckedModeBanner: false,
      getPages: AppRoute.pages,
      initialRoute: RouteName.splashPage,
      theme: theme.light(),
      // darkTheme: theme.dark(),
      translations: AppTranslation(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('id', 'ID'),
      fallbackLocale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID')],
    );
  }
}

// class TestPage extends StatelessWidget {
//   const TestPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     layoutStyle.init(context);
//     File e = File(
//         '/data/user/0/com.example.jaya_propertiy/app_flutter/PROMO/logo-social.png');
//     print('File exists: ${e.existsSync()}');
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         toolbarHeight: layoutStyle.blockVertical * 10,
//         backgroundColor: colorStyle.primary,
//         foregroundColor: colorStyle.white,
//         shadowColor: colorStyle.transparent,
//         elevation: layoutStyle.defaultMargin,
//         leadingWidth: 100,
//         leading: IconButton(
//           icon: Icon(Icons.menu, size: fontSize.header * 2),
//           onPressed: () {
//             // controller.toggleDrawer();
//           },
//         ),
//         title: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Hi, ',
//               style: TextStyle(
//                 fontSize: fontSize.title,
//               ),
//             ),
//             Text(
//               '',
//               style: TextStyle(
//                 fontSize: fontSize.small,
//               ),
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: colorStyle.white,
//       body: FlutterCarousel(
//         options: CarouselOptions(
//           height: layoutStyle.screenHeight,
//           viewportFraction: 1.0,
//           enlargeCenterPage: false,
//           autoPlay: true,
//           enableInfiniteScroll: true,
//           autoPlayInterval: const Duration(seconds: 5),
//           slideIndicator: CircularWaveSlideIndicator(),
//         ),
//         items: [
//           Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: layoutStyle.defaultMargin / 5,
//             ),
//             child: ClipRRect(
//               borderRadius: const BorderRadius.all(Radius.circular(4.0)),
//               child: Container(
//                 width: double.infinity,
//                 child: Container(
//                   width: 300,
//                   height: 300,
//                   child: Image.file(
//                     e,
//                     fit: BoxFit.contain,
//                     // color: colorStyle.red,
//                     errorBuilder: (BuildContext context, Object exception,
//                         StackTrace? stackTrace) {
//                       return Text('Error loading image $exception');
//                     },
//                     // width: layoutStyle.screenWidth,
//                     // height: layoutStyle.screenHeight,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
