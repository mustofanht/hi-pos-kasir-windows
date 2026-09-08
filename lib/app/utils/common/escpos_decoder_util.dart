import 'dart:convert';

/// Menerjemahkan aliran byte ESC/POS menjadi baris-baris yang bisa dibaca orang.
///
/// Tujuannya bukan meniru printer sungguhan, melainkan menjawab pertanyaan yang
/// benar-benar ditanyakan saat mengembangkan tanpa perangkat: **isi struknya
/// betul tidak, dan tata letaknya betul tidak.** Karena itu perintah kontrol
/// tidak dibuang diam-diam — perataan, tebal, ukuran huruf, potong kertas, dan
/// gambar/QR ditampilkan sebagai penanda `[...]` supaya tetap terlihat.
///
/// Byte yang tidak dikenali dilewati tanpa merusak sisa aliran; struk uji lebih
/// berguna daripada penerjemah yang menyerah di perintah pertama yang asing.
class EscPosDecoder {
  static const int _esc = 0x1B;
  static const int _fs = 0x1C;
  static const int _gs = 0x1D;
  static const int _lf = 0x0A;
  static const int _cr = 0x0D;

  /// Jumlah byte parameter untuk tiap perintah ESC.
  ///
  /// Daftar ini penting bukan karena setiap perintahnya perlu ditampilkan,
  /// melainkan karena panjangnya harus benar: salah hitung satu byte membuat
  /// parameter perintah ikut terbaca sebagai teks struk. `ESC p` misalnya
  /// membawa parameter berupa digit ASCII — kalau panjangnya salah, angka "030"
  /// muncul di tengah struk seolah-olah memang dicetak.
  static const Map<int, int> _escParameter = {
    0x21: 1, // ESC ! mode cetak
    0x24: 2, // ESC $ posisi absolut
    0x2D: 1, // ESC - garis bawah
    0x33: 1, // ESC 3 jarak baris
    0x41: 1, // ESC A jarak baris (unit)
    0x45: 1, // ESC E tebal
    0x47: 1, // ESC G tebal ganda
    0x4A: 1, // ESC J umpan n titik
    0x4D: 1, // ESC M jenis huruf
    0x52: 1, // ESC R set karakter internasional
    0x56: 1, // ESC V putar 90 derajat
    0x5C: 2, // ESC \ posisi relatif
    0x61: 1, // ESC a perataan
    0x64: 1, // ESC d umpan n baris
    0x65: 1, // ESC e umpan mundur n baris
    0x70: 3, // ESC p buka laci kasir
    0x74: 1, // ESC t tabel karakter
    0x7B: 1, // ESC { balik teks
  };

  /// Jumlah byte parameter untuk perintah GS yang panjangnya tetap.
  static const Map<int, int> _gsParameter = {
    0x42: 1, // GS B cetak terbalik hitam-putih
    0x48: 1, // GS H posisi teks barcode
    0x61: 1, // GS a status otomatis
    0x66: 1, // GS f huruf teks barcode
    0x68: 1, // GS h tinggi barcode
    0x72: 1, // GS r kirim status
    0x77: 1, // GS w lebar barcode
  };

  /// Hasil terjemahan: satu entri per baris cetak atau per perintah penting.
  static List<String> decode(List<int> bytes) {
    final hasil = <String>[];
    final baris = <int>[];
    var i = 0;

    void tutupBaris() {
      if (baris.isEmpty) return;
      final teks = _teks(baris);
      baris.clear();
      // Baris yang isinya cuma byte kendali tidak perlu memenuhi pratinjau.
      if (teks.isEmpty) return;
      hasil.add(teks);
    }

    while (i < bytes.length) {
      final b = bytes[i];

      if (b == _lf) {
        tutupBaris();
        // Baris kosong tetap dicatat supaya jarak antar bagian struk terlihat.
        if (hasil.isEmpty || hasil.last.isNotEmpty) {
          hasil.add('');
        }
        i++;
        continue;
      }

      if (b == _cr) {
        i++;
        continue;
      }

      if (b == _esc && i + 1 < bytes.length) {
        final perintah = bytes[i + 1];
        switch (perintah) {
          case 0x40: // ESC @ - inisialisasi
            tutupBaris();
            hasil.add('[reset printer]');
            i += 2;
            continue;
          case 0x61: // ESC a n - perataan
            tutupBaris();
            hasil.add('[rata: ${_rata(_byteAt(bytes, i + 2))}]');
            i += 3;
            continue;
          case 0x45: // ESC E n - tebal
            tutupBaris();
            hasil.add(_byteAt(bytes, i + 2) == 0 ? '[tebal: mati]' : '[tebal: nyala]');
            i += 3;
            continue;
          case 0x21: // ESC ! n - mode cetak
            tutupBaris();
            hasil.add('[mode cetak: ${_byteAt(bytes, i + 2)}]');
            i += 3;
            continue;
          case 0x64: // ESC d n - umpan n baris
            tutupBaris();
            hasil.add('[umpan ${_byteAt(bytes, i + 2)} baris]');
            i += 3;
            continue;
          case 0x2A: // ESC * m nL nH - gambar bit-image
            tutupBaris();
            final nL = _byteAt(bytes, i + 3);
            final nH = _byteAt(bytes, i + 4);
            final lebar = nL + nH * 256;
            hasil.add('[gambar bit-image, lebar $lebar titik]');
            // 1 byte per kolom untuk mode 8-dot, 3 byte untuk 24-dot.
            final perKolom = _byteAt(bytes, i + 2) >= 32 ? 3 : 1;
            i += 5 + lebar * perKolom;
            continue;
          default:
            tutupBaris();
            hasil.add('[ESC 0x${perintah.toRadixString(16)}]');
            i += 2 + (_escParameter[perintah] ?? 0);
            continue;
        }
      }

      // FS dipakai untuk pengaturan karakter multi-byte; isinya tidak menarik
      // untuk pratinjau, tetapi panjangnya tetap harus dilewati dengan benar.
      if (b == _fs && i + 1 < bytes.length) {
        final perintah = bytes[i + 1];
        const tanpaParameter = {0x2E, 0x26, 0x69, 0x70}; // FS . & i p
        i += tanpaParameter.contains(perintah) ? 2 : 3;
        continue;
      }

      if (b == _gs && i + 1 < bytes.length) {
        final perintah = bytes[i + 1];
        switch (perintah) {
          case 0x21: // GS ! n - ukuran huruf
            tutupBaris();
            hasil.add('[ukuran huruf: ${_ukuran(_byteAt(bytes, i + 2))}]');
            i += 3;
            continue;
          case 0x56: // GS V - potong kertas
            tutupBaris();
            hasil.add('[potong kertas]');
            // Bentuk "GS V m" panjangnya 3 byte; bentuk "GS V m n" (m = 65/66,
            // potong setelah umpan n titik) panjangnya 4.
            i += _byteAt(bytes, i + 2) >= 65 ? 4 : 3;
            continue;
          case 0x76: // GS v 0 - cetak raster (QR/logo dicetak lewat jalur ini)
            tutupBaris();
            final xL = _byteAt(bytes, i + 4);
            final xH = _byteAt(bytes, i + 5);
            final yL = _byteAt(bytes, i + 6);
            final yH = _byteAt(bytes, i + 7);
            final lebarByte = xL + xH * 256;
            final tinggi = yL + yH * 256;
            hasil.add('[gambar raster ${lebarByte * 8} x $tinggi titik '
                '— di sini QR / logo dicetak]');
            i += 8 + lebarByte * tinggi;
            continue;
          case 0x28: // GS ( k - termasuk perintah QR bawaan printer
            tutupBaris();
            final pL = _byteAt(bytes, i + 3);
            final pH = _byteAt(bytes, i + 4);
            final panjang = pL + pH * 256;
            hasil.add('[perintah QR/2D bawaan printer, $panjang byte]');
            i += 5 + panjang;
            continue;
          case 0x6B: // GS k - cetak barcode
            tutupBaris();
            hasil.add('[barcode]');
            // Bentuk "GS k m n d1..dn" dipakai saat m >= 65; bentuk lama
            // diakhiri NUL.
            final m = _byteAt(bytes, i + 2);
            if (m >= 65) {
              i += 4 + _byteAt(bytes, i + 3);
            } else {
              var j = i + 3;
              while (j < bytes.length && bytes[j] != 0) {
                j++;
              }
              i = j + 1;
            }
            continue;
          default:
            tutupBaris();
            hasil.add('[GS 0x${perintah.toRadixString(16)}]');
            i += 2 + (_gsParameter[perintah] ?? 0);
            continue;
        }
      }

      baris.add(b);
      i++;
    }

    tutupBaris();
    return hasil;
  }

  /// Ringkasan satu baris untuk daftar hasil cetak.
  static String ringkasan(List<int> bytes) {
    final teks = decode(bytes)
        .where((b) => b.isNotEmpty && !b.startsWith('['))
        .toList();
    if (teks.isEmpty) return '(tanpa teks — kemungkinan hanya gambar/QR)';
    return teks.first.trim();
  }

  static int _byteAt(List<int> bytes, int index) =>
      index < bytes.length ? bytes[index] : 0;

  static String _teks(List<int> bytes) {
    // Jaring pengaman: byte kendali apa pun yang lolos dari penghitungan panjang
    // perintah dibuang di sini. Tanpa ini, satu perintah yang belum dikenali
    // cukup untuk menyisipkan karakter aneh ke tengah struk dan membuat
    // pratinjau tampak rusak padahal cetakannya benar.
    final bersih = bytes.where((b) => b >= 0x20 && b != 0x7F).toList();
    if (bersih.isEmpty) return '';
    try {
      // Struk umumnya CP437/latin-1; latin1 cukup untuk menampilkan isinya.
      return latin1.decode(bersih, allowInvalid: true).trimRight();
    } catch (_) {
      return String.fromCharCodes(bersih).trimRight();
    }
  }

  /// Parameter perataan ditulis berbeda-beda antar pustaka: ada yang memakai
  /// nilai biner 0/1/2, ada yang memakai digit ASCII '0'/'1'/'2'
  /// (esc_pos_utils_plus termasuk yang kedua). Keduanya diterima.
  static String _rata(int n) {
    final nilai = (n >= 0x30 && n <= 0x39) ? n - 0x30 : n;
    switch (nilai) {
      case 0:
        return 'kiri';
      case 1:
        return 'tengah';
      case 2:
        return 'kanan';
      default:
        return 'n=$n';
    }
  }

  static String _ukuran(int n) {
    final lebar = (n >> 4) + 1;
    final tinggi = (n & 0x0F) + 1;
    if (lebar == 1 && tinggi == 1) return 'normal';
    return '${lebar}x lebar, ${tinggi}x tinggi';
  }
}
