import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jaya_propertiy/app/main/customer_main.dart';
import 'package:jaya_propertiy/app/utils/common/display_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';

import 'app/main/app_main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  DisplayUtil displayUtil = new DisplayUtil();

  await GetStorage.init("sessions");

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    displayUtil.displayCustomer(null);
    runApp(AppMain());
    // runApp(CustomerMain());
  });
  // runApp(
  //   const AppMain(),
  // );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

@pragma('vm:entry-point')
void secondaryDisplayMain() {
  logger.safeLog('load second display');
  runApp(const CustomerMain());
}
