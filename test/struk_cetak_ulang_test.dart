import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jaya_propertiy/app/utils/common/escpos_decoder_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_member_print_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_print_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/order/order_member_model.dart';
import 'package:jaya_propertiy/data/models/order/order_model.dart';

/// Penanda **CETAK ULANG** pada struk yang dicetak ulang.
///
/// Tanpa penanda, lembar kedua tidak bisa dibedakan dari struk asli: isinya
/// sama persis, termasuk nomor transaksi dan nominalnya. Satu transaksi dengan
/// dua lembar struk tanpa tanda adalah dua bukti pembayaran yang sama sahnya.
///
/// Diperiksa dari byte yang dikirim ke printer, didekode kembali jadi teks —
/// bukan dari niat kodenya.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting(constant.locale);
  });

  OrderModel order() => OrderModel(
        orderNumber: '22102624ORD0001',
        orderReffno: 'RF-01',
        orderName: 'dede',
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
    bool cetakUlang = false,
    bool strukVoid = false,
  }) async {
    final bytes = await GeneratePrintUtil().dataPaymentTiketPrint(
      locationName: 'GOGOPLAY',
      kasirName: 'kasir123',
      paperSize: PaperSize.mm80,
      body: order(),
      cetakUlang: cetakUlang,
      strukVoid: strukVoid,
      alasanVoid: strukVoid ? 'Salah input' : null,
      disetujuiOleh: strukVoid ? 'spv1' : null,
    );
    return EscPosDecoder.decode(bytes);
  }

  group('Struk penjualan', () {
    test('cetakan pertama TIDAK bertanda cetak ulang', () async {
      final baris = await struk();
      expect(baris.any((b) => b.contains('CETAK ULANG')), isFalse);
      expect(baris.any((b) => b.contains('BUKAN STRUK ASLI')), isFalse);
    });

    test('cetak ulang bertanda di ATAS, sebelum nomor transaksi', () async {
      final baris = await struk(cetakUlang: true);
      final iTanda = baris.indexWhere((b) => b.contains('CETAK ULANG'));
      final iReff = baris.indexWhere((b) => b.contains('No Reff.'));
      expect(iTanda, greaterThanOrEqualTo(0), reason: 'penanda tidak ada');
      expect(iTanda, lessThan(iReff),
          reason: 'penanda harus mendahului nomor; penanda yang tersembunyi di '
              'kaki struk tidak terbaca oleh yang hanya melihat sekilas');
      expect(baris, contains('BUKAN STRUK ASLI'));
    });

    test('penanda diulang di bawah — struk panjang sering terpotong', () async {
      final baris = await struk(cetakUlang: true);
      final jumlah = baris.where((b) => b.contains('CETAK ULANG')).length;
      expect(jumlah, greaterThanOrEqualTo(2),
          reason: 'penanda hanya sekali di atas hilang bila struknya dipotong');
    });

    test('waktu cetak ulang ikut tercetak', () async {
      // Membedakan lembar kedua dari lembar ketiga: tanpa waktunya, dua
      // cetakan ulang atas transaksi yang sama tidak bisa dibedakan.
      final baris = await struk(cetakUlang: true);
      expect(baris.any((b) => b.startsWith('Dicetak ulang:')), isTrue, reason: baris.toString());
    });

    test('isi struknya tidak berubah oleh penanda', () async {
      final asli = await struk();
      final ulang = await struk(cetakUlang: true);
      // Nomor, nama pembeli, dan total harus tetap sama — penandanya tambahan,
      // bukan pengganti.
      for (final wajib in ['No Reff. RF-01', 'Nama Pembeli : dede']) {
        expect(asli, contains(wajib));
        expect(ulang, contains(wajib));
      }
    });
  });

  group('Struk pembatalan', () {
    test('struk void TIDAK ikut bertanda cetak ulang', () async {
      // Struk void memang baru dicetak sekali, dan sudah punya penandanya
      // sendiri. Dua penanda sekaligus hanya membuat pembacanya ragu lembar
      // mana yang berlaku.
      final baris = await struk(strukVoid: true);
      expect(baris.any((b) => b.contains('VOID / PEMBATALAN')), isTrue);
      expect(baris.any((b) => b.contains('CETAK ULANG')), isFalse);
    });

    test('void yang dicetak ulang boleh membawa kedua penanda', () async {
      // Keadaan ini tidak dipakai layar kasir sekarang, tetapi pencetaknya
      // tidak boleh menukar atau menelan salah satunya.
      final baris = await struk(strukVoid: true, cetakUlang: true);
      expect(baris.any((b) => b.contains('VOID / PEMBATALAN')), isTrue);
      expect(baris.any((b) => b.contains('CETAK ULANG')), isTrue);
    });
  });

  group('Struk membership', () {
    OrderMemberModel member() => OrderMemberModel(
          orderName: 'Fika',
          orderMemberNo: 'BKS02-MKN20261020539',
          orderPaidBy: 'CASH',
          totalPrice: 100000,
          adminFeeAmt: 0,
        );

    Future<List<String>> strukMember({bool cetakUlang = false}) async {
      final bytes = await GenerateMemberPrintUtil().paymentPrint(
        locationName: 'GOGOPLAY',
        kasirName: 'kasir123',
        paperSize: PaperSize.mm80,
        body: member(),
        paymentDate: DateTime(2026, 10, 22, 14, 30),
        cetakUlang: cetakUlang,
      );
      return EscPosDecoder.decode(bytes);
    }

    test('cetakan pertama tanpa penanda', () async {
      expect((await strukMember()).any((b) => b.contains('CETAK ULANG')), isFalse);
    });

    test('cetak ulang membership ikut bertanda', () async {
      // Jalur member punya pencetaknya sendiri; penanda yang hanya dipasang di
      // struk penjualan akan membuat cetak ulang membership tetap tak bertanda.
      final baris = await strukMember(cetakUlang: true);
      expect(baris.any((b) => b.contains('CETAK ULANG')), isTrue);
      expect(baris, contains('BUKAN STRUK ASLI'));
    });
  });
}
