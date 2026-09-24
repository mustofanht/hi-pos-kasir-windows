import 'package:flutter_test/flutter_test.dart';
import 'package:jaya_propertiy/app/utils/common/kas_util.dart';

/// Modal kas per pecahan saat buka kasir (permintaan 23 Sep 2026).
///
/// Uang modal diserahkan ke kasir dalam bentuk lembaran dan
/// dipertanggungjawabkan begitu juga: "10rb 10 lembar, 20rb 5 lembar". Angka
/// yang dipakai rekap selisih akhir shift berasal dari hitungan di sini, jadi
/// salah sedikit berarti kasir dianggap kurang atau lebih setor.
void main() {
  group('Hitungan uang per pecahan', () {
    test('contoh dari outlet: 10rb 10 lembar + 20rb 5 lembar', () {
      expect(KasUtil.total({10000: 10, 20000: 5}), 200000);
    });

    test('laci kosong berjumlah nol', () {
      expect(KasUtil.total({}), 0);
      expect(KasUtil.total({for (final p in KasUtil.pecahan) p: 0}), 0);
    });

    test('koin ikut dihitung', () {
      expect(KasUtil.total({1000: 3, 500: 4, 200: 5, 100: 6}), 6600);
    });

    test('isian aneh tidak menggeser total', () {
      // Lembar negatif tidak mungkin ada di laci; pecahan nol atau negatif
      // hanya bisa datang dari data rusak. Keduanya diabaikan, bukan dijumlah.
      expect(KasUtil.total({10000: -3, 0: 5, -5000: 2, 20000: 1}), 20000);
    });

    test('hitungan besar tetap tepat, tanpa pembulatan', () {
      expect(KasUtil.total({100000: 137}), 13700000);
    });
  });

  group('Baris yang disimpan', () {
    test('pecahan nol lembar tidak ikut dikirim', () {
      final hasil = KasUtil.terisi({100000: 0, 50000: 2, 10000: 0, 5000: 1});
      expect(hasil.keys.toList(), [50000, 5000]);
    });

    test('urut dari pecahan terbesar', () {
      final hasil = KasUtil.terisi({1000: 1, 100000: 1, 20000: 1, 500: 1});
      expect(hasil.keys.toList(), [100000, 20000, 1000, 500]);
    });

    test('hitungan kosong menghasilkan daftar kosong', () {
      expect(KasUtil.terisi({10000: 0}), isEmpty);
    });
  });

  group('Isian kasir', () {
    test('angka biasa terbaca', () {
      expect(KasUtil.bacaLembar('12'), 12);
    });

    test('isian kosong dibaca nol, bukan gagal', () {
      // Kasir sering menghapus isian untuk menghitung ulang; saat itu totalnya
      // harus ikut berkurang, bukan berhenti berubah.
      expect(KasUtil.bacaLembar(''), 0);
      expect(KasUtil.bacaLembar('   '), 0);
    });

    test('pemisah dan huruf dibuang', () {
      expect(KasUtil.bacaLembar(' 1.200 '), 1200);
      expect(KasUtil.bacaLembar('10 lembar'), 10);
      expect(KasUtil.bacaLembar('-5'), 5);
      expect(KasUtil.bacaLembar('abc'), 0);
    });
  });

  group('Kapan kasir ditahan mengisi modal', () {
    test('lokasi yang tidak memakai modal tidak pernah ditanya', () {
      expect(
        KasUtil.wajibIsiModal(pakaiModalKas: false, modalAwal: null),
        isFalse,
      );
    });

    test('lokasi memakai modal dan belum diisi: ditahan', () {
      expect(
        KasUtil.wajibIsiModal(pakaiModalKas: true, modalAwal: null),
        isTrue,
      );
    });

    test('modal nol tetap dianggap sudah diisi', () {
      // Kasir yang memang tidak memegang uang modal boleh menyimpan nol dan
      // tidak boleh ditanya lagi sepanjang shift.
      expect(
        KasUtil.wajibIsiModal(pakaiModalKas: true, modalAwal: 0),
        isFalse,
      );
    });

    test('modal yang sudah diisi tidak ditanya ulang', () {
      expect(
        KasUtil.wajibIsiModal(pakaiModalKas: true, modalAwal: 500000),
        isFalse,
      );
    });
  });

  group('Daftar pecahan', () {
    test('tidak ada pecahan kembar', () {
      // Pecahan adalah kunci baris di server; kembar berarti hitungan satu
      // pecahan menimpa hitungan pecahan lain.
      expect(KasUtil.pecahan.toSet().length, KasUtil.pecahan.length);
    });

    test('urut dari terbesar dan semuanya masuk akal', () {
      final urut = [...KasUtil.pecahan]..sort((a, b) => b.compareTo(a));
      expect(KasUtil.pecahan, urut);
      expect(KasUtil.pecahan.every((e) => e > 0), isTrue);
      expect(KasUtil.pecahan.first, 100000);
      expect(KasUtil.pecahan.last, 100);
    });
  });
}
