import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/order/order_addon_model.dart';
import 'package:jaya_propertiy/data/models/order/order_model.dart';
// import 'package:jaya_propertiy/data/models/order/order_ticket_model.dart';

class GeneratePrintUtil {
  List<int> buildListRentalPayment(
    Generator generator,
    OrderAddonModel element,
  ) {
    List<int> bytes = [];
    bytes += generator.row(
      [
        PosColumn(
          text: element.addOn?.productName ?? '',
          width: 12,
          styles: const PosStyles(
            align: PosAlign.left,
          ),
        ),
      ],
    );
    bytes += generator.row(
      [
        PosColumn(
          text:
              '(${element.rentHdrDtl?.startDate != null && element.rentHdrDtl?.endDate != null ? '${dateTimeUtil.getFormattedDate(date: element.rentHdrDtl!.startDate!, format: dateFormat.hourMinutes)} - ${dateTimeUtil.getFormattedDate(date: element.rentHdrDtl!.endDate!, format: dateFormat.hourMinutes)}' : ''}) (${element.rentHdrDtl?.hour} Jam)',
          width: 7,
          styles: const PosStyles(
            align: PosAlign.left,
          ),
        ),
        PosColumn(
          text: common.currencyFormat(element.ordadTotalAmount),
          width: 5,
          styles: const PosStyles(
            align: PosAlign.right,
          ),
        )
      ],
    );
    return bytes;
  }

  Future<List<int>> dataPaymentTiketPrint({
    String? locationName,
    String? kasirName,
    required PaperSize paperSize,
    required OrderModel body,
  }) async {
    List<int> bytes = [];
    // Using default profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();

    // final ByteData data = await rootBundle.load(assetsConstant.imgLogo);
    // final Uint8List bytesImg = data.buffer.asUint8List();
    // img.Image? image = img.decodeImage(bytesImg);

    // if (image != null) {
    //   if (image.width > PaperSize.mm80.width) {
    //     image = img.copyResize(image, width: PaperSize.mm80.width);
    //   }
    //   image = img.grayscale(image);
    //   bytes += generator.image(image);
    // }

    // Location Name
    if (locationName != null) {
      bytes += generator.text(
        locationName,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          width: PosTextSize.size2,
          height: PosTextSize.size2,
        ),
      );
      bytes += generator.emptyLines(1);
    }

    // Print Store Information
    bytes += generator.text(
      'No Reff. ${body.orderReffno ?? ''}',
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    bytes += generator.text(
      'Order ID : ${body.orderNumber ?? ''}',
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    bytes += generator.text(
      'Kasir :  $kasirName',
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    bytes += generator.row(
      [
        PosColumn(
          text: body.paymentDate != null
              ? dateTimeUtil.getFormattedDate(
                  date: body.paymentDate!,
                  format: dateFormat.fullTimePrinted,
                )
              : dateTimeUtil.now(
                  format: dateFormat.fullTimePrinted,
                ),
          width: 6,
        ),
        PosColumn(
          text: body.orderName ?? '',
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
          ),
        ),
      ],
    );
    bytes += generator.hr();

    // double totalBayar = 0;
    // List Ticket Order
    for (var element in body.listTicket) {
      // totalBayar += element.totalAmount;
      bytes += generator.text(
        element.ticket?.ticketName ?? '',
        styles: const PosStyles(
          align: PosAlign.left,
        ),
      );
      bytes += generator.row(
        [
          PosColumn(
            text: 'Rp',
            width: 2,
          ),
          PosColumn(
            text: element.ticket?.ticketPrice != null
                ? common.currencyFormat(element.ticket!.ticketPrice!)
                : '',
            width: 3,
          ),
          // PosColumn(
          //   text: '( 0% )',
          //   width: 2,
          // ),
          PosColumn(
            text: 'x ${element.totalTicket}',
            width: 2,
          ),
          PosColumn(
            text: common.currencyFormat(element.totalAmount),
            width: 5,
            styles: const PosStyles(
              align: PosAlign.right,
            ),
          )
        ],
      );
    }
    // List item Order
    for (var element in body.listProduct) {
      // totalBayar += element.ordadTotalAmount;
      logger.safeLog('PRODUCT TO PRINT : ${element.toJson()}');
      if (element.rentHdrDtl != null) {
        bytes += buildListRentalPayment(generator, element);
      } else {
        bytes += generator.text(
          element.addOn?.productName ?? '',
          styles: const PosStyles(
            align: PosAlign.left,
          ),
        );
        bytes += generator.row(
          [
            PosColumn(
              text: 'Rp',
              width: 2,
            ),
            PosColumn(
              text: element.addOn?.productPrice != null
                  ? common.currencyFormat(element.addOn!.productPrice!)
                  : '',
              width: 3,
            ),
            PosColumn(
              text: 'x ${element.ordadTotalAddon}',
              width: 2,
            ),
            PosColumn(
              text: common.currencyFormat(element.ordadTotalAmount),
              width: 5,
              styles: const PosStyles(
                align: PosAlign.right,
              ),
            )
          ],
        );
      }
    }
    // List voucher Order
    // double totalPotongan = 0;
    for (var element in body.listVoucher) {
      bytes += generator.text(
        element.voucher?.voucherName ?? '',
        styles: const PosStyles(
          align: PosAlign.left,
        ),
      );
      if (element.voucher!.voucherUnitType == UnitType.PERCENT) {
        bytes += generator.row(
          [
            PosColumn(
              text: '%',
              width: 2,
            ),
            PosColumn(
              text: element.voucher?.voucherUnitValue != null
                  ? common.currencyFormat(element.voucher!.voucherUnitValue!)
                  : '',
              width: 4,
            ),
            PosColumn(
              text: '- ${common.currencyFormat(element.ordvcTotalAmount)}',
              width: 6,
              styles: const PosStyles(
                align: PosAlign.right,
              ),
            )
          ],
        );
      } else {
        bytes += generator.row(
          [
            PosColumn(
              text: 'Rp',
              width: 2,
            ),
            PosColumn(
              text: element.voucher?.voucherUnitValue != null
                  ? common.currencyFormat(element.voucher!.voucherUnitValue!)
                  : '',
              width: 4,
            ),
            PosColumn(
              text: '- ${common.currencyFormat(element.ordvcTotalAmount)}',
              width: 6,
              styles: const PosStyles(
                align: PosAlign.right,
              ),
            )
          ],
        );
      }
    }
    // double totalPotongan = 0;
    for (var element in body.listVoucherPrice) {
      bytes += generator.text(
        element.entity?.vpName ?? '',
        styles: const PosStyles(
          align: PosAlign.left,
        ),
      );
      if (element.entity!.vpUnitType == UnitType.PERCENT) {
        bytes += generator.row(
          [
            PosColumn(
              text: '%',
              width: 2,
            ),
            PosColumn(
              text: element.entity?.vpUnitValue != null
                  ? common.currencyFormat(element.entity!.vpUnitValue!)
                  : '',
              width: 4,
            ),
            PosColumn(
              text: '- ${common.currencyFormat(element.ovpTotalAmount)}',
              width: 6,
              styles: const PosStyles(
                align: PosAlign.right,
              ),
            )
          ],
        );
      } else {
        bytes += generator.row(
          [
            PosColumn(
              text: 'Rp',
              width: 2,
            ),
            PosColumn(
              text: element.entity?.vpUnitValue != null
                  ? common.currencyFormat(element.entity!.vpUnitValue!)
                  : '',
              width: 4,
            ),
            PosColumn(
              text: '- ${common.currencyFormat(element.ovpTotalAmount)}',
              width: 6,
              styles: const PosStyles(
                align: PosAlign.right,
              ),
            )
          ],
        );
      }
    }
    // double totalPotongan = 0;
    for (var element in body.listDepositUse) {
      bytes += generator.text(
        element.entity?.dpName ?? '',
        styles: const PosStyles(
          align: PosAlign.left,
        ),
      );
        bytes += generator.row(
          [
            PosColumn(
              text: 'Rp',
              width: 2,
            ),
            PosColumn(
              text: element.entity?.dpAmount != null
                  ? common.currencyFormat(element.entity!.dpAmount!)
                  : '',
              width: 4,
            ),
            PosColumn(
              text: '- ${common.currencyFormat(element.odpTotalAmount)}',
              width: 6,
              styles: const PosStyles(
                align: PosAlign.right,
              ),
            )
          ],
        );
    }
    bytes += generator.hr();
    if (body.adminFeeAmt > 0) {
      bytes += generator.row(
        [
          PosColumn(
            text: 'Biaya Admin',
            width: 6,
          ),
          PosColumn(
            text: common.currencyFormat(body.adminFeeAmt),
            width: 6,
            styles: const PosStyles(
              align: PosAlign.right,
            ),
          ),
        ],
      );
    }
    // if (totalPotongan > 0) {
    //   bytes += generator.row(
    //     [
    //       PosColumn(
    //         text: 'Potongan',
    //         width: 6,
    //       ),
    //       PosColumn(
    //         text: '- ${common.currencyFormat(totalPotongan)}',
    //         width: 6,
    //         styles: const PosStyles(
    //           align: PosAlign.right,
    //         ),
    //       ),
    //     ],
    //   );
    // }
    bytes += generator.row(
      [
        PosColumn(
          // text: MapPaymentMethod[body.orderPaidBy] ?? '',
          text: body.orderPaidByName,
          width: 6,
        ),
        PosColumn(
          text: common.currencyFormat(body.orderTotalAmt),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
          ),
        ),
      ],
    );
    // Print Total
    int totalPak =
        body.listCreateTicket == null ? 0 : body.listCreateTicket!.length;
    bytes += generator.row(
      [
        PosColumn(
          text: 'TOTAL',
          width: 4,
        ),
        PosColumn(
          text: '$totalPak PAK',
          width: 2,
        ),
        PosColumn(
          text: common.currencyFormat(body.orderTotalAmt),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
          ),
        ),
      ],
    );
    bytes += generator.hr();
    // Print Thank You Message
    bytes += generator.text(
      '>>>PERHATIAN<<<',
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    bytes += generator.text(
      '1.Jagalah barang-barang anda',
      styles: const PosStyles(
        align: PosAlign.left,
      ),
    );
    bytes += generator.text(
      '2.Harap struk ini disimpan dengan baik',
      styles: const PosStyles(
        align: PosAlign.left,
      ),
    );
    bytes += generator.emptyLines(1);
    bytes += generator.text(
      'TIKET YANG SUDAH DI BELI',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'TIDAK DAPAT DITUKAR/DIKEMBALIKAN',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'TERIMA KASIH ATAS KUNJUNGAN ANDA',
      styles: const PosStyles(
        align: PosAlign.center,
      ),
    );
    // bytes += generator.emptyLines(1);
    bytes += generator.cut();

    return bytes;
  }

  Future<List<int>> dataGatePrint({
    String? locationName,
    required PaperSize paperSize,
    required String orderNo,
    required String reffNo,
    required int pakOf,
    required int pakTotal,
    required String qrCode,
    DateTime? paymentDate,
    required String expiredAt,
    // required OrderTicketModel ticketModel,
    String? ticketName,
  }) async {
    List<int> bytes = [];
    // Using default profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();

    // Location Name
    if (locationName != null) {
      bytes += generator.text(
        locationName,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          width: PosTextSize.size2,
          height: PosTextSize.size2,
        ),
      );
      bytes += generator.emptyLines(1);
    }

    // Print Store Information
    bytes += generator.text(
      'No Reff. $reffNo',
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    bytes += generator.text(
      'Order ID : $orderNo',
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    bytes += generator.text(
      paymentDate != null
          ? dateTimeUtil.getFormattedDate(
              date: paymentDate,
              format: dateFormat.fullTimePrinted,
            )
          : dateTimeUtil.now(
              format: dateFormat.fullTimePrinted,
            ),
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    bytes += generator.hr();

    bytes += generator.text(
      ticketName ?? '',
      styles: const PosStyles(
        align: PosAlign.center,
      ),
    );
    bytes += generator.text(
      '$pakOf of $pakTotal PAK',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );

    bytes += generator.emptyLines(1);
// QRCODE
    bytes += generator.qrcode(
      qrCode,
      align: PosAlign.center,
      size: QRSize.Size8,
    );
    bytes += generator.emptyLines(1);
    bytes += generator.text(
      'Berlaku $expiredAt',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );
    // bytes += generator.emptyLines(1);
    bytes += generator.cut();

    return bytes;
  }

  testPrint({
    required PaperSize paperSize,
  }) async {
    List<int> bytes = [];
    // Using default profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();

    bytes += generator.text(
      'Ready',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );

    bytes += generator.text(
      'At ${dateTimeUtil.now()}',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );

    bytes += generator.cut();

    return bytes;
  }
}

GeneratePrintUtil generatePrintUtil = GeneratePrintUtil();
