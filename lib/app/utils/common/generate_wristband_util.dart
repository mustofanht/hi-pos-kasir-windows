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

  /// Zona sunyi yang **dipesan di tata letak**, dalam modul, per tepi.
  ///
  /// Standar QR meminta 4 modul. Di sini dipesan 2, dan sisanya diserahkan pada
  /// medianya sendiri: gelang 25mm yang polos di kiri-kanan QR sudah menyediakan
  /// beberapa milimeter putih sungguhan di tiap tepi, dan memesan ruang untuk
  /// putih yang sudah ada berarti membayarnya dua kali — dengan QR yang mengecil.
  ///
  /// Bedanya tidak kecil. Pada pita 25mm, 4 modul menahan QR di 15,8mm; 2 modul
  /// melepaskannya ke 18,4mm. Pada gelang bermerek yang hanya menyisakan 20mm
  /// bersih, selisih itu menentukan QR terbaca sekali pindai atau tidak.
  static const int _zonaSunyi = 2;

  /// Sisi kotak yang dipesan satu QR: simbolnya sendiri ditambah zona sunyi di
  /// kedua tepi. Lihat [_zonaSunyi].
  static int _modulTotal(int panjang) => modulQr(panjang) + 2 * _zonaSunyi;

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
    int salinan = 1,
  }) {
    final perintah = _kepala(config);

    perintah.addAll(_susun(
      config,
      (ruang) => _tataLetak(
        config: ruang,
        qrCode: qrCode,
        ticketNo: ticketNo,
        berlakuSampai: berlakuSampai,
      ),
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
    final lebarHuruf = fontDots['2']![0];
    final tinggiHuruf = fontDots['2']![1];

    // Empat penanda sudut, bukan bingkai garis.
    //
    // Bingkai lama digambar dengan `BAR`, dan tidak satu pun cetakan ber-BAR
    // pernah keluar dari printer di lapangan — sementara `TEXT` dan `QRCODE`
    // selalu keluar. Penanda sudut menjawab pertanyaan yang sama: bila keempat
    // huruf muncul utuh, ukuran media pada setelan cocok dengan media yang
    // terpasang; bila ada yang hilang, tidak cocok.
    final kiri = m < 1 ? 1 : m;
    final atas = m < 1 ? 1 : m;
    final kanan = w - kiri - 2 * lebarHuruf;
    final bawah = h - atas - tinggiHuruf;

    final perintah = _kepala(config)
      ..addAll([
        'TEXT $kiri,$atas,"2",0,1,1,"TL"',
        if (kanan > kiri + 2 * lebarHuruf) 'TEXT $kanan,$atas,"2",0,1,1,"TR"',
        if (bawah > atas + tinggiHuruf) 'TEXT $kiri,$bawah,"2",0,1,1,"BL"',
        if (kanan > kiri + 2 * lebarHuruf && bawah > atas + tinggiHuruf)
          'TEXT $kanan,$bawah,"2",0,1,1,"BR"',
      ]);

    perintah.addAll(_susun(
      config,
      (ruang) => _tataLetak(
        config: ruang.salin(
          // Ruang untuk penanda sudut, supaya isi contoh tidak menimpanya.
          marginMm: ruang.marginMm + 4,
        ),
        qrCode: 'TES-GELANG',
        ticketNo: 'TES',
        berlakuSampai: '${config.widthMm.toStringAsFixed(0)}x'
            '${config.heightMm.toStringAsFixed(0)}',
      ),
    ));

    perintah.add('PRINT 1,1');
    return _bytes(perintah);
  }

  /// Cetak penggaris: dua sumbu bernomor untuk **mengukur medianya sendiri**.
  ///
  /// Dibuat setelah beberapa gelang terbuang karena menebak arah sumbu dari
  /// foto. Media gelang tidak memberi tahu ukurannya, dan TSPL tidak mengeluh
  /// saat mencetak di luar media — cetakan hanya hilang. Jadi alih-alih menebak,
  /// cetak penggaris ini sekali dan **baca angka terakhir yang masih terlihat**
  /// di tiap sumbu.
  ///
  /// Memakai **ukuran media dari setelan**; hanya margin dan geserannya yang
  /// dinolkan supaya sumbunya mulai dekat sudut cetak. Versi pertama memaksa
  /// 60 x 60 mm dengan alasan "setelan yang sedang diuji tidak boleh menentukan
  /// hasilnya". Itu keliru: printer melaporkan berhasil lalu tidak mengeluarkan
  /// apa pun, karena ukuran lembar yang dimintanya tidak cocok dengan media yang
  /// terpasang. Penggaris yang tidak keluar tidak mengukur apa-apa.
  List<int> rulerPrint(WristbandConfigModel config) {
    final ukur = config.salin(marginMm: 0, geserXMm: 0, geserYMm: 0);
    final w = ukur.widthDots;
    final h = ukur.heightDots;
    final lebarHuruf = fontDots['2']![0];
    final tinggiHuruf = fontDots['2']![1];

    // Tidak ada satu pun elemen di koordinat 0.
    //
    // Cetakan tiket yang selalu berhasil tidak pernah menggambar di 0 — elemen
    // terdekatnya di 13 titik. Cetak uji dan penggaris, yang belum pernah
    // keluar, keduanya mulai tepat di 0. Sebagian firmware TSPL menolak seluruh
    // lembar bila ada elemen di tepi mutlak, tanpa mengeluh. Satu milimeter
    // masuk ke dalam tidak mengubah gunanya sebagai penggaris, dan menghapus
    // satu perbedaan yang belum terjelaskan.
    final asal = ukur.dots(1);

    final perintah = _kepala(ukur);

    // Hanya TEXT, tanpa satu pun BAR — juga disengaja. Setiap cetakan ber-BAR
    // belum pernah keluar dari printer ini, sementara QRCODE dan TEXT selalu
    // keluar. Alat ukur harus memakai perintah yang sudah terbukti dimengerti.
    perintah.add('TEXT $asal,$asal,"2",0,1,1,"0"');

    for (var mm = 20; mm <= ukur.widthMm.toInt(); mm += 20) {
      final x = ukur.dots(mm.toDouble());
      if (x + 3 * lebarHuruf > w) break;
      perintah.add('TEXT $x,$asal,"2",0,1,1,"L$mm"');
    }

    for (var mm = 20; mm <= ukur.heightMm.toInt(); mm += 20) {
      final y = ukur.dots(mm.toDouble());
      if (y + tinggiHuruf > h) break;
      perintah.add('TEXT $asal,$y,"2",0,1,1,"T$mm"');
    }

    // Uji putaran: dua teks kembar berdampingan, satu tegak satu diputar.
    // Printer TSPL tidak melaporkan apakah ia mendukung teks berputar; hanya
    // hasil cetak berdampingan yang bisa menjawabnya.
    final yUji = asal + tinggiHuruf + 8;
    if (yUji + 3 * fontDots['3']![0] <= h && w > 6 * fontDots['3']![0]) {
      perintah.add('TEXT ${asal + 4 * lebarHuruf},$yUji,"3",0,1,1,"R0"');
      perintah.add('TEXT ${w - asal},$yUji,"3",90,1,1,"R90"');
    }

    perintah.add('PRINT 1,1');
    return _bytes(perintah);
  }

  /// Menjalankan penata isi pada ruang yang benar, lalu memutar dan menggesernya.
  ///
  /// Satu pintu untuk cetak biasa dan cetak uji, supaya keduanya tidak bisa
  /// berbeda perlakuan.
  ///
  /// Saat [WristbandConfigModel.putarIsi] menyala, isi ditata pada lembar yang
  /// **ditukar sisinya** (panjang gelang menjadi lebar tata letak), lalu diputar
  /// 90 derajat ke posisi sebenarnya. Menata langsung dalam koordinat berputar
  /// akan menggandakan seluruh aturan batas dan penengahan; menukar sisinya
  /// lebih dulu membuat semua itu dipakai ulang apa adanya.
  List<String> _susun(
    WristbandConfigModel config,
    List<String> Function(WristbandConfigModel ruang) tata,
  ) {
    if (!config.putarIsi) {
      final atur = _ruangDanGeser(config);
      return _geser(tata(atur.ruang), config, atur.dx, atur.dy);
    }

    // Ditata tanpa geseran; geseran diterapkan setelah diputar, dalam koordinat
    // sebenarnya — supaya arti X dan Y tetap sama bagi operator: X melintang
    // pita, Y menyusuri gelang, apa pun keadaan saklar putarnya.
    final tertukar = config.salin(
      widthMm: config.heightMm,
      heightMm: config.widthMm,
      geserXMm: 0,
      geserYMm: 0,
    );
    return _geser(
      _putar(tata(tertukar), config),
      config,
      config.dots(config.geserXMm),
      config.dots(config.geserYMm),
    );
  }

  /// Memutar gambar 90 derajat searah jarum jam, dari lembar tertukar ke lembar
  /// sebenarnya.
  ///
  /// Elemen yang menempati kotak (u, v, lebar, tinggi) pada lembar tertukar
  /// pindah ke kotak (Lnyata - v - tinggi, u, tinggi, lebar). Karena tinggi
  /// lembar tertukar sama dengan lebar lembar sebenarnya, hasilnya selalu jatuh
  /// di dalam — tanpa perlu pemangkasan tambahan.
  ///
  /// Jangkar teks berputar berbeda antar firmware TSPL: sebagian menaruhnya di
  /// sudut kiri-atas hasil putaran, sebagian di sudut yang sama seperti sebelum
  /// diputar. Yang dipakai di sini yang kedua — jangkarnya ikut berputar, jadi
  /// berada di sisi kanan kotak hasilnya. **Kalau di printer sungguhan teksnya
  /// bergeser tepat setinggi satu huruf, di sinilah tempat membetulkannya.**
  List<String> _putar(List<String> gambar, WristbandConfigModel nyata) {
    final lebar = nyata.widthDots;

    return gambar.map((baris) {
      final kotak = _kotakDari(baris);
      if (kotak == null) return baris;

      final x = lebar - kotak.y - kotak.h;
      final y = kotak.x;
      final isi = _kutip(_isiTerakhir(baris));

      if (baris.startsWith('QRCODE')) {
        final bagian = baris.substring(6).split(',');
        // QR persegi; jangkarnya tetap sudut kiri-atas.
        return 'QRCODE ${x < 0 ? 0 : x},$y,${bagian[2].trim()},'
            '${bagian[3].trim()},${bagian[4].trim()},90,"$isi"';
      }

      final bagian = baris.substring(4).split(',');
      final font = bagian[2].trim();
      final xMul = bagian[4].trim();
      final yMul = bagian[5].trim();
      return 'TEXT ${x + kotak.h},$y,$font,90,$xMul,$yMul,"$isi"';
    }).toList();
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
  ///
  /// Ikut memperhitungkan putaran: teks berputar 90 derajat menempati kotak yang
  /// sisi-sisinya tertukar, dan jangkarnya berada di tepi kanan kotak itu, bukan
  /// tepi kiri. Tanpa ini, pemangkasan geseran menghitung kotak yang salah dan
  /// justru membiarkan cetakan keluar lembar.
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
      final x = int.parse(bagian[0].trim());
      final y = int.parse(bagian[1].trim());
      final lebarTeks = isi.length * ukuran[0];
      final tinggiTeks = ukuran[1];
      final putaran = int.tryParse(bagian[3].trim()) ?? 0;
      if (putaran == 90 || putaran == 270) {
        return _Kotak(x - tinggiTeks, y, tinggiTeks, lebarTeks);
      }
      return _Kotak(x, y, lebarTeks, tinggiTeks);
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
      ..._sensorMedia(config),
      'DIRECTION ${config.direction}',
      'REFERENCE 0,0',
      'DENSITY ${config.density}',
      'SPEED ${config.speed}',
      ..._pemisah(config.potong),
      // Hanya dikirim bila dipakai. Perintah asing bisa membuat sebagian
      // firmware menolak seluruh lembar tanpa mengeluh, dan tidak ada alasan
      // menanggung risiko itu pada printer yang tidak membutuhkannya.
      if (config.shiftMm != 0) 'SHIFT ${config.dots(config.shiftMm)}',
      'CLS',
    ];
  }

  /// Cara batas antar gelang dikenali printer.
  ///
  /// `GAP` dan `BLINE` adalah dua perintah yang **saling menggantikan**, bukan
  /// dua setelan yang bisa hidup bersama: yang terakhir dikirim menentukan
  /// sensor mana yang dipakai. Mengirim keduanya membuat perilakunya bergantung
  /// urutan, dan itu jenis kesalahan yang baru terlihat berbulan-bulan kemudian
  /// saat gulungan mereknya berganti.
  ///
  /// Mode menyambung sengaja mengirim `GAP 0 mm,0 mm` secara eksplisit, bukan
  /// tidak mengirim apa-apa. Printer menyimpan setelan sensor terakhirnya di
  /// memori — termasuk dari kalibrasi tombol FEED — jadi diam berarti mewarisi
  /// keadaan yang tidak diketahui, dan gelang pertama tiap pagi bisa keluar
  /// berbeda dari yang kemarin.
  List<String> _sensorMedia(WristbandConfigModel config) {
    switch (config.sensor) {
      case SensorMedia.menerus:
        return const ['GAP 0 mm,0 mm'];
      case SensorMedia.celah:
        return ['GAP ${_mm(config.gapMm)} mm,0 mm'];
      case SensorMedia.tandaHitam:
        return ['BLINE ${_mm(config.gapMm)} mm,0 mm'];
    }
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
      case ModePotong.tanpaMaju:
        return const ['SET CUTTER OFF', 'SET TEAR OFF'];
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
      if (ticketNo != null && ticketNo.trim().isNotEmpty)
        _BarisTeks(_ascii(ticketNo), tampil: 1, penting: 0),
      if (berlakuSampai != null && berlakuSampai.trim().isNotEmpty)
        _BarisTeks(_ascii(berlakuSampai), tampil: 2, penting: 2),
    ]..sort((a, b) => a.penting.compareTo(b.penting));

    // Batas atas dari operator, bila ada. Dihitung terhadap modul yang
    // benar-benar tercetak (tanpa zona sunyi), karena itu yang diukur orang
    // dengan penggaris di atas gelang.
    final selMaksPermintaan = config.qrMaksMm <= 0
        ? 9999
        : (config.dots(config.qrMaksMm) / modulQr(isi.length)).floor();

    final selMaksLebar =
        _kecil(((w - 2 * m) / modul).floor(), selMaksPermintaan);
    final selMaksTinggi =
        _kecil(((h - 2 * m) / modul).floor(), selMaksPermintaan);

    // Media terlalu kecil untuk apa pun selain QR. Lebih baik gelang berisi QR
    // saja daripada gelang berisi potongan QR yang tidak bisa dipindai.
    if (selMaksLebar < 1 || selMaksTinggi < 1) {
      return [_qr(m, m, 1, isi)];
    }

    if (baris.isEmpty) {
      final sel = selMaksLebar < selMaksTinggi ? selMaksLebar : selMaksTinggi;
      final sisi = sel * modul;
      // Perataan berlaku di sini juga, bukan cuma saat ada teks. Dulu cabang ini
      // selalu memusatkan, dan itu tidak terasa selama gelang selalu punya
      // nomor di bawahnya. Begitu nomornya dimatikan demi QR yang lebih besar,
      // QR yang dipusatkan justru bergeser turun sampai ekornya menimpa cetakan
      // pabrik — persis yang dihindari dengan memilih "rapat ke atas".
      return [
        _qr(
          ((w - sisi) / 2).round().clamp(0, w),
          _mulaiY(h, sisi, m, config.posisi).clamp(0, h - sisi),
          sel,
          isi,
        )
      ];
    }

    // --- Berdampingan -------------------------------------------------------
    // Kolom teks minimal selebar baris terpanjang pada huruf terkecil.
    final butuh =
        baris.map((b) => b.isi.length).reduce((a, b) => a > b ? a : b) *
            fontDots['1']![0];
    final selSampingLebar =
        _kecil(((w - 3 * m - butuh) / modul).floor(), selMaksPermintaan);
    final selSamping =
        selSampingLebar < selMaksTinggi ? selSampingLebar : selMaksTinggi;

    // Berapa besar QR kalau susunannya bertumpuk? Dihitung lebih dulu, bukan
    // dipakai sebagai cadangan, karena pada media sempit bertumpuk sering
    // memberi QR **berkali-kali lebih besar** — susunan berdampingan memotong
    // lebar QR demi kolom teks di sampingnya.
    //
    // Dulu berdampingan selalu menang asal selnya >= 2. Akibatnya nyata:
    // memendekkan satu baris teks membuat kolom sampingnya muat, susunan
    // berpindah ke berdampingan, dan QR jatuh dari 15,8mm ke 5,2mm — mengecil
    // justru karena teksnya diperbaiki.
    final selTumpuk =
        _selBertumpuk(baris, w, h, m, modul, selMaksPermintaan).sel;

    if (selSamping >= 2 && selSamping >= selTumpuk) {
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
          _qr(
              xQr,
              _mulaiY(h, sisi, m, config.posisi).clamp(0, h - sisi),
              selSamping,
              isi),
          ..._tulis(
            teks,
            x: xQr + sisi + m,
            y: _mulaiY(h, tinggiTeks, m, config.posisi)
                .clamp(0, h - tinggiTeks),
            lebarBlok: lebarTeks,
          ),
        ];
      }
    }

    // --- Bertumpuk ----------------------------------------------------------
    final tumpuk = _selBertumpuk(baris, w, h, m, modul, selMaksPermintaan);
    final sel = tumpuk.sel;
    final teks = tumpuk.teks;

    final sisi = sel * modul;
    final tinggiTeks = _tinggiBlok(teks);
    // Seluruh susunan (QR + jarak + teks) dipusatkan tegak, bukan menempel atas.
    final tinggiSusun = sisi + (teks.isEmpty ? 0 : m + tinggiTeks);
    final yAtas =
        _mulaiY(h, tinggiSusun, m, config.posisi).clamp(0, h - tinggiSusun);

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

  /// Sel QR terbesar yang mungkin pada susunan bertumpuk, beserta baris teks
  /// yang masih terbawa.
  ///
  /// Baris dikurangi satu per satu — yang paling tidak penting duluan — sampai
  /// QR mendapat sel yang masih layak dipindai. Dipisah menjadi fungsi sendiri
  /// supaya hasilnya bisa **dibandingkan** dengan susunan berdampingan sebelum
  /// salah satunya dipilih, bukan sekadar dipakai kalau yang lain gagal.
  ({int sel, List<_TeksJadi> teks}) _selBertumpuk(List<_BarisTeks> baris, int w,
      int h, int m, int modul, int selMaksPermintaan) {
    final selMaksLebar =
        _kecil(((w - 2 * m) / modul).floor(), selMaksPermintaan);
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
    return (sel: sel < 1 ? 1 : sel, teks: teks);
  }

  static int _kecil(int a, int b) => a < b ? a : b;

  /// Titik awal isi searah tinggi lembar, menurut perataan yang dipilih.
  ///
  /// Perataan berbeda dari geseran: ia tidak mengubah ukuran ruang tata letak,
  /// hanya memilih ujung mana yang dipakai. Karena itu merapatkan isi ke atas
  /// tidak mengecilkan QR sedikit pun, sementara menggeser sejauh yang sama
  /// selalu mengecilkannya.
  static int _mulaiY(int h, int tinggiIsi, int m, PosisiIsi posisi) {
    switch (posisi) {
      case PosisiIsi.atas:
        return m;
      case PosisiIsi.bawah:
        return h - m - tinggiIsi;
      case PosisiIsi.tengah:
        return ((h - tinggiIsi) / 2).round();
    }
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
  /// [x] dan [y] adalah pojok **kotak** yang dipesan tata letak, bukan pojok
  /// simbolnya. Zona sunyinya dibagi rata ke empat tepi di sini.
  ///
  /// Dulu simbol digambar tepat di pojok kotak, sehingga seluruh zona sunyi
  /// menumpuk di sisi kanan dan bawah saja. Akibatnya QR yang "dipusatkan"
  /// tata letak justru tercetak melenceng ke kiri-atas beberapa milimeter —
  /// terlihat jelas pada pita 25mm, dan sempat dikira salah setelan margin.
  String _qr(int x, int y, int sel, String isi) {
    final sunyi = _zonaSunyi * sel;
    return 'QRCODE ${x + sunyi},${y + sunyi},M,$sel,A,0,"${_kutip(isi)}"';
  }

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

  /// Perintah menjadi byte, sebagai `List<int>` biasa — **bukan** `Uint8List`.
  ///
  /// `latin1.encode` mengembalikan `Uint8List`, dan dari Dart itu terlihat sama
  /// saja karena bertipe `List<int>`. Tapi jembatan Flutter mengirim keduanya
  /// dengan cara berbeda: daftar biasa sampai di Android sebagai `ArrayList`,
  /// `Uint8List` sampai sebagai `byte[]`. Plugin printer hanya menerima yang
  /// pertama, dan yang kedua membuatnya melempar
  /// `ClassCastException: byte[] cannot be cast to java.util.ArrayList` — yang
  /// di Dart hanya terlihat sebagai "cetak gagal", tanpa sebab.
  List<int> _bytes(List<String> perintah) {
    // Dipanjangkan sampai kelipatan 64 dengan baris kosong.
    //
    // Plugin printer memotong kiriman per 64 byte memakai `Arrays.copyOfRange`,
    // yang **membantali potongan terakhir dengan byte NUL** bila panjangnya
    // tidak pas. ESC/POS mengabaikan NUL, tapi TSPL tidak menjanjikan apa pun
    // tentangnya. Baris kosong aman: penerjemah TSPL melewatinya.
    final teks = StringBuffer('${perintah.join('\r\n')}\r\n');
    while (teks.length % 64 != 0) {
      teks.write('\n');
    }
    return List<int>.from(latin1.encode(teks.toString()));
  }
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
