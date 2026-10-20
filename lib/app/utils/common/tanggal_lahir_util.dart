/// Tanggal lahir yang diisi kasir: perubahan bentuk dari isian layar menjadi
/// nilai yang dikirim ke server.
///
/// Dipisah dari controller supaya bisa diuji sendiri. Yang diuji di sini bukan
/// tampilannya, melainkan dua hal yang diam-diam bisa salah:
/// panjang & urutan daftarnya (harus sejajar dengan daftar nama anak, karena
/// server memasangkannya berdasarkan posisi), dan bentuk tanggalnya.
class TanggalLahirUtil {
  const TanggalLahirUtil();

  /// Satu tanggal dalam bentuk kiriman server, "yyyy-MM-dd".
  ///
  /// Dirakit tangan, bukan dengan `DateFormat`: bentuk kiriman ke server tidak
  /// boleh ikut berubah bila lokal aplikasi berubah. Hanya bagian tanggalnya
  /// yang dipakai — jam tidak punya arti untuk tanggal lahir.
  ///
  /// Mengembalikan string KOSONG untuk null, bukan null, supaya daftarnya tetap
  /// rapat: server memasangkan tanggal dengan tiket berdasarkan posisi, jadi
  /// tiket yang tanggalnya tidak diisi tetap harus menempati tempatnya.
  String iso(DateTime? nilai) {
    if (nilai == null) {
      return '';
    }
    final tahun = nilai.year.toString().padLeft(4, '0');
    final bulan = nilai.month.toString().padLeft(2, '0');
    final hari = nilai.day.toString().padLeft(2, '0');
    return '$tahun-$bulan-$hari';
  }

  /// Daftar tanggal lahir sepanjang [jumlah] tiket playground, urut.
  ///
  /// [samaSemua] = pilihan "Sama untuk semua" di layar pembayaran: satu tanggal
  /// (yang diisi di samping Nama Pemesan) dipakai untuk seluruh tiket.
  ///
  /// [nilai] boleh lebih pendek dari [jumlah] — kasir bisa menambah tiket
  /// setelah mengisi beberapa tanggal, dan posisi yang belum ada isinya
  /// diperlakukan sebagai belum diisi, bukan error.
  List<String> daftar({
    required int jumlah,
    required bool samaSemua,
    required List<DateTime?> nilai,
  }) {
    if (jumlah <= 0) {
      return const [];
    }
    if (samaSemua) {
      return List.filled(jumlah, iso(_pada(nilai, 0)));
    }
    return List.generate(jumlah, (i) => iso(_pada(nilai, i)));
  }

  DateTime? _pada(List<DateTime?> nilai, int indeks) {
    if (indeks < 0 || indeks >= nilai.length) {
      return null;
    }
    return nilai[indeks];
  }
}

TanggalLahirUtil tanggalLahirUtil = const TanggalLahirUtil();
