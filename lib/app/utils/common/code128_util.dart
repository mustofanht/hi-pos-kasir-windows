/// Penyandi barcode CODE128 menjadi lebar batang & spasi, dalam modul.
///
/// Dipakai gelang playground (TSPL), yang menggambar barcode sendiri sebagai
/// kotak-kotak `BAR`, bukan lewat perintah `BARCODE` milik printer. Di printer
/// gelang Blueprint (21 Nov 2026), `BARCODE ... ,90,...` tercetak TANPA
/// diputar: batangnya searah panjang gelang, simbolnya melebar melintang pita
/// 25mm dan terpotong di kedua tepi — tidak bisa dipindai sama sekali.
/// `BAR` hanya menggambar persegi panjang hitam; tidak ada putaran, tidak ada
/// pilihan subset oleh firmware, jadi hasilnya sama di printer TSPL mana pun.
///
/// Tabel pola dicocokkan satu per satu dengan tabel pustaka `barcode` 2.2.9
/// (David PHAM-VAN) sebelum dipakai.
class Code128 {
  Code128._();

  /// Pola nilai 0..105: enam angka lebar, bergantian batang-spasi-batang-...,
  /// masing-masing berjumlah 11 modul. 103/104/105 = Start A/B/C.
  static const List<String> _pola = [
    '212222', '222122', '222221', '121223', '121322', '131222', '122213',
    '122312', '132212', '221213', '221312', '231212', '112232', '122132',
    '122231', '113222', '123122', '123221', '223211', '221132', '221231',
    '213212', '223112', '312131', '311222', '321122', '321221', '312212',
    '322112', '322211', '212123', '212321', '232121', '111323', '131123',
    '131321', '112313', '132113', '132311', '211313', '231113', '231311',
    '112133', '112331', '132131', '113123', '113321', '133121', '313121',
    '211331', '231131', '213113', '213311', '213131', '311123', '311321',
    '331121', '312113', '312311', '332111', '314111', '221411', '431111',
    '111224', '111422', '121124', '121421', '141122', '141221', '112214',
    '112412', '122114', '122411', '142112', '142211', '241211', '221114',
    '413111', '241112', '134111', '111242', '121142', '121241', '114212',
    '124112', '124211', '411212', '421112', '421211', '212141', '214121',
    '412121', '111143', '111341', '131141', '114113', '114311', '411113',
    '411311', '113141', '114131', '311141', '411131', '211412', '211214',
    '211232',
  ];

  /// Stop: tujuh lebar, 13 modul.
  static const String _stop = '2331112';

  static const int _startB = 104;
  static const int _startC = 105;

  /// Nilai simbol (start, data, cek) untuk [isi].
  ///
  /// Angka saja dengan panjang genap → subset C (dua digit per simbol); nomor
  /// tiket sekarang 10 digit, jadi barcodenya separuh lebih pendek. Selain itu
  /// subset B (ASCII 32..126). Kosong bila ada karakter di luar itu.
  static List<int> nilai(String isi) {
    if (isi.isEmpty) return const [];
    final data = <int>[];
    final int start;
    if (RegExp(r'^\d+$').hasMatch(isi) && isi.length.isEven) {
      start = _startC;
      for (var i = 0; i < isi.length; i += 2) {
        data.add(int.parse(isi.substring(i, i + 2)));
      }
    } else {
      start = _startB;
      for (final c in isi.codeUnits) {
        if (c < 32 || c > 126) return const [];
        data.add(c - 32);
      }
    }
    var jumlah = start;
    for (var i = 0; i < data.length; i++) {
      jumlah += data[i] * (i + 1);
    }
    return [start, ...data, jumlah % 103];
  }

  /// Lebar tiap elemen dalam modul, berurutan dari awal: indeks genap = batang
  /// hitam, ganjil = spasi. Sudah termasuk start, cek, dan stop; zona sunyi
  /// TIDAK termasuk. Kosong bila [isi] tidak bisa disandikan.
  static List<int> lebarModul(String isi) {
    final simbol = nilai(isi);
    if (simbol.isEmpty) return const [];
    final hasil = <int>[];
    for (final s in simbol) {
      hasil.addAll(_pola[s].split('').map(int.parse));
    }
    hasil.addAll(_stop.split('').map(int.parse));
    return hasil;
  }
}
