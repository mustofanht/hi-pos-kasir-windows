import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jaya_propertiy/app/utils/common/escpos_decoder_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_member_print_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_print_util.dart';
import 'package:jaya_propertiy/app/utils/common/kepala_struk_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/order/order_member_model.dart';
import 'package:jaya_propertiy/data/models/order/order_model.dart';

void main() {
  late Generator generator;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting(constant.locale);
    final profile = await CapabilityProfile.load();
    generator = Generator(PaperSize.mm80, profile);
  });

  List<String> teks(List<int> bytes) => EscPosDecoder.decode(bytes)
      .where((b) => b.trim().isNotEmpty && !b.startsWith('['))
      .map((b) => b.trim())
      .toList();

  group('Kepala struk', () {
    test('nama, alamat, lalu telepon — berurutan', () {
      final hasil = teks(KepalaStruk.cetak(
        generator,
        nama: 'Arena Playground Bekasi',
        alamat: 'Kp. Rawa Panjang RT003/RW004',
        telepon: '85933533953',
      ));
      expect(hasil, [
        'Arena Playground Bekasi',
        'Kp. Rawa Panjang RT003/RW004',
        'Telp. 085933533953',
      ]);
    });

    test('telepon tanpa angka 0 di depan dilengkapi, yang lain apa adanya', () {
      expect(KepalaStruk.formatTelepon('89630918829'), '089630918829');
      expect(KepalaStruk.formatTelepon('0215551234'), '0215551234');
      expect(KepalaStruk.formatTelepon('+62 812 3456'), '+62 812 3456');
      expect(KepalaStruk.formatTelepon('  '), isNull);
      expect(KepalaStruk.formatTelepon(null), isNull);
    });

    test('lokasi tanpa kontak menghasilkan kepala struk seperti sebelumnya', () {
      expect(teks(KepalaStruk.cetak(generator, nama: 'Lokasi Test')),
          ['Lokasi Test']);
      expect(KepalaStruk.barisKontak(alamat: '-', telepon: ''), isEmpty);
      expect(KepalaStruk.cetak(generator), isEmpty);
    });

    test('alamat panjang dipecah per kata, tidak ada baris melebihi kertas', () {
      const alamat = 'Jl. Raya Kalimalang No. 88 Blok C/12, Kel. Jakasampurna, '
          'Kec. Bekasi Barat, Kota Bekasi, Jawa Barat 17145';
      final baris = KepalaStruk.barisKontak(alamat: alamat);
      expect(baris.length, greaterThan(1));
      for (final b in baris) {
        expect(b.length, lessThanOrEqualTo(KepalaStruk.lebarBaris80mm), reason: b);
      }
      expect(baris.join(' '), alamat);
    });

    test('kata yang lebih panjang dari satu baris dipotong paksa', () {
      expect(KepalaStruk.pecahBaris('ABCDEFGHIJ KL', 4), ['ABCD', 'EFGH', 'IJ', 'KL']);
    });

    test('alamat dengan baris baru dirapikan jadi satu spasi', () {
      expect(KepalaStruk.barisKontak(alamat: 'Jl. Yos\n  Sudarso'), ['Jl. Yos Sudarso']);
    });
  });

  group('Struk memakai kepala struk', () {
    test('struk penjualan tiket mencetak alamat & telepon lokasi', () async {
      final bytes = await GeneratePrintUtil().dataPaymentTiketPrint(
        locationName: 'Arena Playground Bekasi',
        locationAddress: 'Bekasi',
        locationPhone: '89630918829',
        kasirName: 'kasirnht',
        paperSize: PaperSize.mm80,
        body: OrderModel(
          orderTotalItem: 0,
          orderTotalAmt: 0,
          adminFeeAmt: 0,
          orderUnitId: 1,
          orderLoacationId: 30,
          orderPaidBy: 'CASH',
          orderPaidByName: 'Tunai',
          orderStatus: 'P',
          listTicket: [],
          listProduct: [],
          listVoucher: [],
          listVoucherPrice: [],
          listDepositUse: [],
        ),
      );
      final hasil = teks(bytes);
      final i = hasil.indexOf('Arena Playground Bekasi');
      expect(i, isNot(-1));
      expect(hasil.sublist(i + 1, i + 3), ['Bekasi', 'Telp. 089630918829']);
    });

    test('struk member mencetak alamat & telepon lokasi', () async {
      final bytes = await GenerateMemberPrintUtil().paymentPrint(
        locationName: 'Club House NHT Bekasi',
        locationAddress: 'dewi sartika',
        locationPhone: '987654321',
        kasirName: 'kasir',
        paperSize: PaperSize.mm80,
        body: OrderMemberModel(),
      );
      final hasil = teks(bytes);
      expect(hasil, containsAllInOrder(['Club House NHT Bekasi', 'dewi sartika', 'Telp. 987654321']));
    });
  });
}
