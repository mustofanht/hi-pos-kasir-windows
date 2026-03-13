// import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// import 'package:get/get.dart';
// import 'package:jaya_propertiy/app/utils/common/app_common.dart';
// import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
// import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
// import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
// import 'package:jaya_propertiy/data/models/order/order_model.dart';

// class PaymentPrintController extends GetxController {
//   PaymentPrintController();

//   Future<List<int>> dataPaymentTiketPrint({
//     required PaperSize paperSize,
//     required OrderModel body,
//   }) async {
//     List<int> bytes = [];
//     // Using default profile
//     final profile = await CapabilityProfile.load();
//     final generator = Generator(paperSize, profile);
//     bytes += generator.setGlobalFont(PosFontType.fontA);
//     bytes += generator.reset();

//     // final ByteData data = await rootBundle.load(assetsConstant.imgLogo);
//     // final Uint8List bytesImg = data.buffer.asUint8List();
//     // img.Image? image = img.decodeImage(bytesImg);

//     // if (image != null) {
//     //   if (image.width > PaperSize.mm80.width) {
//     //     image = img.copyResize(image, width: PaperSize.mm80.width);
//     //   }
//     //   image = img.grayscale(image);
//     //   bytes += generator.image(image);
//     // }

//     // Print Store Information
//     bytes += generator.text(
//       'No Reff. ${body.orderReffno ?? ''}',
//       styles: const PosStyles(
//         align: PosAlign.left,
//         bold: true,
//       ),
//     );
//     bytes += generator.row(
//       [
//         PosColumn(
//           text: dateTimeUtil.now(
//             format: dateFormat.fullTimePrinted,
//           ),
//           width: 6,
//         ),
//         PosColumn(
//           text: body.orderName,
//           width: 6,
//           styles: const PosStyles(
//             align: PosAlign.right,
//           ),
//         ),
//       ],
//     );
//     bytes += generator.hr();

//     // List Ticket Order
//     for (var element in body.listTicket) {
//       bytes += generator.text(
//         element.ticket?.ticketName ?? '',
//         styles: const PosStyles(
//           align: PosAlign.left,
//         ),
//       );
//       bytes += generator.row(
//         [
//           PosColumn(
//             text: 'Rp',
//             width: 2,
//           ),
//           PosColumn(
//             text: element.ticket?.ticketPrice != null
//                 ? common.currencyFormat(element.ticket!.ticketPrice!)
//                 : '',
//             width: 2,
//           ),
//           PosColumn(
//             text: '( 0% )',
//             width: 2,
//           ),
//           PosColumn(
//             text: 'x ${element.totalTicket}',
//             width: 2,
//           ),
//           PosColumn(
//             text: common.currencyFormat(element.totalAmount),
//             width: 4,
//             styles: const PosStyles(
//               align: PosAlign.right,
//             ),
//           )
//         ],
//       );
//     }
//     // List item Order
//     for (var element in body.listProduct) {
//       bytes += generator.text(
//         element.addOn?.productName ?? '',
//         styles: const PosStyles(
//           align: PosAlign.left,
//         ),
//       );
//       bytes += generator.row(
//         [
//           PosColumn(
//             text: 'Rp',
//             width: 2,
//           ),
//           PosColumn(
//             text: element.addOn?.productPrice != null
//                 ? common.currencyFormat(element.addOn!.productPrice!)
//                 : '',
//             width: 2,
//           ),
//           PosColumn(
//             text: '( 0% )',
//             width: 2,
//           ),
//           PosColumn(
//             text: 'x ${element.ordadTotalAddon}',
//             width: 2,
//           ),
//           PosColumn(
//             text: common.currencyFormat(element.ordadTotalAmount),
//             width: 4,
//             styles: const PosStyles(
//               align: PosAlign.right,
//             ),
//           )
//         ],
//       );
//     }
//     // List voucher Order
//     double totalVoucher = 0;
//     for (var element in body.listVoucher) {
//       bytes += generator.text(
//         element.voucher?.voucherName ?? '',
//         styles: const PosStyles(
//           align: PosAlign.left,
//         ),
//       );
//       bytes += generator.row(
//         [
//           PosColumn(
//             text: 'Rp',
//             width: 2,
//           ),
//           PosColumn(
//             text: element.voucher?.voucherUnitValue != null
//                 ? common.currencyFormat(element.voucher!.voucherUnitValue!)
//                 : '',
//             width: 2,
//           ),
//           PosColumn(
//             text: '( 0% )',
//             width: 2,
//           ),
//           PosColumn(
//             text: 'x ${element.ordvcTotalVoucher}',
//             width: 2,
//           ),
//           PosColumn(
//             text: '- ${common.currencyFormat(element.ordvcTotalAmount)}',
//             width: 4,
//             styles: const PosStyles(
//               align: PosAlign.right,
//             ),
//           )
//         ],
//       );
//     }
//     bytes += generator.hr();
//     // Print Total
//     bytes += generator.row(
//       [
//         PosColumn(
//           text: 'TOTAL',
//           width: 4,
//         ),
//         PosColumn(
//           text: '1 PAK',
//           width: 2,
//         ),
//         PosColumn(
//           text: common.currencyFormat(body.orderTotalAmt),
//           width: 6,
//           styles: const PosStyles(
//             align: PosAlign.right,
//           ),
//         ),
//       ],
//     );
//     if (totalVoucher > 0) {
//       bytes += generator.row(
//         [
//           PosColumn(
//             text: 'Voucher',
//             width: 6,
//           ),
//           PosColumn(
//             text: '- ${common.currencyFormat(totalVoucher)}',
//             width: 6,
//             styles: const PosStyles(
//               align: PosAlign.right,
//             ),
//           ),
//         ],
//       );
//     }
//     bytes += generator.row(
//       [
//         PosColumn(
//           text: MapPaymentMethod[body.orderPaidBy] ?? '',
//           width: 6,
//         ),
//         PosColumn(
//           text: common.currencyFormat(body.orderTotalAmt),
//           width: 6,
//           styles: const PosStyles(
//             align: PosAlign.right,
//           ),
//         ),
//       ],
//     );
//     bytes += generator.hr();
//     // Print Thank You Message
//     bytes += generator.text(
//       '>>>PERHATIAN<<<',
//       styles: const PosStyles(
//         align: PosAlign.left,
//         bold: true,
//       ),
//     );
//     bytes += generator.text(
//       '1.Jagalah barang-barang anda',
//       styles: const PosStyles(
//         align: PosAlign.left,
//       ),
//     );
//     bytes += generator.text(
//       '1.Harap struk ini disimpan dengan baik',
//       styles: const PosStyles(
//         align: PosAlign.left,
//       ),
//     );
//     bytes += generator.emptyLines(1);
//     bytes += generator.text(
//       'TIKET YANG SUDAH DI BELI',
//       styles: const PosStyles(align: PosAlign.center, bold: true),
//     );
//     bytes += generator.text(
//       'TIDAK DAPAT DITUKAR/DIKEMBALIKAN',
//       styles: const PosStyles(align: PosAlign.center, bold: true),
//     );
//     bytes += generator.text(
//       'TERIMA KASIH ATAS KUNJUNGAN ANDA',
//       styles: const PosStyles(
//         align: PosAlign.center,
//       ),
//     );
//     // bytes += generator.emptyLines(1);
//     bytes += generator.cut();

//     return bytes;
//   }

//   // List<int> _generateEscPosImage(img.Image image) {
//   //   List<int> bytes = [];

//   //   // ESC/POS command: Initialize printer
//   //   bytes.addAll([0x1B, 0x40]);

//   //   // Image dimensions
//   //   int width = image.width;
//   //   int height = image.height;

//   //   // ESC/POS command: Select bit-image mode
//   //   for (int y = 0; y < height; y += 24) {
//   //     // ESC/POS command: Set print position to left margin
//   //     bytes.addAll([0x1B, 0x24, 0x00, 0x00]);

//   //     // ESC/POS command: Define the bit-image mode
//   //     bytes.addAll([0x1B, 0x2A, 0x21, (width / 8).ceil(), 0x00]);

//   //     for (int x = 0; x < width; x++) {
//   //       for (int k = 0; k < 3; k++) {
//   //         int slice = 0;
//   //         for (int b = 0; b < 8; b++) {
//   //           int yIndex = y + k * 8 + b;
//   //           int pixel = 0;
//   //           if (yIndex < height) {
//   //             int pixelColor = image.getPixel(x, yIndex).r.toInt();
//   //             pixel = (pixelColor & 0xFF) < 128 ? 1 : 0;
//   //           }
//   //           slice |= (pixel << (7 - b));
//   //         }
//   //         bytes.add(slice);
//   //       }
//   //     }
//   //     // ESC/POS command: Print the data in the buffer
//   //     bytes.addAll([0x0A]);
//   //   }

//   //   // ESC/POS command: Print and feed
//   //   bytes.addAll([0x1B, 0x64, 0x02]);

//   //   return bytes;
//   // }
// }
