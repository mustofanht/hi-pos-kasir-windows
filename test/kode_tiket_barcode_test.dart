import 'dart:convert';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jaya_propertiy/app/utils/common/generate_print_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_wristband_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/common/wristband_config_model.dart';
import 'package:jaya_propertiy/domain/entities/auth/user_entity.dart';

/// Setelan lokasi "kode di tiket / gelang": QR atau BARCODE, selalu salah
/// satu — tidak pernah keduanya tercetak bersamaan.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting(constant.locale);
  });

  /// `GS ( k` = perintah QR ESC/POS; `GS k` = perintah barcode.
  bool adaQr(List<int> b) {
    for (var i = 0; i + 2 < b.length; i++) {
      if (b[i] == 0x1D && b[i + 1] == 0x28 && b[i + 2] == 0x6B) return true;
    }
    return false;
  }

  bool adaBarcode(List<int> b) {
    for (var i = 0; i + 2 < b.length; i++) {
      if (b[i] == 0x1D && b[i + 1] == 0x6B && b[i + 2] == 73) return true;
    }
    return false;
  }

  Future<List<int>> tiket({required bool barcode, String no = '2011300015'}) =>
      generatePrintUtil.dataGatePrint(
        paperSize: PaperSize.mm80,
        orderNo: 'ORD0001',
        reffNo: '-',
        pakOf: 1,
        pakTotal: 1,
        qrCode: no,
        expiredAt: '20 November 2026',
        barcode: barcode,
      );

  group('struk tiket', () {
    test('bawaan QR saja', () async {
      final b = await tiket(barcode: false);
      expect(adaQr(b), isTrue);
      expect(adaBarcode(b), isFalse);
    });

    test('BARCODE: CODE128 subset C, tanpa QR, nomor tetap tercetak', () async {
      final b = await tiket(barcode: true);
      expect(adaBarcode(b), isTrue);
      expect(adaQr(b), isFalse);
      // GS k 73 n {C 20 11 30 00 15
      final i = List.generate(b.length - 2, (i) => i).firstWhere(
          (i) => b[i] == 0x1D && b[i + 1] == 0x6B && b[i + 2] == 73);
      expect(b.sublist(i + 3, i + 3 + 8), [7, 0x7B, 0x43, 20, 11, 30, 0, 15]);
      expect(latin1.decode(b, allowInvalid: true), contains('2011300015'));
    });

    test('nomor berhuruf / ganjil memakai subset B', () async {
      final b = await tiket(barcode: true, no: 'A12345');
      final i = List.generate(b.length - 2, (i) => i).firstWhere(
          (i) => b[i] == 0x1D && b[i + 1] == 0x6B && b[i + 2] == 73);
      expect(b.sublist(i + 4, i + 6), [0x7B, 0x42]);
    });
  });

  group('setelan lokasi di UserEntity', () {
    test('kosong / QR = QR; BARCODE (huruf apa pun) = barcode', () {
      final u = UserEntity();
      expect(u.tiketPakaiBarcode, isFalse);
      expect(u.gelangPakaiBarcode, isFalse);
      u.locationTicketCodeType = 'barcode';
      u.locationWristbandCodeType = 'QR';
      expect(u.tiketPakaiBarcode, isTrue);
      expect(u.gelangPakaiBarcode, isFalse);
    });
  });

  group('gelang playground', () {
    final gen = GenerateWristbandUtil();
    final c = WristbandConfigModel.terbukti();

    String tspl(bool barcode) => latin1.decode(gen.dataGelangPlayground(
          config: c,
          qrCode: '2011300015',
          lokasi: 'UJI GELANG',
          nama: 'Pendamping (nama anak)',
          nomorTiket: '2011300015',
          waktu: '2026-11-20 10:00:00',
          barcode: barcode,
        ));

    test('bawaan QR, tanpa BARCODE', () {
      final t = tspl(false);
      expect(t, contains('QRCODE'));
      expect(t, isNot(contains('BARCODE')));
    });

    test('BARCODE: satu barcode berputar, tanpa QR, di dalam lembar', () {
      final t = tspl(true);
      expect(t, isNot(contains('QRCODE')));
      final baris =
          t.split(RegExp(r'\r?\n')).where((l) => l.startsWith('BARCODE'));
      expect(baris.length, 1);
      final bagian = baris.first.substring(7).split(',');
      final x = int.parse(bagian[0].trim());
      final y = int.parse(bagian[1].trim());
      final tinggi = int.parse(bagian[3].trim());
      final sempit = int.parse(bagian[6].trim());
      expect(bagian[5].trim(), '90');
      expect(sempit, greaterThanOrEqualTo(c.dots(0.25)));
      final panjang = GenerateWristbandUtil.modulBarcode('2011300015') * sempit;
      expect(x - tinggi, greaterThanOrEqualTo(0));
      expect(x, lessThanOrEqualTo(c.widthDots));
      expect(y, greaterThanOrEqualTo(0));
      expect(y + panjang, lessThanOrEqualTo(c.heightDots));
      // Nomor tiket tetap tercetak sebagai teks untuk Keluar Manual.
      expect(t, contains('TEXT'));
      expect(t, contains('2011300015'));
    });
  });
}
