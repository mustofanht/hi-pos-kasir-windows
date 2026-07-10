// import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// import 'package:get/get.dart';
// import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
// import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
// import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
// import 'package:jaya_propertiy/data/models/order/order_model.dart';
// import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
// import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';
// import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
// import 'package:jaya_propertiy/presentation/controllers/common/gate_print_controller.dart';
// import 'package:jaya_propertiy/presentation/controllers/common/payment_print_controller.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

// class PrintController extends GetxController {
//   final String? macAddrPrint;
//   PrintController({this.macAddrPrint});

//   final connected = false.obs;
//   final _progress = false.obs;
//   final _msjprogress = "".obs;
//   final _msj = "".obs;
//   // final _info = "".obs;
//   final listBluetooth = <BluetoothInfo>[].obs;
//   final selectedPrinter = Rxn<CustomIdNameEntity>(null);
//   // final bluetoothIsEnabled = RxBool(false);

//   @override
//   void onInit() {
//     // TODO: implement onInit
//     // initPlatformState();
//     // if (macAddrPrint != null) {
//     //   await connect(macAddrPrint!);
//     //   var paymentPrintController = Get.put(PaymentPrintController());
//     //   List<int> data = await paymentPrintController.dataPaymentTiketPrint(PaperSize.mm80);
//     //   await printTicket(data: data);
//     // }
//     super.onInit();
//   }

//   @override
//   void onClose() {
//     disconnect();
//     super.onClose();
//   }

//   // Future<void> initPlatformState() async {
//   //   String platformVersion;
//   //   int porcentbatery = 0;
//   //   // Platform messages may fail, so we use a try/catch PlatformException.
//   //   try {
//   //     platformVersion = await PrintBluetoothThermal.platformVersion;
//   //     //logger.safeLog("patformversion: $platformVersion");
//   //     porcentbatery = await PrintBluetoothThermal.batteryLevel;
//   //   } on PlatformException {
//   //     platformVersion = 'Failed to get platform version.';
//   //   }

//   //   final bool result = await PrintBluetoothThermal.bluetoothEnabled;
//   //   bluetoothIsEnabled.value = result;
//   //   logger.safeLog("bluetooth enabled: $result");
//   //   if (result) {
//   //     _msj.value = "Bluetooth enabled, please search and connect";
//   //   } else {
//   //     _msj.value = "Bluetooth not enabled";
//   //   }

//   //   _info.value = platformVersion + " ($porcentbatery% battery)";

//   //   logger.safeLog(_msj.value);
//   //   logger.safeLog(_info.value);
//   //   update();
//   // }

//   Future<bool> bluetoothIsEnabled() async {
//     try {
//       bool permisionBluethoot =
//           await PrintBluetoothThermal.isPermissionBluetoothGranted;
//       if (permisionBluethoot) {
//         return PrintBluetoothThermal.bluetoothEnabled;
//       } else {
//         return false;
//       }
//     } catch (e) {
//       logger.safeLog(e.toString());
//       return Future.value(false);
//     }
//   }

//   Future<void> getBluetoots() async {
//     _progress.value = true;
//     _msjprogress.value = "Wait";
//     listBluetooth.value = await PrintBluetoothThermal.pairedBluetooths;

//     await Future.forEach(listBluetooth, (BluetoothInfo bluetooth) {
//       String name = bluetooth.name;
//       String mac = bluetooth.macAdress;
//       logger.safeLog('name ${name} - mac ${mac} ');
//     });

//     _progress.value = false;

//     if (listBluetooth.isEmpty) {
//       _msj.value =
//           "There are no bluetoohs linked, go to settings and link the printer";
//     } else {
//       _msj.value = "Touch an item in the list to connect";
//     }

//     update();
//   }

//   Future<bool> isConnect() {
//     return PrintBluetoothThermal.connectionStatus;
//   }

//   Future<bool> connect(String mac) async {
//     _progress.value = true;
//     _msjprogress.value = "Printer Connecting...";
//     connected.value = false;
//     logger.safeLog(_msjprogress.value);
//     final bool result = await PrintBluetoothThermal.connect(
//       macPrinterAddress: mac,
//     );
//     logger.safeLog("state conected $result");
//     if (result) connected.value = true;
//     _progress.value = false;
//     update();
//     return result;
//   }

//   Future<void> disconnect() async {
//     final bool status = await PrintBluetoothThermal.disconnect;
//     connected.value = false;
//     logger.safeLog("status disconnect $status");
//     update();
//   }

//   Future<bool> printTicket({required List<int> data}) async {
//     bool connection = await PrintBluetoothThermal.connectionStatus;
//     logger.safeLog('connection : ${connection}');
//     if (connection) {
//       var result = await PrintBluetoothThermal.writeBytes(data);
//       logger.safeLog('Printed : ${result}');
//       return result;
//     } else {
//       logger.safeLog("print test connection: $connection");
//       disconnect();
//       return false;
//     }
//   }

//   printPaymentTiket(
//     OrderModel body,
//     PaymentPrintController paymentPrintController,
//     GatePrintController gatePrintController,
//   ) async {
//     bool isConnectPrinter = await isConnect();
//     if (isConnectPrinter) {
//       List<int> data = await paymentPrintController.dataPaymentTiketPrint(
//         paperSize: PaperSize.mm80,
//         body: body,
//       );
//       int count = 1;
//       int totalPak = body.listTicket.fold(0, (sum, e) => sum + e.totalTicket);
//       for (var element in body.listTicket) {
//         for (var i = 0; i < element.totalTicket; i++) {
//           List<int> dataPrint = await gatePrintController.dataGatePrint(
//             paperSize: PaperSize.mm80,
//             reffNo: body.orderReffno!,
//             pakOf: count,
//             pakTotal: totalPak,
//             qrCode: '12345',
//             expiredAt: dateTimeUtil.now(format: dateFormat.dateWithoutTime),
//             ticketModel: element,
//           );
//           data.addAll(dataPrint);
//           count++;
//         }
//       }

//       loading.popUpLoading();
//       bool isPrinted = await printTicket(
//         data: data,
//       );
//       logger.safeLog('isPrinted : $isPrinted');
//       if (isPrinted) {
//         Get.back();
//         Get.back();
//       } else {
//         await printPaymentTiket(
//           body,
//           paymentPrintController,
//           gatePrintController,
//         );
//       }
//     } else {
//       dialog.selectPrint(
//         printController: this,
//         title: 'Select Printer',
//         msg: 'Silahkan Pilih printer',
//         onPrint: () async {
//           await printPaymentTiket(
//             body,
//             paymentPrintController,
//             gatePrintController,
//           );
//         },
//       );
//     }
//   }
// }
