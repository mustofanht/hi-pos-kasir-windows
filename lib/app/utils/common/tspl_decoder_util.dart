import 'dart:convert';

/// Menerjemahkan perintah TSPL menjadi baris yang bisa dibaca orang, untuk
/// pratinjau saat mode simulasi printer menyala.
///
/// Berbeda dari ESC/POS, TSPL sudah berupa teks — jadi tugas di sini bukan
/// membongkar byte, melainkan menjawab pertanyaan yang sebenarnya: **apa yang
/// akan muncul di gelang, di posisi mana, sebesar apa.** Karena itu koordinat
/// dan ukuran sel QR ikut ditampilkan; itulah yang salah saat cetakan terpotong.
class TsplDecoder {
  /// Apakah aliran byte ini TSPL dan bukan ESC/POS?
  ///
  /// Diperiksa dari dua sisi sekaligus supaya tidak salah tebak: seluruh isinya
  /// harus teks yang bisa dicetak, **dan** memuat perintah yang khas TSPL.
  /// Struk ESC/POS selalu mengandung byte kontrol (0x1B, 0x1D), jadi keduanya
  /// tidak pernah tertukar.
  static bool sepertinyaTspl(List<int> bytes) {
    if (bytes.isEmpty) return false;
    final cuplikan = bytes.take(512);
    for (final b in cuplikan) {
      final teksBiasa = (b >= 0x20 && b <= 0x7E) || b == 0x0A || b == 0x0D;
      if (!teksBiasa) return false;
    }
    final awal = latin1.decode(cuplikan.toList()).toUpperCase();
    return awal.contains('SIZE ') ||
        awal.contains('CLS') ||
        awal.startsWith('PRINT');
  }

  static List<String> decode(List<int> bytes) {
    final hasil = <String>[];
    final baris = latin1
        .decode(bytes, allowInvalid: true)
        .split(RegExp(r'\r\n|\n|\r'))
        .where((b) => b.trim().isNotEmpty);

    for (final b in baris) {
      hasil.add(_terjemahkan(b.trim()));
    }
    return hasil;
  }

  static String ringkasan(List<int> bytes) {
    for (final b in decode(bytes)) {
      // Isi teks dan QR yang paling menjelaskan gelang itu milik siapa.
      if (b.startsWith('[QR') || b.startsWith('[teks')) return b;
    }
    return 'Cetak gelang (TSPL)';
  }

  static String _terjemahkan(String baris) {
    final besar = baris.toUpperCase();

    if (besar.startsWith('SIZE')) {
      return '[media ${_setelah(baris, 'SIZE')}]';
    }
    if (besar.startsWith('GAP')) {
      final v = _setelah(baris, 'GAP');
      return v.startsWith('0 mm') || v.startsWith('0,')
          ? '[media menyambung, tanpa jarak]'
          : '[jarak antar label $v]';
    }
    if (besar.startsWith('DIRECTION')) {
      return '[arah cetak ${_setelah(baris, 'DIRECTION')}]';
    }
    if (besar.startsWith('DENSITY')) {
      return '[kerapatan panas ${_setelah(baris, 'DENSITY')}]';
    }
    if (besar.startsWith('SPEED')) {
      return '[kecepatan ${_setelah(baris, 'SPEED')}]';
    }
    if (besar.startsWith('REFERENCE')) {
      return '[titik acuan ${_setelah(baris, 'REFERENCE')}]';
    }
    if (besar.startsWith('CLS')) {
      return '[lembar baru]';
    }
    if (besar.startsWith('BAR ')) {
      final a = _angka(_setelah(baris, 'BAR'));
      if (a.length >= 4) {
        return '[garis di (${a[0]},${a[1]}) ${a[2]}x${a[3]} titik]';
      }
      return '[garis]';
    }
    if (besar.startsWith('QRCODE')) {
      final isi = _isiKutip(baris);
      final bagian = _setelah(baris, 'QRCODE').split(',');
      if (bagian.length >= 4) {
        final x = bagian[0].trim();
        final y = bagian[1].trim();
        final ecc = bagian[2].trim();
        final sel = bagian[3].trim();
        return '[QR di ($x,$y) sel $sel koreksi $ecc] $isi';
      }
      return '[QR] $isi';
    }
    if (besar.startsWith('TEXT')) {
      final isi = _isiKutip(baris);
      final bagian = _setelah(baris, 'TEXT').split(',');
      if (bagian.length >= 3) {
        final x = bagian[0].trim();
        final y = bagian[1].trim();
        final font = bagian[2].trim().replaceAll('"', '');
        return '[teks di ($x,$y) huruf $font] $isi';
      }
      return '[teks] $isi';
    }
    if (besar.startsWith('PRINT')) {
      final a = _angka(_setelah(baris, 'PRINT'));
      final jumlah = a.isNotEmpty ? a.first : 1;
      return '[cetak $jumlah lembar]';
    }

    // Perintah asing tetap ditampilkan apa adanya. Menyembunyikannya justru
    // menyulitkan saat menelusuri masalah di printer merek lain.
    return '[?] $baris';
  }

  static String _setelah(String baris, String perintah) =>
      baris.substring(perintah.length).trim();

  /// Isi di dalam pasangan kutip ganda **terakhir** — bagian teks/QR-nya.
  ///
  /// Harus yang terakhir, bukan yang pertama: `TEXT 10,20,"3",0,1,1,"290809..."`
  /// punya dua pasang kutip, dan yang pertama itu nama huruf, bukan isinya.
  /// Kutip yang dilindungi garis miring balik dilewati karena ia bagian dari isi.
  static String _isiKutip(String baris) {
    final pasangan = <String>[];
    var mulai = -1;
    for (var i = 0; i < baris.length; i++) {
      if (baris[i] == '\\') {
        i++; // karakter berikutnya dilindungi, apa pun itu
        continue;
      }
      if (baris[i] != '"') continue;
      if (mulai < 0) {
        mulai = i;
      } else {
        pasangan.add(baris.substring(mulai + 1, i));
        mulai = -1;
      }
    }
    if (pasangan.isEmpty) return '';
    return pasangan.last.replaceAll('\\"', '"').replaceAll('\\\\', '\\');
  }

  static List<int> _angka(String s) {
    final tanpaKutip = s.contains('"') ? s.substring(0, s.indexOf('"')) : s;
    return RegExp(r'-?\d+')
        .allMatches(tanpaKutip)
        .map((m) => int.parse(m.group(0)!))
        .toList();
  }
}
