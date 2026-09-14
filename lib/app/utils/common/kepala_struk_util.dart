import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

/// Kepala struk: nama lokasi, lalu alamat dan nomor telepon lokasi itu.
///
/// Satu tempat untuk semua struk (penjualan tiket, booking lapangan, member),
/// supaya kepala struk tidak berbeda antar jenis transaksi.
class KepalaStruk {
  KepalaStruk._();

  /// Jumlah karakter satu baris huruf normal (font A) di kertas 80 mm.
  static const int lebarBaris80mm = 48;

  static List<int> cetak(
    Generator generator, {
    String? nama,
    String? alamat,
    String? telepon,
    int lebarBaris = lebarBaris80mm,
  }) {
    List<int> bytes = [];
    if (nama == null) return bytes;

    bytes += generator.text(
      nama,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        width: PosTextSize.size2,
        height: PosTextSize.size2,
      ),
    );

    for (final baris in barisKontak(
      alamat: alamat,
      telepon: telepon,
      lebarBaris: lebarBaris,
    )) {
      bytes += generator.text(
        baris,
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes += generator.emptyLines(1);
    return bytes;
  }

  /// Baris alamat (dipecah per kata agar muat satu baris kertas) diikuti baris
  /// telepon. Yang kosong tidak dicetak, jadi lokasi tanpa data kontak tetap
  /// menghasilkan kepala struk seperti sebelumnya.
  static List<String> barisKontak({
    String? alamat,
    String? telepon,
    int lebarBaris = lebarBaris80mm,
  }) {
    final hasil = <String>[];
    final a = _rapikan(alamat);
    if (a != null) hasil.addAll(pecahBaris(a, lebarBaris));
    final t = formatTelepon(telepon);
    if (t != null) hasil.add('Telp. $t');
    return hasil;
  }

  /// Nomor di master lokasi banyak yang tersimpan tanpa angka 0 di depan
  /// (`89630918829`), karena pernah diisi sebagai angka. Di struk ditulis
  /// seperti nomor yang biasa dilihat pelanggan: `089630918829`.
  static String? formatTelepon(String? telepon) {
    final t = _rapikan(telepon);
    if (t == null) return null;
    if (t.startsWith('8')) return '0$t';
    return t;
  }

  /// Memecah [teks] per kata menjadi baris sepanjang paling banyak [lebar].
  /// Kata yang lebih panjang dari satu baris dipotong paksa.
  static List<String> pecahBaris(String teks, int lebar) {
    final baris = <String>[];
    var sekarang = '';
    for (var kata in teks.split(' ')) {
      if (kata.isEmpty) continue;
      while (kata.length > lebar) {
        if (sekarang.isNotEmpty) {
          baris.add(sekarang);
          sekarang = '';
        }
        baris.add(kata.substring(0, lebar));
        kata = kata.substring(lebar);
      }
      if (sekarang.isEmpty) {
        sekarang = kata;
      } else if (sekarang.length + 1 + kata.length <= lebar) {
        sekarang = '$sekarang $kata';
      } else {
        baris.add(sekarang);
        sekarang = kata;
      }
    }
    if (sekarang.isNotEmpty) baris.add(sekarang);
    return baris;
  }

  static String? _rapikan(String? s) {
    if (s == null) return null;
    final r = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return r.isEmpty || r == '-' ? null : r;
  }
}
