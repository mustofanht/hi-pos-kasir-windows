import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jaya_propertiy/app/utils/common/escpos_decoder_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_print_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/domain/entities/gate/gate_entity.dart';

/// Cetak ulang tiket dari layar Keluar Manual: data dari server dibaca utuh, dan
/// kertas yang keluar membawa nomor tiket yang sama.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting(constant.locale);
  });

  test('data tiket dari server terbaca, termasuk penanda pendamping', () {
    final t = ManualExitTicketEntity.fromJson({
      'ticketNo': '300909260012',
      'orderNo': 'ORD-0161',
      'reffNo': 'RF-99',
      'ticketName': 'Tiket 1 jam weekday',
      'activeDate': '2026-09-09T00:00:00.000+07:00',
      'isCompanion': 'Y',
      'orderDate': '2026-09-09T10:15:00.000+07:00',
      'alreadyTakeout': true,
    });
    expect(t.ticketNo, '300909260012');
    expect(t.reffNo, 'RF-99');
    expect(t.pendamping, isTrue);
    expect(t.alreadyTakeout, isTrue);
    expect(t.activeDate!.isUtc, isFalse, reason: 'tanggal ditampilkan waktu setempat');
  });

  test('kertas cetak ulang membawa nomor tiket yang sama sebagai QR', () async {
    final bytes = await GeneratePrintUtil().dataGatePrint(
      locationName: 'Arena Playground Bekasi',
      paperSize: PaperSize.mm80,
      orderNo: 'ORD-0161',
      reffNo: 'RF-99',
      pakOf: 1,
      pakTotal: 1,
      qrCode: '300909260012',
      expiredAt: '09 September 2026',
      ticketName: 'Tiket 1 jam weekday',
      isCompanion: 'N',
      paymentDate: DateTime(2026, 9, 9, 10, 15),
    );
    // Isi QR tidak diterjemahkan jadi teks oleh penerjemah, jadi dicari di byte
    // perintah QR-nya langsung.
    expect(String.fromCharCodes(bytes), contains('300909260012'));
    expect(EscPosDecoder.decode(bytes).join('\n'), contains('Order ID : ORD-0161'));
  });
}
