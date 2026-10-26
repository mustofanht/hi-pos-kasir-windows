import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jaya_propertiy/app/utils/common/escpos_decoder_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_print_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/order/order_model.dart';

/// Keterangan Voucher pada struk (permintaan 26 Oktober 2026).
///
/// Isian "Keterangan Voucher" di menu Pembayaran selama ini hanya tersimpan di
/// `trn_order.order_voucher_desc` dan hanya terlihat di back office — struk
/// pelanggan tidak memuat jejak voucher mana yang dipakai.
///
/// Dua kegagalan berlawanan yang dijaga di sini:
///
/// 1. **Keterangannya hilang.** Nilainya ada di order tetapi tidak sampai ke
///    kertas — termasuk pada CETAK ULANG, yang model struknya dirakit ulang
///    dari data layar (persis cara nama pembeli dulu hilang).
/// 2. **Baris kosong di setiap struk.** Layar penjualan mengirim **spasi**
///    untuk isian yang kosong (`keteranganVoucher.text.isEmpty ? ' ' : ...`),
///    jadi pemeriksaan `isEmpty` saja akan meloloskan baris "Ket. Voucher :"
///    hampa pada semua transaksi tanpa voucher.
///
/// Diperiksa dari byte yang dikirim ke printer, didekode kembali jadi teks.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting(constant.locale);
  });

  OrderModel order({String? ketVoucher}) => OrderModel(
        orderNumber: '26102624ORD0008',
        orderReffno: 'RF-08',
        orderName: 'sasa',
        orderVoucherDesc: ketVoucher,
        orderTotalItem: 1,
        orderTotalAmt: 60000,
        adminFeeAmt: 0,
        orderUnitId: 1,
        orderLoacationId: 24,
        orderPaidBy: 'CASH',
        orderPaidByName: 'Tunai',
        orderStatus: 'C',
        paymentDate: DateTime(2026, 10, 26, 14, 51),
        listTicket: const [],
        listProduct: const [],
        listVoucher: const [],
        listVoucherPrice: const [],
        listDepositUse: const [],
      );

  Future<List<String>> struk({String? ketVoucher}) async {
    final bytes = await GeneratePrintUtil().dataPaymentTiketPrint(
      locationName: 'GOGOPLAY',
      locationAddress: 'Kalut-Tarakan',
      locationPhone: '087762997316',
      kasirName: 'spvadmin',
      paperSize: PaperSize.mm80,
      body: order(ketVoucher: ketVoucher),
    );
    return EscPosDecoder.decode(bytes);
  }

  List<String> barisKet(List<String> baris) =>
      baris.where((b) => b.contains('Ket. Voucher')).toList();

  group('Keterangan voucher di struk', () {
    test('tercetak berlabel saat diisi', () async {
      final baris = await struk(ketVoucher: 'VCKARYAWAN001');
      expect(baris, contains('Ket. Voucher : VCKARYAWAN001'));
    });

    test('tidak menumpang di baris nama pembeli', () async {
      // Baris berlabel yang digabung terbaca sebagai bagian dari nama, persis
      // masalah nama pembeli yang dulu menumpang di baris tanggal.
      final baris = await struk(ketVoucher: 'VCKARYAWAN001');
      final namaBaris = baris.firstWhere((b) => b.contains('Nama Pembeli'));
      expect(namaBaris.contains('VCKARYAWAN001'), isFalse,
          reason: 'keterangan voucher ikut di baris nama: $namaBaris');
    });

    test('berada di atas garis pemisah, bukan di kaki struk', () async {
      final baris = await struk(ketVoucher: 'VCKARYAWAN001');
      final iKet = baris.indexWhere((b) => b.contains('Ket. Voucher'));
      final iNama = baris.indexWhere((b) => b.contains('Nama Pembeli'));
      final iTiket = baris.indexWhere((b) => b.contains('TOTAL'));
      expect(iKet, greaterThan(iNama));
      if (iTiket >= 0) {
        expect(iKet, lessThan(iTiket));
      }
    });

    group('tanpa voucher: TIDAK ada baris sama sekali', () {
      test('null', () async {
        expect(barisKet(await struk()), isEmpty);
      });

      test('spasi — yang dikirim layar untuk isian kosong', () async {
        expect(barisKet(await struk(ketVoucher: ' ')), isEmpty);
      });

      test('string kosong', () async {
        expect(barisKet(await struk(ketVoucher: '')), isEmpty);
      });

      test('tanda hubung', () async {
        // Beberapa layar mengirim "-" sebagai penanda kosong; itu bukan
        // keterangan voucher dan tidak perlu dicetak.
        expect(barisKet(await struk(ketVoucher: '-')), isEmpty);
      });
    });

    test('spasi tepi dipangkas, isinya utuh', () async {
      final baris = await struk(ketVoucher: '  VC-LEBARAN 2026  ');
      expect(baris, contains('Ket. Voucher : VC-LEBARAN 2026'));
    });
  });
}
