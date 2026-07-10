import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/order/order_member_model.dart';

class GenerateMemberPrintUtil {
  Future<List<int>> paymentPrint({
    String? locationName,
    String? kasirName,
    DateTime? paymentDate,
    required PaperSize paperSize,
    required OrderMemberModel body,
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
      'No Reff. ${body.orderReffno ?? ''}',
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    bytes += generator.text(
      'Member No : ${body.orderMemberNo ?? ''}',
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

    // paymentDate
    bytes += generator.row(
      [
        PosColumn(
          text: paymentDate != null
              ? dateTimeUtil.getFormattedDate(
                  date: paymentDate,
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
    // List Order Payment
    if (body.membership != null) {
      bytes += generator.text(
        body.membership?.membName ?? '',
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
            text: body.membership?.membRegPrice != null
                ? common.currencyFormat(body.membership!.membRegPrice ?? 0)
                : '',
            width: 4,
          ),
          PosColumn(
            text: common.currencyFormat(body.totalPrice ?? 0),
            width: 6,
            styles: const PosStyles(
              align: PosAlign.right,
            ),
          )
        ],
      );
    }
    bytes += generator.hr();

    if (body.adminFeeAmt != null && body.adminFeeAmt! > 0) {
      bytes += generator.row(
        [
          PosColumn(
            text: 'Biaya Admin',
            width: 6,
          ),
          PosColumn(
            text: common.currencyFormat(body.adminFeeAmt ?? 0),
            width: 6,
            styles: const PosStyles(
              align: PosAlign.right,
            ),
          ),
        ],
      );
    }

    bytes += generator.row(
      [
        PosColumn(
          text: body.orderPaidBy ?? '',
          width: 6,
        ),
        PosColumn(
          text: common.currencyFormat(body.totalPrice ?? 0),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
          ),
        ),
      ],
    );
    // Print Total
    bytes += generator.row(
      [
        PosColumn(
          text: 'TOTAL',
          width: 6,
        ),
        PosColumn(
          text: common.currencyFormat(body.totalPrice ?? 0),
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
      'MEMBER YANG SUDAH DI BELI',
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

    bytes += generator.cut();

    bytes += await paymentPrintDetail(
      paperSize: paperSize,
      body: body,
      paymentDate: paymentDate,
    );

    bytes += generator.cut();
    
    return bytes;
  }

  Future<List<int>> paymentPrintDetail({
    required PaperSize paperSize,
    required OrderMemberModel body,
    DateTime? paymentDate,
  }) async {
    List<int> bytes = [];
    // Using default profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();

    // bytes += generator.text(
    //   'Member ${body.orderName}',
    //   styles: const PosStyles(
    //     align: PosAlign.center,
    //     bold: true,
    //     width: PosTextSize.size2,
    //     height: PosTextSize.size2,
    //   ),
    // );
    bytes += generator.text(
      body.orderMemberNo ?? '',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        width: PosTextSize.size2,
        height: PosTextSize.size2,
      ),
    );
    bytes += generator.emptyLines(1);

    bytes += generator.text(
      'No Reff. ${body.orderReffno ?? ''}',
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    // bytes += generator.text(
    //   'Member No : ${body.orderMemberNo ?? ''}',
    //   styles: const PosStyles(
    //     align: PosAlign.left,
    //     bold: true,
    //   ),
    // );
    bytes += generator.text(
      'Nama Member : ${body.membership?.membName ?? ''}',
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );

    // paymentDate
    bytes += generator.row(
      [
        PosColumn(
          text: paymentDate != null
              ? dateTimeUtil.getFormattedDate(
                  date: paymentDate,
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

    // Print Total
    bytes += generator.row(
      [
        PosColumn(
          text: 'NAMA',
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

    // bytes += generator.row(
    //   [
    //     PosColumn(
    //       text: 'EMAIL',
    //       width: 6,
    //     ),
    //     PosColumn(
    //       text: body.orderEmail ?? '',
    //       width: 6,
    //       styles: const PosStyles(
    //         align: PosAlign.right,
    //       ),
    //     ),
    //   ],
    // );

    bytes += generator.row(
      [
        PosColumn(
          text: 'MASA BERLAKU',
          width: 6,
        ),
        PosColumn(
          text: body.orderMemberExpiredDate != null
              ? dateTimeUtil.getFormattedDate(
                  date: body.orderMemberExpiredDate!,
                  format: dateFormat.fullTimePrinted,
                )
              : 'Selamanya',
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
          ),
        ),
      ],
    );

    bytes += generator.hr();

    if (body.listMember != null && body.listMember!.length > 0) {
      bytes += generator.row(
        [
          PosColumn(
            text: 'NAMA',
            width: 6,
          ),
          PosColumn(
            text: 'HUBUNGAN',
            width: 6,
            styles: const PosStyles(
              align: PosAlign.right,
            ),
          ),
        ],
      );

      for (var element in body.listMember!) {
        bytes += generator.row(
          [
            PosColumn(
              text: element.lsName ?? '',
              width: 6,
            ),
            PosColumn(
              text: element.lsRelCode != null
                  ? MemberRelation.getName(element.lsRelCode!)
                  : '',
              width: 6,
              styles: const PosStyles(
                align: PosAlign.right,
              ),
            ),
          ],
        );
      }
    }

    return bytes;
  }
}

GenerateMemberPrintUtil generateMemberPrintUtil = GenerateMemberPrintUtil();
