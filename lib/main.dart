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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jaya_propertiy/app/main/app_main.dart';
import 'package:jaya_propertiy/app/main/app_route.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/layar_pelanggan_windows.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/printer_util.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/app/utils/translation/app_translation.dart';
import 'package:jaya_propertiy/presentation/views/modules/customer_page.dart';
import 'package:window_manager/window_manager.dart';

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

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await GetStorage.init("sessions");
  // Setelan perangkat (printer gelang dan ukuran medianya) sengaja di kotak
  // terpisah: kotak "sessions" dihapus seluruhnya setiap kali kasir logout.
  await GetStorage.init("perangkat");
  // Dibaca di sini, bukan di `AppCommon.globalInitialize`: fungsi itu hanya
  // terpanggil lewat `AppMain`, dan `AppMain` tidak pernah dipakai sejak aplikasi
  // berpindah ke `GetMaterialApp`. Setelan gelang ditulis ke penyimpanan tapi
  // tidak pernah dibaca balik — setiap aplikasi dibuka ulang, printer gelang
  // kembali "belum diatur" dan ukuran medianya kembali ke bawaan 50x25mm.
  //
  // Harus sebelum halaman mana pun terbuka: pemilihan otomatis printer struk
  // melewati printer gelang yang tersimpan, dan tanpa itu gelang TSPL bisa
  // terpilih sebagai printer struk lagi.
  // Windows: satu berkas aplikasi menjalankan dua jendela. Engine jendela
  // kedua memulai `main()` dari awal, dan yang membedakannya hanya argumen
  // yang diberikan plugin — jadi cabang ini harus diperiksa sebelum apa pun
  // yang khusus kasir (printer, rute, sesi) disiapkan.
  if (LayarPelangganWindows.bacaArgumen(args) != null) {
    await windowManager.ensureInitialized();
    await LayarPelangganWindows.siapkanJendela();
    runApp(const LayarPelangganApp());
    return;
  }

  printerUtil.muatSetelanGelang();
  runApp(MyApp());

  // Dibuka setelah jendela kasir berjalan: kasir yang terakhir memakai layar
  // pelanggan tidak perlu menyalakannya lagi setiap pagi.
  if (Platform.isWindows && layarPelangganWindows.seharusnyaTerbuka) {
    final gagal = await layarPelangganWindows.buka();
    if (gagal != null) logger.safeLog('LAYAR PELANGGAN OTOMATIS : $gagal');
    // Logo & sambutan dari pemakaian sebelumnya dikirimkan lebih dulu, supaya
    // bilah atasnya sudah benar sebelum kasir sempat login.
    if (gagal == null) await common.kirimTampilanLayarPelanggan();
  }
}

/// Aplikasi untuk jendela layar pelanggan.
///
/// Dipisah dari [MyApp]: jendela ini tidak punya rute, tidak butuh splash, dan
/// tidak boleh ikut memuat halaman kasir — isinya hanya satu halaman pelanggan.
class LayarPelangganApp extends StatelessWidget {
  const LayarPelangganApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Layar Pelanggan',
      debugShowCheckedModeBanner: false,
      theme: theme.light(),
      translations: AppTranslation(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('id', 'ID'),
      fallbackLocale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID')],
      home: const CustomerPage(),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return const MaterialApp(
    //   title: 'Jaya Propertiy',
    //   debugShowCheckedModeBanner: false,
    //   onGenerateRoute: generateRoute,
    //   initialRoute: '/',
    // );

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

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
