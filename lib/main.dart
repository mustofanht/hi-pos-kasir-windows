// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:jaya_propertiy/app/main/app_display.dart';
// import 'package:jaya_propertiy/app/utils/common/app_common.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   HttpOverrides.global = MyHttpOverrides();

//   await GetStorage.init("sessions");

//   SystemChrome.setPreferredOrientations([
//     DeviceOrientation.landscapeLeft,
//     DeviceOrientation.landscapeRight,
//   ]).then((_) {
//     common.globalInitialize();
//     runApp(const AppDisplay());
//     // runApp(CustomerMain());
//   });
//   // runApp(
//   //   const AppMain(),
//   // );
// }

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }

// // @pragma('vm:entry-point')
// // void secondaryDisplayMain() {
// //   logger.safeLog('load second display');
// //   runApp(const CustomerMain());
// // }
import 'package:flutter/material.dart';
import 'package:jaya_propertiy/app/main/app_main.dart';
import 'package:jaya_propertiy/presentation/views/modules/customer_page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const AppMain());
    case 'presentation':
      return MaterialPageRoute(builder: (_) => const CustomerPage());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Jaya Propertiy',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoute,
      initialRoute: '/',
    );
  }
}
