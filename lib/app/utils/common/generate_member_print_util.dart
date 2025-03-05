import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/order/order_member_model.dart';
import 'package:jaya_propertiy/domain/entities/member/member_list.dart';

class GenerateMemberPrintUtil {
  List<int> buildListMemberPayment(
    Generator generator,
    List<MemberListResponse>? element,
  ) {
    List<int> bytes = [];

    bytes += generator.row(
      [
        PosColumn(
          text: 'Nama',
          width: 6,
        ),
        PosColumn(
          text: 'Hubungan',
          width: 6,
        ),
      ],
    );
    if (element != null) {
      for (var e in element) {
        bytes += generator.row(
          [
            PosColumn(
              text: e.lsName ?? '',
              width: 6,
            ),
            PosColumn(
              text: MemberRelation.getName(e.lsRelCode ?? ''),
              width: 6,
            ),
          ],
        );
      }
    }

    return bytes;
  }

  Future<List<int>> paymentPrint({
    String? locationName,
    String? kasirName,
    required PaperSize paperSize,
    required OrderMemberModel body,
  }) async {
    List<int> bytes = [];
    // Using default profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();

    bytes += generator.text(
      'Member ${body.orderName}',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        width: PosTextSize.size2,
        height: PosTextSize.size2,
      ),
    );

    bytes += generator.hr();
    bytes += generator.row(
      [
        PosColumn(
          text: 'Nama',
          width: 1,
        ),
        PosColumn(
          text: ':',
          width: 1,
        ),
        PosColumn(
          text: body.orderName ?? '',
          width: 10,
        ),
      ],
    );
    bytes += generator.row(
      [
        PosColumn(
          text: 'Email',
          width: 1,
        ),
        PosColumn(
          text: ':',
          width: 1,
        ),
        PosColumn(
          text: body.orderEmail ?? '',
          width: 10,
        ),
      ],
    );
    bytes += generator.row(
      [
        PosColumn(
          text: 'Masa Berlaku',
          width: 1,
        ),
        PosColumn(
          text: ':',
          width: 1,
        ),
        PosColumn(
          text: '',
          width: 10,
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
    return bytes;
  }
}

GenerateMemberPrintUtil generateMemberPrintUtil = GenerateMemberPrintUtil();
