import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class PrintController extends GetxController {
  PrintController();

  @override
  void onInit() {
    // TODO: implement onInit
    initPlatformState();
    super.onInit();
  }

  final connected = false.obs;
  final _progress = false.obs;
  final _msjprogress = "".obs;
  final _msj = "".obs;
  final _info = "".obs;
  final listBluetooth = <BluetoothInfo>[].obs;
  final macAddrrBluetooth = '86:67:7A:56:DC:4B'.obs;

  Future<void> initPlatformState() async {
    String platformVersion;
    int porcentbatery = 0;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await PrintBluetoothThermal.platformVersion;
      //logger.safeLog("patformversion: $platformVersion");
      porcentbatery = await PrintBluetoothThermal.batteryLevel;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    final bool result = await PrintBluetoothThermal.bluetoothEnabled;
    logger.safeLog("bluetooth enabled: $result");
    if (result) {
      _msj.value = "Bluetooth enabled, please search and connect";
    } else {
      _msj.value = "Bluetooth not enabled";
    }

    _info.value = platformVersion + " ($porcentbatery% battery)";

    update();
  }

  Future<void> getBluetoots() async {
    _progress.value = true;
    _msjprogress.value = "Wait";
    listBluetooth.value = await PrintBluetoothThermal.pairedBluetooths;

    await Future.forEach(listBluetooth, (BluetoothInfo bluetooth) {
      String name = bluetooth.name;
      String mac = bluetooth.macAdress;
      logger.safeLog('name ${name} - mac ${mac} ');
    });

    _progress.value = false;

    if (listBluetooth.isEmpty) {
      _msj.value =
          "There are no bluetoohs linked, go to settings and link the printer";
    } else {
      _msj.value = "Touch an item in the list to connect";
    }

    update();
  }

  Future<void> connect(String mac) async {
    _progress.value = true;
    _msjprogress.value = "Connecting...";
    connected.value = false;
    final bool result = await PrintBluetoothThermal.connect(
      macPrinterAddress: mac,
    );
    logger.safeLog("state conected $result");
    if (result) connected.value = true;
    _progress.value = false;
    update();
  }

  Future<void> disconnect() async {
    final bool status = await PrintBluetoothThermal.disconnect;
    connected.value = false;
    logger.safeLog("status disconnect $status");
    update();
  }

  // Future<void> printTest() async {
  //   /*if (kDebugMode) {
  //     bool result = await PrintBluetoothThermalWindows.writeBytes(bytes: "Hello \n".codeUnits);
  //     return;
  //   }*/

  //   bool conexionStatus = await PrintBluetoothThermal.connectionStatus;
  //   //logger.safeLog("connection status: $conexionStatus");
  //   if (conexionStatus) {
  //     bool result = false;
  //     if (Platform.isWindows) {
  //       List<int> ticket = await testWindows();
  //       result = await PrintBluetoothThermalWindows.writeBytes(bytes: ticket);
  //     } else {
  //       List<int> ticket = await testTicket();
  //       result = await PrintBluetoothThermal.writeBytes(ticket);
  //     }
  //     logger.safeLog("print test result:  $result");
  //   } else {
  //     logger.safeLog("print test conexionStatus: $conexionStatus");
  //     disconnect();
  //     //throw Exception("Not device connected");
  //   }
  //   update();
  // }

  // Future<void> printString() async {
  //   bool conexionStatus = await PrintBluetoothThermal.connectionStatus;
  //   if (conexionStatus) {
  //     String enter = '\n';
  //     await PrintBluetoothThermal.writeBytes(enter.codeUnits);
  //     //size of 1-5
  //     String text = "Hello";
  //     await PrintBluetoothThermal.writeString(
  //         printText: PrintTextSize(size: 1, text: text));
  //     await PrintBluetoothThermal.writeString(
  //         printText: PrintTextSize(size: 2, text: text + " size 2"));
  //     await PrintBluetoothThermal.writeString(
  //         printText: PrintTextSize(size: 3, text: text + " size 3"));
  //   } else {
  //     //desconectado
  //     logger.safeLog("desconectado bluetooth $conexionStatus");
  //   }
  // }

  // Future<List<int>> testTicket() async {
  //   List<int> bytes = [];
  //   // Using default profile
  //   final profile = await CapabilityProfile.load();
  //   final generator = Generator(
  //       optionprinttype == "58 mm" ? PaperSize.mm58 : PaperSize.mm80, profile);
  //   //bytes += generator.setGlobalFont(PosFontType.fontA);
  //   bytes += generator.reset();

  //   final ByteData data = await rootBundle.load('assets/mylogo.jpg');
  //   final Uint8List bytesImg = data.buffer.asUint8List();
  //   img.Image? image = img.decodeImage(bytesImg);

  //   if (Platform.isIOS) {
  //     // Resizes the image to half its original size and reduces the quality to 80%
  //     final resizedImage = img.copyResize(image!,
  //         width: image.width ~/ 1.3,
  //         height: image.height ~/ 1.3,
  //         interpolation: img.Interpolation.nearest);
  //     final bytesimg = Uint8List.fromList(img.encodeJpg(resizedImage));
  //     //image = img.decodeImage(bytesimg);
  //   }

  //   //Using `ESC *`
  //   //bytes += generator.image(image!);

  //   bytes += generator.text(
  //       'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
  //   bytes += generator.text('Special 1: ñÑ àÀ èÈ éÉ üÜ çÇ ôÔ',
  //       styles: PosStyles(codeTable: 'CP1252'));
  //   bytes += generator.text('Special 2: blåbærgrød',
  //       styles: PosStyles(codeTable: 'CP1252'));

  //   bytes += generator.text('Bold text', styles: PosStyles(bold: true));
  //   bytes += generator.text('Reverse text', styles: PosStyles(reverse: true));
  //   bytes += generator.text('Underlined text',
  //       styles: PosStyles(underline: true), linesAfter: 1);
  //   bytes +=
  //       generator.text('Align left', styles: PosStyles(align: PosAlign.left));
  //   bytes += generator.text('Align center',
  //       styles: PosStyles(align: PosAlign.center));
  //   bytes += generator.text('Align right',
  //       styles: PosStyles(align: PosAlign.right), linesAfter: 1);

  //   bytes += generator.row([
  //     PosColumn(
  //       text: 'col3',
  //       width: 3,
  //       styles: PosStyles(align: PosAlign.center, underline: true),
  //     ),
  //     PosColumn(
  //       text: 'col6',
  //       width: 6,
  //       styles: PosStyles(align: PosAlign.center, underline: true),
  //     ),
  //     PosColumn(
  //       text: 'col3',
  //       width: 3,
  //       styles: PosStyles(align: PosAlign.center, underline: true),
  //     ),
  //   ]);

  //   //barcode

  //   final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
  //   bytes += generator.barcode(Barcode.upcA(barData));

  //   //QR code
  //   bytes += generator.qrcode('example.com');

  //   bytes += generator.text(
  //     'Text size 50%',
  //     styles: PosStyles(
  //       fontType: PosFontType.fontB,
  //     ),
  //   );
  //   bytes += generator.text(
  //     'Text size 100%',
  //     styles: PosStyles(
  //       fontType: PosFontType.fontA,
  //     ),
  //   );
  //   bytes += generator.text(
  //     'Text size 200%',
  //     styles: PosStyles(
  //       height: PosTextSize.size2,
  //       width: PosTextSize.size2,
  //     ),
  //   );

  //   bytes += generator.feed(2);
  //   //bytes += generator.cut();
  //   return bytes;
  // }

  // Future<List<int>> testWindows() async {
  //   List<int> bytes = [];

  //   bytes +=
  //       PostCode.text(text: "Size compressed", fontSize: FontSize.compressed);
  //   bytes += PostCode.text(text: "Size normal", fontSize: FontSize.normal);
  //   bytes += PostCode.text(text: "Bold", bold: true);
  //   bytes += PostCode.text(text: "Inverse", inverse: true);
  //   bytes += PostCode.text(text: "AlignPos right", align: AlignPos.right);
  //   bytes += PostCode.text(text: "Size big", fontSize: FontSize.big);
  //   bytes += PostCode.enter();

  //   //List of rows
  //   bytes += PostCode.row(
  //       texts: ["PRODUCT", "VALUE"],
  //       proportions: [60, 40],
  //       fontSize: FontSize.compressed);
  //   for (int i = 0; i < 3; i++) {
  //     bytes += PostCode.row(
  //         texts: ["Item $i", "$i,00"],
  //         proportions: [60, 40],
  //         fontSize: FontSize.compressed);
  //   }

  //   bytes += PostCode.line();

  //   bytes += PostCode.barcode(barcodeData: "123456789");
  //   bytes += PostCode.qr("123456789");

  //   bytes += PostCode.enter(nEnter: 5);

  //   return bytes;
  // }

  // Future<void> printWithoutPackage() async {
  //   //impresion sin paquete solo de PrintBluetoothTermal
  //   bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
  //   if (connectionStatus) {
  //     String text = _txtText.text.toString() + "\n";
  //     bool result = await PrintBluetoothThermal.writeString(
  //         printText: PrintTextSize(size: int.parse(_selectSize), text: text));
  //     logger.safeLog("status print result: $result");
  //     setState(() {
  //       _msj = "printed status: $result";
  //     });
  //   } else {
  //     //no conectado, reconecte
  //     setState(() {
  //       _msj = "no connected device";
  //     });
  //     logger.safeLog("no conectado");
  //   }
  // }
}
