import 'package:flutter_test/flutter_test.dart';
import 'package:jaya_propertiy/app/utils/common/paginasi_util.dart';

/// Perhitungan halaman daftar Tiket & Item yang dimuat sambil digulir
/// (laporan 26 Oktober 2026: "menu tiket jika terbagi 2 halaman tidak bisa
/// scroll atas maupun bawah").
///
/// Dua kesalahan yang bersama-sama mengosongkan layar:
///
/// 1. `pageNo` berbasis 0 dibandingkan dengan `ttlPages` yang berupa **cacah**
///    halaman, sehingga pada halaman terakhir kasir masih meminta halaman
///    berikutnya. Server menjawab daftar kosong.
/// 2. Daftarnya dikosongkan sebelum diisi, jadi jawaban kosong itu menghapus
///    seluruh isi layar — tidak ada lagi yang bisa digulir ke mana pun.
///
/// Yang kedua diperbaiki di controller (tidak bisa diuji tanpa GetX dan
/// service hidup); yang pertama dihitung di sini.
void main() {
  group('ada halaman berikutnya', () {
    test('halaman pertama dari dua: masih ada', () {
      expect(PaginasiKasir.adaHalamanBerikutnya(0, 2), isTrue);
    });

    test('halaman TERAKHIR dari dua: sudah habis', () {
      // Inilah bandingan yang dulu salah: 1 < 2 bernilai benar, sehingga
      // kasir meminta halaman 2 yang tidak ada.
      expect(PaginasiKasir.adaHalamanBerikutnya(1, 2), isFalse);
    });

    test('satu halaman saja: tidak pernah meminta tambahan', () {
      expect(PaginasiKasir.adaHalamanBerikutnya(0, 1), isFalse);
    });

    test('halaman tengah dari lima', () {
      expect(PaginasiKasir.adaHalamanBerikutnya(2, 5), isTrue);
      expect(PaginasiKasir.adaHalamanBerikutnya(4, 5), isFalse);
    });

    test('daftar kosong', () {
      expect(PaginasiKasir.adaHalamanBerikutnya(0, 0), isFalse);
    });

    test('nilai belum ada (balasan pertama belum tiba) tidak memicu apa pun',
        () {
      // Dulu di sini dipakai `!` pada dua nilai yang bisa null; pemuatan awal
      // yang gagal membuat seluruh gulir melempar galat.
      expect(PaginasiKasir.adaHalamanBerikutnya(null, 2), isFalse);
      expect(PaginasiKasir.adaHalamanBerikutnya(0, null), isFalse);
      expect(PaginasiKasir.adaHalamanBerikutnya(null, null), isFalse);
    });

    test('nilai aneh dari server tidak dipercaya', () {
      expect(PaginasiKasir.adaHalamanBerikutnya(-1, 3), isFalse);
      expect(PaginasiKasir.adaHalamanBerikutnya(0, -2), isFalse);
    });
  });

  group('sudah di dasar daftar', () {
    test('tepat di dasar', () {
      expect(PaginasiKasir.sudahDiDasar(800, 800), isTrue);
    });

    test('kurang beberapa piksel tetap dihitung sampai', () {
      // `pixels == maxScrollExtent` mudah terlewat: satu piksel sisa karena
      // pantulan gulir atau pembulatan membuat halaman berikutnya tidak pernah
      // diminta, dan daftarnya berhenti diam-diam di tengah.
      expect(PaginasiKasir.sudahDiDasar(799, 800), isTrue);
      expect(PaginasiKasir.sudahDiDasar(760, 800), isTrue);
    });

    test('masih jauh dari dasar', () {
      expect(PaginasiKasir.sudahDiDasar(100, 800), isFalse);
    });

    test('isi belum melebihi layar: tidak ada halaman yang perlu ditarik', () {
      expect(PaginasiKasir.sudahDiDasar(0, 0), isFalse);
    });

    test('tergulir melewati dasar (pantulan) tetap dihitung sampai', () {
      expect(PaginasiKasir.sudahDiDasar(830, 800), isTrue);
    });
  });
}
