import 'package:flutter_test/flutter_test.dart';
import 'package:jaya_propertiy/app/utils/common/tanggal_lahir_util.dart';
import 'package:jaya_propertiy/data/models/order/order_member_model.dart';
import 'package:jaya_propertiy/data/models/order/order_model.dart';
import 'package:jaya_propertiy/domain/entities/member/member_valid.dart';

/// Tanggal lahir: anak di layar pembayaran kasir, dan pemilik kartu di Form
/// Membership.
///
/// Yang dikejar bukan tampilannya, melainkan dua hal yang bisa salah tanpa
/// pernah menampakkan error: panjang & urutan daftar tanggal (server
/// memasangkannya dengan tiket BERDASARKAN POSISI, jadi satu posisi yang
/// bergeser membuat tanggal lahir menempel pada anak yang salah), dan bentuk
/// tanggalnya — "12-03-2019" akan ditolak server sebagai tanggal dan berakhir
/// NULL tanpa ada yang tahu.
void main() {
  OrderModel order({List<String>? namaAnak, List<String>? tglLahir}) =>
      OrderModel(
        orderTotalItem: 1,
        orderTotalAmt: 0,
        adminFeeAmt: 0,
        orderUnitId: 1,
        orderLoacationId: 1,
        orderPaidBy: 'CASH',
        orderPaidByName: 'Tunai',
        orderStatus: 'N',
        listTicket: const [],
        listProduct: const [],
        listVoucher: const [],
        listVoucherPrice: const [],
        listDepositUse: const [],
        childNames: namaAnak,
        childDobs: tglLahir,
      );

  group('Bentuk tanggal kiriman server', () {
    test('yyyy-MM-dd dengan nol di depan', () {
      expect(tanggalLahirUtil.iso(DateTime(2019, 3, 5)), '2019-03-05');
      expect(tanggalLahirUtil.iso(DateTime(2021, 12, 31)), '2021-12-31');
    });

    test('jam diabaikan', () {
      // Pemilih tanggal mengembalikan tengah malam lokal, tapi kalau suatu saat
      // ia membawa jam, yang dikirim tetap harus tanggalnya saja.
      expect(
        tanggalLahirUtil.iso(DateTime(2019, 3, 5, 23, 59, 59)),
        '2019-03-05',
      );
    });

    test('tidak diisi menjadi string kosong, bukan "null"', () {
      // String kosong penting: posisi tiketnya tetap terpakai, jadi tanggal
      // tiket-tiket sesudahnya tidak bergeser.
      expect(tanggalLahirUtil.iso(null), '');
    });
  });

  group('Daftar tanggal per tiket playground', () {
    test('isi per anak: urut sesuai posisi tiketnya', () {
      final hasil = tanggalLahirUtil.daftar(
        jumlah: 3,
        samaSemua: false,
        nilai: [DateTime(2019, 3, 12), null, DateTime(2021, 9, 4)],
      );
      expect(hasil, ['2019-03-12', '', '2021-09-04']);
    });

    test('sama untuk semua: satu tanggal diulang sebanyak tiketnya', () {
      final hasil = tanggalLahirUtil.daftar(
        jumlah: 4,
        samaSemua: true,
        nilai: [DateTime(2018, 1, 2), DateTime(2020, 5, 6)],
      );
      // Hanya isian pertama yang dipakai — isian lama dari mode "isi per anak"
      // tidak boleh ikut terkirim diam-diam.
      expect(hasil, ['2018-01-02', '2018-01-02', '2018-01-02', '2018-01-02']);
    });

    test('sama untuk semua tanpa tanggal: semuanya kosong', () {
      expect(
        tanggalLahirUtil.daftar(jumlah: 2, samaSemua: true, nilai: [null]),
        ['', ''],
      );
    });

    test('tiket ditambah setelah tanggal diisi: sisanya kosong', () {
      // Kasir menambah tiket di keranjang sesudah mengisi dua tanggal.
      final hasil = tanggalLahirUtil.daftar(
        jumlah: 4,
        samaSemua: false,
        nilai: [DateTime(2019, 3, 12), DateTime(2020, 7, 1)],
      );
      expect(hasil, ['2019-03-12', '2020-07-01', '', '']);
      expect(hasil.length, 4);
    });

    test('tiket dikurangi: tanggal lebih tidak ikut terkirim', () {
      final hasil = tanggalLahirUtil.daftar(
        jumlah: 1,
        samaSemua: false,
        nilai: [DateTime(2019, 3, 12), DateTime(2020, 7, 1)],
      );
      expect(hasil, ['2019-03-12']);
    });

    test('tanpa tiket playground: daftarnya kosong', () {
      expect(
        tanggalLahirUtil.daftar(jumlah: 0, samaSemua: false, nilai: []),
        isEmpty,
      );
      expect(
        tanggalLahirUtil.daftar(jumlah: 0, samaSemua: true, nilai: []),
        isEmpty,
      );
    });

    test('panjangnya selalu sama dengan jumlah tiket', () {
      for (final jumlah in [1, 2, 5, 10]) {
        for (final samaSemua in [false, true]) {
          expect(
            tanggalLahirUtil
                .daftar(jumlah: jumlah, samaSemua: samaSemua, nilai: []).length,
            jumlah,
            reason: 'jumlah=$jumlah samaSemua=$samaSemua',
          );
        }
      }
    });
  });

  group('Kiriman order kasir', () {
    test('childDobs ikut terkirim & sejajar dengan childNames', () {
      final json = order(
        namaAnak: ['Kairi', 'Raka'],
        tglLahir: ['2019-03-12', ''],
      ).toJson();

      expect(json['childNames'], ['Kairi', 'Raka']);
      expect(json['childDobs'], ['2019-03-12', '']);
      expect(
        (json['childDobs'] as List).length,
        (json['childNames'] as List).length,
      );
    });

    test('order non-playground tidak mengirim tanggal lahir', () {
      final json = order().toJson();
      expect(json.containsKey('childDobs'), isTrue);
      expect(json['childDobs'], isNull);
    });

    test('kosong semua tetap terkirim sepanjang tiketnya', () {
      // Semua tanggal dikosongkan kasir: daftarnya TETAP dikirim sepanjang
      // jumlah tiket, bukan dipendekkan — server membaca posisi, dan daftar
      // yang memendek membuat nama & tanggal tidak lagi sejajar.
      final json = order(
        namaAnak: ['Kairi', 'Raka', 'Sita'],
        tglLahir: tanggalLahirUtil
            .daftar(jumlah: 3, samaSemua: false, nilai: const []),
      ).toJson();
      expect(json['childDobs'], ['', '', '']);
    });
  });

  group('Form Membership', () {
    test('tanggal lahir kartu terkirim sebagai yyyy-MM-dd', () {
      final json = OrderMemberModel(
        orderName: 'Budi',
        custIdentityNo: '3201010101010001',
        custBirthDate: tanggalLahirUtil.iso(DateTime(1988, 7, 9)),
      ).toJson();
      expect(json['custBirthDate'], '1988-07-09');
    });

    test('tanggal lahir tidak diisi dikirim null, bukan string kosong', () {
      // Bedanya penting: pada perpanjangan kartu, null berarti "jangan diubah".
      final json = OrderMemberModel(orderName: 'Budi').toJson();
      expect(json['custBirthDate'], isNull);
    });

    test('kartu lama: tanggal lahir dari server dibaca untuk mengisi ulang form',
        () {
      final member = MemberValid.fromJson({
        'cardNo': 'PG-M0120261020001',
        'cardName': 'Budi',
        'cardBirthDate': '1988-07-09',
      });
      expect(member.cardBirthDate, DateTime(1988, 7, 9));
    });

    test('kartu tanpa tanggal lahir tidak menggagalkan pencarian member', () {
      expect(
        MemberValid.fromJson({'cardNo': 'X', 'cardName': 'Budi'}).cardBirthDate,
        isNull,
      );
      // Nilai aneh pun tidak boleh melempar — kasir masih harus bisa melayani.
      expect(
        MemberValid.fromJson({'cardNo': 'X', 'cardBirthDate': 'bukan tanggal'})
            .cardBirthDate,
        isNull,
      );
    });
  });
}
