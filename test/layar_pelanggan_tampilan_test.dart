import 'package:flutter_test/flutter_test.dart';
import 'package:jaya_propertiy/app/utils/common/layar_pelanggan_tampilan.dart';

/// Logo dan teks sambutan layar pelanggan (permintaan 24 Sep 2026).
///
/// Keduanya datang dari master lokasi, dan lokasi yang belum mengisinya harus
/// kembali ke logo bawaan aplikasi — bukan menampilkan kotak kosong atau
/// gambar rusak di depan pelanggan.
void main() {
  group('Nilai tampilan layar pelanggan', () {
    test('teks biasa dipakai apa adanya', () {
      expect(LayarPelangganTampilan.bersih('WELCOME TO GOGOPLAY'),
          'WELCOME TO GOGOPLAY');
    });

    test('spasi di ujung dibuang', () {
      expect(LayarPelangganTampilan.bersih('  Selamat Datang  '), 'Selamat Datang');
    });

    test('kosong dan spasi saja dianggap belum disetel', () {
      // Back office menyimpan string kosong saat isiannya dihapus; itu harus
      // berarti "pakai bawaan", bukan judul kosong yang memakan tempat.
      expect(LayarPelangganTampilan.bersih(''), isNull);
      expect(LayarPelangganTampilan.bersih('   '), isNull);
    });

    test('nilai bukan teks tidak dipakai', () {
      expect(LayarPelangganTampilan.bersih(null), isNull);
      expect(LayarPelangganTampilan.bersih(12345), isNull);
    });
  });
}
