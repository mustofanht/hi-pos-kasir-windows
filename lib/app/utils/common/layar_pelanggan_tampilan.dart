import 'package:get_storage/get_storage.dart';

/// Tampilan bilah atas layar pelanggan: logo outlet dan teks sambutannya.
///
/// Keduanya diatur per lokasi di back office (Data Lokasi → General Info) dan
/// ikut terbawa saat keterangan lokasi dimuat kasir.
///
/// Disimpan di penyimpanan perangkat, bukan dioper lewat memori, karena layar
/// pelanggan berjalan di **engine Flutter tersendiri** — jendela kedua di
/// Windows, Presentation di Android. Engine itu tidak bisa membaca objek milik
/// layar kasir, sedangkan bilah atasnya harus sudah benar sejak layar pertama
/// digambar, bukan menunggu transaksi pertama tiba.
class LayarPelangganTampilan {
  static const String _kunciLogo = 'layar_pelanggan_logo';
  static const String _kunciTeks = 'layar_pelanggan_teks';

  final GetStorage _store = GetStorage('perangkat');

  /// Alamat gambar logo outlet; null bila outlet memakai logo bawaan aplikasi.
  String? get logo => bersih(_store.read(_kunciLogo));

  /// Teks sambutan; null bila bilah atas tidak perlu tulisan.
  String? get teks => bersih(_store.read(_kunciTeks));

  /// Menyimpan setelan terbaru dari master lokasi.
  ///
  /// Nilai kosong ikut disimpan sebagai kosong: outlet yang menghapus logonya
  /// di back office harus benar-benar kembali ke logo bawaan, bukan tetap
  /// memakai gambar lama yang tersisa di perangkat.
  void simpan({String? logo, String? teks}) {
    _store.write(_kunciLogo, bersih(logo) ?? '');
    _store.write(_kunciTeks, bersih(teks) ?? '');
  }

  /// Nilai dari penyimpanan yang siap dipakai: kosong dan spasi jadi null.
  ///
  /// Dipisah supaya bisa diuji tanpa menyalakan penyimpanan perangkat.
  static String? bersih(dynamic nilai) {
    if (nilai is! String) return null;
    final teks = nilai.trim();
    return teks.isEmpty ? null : teks;
  }
}

LayarPelangganTampilan layarPelangganTampilan = LayarPelangganTampilan();
