import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jaya_propertiy/app/utils/common/escpos_decoder_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_print_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/order/order_model.dart';

/// Nama pembeli pada cetakan, dan struk pembatalan (VOID).
///
/// Dibuat setelah laporan dari lapangan: baris "Nama Pembeli" tidak muncul di
/// struk cetak ulang. Penyebabnya bukan di pencetaknya, melainkan model struk
/// yang dirakit ulang dari data layar tanpa mengisi `orderName` — dan karena
/// pencetaknya menulis "-" untuk nama kosong, keluarannya terlihat wajar.
///
/// Uji ini memeriksa dari sisi yang tidak bisa berbohong: byte yang dikirim ke
/// printer, didekode kembali menjadi teks.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting(constant.locale);
  });

  OrderModel order({String? nama}) => OrderModel(
        orderNumber: '22102624ORD0001',
        orderReffno: 'RF-01',
        orderName: nama,
        orderTotalItem: 1,
        orderTotalAmt: 60000,
        adminFeeAmt: 0,
        orderUnitId: 1,
        orderLoacationId: 24,
        orderPaidBy: 'CASH',
        orderPaidByName: 'Tunai',
        orderStatus: 'C',
        paymentDate: DateTime(2026, 10, 22, 14, 30),
        listTicket: const [],
        listProduct: const [],
        listVoucher: const [],
        listVoucherPrice: const [],
        listDepositUse: const [],
      );

  Future<List<String>> struk({
    String? nama,
    bool strukVoid = false,
    String? alasan,
    String? disetujui,
  }) async {
    final bytes = await GeneratePrintUtil().dataPaymentTiketPrint(
      locationName: 'GOGOPLAY',
      locationAddress: 'Bekasi',
      locationPhone: '0218888',
      kasirName: 'kasir123',
      paperSize: PaperSize.mm80,
      body: order(nama: nama),
      strukVoid: strukVoid,
      alasanVoid: alasan,
      disetujuiOleh: disetujui,
    );
    return EscPosDecoder.decode(bytes);
  }

  group('Nama pembeli di struk pembayaran', () {
    test('tercetak berlabel, satu baris sendiri', () async {
      final baris = await struk(nama: 'dede');
      expect(baris, contains('Nama Pembeli : dede'));
    });

    test('tidak menumpang di baris tanggal', () async {
      // Posisi lamanya (ujung kanan baris tanggal) memotong nama panjang dan
      // membuatnya terbaca seperti potongan nama kasir.
      final baris = await struk(nama: 'Muhamad Ridwan Ahfi');
      final barisTanggal = baris.firstWhere((b) => b.contains('2026'),
          orElse: () => '');
      expect(barisTanggal.contains('Muhamad'), isFalse,
          reason: 'nama tidak boleh ikut di baris tanggal');
      expect(baris, contains('Nama Pembeli : Muhamad Ridwan Ahfi'));
    });

    test('nama kosong ditulis "-", bukan baris berlabel yang hampa', () async {
      // Baris berlabel yang isinya kosong terbaca sebagai cetakan terpotong,
      // dan petugas mencetaknya lagi.
      expect(await struk(nama: null), contains('Nama Pembeli : -'));
      expect(await struk(nama: '   '), contains('Nama Pembeli : -'));
    });
  });

  group('Struk pembatalan (VOID)', () {
    test('penanda VOID di paling atas, sebelum nomor apa pun', () async {
      final baris = await struk(nama: 'dede', strukVoid: true);
      final iVoid = baris.indexWhere((b) => b.contains('VOID / PEMBATALAN'));
      final iReff = baris.indexWhere((b) => b.contains('No Reff.'));
      expect(iVoid, greaterThanOrEqualTo(0), reason: 'penanda VOID tidak ada');
      expect(iVoid, lessThan(iReff),
          reason: 'penanda VOID harus mendahului nomor — struk void yang hanya '
              'berbeda satu baris di bawah akan dibaca sebagai bukti bayar');
    });

    test('alasan dan nama penyetuju tercetak', () async {
      final baris = await struk(
        nama: 'dede',
        strukVoid: true,
        alasan: 'Salah input tiket',
        disetujui: 'spv1',
      );
      expect(baris, contains('Alasan : Salah input tiket'));
      // Tanpa nama penyetuju, kertas bertulisan VOID tidak bisa dibedakan dari
      // kertas yang dibuat kasir sendiri.
      expect(baris, contains('Disetujui : spv1'));
    });

    test('alasan/penyetuju kosong tetap bertanda "-"', () async {
      final baris = await struk(nama: 'dede', strukVoid: true);
      expect(baris, contains('Alasan : -'));
      expect(baris, contains('Disetujui : -'));
    });

    test('struk penjualan biasa tidak membawa penanda VOID', () async {
      final baris = await struk(nama: 'dede');
      expect(baris.any((b) => b.contains('VOID')), isFalse);
      expect(baris.any((b) => b.startsWith('Alasan :')), isFalse);
    });

    test('nama pembeli tetap ada di struk pembatalan', () async {
      // Pelanggan harus bisa mencocokkan struk void dengan struk pembeliannya.
      final baris = await struk(nama: 'dede', strukVoid: true);
      expect(baris, contains('Nama Pembeli : dede'));
    });
  });
}
