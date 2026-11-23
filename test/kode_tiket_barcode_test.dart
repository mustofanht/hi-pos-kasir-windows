import 'dart:convert';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jaya_propertiy/app/utils/common/code128_util.dart';
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

    List<String> batang(String t) => t
        .split(RegExp(r'\r?\n'))
        .where((l) => l.startsWith('BAR '))
        .toList();

    test('bawaan QR, tanpa batang barcode', () {
      final t = tspl(false);
      expect(t, contains('QRCODE'));
      expect(batang(t), isEmpty);
    });

    test('BARCODE: batang BAR melintang pita, tanpa QR / perintah BARCODE',
        () {
      final t = tspl(true);
      expect(t, isNot(contains('QRCODE')));
      // Perintah BARCODE printer tidak dipakai: di printer Blueprint ia
      // tercetak tanpa diputar dan terpotong di tepi pita.
      expect(t, isNot(contains('BARCODE')));

      final pola = Code128.lebarModul('2011300015');
      final b = batang(t)
          .map((l) => l.substring(4).split(',').map(int.parse).toList())
          .toList();
      // Satu BAR per batang hitam (elemen genap pola).
      expect(b.length, (pola.length + 1) ~/ 2);

      final sempit = b.first[3] ~/ pola.first;
      expect(sempit, greaterThanOrEqualTo(c.dots(0.25)));
      for (final k in b) {
        // Melintang pita: x & lebar sama untuk semua batang, di dalam lembar.
        expect(k[0], b.first[0]);
        expect(k[2], b.first[2]);
        expect(k[0], greaterThanOrEqualTo(0));
        expect(k[0] + k[2], lessThanOrEqualTo(c.widthDots));
        expect(k[1], greaterThanOrEqualTo(0));
        expect(k[1] + k[3], lessThanOrEqualTo(c.heightDots));
      }
      // Urutan batang + celah di antaranya membentuk pola CODE128 persis.
      final dibaca = <int>[];
      for (var i = 0; i < b.length; i++) {
        dibaca.add(b[i][3] ~/ sempit);
        if (i + 1 < b.length) {
          dibaca.add((b[i + 1][1] - b[i][1] - b[i][3]) ~/ sempit);
        }
      }
      expect(dibaca, pola);

      // Nomor tiket tetap tercetak sebagai teks untuk Keluar Manual.
      expect(t, contains('TEXT'));
      expect(t, contains('2011300015'));
    });
  });

  group('Code128', () {
    test('nomor 10 digit: Start C, 5 pasang digit, cek 3, stop', () {
      // 105 + 20*1 + 11*2 + 30*3 + 0*4 + 15*5 = 312; 312 mod 103 = 3
      expect(Code128.nilai('2011300015'), [105, 20, 11, 30, 0, 15, 3]);
      final pola = Code128.lebarModul('2011300015');
      expect(pola.reduce((a, b) => a + b), 7 * 11 + 13);
      expect(pola.take(6), [2, 1, 1, 2, 3, 2]); // Start C
      expect(pola.skip(pola.length - 7), [2, 3, 3, 1, 1, 1, 2]); // Stop
    });

    test('berhuruf / ganjil memakai subset B; karakter asing ditolak', () {
      expect(Code128.nilai('A1').first, 104);
      expect(Code128.nilai('123').first, 104);
      expect(Code128.lebarModul('tiketé'), isEmpty);
    });
  });
}
