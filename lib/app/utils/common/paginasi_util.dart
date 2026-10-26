/// Perhitungan halaman untuk daftar yang dimuat sambil digulir.
///
/// Dipisahkan dari controller supaya bisa diuji: controller memerlukan GetX
/// dan service hidup, sementara satu salah banding di sini sudah cukup untuk
/// mengosongkan layar kasir.
class PaginasiKasir {
  /// Masih ada halaman sesudah [currentPage]?
  ///
  /// `pageNo` dari server **berbasis 0** dan `ttlPages` adalah **cacah**
  /// halaman (keduanya dari Spring: `getNumber()` & `getTotalPages()`). Jadi
  /// halaman terakhir ber-nomor `ttlPages - 1`, dan pembandingnya harus
  /// `currentPage + 1 < ttlPages`.
  ///
  /// Dulu di sini tertulis `currentPage < ttlPages`, yang pada halaman
  /// terakhir masih berkata "ada lagi" dan membuat kasir meminta halaman di
  /// luar jangkauan. Server menjawab dengan daftar kosong — dan di halaman
  /// Tiket, yang mengosongkan daftarnya sebelum mengisi, layarnya menjadi
  /// kosong sama sekali: tidak ada yang bisa digulir ke atas maupun ke bawah
  /// (dilaporkan 26 Okt 2026).
  static bool adaHalamanBerikutnya(int? currentPage, int? totalPage) {
    if (currentPage == null || totalPage == null) return false;
    if (currentPage < 0 || totalPage <= 0) return false;
    return currentPage + 1 < totalPage;
  }

  /// Sudah cukup dekat ke dasar daftar untuk memuat halaman berikutnya?
  ///
  /// Memakai ambang, bukan `pixels == maxScrollExtent`. Persamaan tepat itu
  /// mudah terlewat: satu piksel sisa karena pantulan gulir, perubahan tinggi
  /// kartu, atau pembulatan membuat halaman berikutnya tidak pernah diminta,
  /// dan daftarnya berhenti diam-diam di tengah.
  static bool sudahDiDasar(double pixels, double maxScrollExtent,
      {double ambang = 48}) {
    if (maxScrollExtent <= 0) return false;
    return pixels >= maxScrollExtent - ambang;
  }
}
