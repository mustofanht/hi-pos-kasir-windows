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
    final perintah = _kepala(config);

    final atur = _ruangDanGeser(config);
    perintah.addAll(_geser(
      _tataLetak(
        config: atur.ruang,
        qrCode: qrCode,
        ticketNo: ticketNo,
        berlakuSampai: berlakuSampai,
        pendamping: pendamping,
      ),
      config,
      atur.dx,
      atur.dy,
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

    final perintah = _kepala(config)
      ..addAll([
      // Bingkai batas margin.
      'BAR $m,$m,${w - 2 * m},$tebal',
      'BAR $m,${h - m - tebal},${w - 2 * m},$tebal',
      'BAR $m,$m,$tebal,${h - 2 * m}',
      'BAR ${w - m - tebal},$m,$tebal,${h - 2 * m}',
      ]);

    final atur = _ruangDanGeser(config);
    perintah.addAll(_geser(
      _tataLetak(
        config: atur.ruang,
        qrCode: 'TES-GELANG',
        ticketNo: 'TES GELANG',
        berlakuSampai: '${config.widthMm.toStringAsFixed(0)}x'
            '${config.heightMm.toStringAsFixed(0)}mm ${config.dpi}dpi',
      ),
      config,
      atur.dx,
      atur.dy,
    ));

    perintah.add('PRINT 1,1');

    return _bytes(perintah);
  }

  /// Ruang untuk menata isi, beserta geseran yang akan diterapkan setelahnya.
  ///
  /// Isi ditata **di tengah**, jadi ruang kosong yang tersisa terbagi rata ke
  /// kiri dan kanan — dan itu semua yang tersedia untuk digeser. Pada media yang
  /// pas, sisanya hanya beberapa milimeter, sehingga tombol geser terasa tidak
  /// berfungsi.
  ///
  /// Karena itu ruang tata letaknya **dikecilkan dua kali geseran** lebih dulu.
  /// Isi lalu digeser dua kali lipat, dan hasil akhirnya persis: menepi sejauh
  /// yang diminta, tanpa satu pun elemen keluar lembar. Yang dikorbankan adalah
  /// lebar teks — bukan ukuran QR, karena QR dibatasi tinggi lembar dan geseran
  /// tegak biasanya nol.
  ({WristbandConfigModel ruang, int dx, int dy}) _ruangDanGeser(
      WristbandConfigModel c) {
    final dx = c.dots(c.geserXMm);
    final dy = c.dots(c.geserYMm);
    if (dx == 0 && dy == 0) return (ruang: c, dx: 0, dy: 0);

    final lebar = c.widthMm - 2 * c.geserXMm.abs();
    final tinggi = c.heightMm - 2 * c.geserYMm.abs();

    // Geseran yang menelan hampir seluruh media tidak bisa dipenuhi. Pakai
    // lembar penuh dan biarkan [_geser] memangkasnya seadanya — lebih baik
    // bergeser sedikit daripada tidak mencetak apa-apa.
    if (lebar < 10 || tinggi < 10) return (ruang: c, dx: dx, dy: dy);

    return (
      ruang: c.salin(widthMm: lebar, heightMm: tinggi),
      dx: dx + dx.abs(),
      dy: dy + dy.abs(),
    );
  }

  /// Menggeser seluruh gambar, **tanpa membiarkannya keluar lembar**.
  ///
  /// Geseran diminta operator untuk menjauhkan cetakan dari perekat gelang.
  /// Tapi geseran yang membuat QR menyentuh tepi lebih buruk daripada cetakan
  /// yang terlalu dekat perekat: TSPL memotong apa pun yang melewati tepi tanpa
  /// mengeluh, dan yang hilang biasanya sudut QR. Pemangkasan di sini jaring
  /// pengaman terakhir; yang seharusnya membuat geserannya muat adalah
  /// [_ruangDanGeser].
  ///
  /// Bekerja di atas perintah yang sudah jadi supaya kedua susunan
  /// (berdampingan dan bertumpuk) memakai jalur yang sama persis — aturan batas
  /// yang ditulis dua kali adalah aturan yang suatu saat berbeda.
  List<String> _geser(
      List<String> gambar, WristbandConfigModel config, int dxMinta, int dyMinta) {
    if (dxMinta == 0 && dyMinta == 0) return gambar;

    final kotak = gambar.map(_kotakDari).whereType<_Kotak>().toList();
    if (kotak.isEmpty) return gambar;

    int kecil(Iterable<int> v) => v.reduce((a, b) => a < b ? a : b);
    int besar(Iterable<int> v) => v.reduce((a, b) => a > b ? a : b);

    final kiri = kecil(kotak.map((k) => k.x));
    final kanan = besar(kotak.map((k) => k.x + k.w));
    final atas = kecil(kotak.map((k) => k.y));
    final bawah = besar(kotak.map((k) => k.y + k.h));

    final dx = dxMinta.clamp(-kiri, config.widthDots - kanan);
    final dy = dyMinta.clamp(-atas, config.heightDots - bawah);
    if (dx == 0 && dy == 0) return gambar;

    return gambar.map((b) => _pindah(b, dx, dy)).toList();
  }

  /// Kotak yang ditempati satu perintah gambar, atau null bila bukan gambar.
  _Kotak? _kotakDari(String baris) {
    if (baris.startsWith('QRCODE')) {
      final bagian = baris.substring(6).split(',');
      final sel = int.parse(bagian[3].trim());
      final isi = _isiTerakhir(baris);
      final sisi = modulQr(isi.length) * sel;
      return _Kotak(
          int.parse(bagian[0].trim()), int.parse(bagian[1].trim()), sisi, sisi);
    }
    if (baris.startsWith('TEXT')) {
      final bagian = baris.substring(4).split(',');
      final font = bagian[2].trim().replaceAll('"', '');
      final ukuran = fontDots[font];
      if (ukuran == null) return null;
      final isi = _isiTerakhir(baris);
      return _Kotak(int.parse(bagian[0].trim()), int.parse(bagian[1].trim()),
          isi.length * ukuran[0], ukuran[1]);
    }
    return null;
  }

  String _pindah(String baris, int dx, int dy) {
    final nama = baris.startsWith('QRCODE')
        ? 'QRCODE'
        : baris.startsWith('TEXT')
            ? 'TEXT'
            : null;
    if (nama == null) return baris;
    final sisa = baris.substring(nama.length).trimLeft();
    final koma1 = sisa.indexOf(',');
    final koma2 = sisa.indexOf(',', koma1 + 1);
    final x = int.parse(sisa.substring(0, koma1).trim()) + dx;
    final y = int.parse(sisa.substring(koma1 + 1, koma2).trim()) + dy;
    return '$nama $x,$y${sisa.substring(koma2)}';
  }

  /// Isi di dalam pasangan kutip terakhir — sama seperti yang ditulis [_kutip].
  String _isiTerakhir(String baris) {
    final akhir = baris.lastIndexOf('"');
    if (akhir <= 0) return '';
    final awal = baris.lastIndexOf('"', akhir - 1);
    if (awal < 0) return '';
    return baris.substring(awal + 1, akhir);
  }

  /// Perintah pembuka satu lembar: ukuran media, kerapatan, dan cara memisahkan.
  ///
  /// Disatukan supaya cetak biasa dan cetak uji tidak bisa berbeda setelan —
  /// cetak uji yang tidak mewakili cetak sungguhan adalah cetak uji yang
  /// menyesatkan.
  List<String> _kepala(WristbandConfigModel config) {
    return <String>[
      'SIZE ${_mm(config.widthMm)} mm,${_mm(config.heightMm)} mm',
      // GAP 0 berarti media menyambung tanpa jeda; printer memotong sesuai SIZE.
      'GAP ${_mm(config.gapMm)} mm,0 mm',
      'DIRECTION ${config.direction}',
      'REFERENCE 0,0',
      'DENSITY ${config.density}',
      'SPEED ${config.speed}',
      ..._pemisah(config.potong),
      'CLS',
    ];
  }

  /// Cara media dipisahkan.
  ///
  /// Ini yang tidak ada di ESC/POS: di sana `cut()` menyatu dengan alur cetak,
  /// sedangkan TSPL harus diberi tahu lebih dulu apakah pemotongnya dipakai.
  /// Tanpa perintah ini printer mencetak lalu berhenti di situ — gelang
  /// terakhir tertinggal setengah di dalam dan tidak bisa disobek rapi.
  ///
  /// `SET TEAR ON` dipakai saat tidak ada pemotong: media dimajukan ke bilah
  /// sobek. Aman dikirim ke printer yang punya pemotong sekalipun.
  List<String> _pemisah(ModePotong mode) {
    switch (mode) {
      case ModePotong.tiapGelang:
        return const ['SET TEAR OFF', 'SET CUTTER 1'];
      case ModePotong.akhirBatch:
        return const ['SET TEAR OFF', 'SET CUTTER BATCH'];
      case ModePotong.sobek:
        return const ['SET CUTTER OFF', 'SET TEAR ON'];
    }
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
  /// Yang digambar **dipusatkan sebagai satu kesatuan**, bukan ditempelkan ke
  /// margin. Menempel ke margin membuat cetakan terlihat terdorong ke satu tepi
  /// padahal separuh medianya kosong — dan pada gelang yang dipakai di
  /// pergelangan tangan, itu terlihat jelas.
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
      final teks = _pilihTeks(
        baris,
        lebarMaks: w - 3 * m - sisi,
        tinggiMaks: h - 2 * m,
      );
      if (teks.isNotEmpty) {
        final lebarTeks = _lebarBlok(teks);
        final tinggiTeks = _tinggiBlok(teks);
        // Komposisi = QR + jarak + teks, dipusatkan mendatar sebagai satu blok.
        final komposisi = sisi + m + lebarTeks;
        final xQr = ((w - komposisi) / 2).round().clamp(0, w - komposisi);

        return [
          _qr(xQr, ((h - sisi) / 2).round().clamp(0, h - sisi), selSamping, isi),
          ..._tulis(
            teks,
            x: xQr + sisi + m,
            y: ((h - tinggiTeks) / 2).round().clamp(0, h - tinggiTeks),
            lebarBlok: lebarTeks,
          ),
        ];
      }
    }

    // --- Bertumpuk ----------------------------------------------------------
    // Kurangi baris teks satu per satu (yang paling tidak penting duluan)
    // sampai QR mendapat sel yang masih layak dipindai.
    var dipakai = baris.length;
    var sel = 1;
    var teks = <_TeksJadi>[];
    while (dipakai >= 0) {
      teks = dipakai == 0
          ? <_TeksJadi>[]
          : _pilihTeks(
              baris.take(dipakai).toList(),
              lebarMaks: w - 2 * m,
              tinggiMaks: h - 2 * m,
            );
      final ruang = h - 2 * m - _tinggiBlok(teks) - (teks.isEmpty ? 0 : m);
      final selRuang = (ruang / modul).floor();
      sel = selRuang < selMaksLebar ? selRuang : selMaksLebar;
      if (sel >= 2 || dipakai == 0) break;
      dipakai--;
    }
    if (sel < 1) sel = 1;

    final sisi = sel * modul;
    final tinggiTeks = _tinggiBlok(teks);
    // Seluruh susunan (QR + jarak + teks) dipusatkan tegak, bukan menempel atas.
    final tinggiSusun = sisi + (teks.isEmpty ? 0 : m + tinggiTeks);
    final yAtas = ((h - tinggiSusun) / 2).round().clamp(0, h - tinggiSusun);

    return [
      _qr(((w - sisi) / 2).round().clamp(0, w), yAtas, sel, isi),
      if (teks.isNotEmpty)
        ..._tulis(
          teks,
          x: m,
          y: yAtas + sisi + m,
          lebarBlok: w - 2 * m,
          diTengah: true,
        ),
    ];
  }

  /// Jarak bawah satu baris, sepertiga tinggi hurufnya.
  ///
  /// Dulu tetap 4 titik untuk semua ukuran, dan itu terlalu rapat: pada huruf
  /// besar baris-barisnya nyaris bersinggungan, dan bila ukuran huruf yang
  /// sebenarnya dicetak printer lebih besar dari tabel di sini, barisnya
  /// benar-benar saling menimpa sampai nomor tiketnya tidak terbaca.
  static int _jarak(String font) {
    final j = fontDots[font]![1] ~/ 3;
    return j < 6 ? 6 : j;
  }

  int _tinggiBlok(List<_TeksJadi> teks) {
    if (teks.isEmpty) return 0;
    var total = 0;
    for (var i = 0; i < teks.length; i++) {
      total += fontDots[teks[i].font]![1];
      if (i < teks.length - 1) total += _jarak(teks[i].font);
    }
    return total;
  }

  int _lebarBlok(List<_TeksJadi> teks) => teks.isEmpty
      ? 0
      : teks
          .map((t) => t.isi.length * fontDots[t.font]![0])
          .reduce((a, b) => a > b ? a : b);

  /// Memilih huruf terbesar yang muat untuk tiap baris, lalu memastikan
  /// seluruhnya muat tinggi.
  ///
  /// Teks yang tetap tidak muat **dipotong**, dan baris yang tidak kebagian
  /// tinggi **dibuang** — keduanya disengaja. TSPL tidak memenggal baris dan
  /// tidak mengeluh: apa pun yang melewati tepi lembar hilang tanpa jejak.
  /// Lebih baik memutuskan sendiri apa yang dikorbankan daripada menyerahkannya
  /// pada tepi kertas.
  List<_TeksJadi> _pilihTeks(
    List<_BarisTeks> baris, {
    required int lebarMaks,
    required int tinggiMaks,
  }) {
    if (baris.isEmpty || lebarMaks <= 0 || tinggiMaks <= 0) return const [];

    // Urutkan kembali ke urutan tampil setelah penyaringan menurut kepentingan.
    final urut = [...baris]..sort((a, b) => a.tampil.compareTo(b.tampil));

    final terpilih = <_TeksJadi>[];
    for (var i = 0; i < urut.length; i++) {
      // Semua baris boleh memakai huruf terbesar yang muat lebarnya; yang
      // menyaring berikutnya adalah tinggi, di bawah. Membatasi baris kedua dan
      // seterusnya ke huruf kecil sejak awal membuat cetakan mengecil tanpa
      // alasan pada media yang sebenarnya lapang.
      var font = _fontMenurun.last;
      for (final f in _fontMenurun) {
        if (urut[i].isi.length * fontDots[f]![0] <= lebarMaks) {
          font = f;
          break;
        }
      }
      terpilih.add(_TeksJadi(_potong(urut[i].isi, lebarMaks, font), font));
    }

    // Terlalu tinggi: kecilkan huruf terbesar dulu, buang baris hanya bila
    // sudah tidak ada yang bisa dikecilkan lagi.
    while (terpilih.isNotEmpty && _tinggiBlok(terpilih) > tinggiMaks) {
      var besar = -1;
      for (var i = 0; i < terpilih.length; i++) {
        if (terpilih[i].font == '1') continue;
        if (besar < 0 ||
            fontDots[terpilih[i].font]![1] > fontDots[terpilih[besar].font]![1]) {
          besar = i;
        }
      }
      if (besar < 0) {
        terpilih.removeLast();
        continue;
      }
      final turun =
          _fontMenurun[_fontMenurun.indexOf(terpilih[besar].font) + 1];
      terpilih[besar] =
          _TeksJadi(_potong(terpilih[besar].isi, lebarMaks, turun), turun);
    }
    return terpilih;
  }

  /// Menuliskan baris yang sudah dipastikan huruf dan panjangnya.
  List<String> _tulis(
    List<_TeksJadi> teks, {
    required int x,
    required int y,
    required int lebarBlok,
    bool diTengah = false,
  }) {
    final hasil = <String>[];
    var baris = y;
    for (var i = 0; i < teks.length; i++) {
      final t = teks[i];
      final lebarTeks = t.isi.length * fontDots[t.font]![0];
      final xPakai = diTengah ? x + ((lebarBlok - lebarTeks) / 2).round() : x;
      hasil.add('TEXT ${xPakai < 0 ? 0 : xPakai},$baris,"${t.font}",0,1,1,'
          '"${_kutip(t.isi)}"');
      baris += fontDots[t.font]![1] + _jarak(t.font);
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

/// Kotak yang ditempati satu elemen di atas lembar, dalam titik.
class _Kotak {
  final int x;
  final int y;
  final int w;
  final int h;

  _Kotak(this.x, this.y, this.w, this.h);
}

/// Baris yang sudah dipastikan huruf dan panjangnya.
class _TeksJadi {
  final String isi;
  final String font;

  _TeksJadi(this.isi, this.font);
}

GenerateWristbandUtil generateWristbandUtil = GenerateWristbandUtil();
