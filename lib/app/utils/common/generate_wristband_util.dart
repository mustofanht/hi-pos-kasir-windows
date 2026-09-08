import 'dart:convert';

import 'package:jaya_propertiy/data/models/common/wristband_config_model.dart';

/// Penyusun perintah cetak gelang dalam bahasa **TSPL** (TSC Printer Language),
/// dipakai printer label thermal Xprinter / TSC / Godex / iDPRT.
///
/// Ini bahasa yang berbeda sama sekali dari ESC/POS yang dipakai printer struk:
/// ESC/POS mengalirkan teks baris demi baris dan printer yang mengatur tata
/// letak, sedangkan TSPL menaruh setiap elemen pada koordinat titik di atas satu
/// lembar berukuran tetap, lalu mencetaknya sekaligus. Karena itu generator ini
/// berdiri sendiri, bukan tambahan pada [GeneratePrintUtil].
///
/// Perintahnya teks ASCII biasa, satu baris satu perintah, diakhiri CRLF —
/// artinya hasilnya bisa dibaca mata saat menelusuri masalah, dan itu disengaja.
class GenerateWristbandUtil {
  /// Ukuran huruf bawaan TSPL dalam titik: lebar x tinggi per karakter.
  ///
  /// Font ini bitmap, bukan skalabel — ukurannya tetap dalam **titik**, jadi di
  /// printer 300 dpi hurufnya tampak lebih kecil secara fisik daripada di 203
  /// dpi. Pengali x/y dipakai untuk menebalkan, bukan untuk mengubah bentuk.
  static const Map<String, List<int>> fontDots = {
    '1': [8, 12],
    '2': [12, 20],
    '3': [16, 24],
    '4': [24, 32],
    '5': [32, 48],
  };

  /// Urut dari besar ke kecil — dipakai saat mencari huruf terbesar yang muat.
  static const List<String> _fontMenurun = ['5', '4', '3', '2', '1'];

  /// Perkiraan jumlah modul QR untuk isi sepanjang [panjang] karakter angka,
  /// dengan koreksi galat M. Dipakai hanya untuk menghitung tata letak; printer
  /// tetap menentukan versi QR yang sebenarnya.
  ///
  /// Dilebihkan satu tingkat ketimbang dikurangi: QR yang diberi ruang lebih
  /// hanya menyisakan kertas kosong, sedangkan QR yang kekurangan ruang akan
  /// terpotong dan tidak bisa dipindai sama sekali.
  static int modulQr(int panjang) {
    if (panjang <= 25) return 21; // versi 1
    if (panjang <= 47) return 25; // versi 2
    if (panjang <= 77) return 29; // versi 3
    return 33; // versi 4
  }

  /// Sisi QR termasuk zona sunyi 4 modul di setiap tepi. Tanpa zona ini pemindai
  /// sering gagal mengunci sudut QR, terutama pada cetakan kecil.
  static int _modulTotal(int panjang) => modulQr(panjang) + 8;

  /// Susun satu gelang.
  ///
  /// [qrCode] adalah isi QR — nomor tiket yang dibaca alat pindai gate.
  /// [ticketNo] dicetak sebagai teks supaya operator gate bisa mengetiknya
  /// manual saat gelang basah atau QR-nya tergores; alur Keluar Manual bertumpu
  /// pada nomor ini.
  List<int> dataWristbandPrint({
    required WristbandConfigModel config,
    required String qrCode,
    String? ticketNo,
    String? berlakuSampai,
    bool pendamping = false,
    int salinan = 1,
  }) {
    final perintah = <String>[];

    perintah.add('SIZE ${_mm(config.widthMm)} mm,${_mm(config.heightMm)} mm');
    // GAP 0,0 berarti media menyambung tanpa jeda; printer memotong sesuai SIZE.
    perintah.add('GAP ${_mm(config.gapMm)} mm,0 mm');
    perintah.add('DIRECTION ${config.direction}');
    perintah.add('REFERENCE 0,0');
    perintah.add('DENSITY ${config.density}');
    perintah.add('SPEED ${config.speed}');
    perintah.add('CLS');

    perintah.addAll(_tataLetak(
      config: config,
      qrCode: qrCode,
      ticketNo: ticketNo,
      berlakuSampai: berlakuSampai,
      pendamping: pendamping,
    ));

    perintah.add('PRINT ${salinan < 1 ? 1 : salinan},1');

    return _bytes(perintah);
  }

  /// Cetak uji untuk kalibrasi media di depan printer.
  ///
  /// Sengaja menggambar kotak tepat di batas margin: kalau garisnya terpotong
  /// atau miring, ukuran media pada setelan belum cocok dengan media yang
  /// terpasang — itu yang paling sering salah saat printer pertama dipasang.
  List<int> testPrint(WristbandConfigModel config) {
    final w = config.widthDots;
    final h = config.heightDots;
    final m = config.marginDots;
    final tebal = (config.titikPerMm * 0.3).round().clamp(1, 4);

    final perintah = <String>[
      'SIZE ${_mm(config.widthMm)} mm,${_mm(config.heightMm)} mm',
      'GAP ${_mm(config.gapMm)} mm,0 mm',
      'DIRECTION ${config.direction}',
      'REFERENCE 0,0',
      'DENSITY ${config.density}',
      'SPEED ${config.speed}',
      'CLS',
      // Bingkai batas margin.
      'BAR $m,$m,${w - 2 * m},$tebal',
      'BAR $m,${h - m - tebal},${w - 2 * m},$tebal',
      'BAR $m,$m,$tebal,${h - 2 * m}',
      'BAR ${w - m - tebal},$m,$tebal,${h - 2 * m}',
    ];

    perintah.addAll(_tataLetak(
      config: config,
      qrCode: 'TES-GELANG',
      ticketNo: 'TES GELANG',
      berlakuSampai: '${config.widthMm.toStringAsFixed(0)}x'
          '${config.heightMm.toStringAsFixed(0)}mm ${config.dpi}dpi',
    ));

    perintah.add('PRINT 1,1');

    return _bytes(perintah);
  }

  /// Menata QR dan teks di atas lembar.
  ///
  /// Dua susunan, dipilih otomatis menurut ruang yang tersisa:
  /// - **berdampingan** — QR di kiri, teks di kanan. Dipakai bila kolom teksnya
  ///   masih cukup untuk nomor tiket. Ini bentuk yang diinginkan: QR sebesar
  ///   mungkin, nomor tetap terbaca.
  /// - **bertumpuk** — QR di atas, teks di bawah. Cadangan untuk media sempit
  ///   seperti gulungan gelang 25mm, di mana kolom teks di samping QR tidak
  ///   menyisakan ruang yang berguna.
  ///
  /// Sel QR selalu dibatasi lebar **dan** tinggi lembar sekaligus. Membatasi
  /// satu sisi saja terlihat benar pada label mendatar lalu meleset jauh pada
  /// gelang yang tinggi dan sempit — QR-nya jadi lebih lebar dari medianya dan
  /// tepi kanannya terpotong, yang berarti gelang gagal dipindai di gate.
  List<String> _tataLetak({
    required WristbandConfigModel config,
    required String qrCode,
    String? ticketNo,
    String? berlakuSampai,
    bool pendamping = false,
  }) {
    final w = config.widthDots;
    final h = config.heightDots;
    final m = config.marginDots;

    final isi = _ascii(qrCode);
    final modul = _modulTotal(isi.length);

    // Urutan tampil dan urutan kepentingan sengaja dipisah. Yang tampil paling
    // atas belum tentu yang paling penting: kalau media terlalu kecil, nomor
    // tiket adalah baris terakhir yang boleh hilang — alur Keluar Manual
    // bertumpu padanya saat QR tidak terbaca.
    final baris = <_BarisTeks>[
      if (pendamping) _BarisTeks('PENDAMPING', tampil: 0, penting: 1),
      if (ticketNo != null && ticketNo.trim().isNotEmpty)
        _BarisTeks(_ascii(ticketNo), tampil: 1, penting: 0),
      if (berlakuSampai != null && berlakuSampai.trim().isNotEmpty)
        _BarisTeks(_ascii(berlakuSampai), tampil: 2, penting: 2),
    ]..sort((a, b) => a.penting.compareTo(b.penting));

    final selMaksLebar = ((w - 2 * m) / modul).floor();
    final selMaksTinggi = ((h - 2 * m) / modul).floor();

    // Media terlalu kecil untuk apa pun selain QR. Lebih baik gelang berisi QR
    // saja daripada gelang berisi potongan QR yang tidak bisa dipindai.
    if (selMaksLebar < 1 || selMaksTinggi < 1) {
      return [_qr(m, m, 1, isi)];
    }

    if (baris.isEmpty) {
      final sel = selMaksLebar < selMaksTinggi ? selMaksLebar : selMaksTinggi;
      final sisi = sel * modul;
      return [
        _qr(((w - sisi) / 2).round(), ((h - sisi) / 2).round(), sel, isi)
      ];
    }

    // --- Berdampingan -------------------------------------------------------
    // Kolom teks minimal selebar baris terpanjang pada huruf terkecil.
    final butuh =
        baris.map((b) => b.isi.length).reduce((a, b) => a > b ? a : b) *
            fontDots['1']![0];
    final selSampingLebar = ((w - 3 * m - butuh) / modul).floor();
    final selSamping =
        selSampingLebar < selMaksTinggi ? selSampingLebar : selMaksTinggi;

    if (selSamping >= 2) {
      final sisi = selSamping * modul;
      final qrY = ((h - sisi) / 2).round();
      return [
        _qr(m, qrY < m ? m : qrY, selSamping, isi),
        ..._kolomTeks(
          x: m + sisi + m,
          lebar: w - (m + sisi + m) - m,
          tinggiTersedia: h - 2 * m,
          atasLembar: m,
          teks: baris,
        ),
      ];
    }

    // --- Bertumpuk ----------------------------------------------------------
    // Kurangi baris teks satu per satu (yang paling tidak penting duluan)
    // sampai QR mendapat sel yang masih layak dipindai.
    final tinggiBaris = fontDots['1']![1] + _jarakBaris;
    var dipakai = baris.length;
    var sel = 1;
    while (dipakai >= 0) {
      final ruang = h - 2 * m - dipakai * tinggiBaris;
      final selRuang = (ruang / modul).floor();
      sel = selRuang < selMaksLebar ? selRuang : selMaksLebar;
      if (sel >= 2 || dipakai == 0) break;
      dipakai--;
    }
    if (sel < 1) sel = 1;

    final sisi = sel * modul;
    final atasTeks = m + sisi + 2;

    return [
      _qr(((w - sisi) / 2).round().clamp(0, w), m, sel, isi),
      ..._kolomTeks(
        x: m,
        lebar: w - 2 * m,
        tinggiTersedia: h - m - atasTeks,
        atasLembar: atasTeks,
        teks: baris.take(dipakai).toList(),
        diTengah: true,
      ),
    ];
  }

  static const int _jarakBaris = 4;

  /// Menempatkan baris teks, memilih huruf terbesar yang muat di [lebar].
  ///
  /// Teks yang tetap tidak muat **dipotong**, dan baris yang tidak kebagian
  /// tinggi **dibuang** — keduanya disengaja. TSPL tidak memenggal baris dan
  /// tidak mengeluh: apa pun yang melewati tepi lembar hilang tanpa jejak.
  /// Lebih baik memutuskan sendiri apa yang dikorbankan daripada menyerahkannya
  /// pada tepi kertas.
  List<String> _kolomTeks({
    required int x,
    required int lebar,
    required int tinggiTersedia,
    required int atasLembar,
    required List<_BarisTeks> teks,
    bool diTengah = false,
  }) {
    if (teks.isEmpty || lebar <= 0 || tinggiTersedia <= 0) return const [];

    // Urutkan kembali ke urutan tampil setelah penyaringan menurut kepentingan.
    final urut = [...teks]..sort((a, b) => a.tampil.compareTo(b.tampil));

    final terpilih = <_TeksJadi>[];
    for (var i = 0; i < urut.length; i++) {
      // Baris pertama boleh besar; sisanya dibatasi agar tidak menyaingi dan
      // tetap muat bersama-sama.
      final kandidat = i == 0 ? _fontMenurun : const ['3', '2', '1'];
      var font = kandidat.last;
      for (final f in kandidat) {
        if (urut[i].isi.length * fontDots[f]![0] <= lebar) {
          font = f;
          break;
        }
      }
      terpilih.add(_TeksJadi(_potong(urut[i].isi, lebar, font), font));
    }

    int tinggiTotal(List<_TeksJadi> t) =>
        t.fold<int>(0, (a, b) => a + fontDots[b.font]![1] + _jarakBaris) -
        _jarakBaris;

    // Terlalu tinggi: kecilkan huruf dulu, buang baris hanya bila terpaksa.
    while (terpilih.isNotEmpty && tinggiTotal(terpilih) > tinggiTersedia) {
      final besar = terpilih.indexWhere((t) => t.font != '1');
      if (besar >= 0) {
        terpilih[besar] = _TeksJadi(_potong(terpilih[besar].isi, lebar, '1'), '1');
      } else {
        terpilih.removeLast();
      }
    }
    if (terpilih.isEmpty) return const [];

    var y = atasLembar + ((tinggiTersedia - tinggiTotal(terpilih)) / 2).round();
    if (y < atasLembar) y = atasLembar;

    final hasil = <String>[];
    for (final t in terpilih) {
      final lebarTeks = t.isi.length * fontDots[t.font]![0];
      final xPakai = diTengah ? x + ((lebar - lebarTeks) / 2).round() : x;
      hasil.add('TEXT ${xPakai < 0 ? 0 : xPakai},$y,"${t.font}",0,1,1,'
          '"${_kutip(t.isi)}"');
      y += fontDots[t.font]![1] + _jarakBaris;
    }
    return hasil;
  }

  String _potong(String isi, int lebar, String font) {
    final maks = (lebar / fontDots[font]![0]).floor();
    return maks > 0 && isi.length > maks ? isi.substring(0, maks) : isi;
  }

  /// `QRCODE x,y,ECC,sel,mode,rotasi,"isi"`.
  ///
  /// Koreksi galat **M** (±15%) dipilih dengan sengaja: gelang dipakai di kolam
  /// dan wahana basah, kena gesek dan lipatan, jadi QR-nya harus tetap terbaca
  /// meski sebagian rusak. Tingkat L lebih rapat tapi menyerah lebih cepat.
  String _qr(int x, int y, int sel, String isi) =>
      'QRCODE $x,$y,M,$sel,A,0,"${_kutip(isi)}"';

  /// TSPL menutup isi perintah dengan tanda kutip ganda, jadi kutip dan garis
  /// miring balik di dalam isi harus dilindungi — kalau tidak, perintahnya
  /// terpotong di tengah dan printer menolak seluruh lembar.
  String _kutip(String s) => s.replaceAll('\\', '\\\\').replaceAll('"', '\\"');

  /// TSPL hanya aman dengan ASCII pada halaman kode bawaan. Karakter di luar itu
  /// diganti spasi ketimbang dikirim apa adanya dan keluar sebagai simbol acak.
  String _ascii(String s) => s
      .replaceAll(RegExp(r'[^\x20-\x7E]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  /// Angka milimeter tanpa nol di belakang koma — `50` bukan `50.0`, karena
  /// sebagian firmware TSPL menolak pecahan yang tidak perlu.
  String _mm(double v) {
    final bulat = v.roundToDouble();
    return v == bulat ? bulat.toStringAsFixed(0) : v.toStringAsFixed(1);
  }

  List<int> _bytes(List<String> perintah) =>
      latin1.encode('${perintah.join('\r\n')}\r\n');
}

/// Satu baris teks calon cetak, dengan dua urutan: [tampil] menentukan
/// posisinya di gelang, [penting] menentukan siapa yang dikorbankan lebih dulu
/// saat medianya tidak cukup.
class _BarisTeks {
  final String isi;
  final int tampil;
  final int penting;

  _BarisTeks(this.isi, {required this.tampil, required this.penting});
}

/// Baris yang sudah dipastikan huruf dan panjangnya.
class _TeksJadi {
  final String isi;
  final String font;

  _TeksJadi(this.isi, this.font);
}

GenerateWristbandUtil generateWristbandUtil = GenerateWristbandUtil();
