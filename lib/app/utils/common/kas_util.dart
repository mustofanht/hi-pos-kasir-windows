/// Hitungan uang kasir per pecahan.
///
/// Modal kas diserahkan ke kasir dalam bentuk lembaran, bukan satu angka, dan
/// yang dipertanggungjawabkan memang lembarannya: "10rb 10 lembar, 20rb 5
/// lembar". Semua perhitungannya dikumpulkan di sini supaya layar modal awal,
/// layar hitung laci, dan rekap shift memakai aturan yang sama persis.
class KasUtil {
  /// Pecahan rupiah yang dihitung kasir, dari yang terbesar.
  ///
  /// Seribu hanya muncul sekali walaupun ada dalam bentuk kertas dan koin:
  /// yang dicatat adalah nilainya, dan laci tidak membedakan keduanya.
  static const List<int> pecahan = [
    100000,
    50000,
    20000,
    10000,
    5000,
    2000,
    1000,
    500,
    200,
    100,
  ];

  /// Jumlah uang dari sebuah hitungan lembar per pecahan.
  ///
  /// Pecahan yang tidak ada di [pecahan] tetap dijumlah: hitungan lama yang
  /// tersimpan di server tidak boleh berubah nilainya hanya karena daftar
  /// pecahan di aplikasi suatu saat dirapikan.
  static int total(Map<int, int> lembar) {
    var jumlah = 0;
    lembar.forEach((nilai, banyak) {
      if (nilai <= 0 || banyak <= 0) return;
      jumlah += nilai * banyak;
    });
    return jumlah;
  }

  /// Hitungan yang benar-benar diisi, terurut dari pecahan terbesar.
  ///
  /// Baris nol lembar dibuang di sini, bukan di layar: yang tidak ada di laci
  /// tidak perlu dikirim maupun disimpan.
  static Map<int, int> terisi(Map<int, int> lembar) {
    final hasil = <int, int>{};
    final kunci = lembar.keys.where((e) => e > 0).toList()
      ..sort((a, b) => b.compareTo(a));
    for (final nilai in kunci) {
      final banyak = lembar[nilai] ?? 0;
      if (banyak > 0) hasil[nilai] = banyak;
    }
    return hasil;
  }

  /// Membaca isian lembar yang diketik kasir.
  ///
  /// Kasir mengetik di tengah pekerjaan: spasi, titik pemisah ribuan, dan
  /// isian yang dikosongkan lagi semuanya wajar dan tidak boleh berakhir
  /// dengan angka yang salah. Yang tidak masuk akal dibaca sebagai nol.
  static int bacaLembar(String teks) {
    final angka = teks.replaceAll(RegExp(r'[^0-9]'), '');
    if (angka.isEmpty) return 0;
    final nilai = int.tryParse(angka) ?? 0;
    return nilai < 0 ? 0 : nilai;
  }

  /// Apakah kasir wajib mengisi modal sebelum boleh berjualan.
  ///
  /// Dua syarat dan keduanya berasal dari server: lokasinya memakai modal kas,
  /// dan modal shift ini belum pernah diisi. Nol pun dianggap sudah diisi —
  /// kasir yang memang tidak memegang uang modal boleh menyimpan nol dan tidak
  /// akan ditanya lagi sepanjang shift.
  static bool wajibIsiModal({
    required bool pakaiModalKas,
    required num? modalAwal,
  }) {
    if (!pakaiModalKas) return false;
    return modalAwal == null;
  }
}

KasUtil kasUtil = KasUtil();
