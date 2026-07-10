// import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// import 'package:get/get.dart';
// import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
// import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
// import 'package:jaya_propertiy/data/models/order/order_ticket_model.dart';

// class GatePrintController extends GetxController {
//   GatePrintController();

//   Future<List<int>> dataGatePrint({
//     required PaperSize paperSize,
//     required String reffNo,
//     required int pakOf,
//     required int pakTotal,
//     required String qrCode,
//     required String expiredAt,
//     required OrderTicketModel ticketModel,
//   }) async {
//     List<int> bytes = [];
//     // Using default profile
//     final profile = await CapabilityProfile.load();
//     final generator = Generator(paperSize, profile);
//     bytes += generator.setGlobalFont(PosFontType.fontA);
//     bytes += generator.reset();

//     // Print Store Information
//     bytes += generator.text(
//       'No Reff. $reffNo',
//       styles: const PosStyles(
//         align: PosAlign.left,
//         bold: true,
//       ),
//     );
//     bytes += generator.text(
//       dateTimeUtil.now(
//         format: dateFormat.fullTimePrinted,
//       ),
//       styles: const PosStyles(
//         align: PosAlign.left,
//         bold: true,
//       ),
//     );
//     bytes += generator.hr();

//     bytes += generator.text(
//       ticketModel.ticket?.ticketName ?? '',
//       styles: const PosStyles(
//         align: PosAlign.center,
//       ),
//     );
//     bytes += generator.text(
//       '$pakOf of $pakTotal PAK',
//       styles: const PosStyles(
//         align: PosAlign.center,
//         bold: true,
//       ),
//     );

//     bytes += generator.emptyLines(1);
// // QRCODE
//     bytes += generator.qrcode(
//       qrCode,
//       align: PosAlign.center,
//     );
//     bytes += generator.emptyLines(1);
//     bytes += generator.text(
//       'Berlaku $expiredAt',
//       styles: const PosStyles(
//         align: PosAlign.center,
//         bold: true,
//       ),
//     );
//     // bytes += generator.emptyLines(1);
//     bytes += generator.cut();

//     return bytes;
//   }
// }
