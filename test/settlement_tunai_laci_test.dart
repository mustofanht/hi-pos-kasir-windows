import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/escpos_decoder_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_print_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_detail_entity.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_detail_payment_entity.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_kas_pecahan_entity.dart';

/// Baris TUNAI di ringkasan pembayaran struk settlement = uang hasil hitung
/// kasir di laci, bukan hitungan sistem (24 Nov 2026). Hitungan sistem tetap
/// tertulis sebagai TOTAL TUNAI di RINCIAN LACI TUNAI.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting(constant.locale);
  });

  String rp(double v) => common.currencyFormat(v);

  /// Penjualan tunai 300.000 + modal 200.000 = seharusnya 500.000; kasir
  /// menghitung 480.000 di laci (kurang 20.000). QRIS 150.000.
  ShiftDetailEntity shift({
    double? kasAkhir = 480000,
    List<ShiftKasPecahanEntity>? pecahan,
    bool adaTunai = true,
    String modal = 'Y',
  }) =>
      ShiftDetailEntity(
        userFullName: 'Kasir Uji',
        lokasiName: 'UJI',
        shftStart: DateTime(2026, 11, 24, 8),
        shftEnd: DateTime(2026, 11, 24, 16),
        pakaiModalKas: modal,
        modalAwal: 200000,
        tunaiSum: adaTunai ? 300000 : 0,
        kasSeharusnya: adaTunai ? 500000 : 200000,
        kasAkhir: kasAkhir,
        listPecahanAkhir: pecahan ??
            [ShiftKasPecahanEntity(pecahan: 100000, lembar: 4, jumlah: 400000),
             ShiftKasPecahanEntity(pecahan: 50000, lembar: 1, jumlah: 50000)],
        listSumPayment: [
          if (adaTunai) ShiftDetailPaymentEntity(name: 'CASH', amount: 300000),
          ShiftDetailPaymentEntity(name: 'QRIS', amount: 150000),
        ],
      );

  Future<List<String>> cetak(ShiftDetailEntity d) async => EscPosDecoder.decode(
        await generatePrintUtil.dataSettlementPrint(paperSize: PaperSize.mm80, detail: d),
      );

  /// Nilai kolom kanan untuk baris berlabel [label]: dekoder menulis tiap
  /// kolom sebagai baris sendiri, diselingi baris perintah `[...]`.
  String baris(List<String> struk, String label) {
    final i = struk.indexWhere((l) => l.trim() == label);
    if (i < 0) return '<tidak ada baris $label>';
    return struk
        .skip(i + 1)
        .firstWhere((l) => l.trim().isNotEmpty && !l.startsWith('['), orElse: () => '')
        .trim();
  }

  test('TUNAI = hasil hitung laci (kasAkhir), TOTAL TUNAI tetap hitungan sistem', () async {
    final s = await cetak(shift());
    expect(baris(s, 'CASH'), endsWith(rp(480000)));
    expect(baris(s, 'Total'), endsWith(rp(480000 + 150000)));
    expect(baris(s, 'TOTAL TUNAI'), endsWith(rp(500000)));
  });

  test('kasAkhir kosong: dijumlah dari pecahan akhir', () async {
    final s = await cetak(shift(kasAkhir: null));
    expect(baris(s, 'CASH'), endsWith(rp(450000)));
  });

  test('laci belum dihitung: kembali ke hitungan sistem', () async {
    final s = await cetak(shift(kasAkhir: null, pecahan: const []));
    expect(baris(s, 'CASH'), endsWith(rp(500000)));
  });

  test('tanpa penjualan tunai: baris TUNAI tetap dicetak dari hitungan laci', () async {
    final s = await cetak(shift(adaTunai: false, kasAkhir: 200000));
    expect(baris(s, 'TUNAI'), endsWith(rp(200000)));
    expect(baris(s, 'Total'), endsWith(rp(200000 + 150000)));
  });
}
