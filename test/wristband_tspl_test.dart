import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jaya_propertiy/app/utils/common/generate_wristband_util.dart';
import 'package:jaya_propertiy/app/utils/common/tspl_decoder_util.dart';
import 'package:jaya_propertiy/data/models/common/wristband_config_model.dart';

/// Menguji penyusun perintah cetak gelang.
///
/// Yang benar-benar berbahaya di sini bukan salah ketik perintah — printer akan
/// menolaknya dengan terang — melainkan cetakan yang **meluber keluar media**.
/// TSPL tidak memenggal dan tidak mengeluh: elemen yang melewati tepi lembar
/// hilang begitu saja, dan yang hilang biasanya QR. Gelang keluar tampak wajar,
/// lalu gagal dipindai di gate. Karena itu sebagian besar uji di bawah memeriksa
/// batas, bukan isi.
void main() {
  final gen = GenerateWristbandUtil();

  /// Satu elemen yang digambar di atas lembar, dalam titik.
  ({int x, int y, int w, int h, String jenis, String isi}) elemen(String b) {
    final isi = RegExp(r'"([^"]*)"$').firstMatch(b)?.group(1) ?? '';
    if (b.startsWith('QRCODE')) {
      final a = b.substring(6).split(',');
      final x = int.parse(a[0].trim());
      final y = int.parse(a[1].trim());
      final sel = int.parse(a[3].trim());
      final sisi = GenerateWristbandUtil.modulQr(isi.length) * sel;
      return (x: x, y: y, w: sisi, h: sisi, jenis: 'QR', isi: isi);
    }
    final a = b.substring(4).split(',');
    final x = int.parse(a[0].trim());
    final y = int.parse(a[1].trim());
    final font = a[2].trim().replaceAll('"', '');
    final ukuran = GenerateWristbandUtil.fontDots[font]!;
    final lebar = isi.length * ukuran[0];
    final tinggi = ukuran[1];
    // Teks berputar menempati kotak yang sisinya tertukar, dan jangkarnya di
    // tepi kanan kotak itu. Mengabaikannya membuat uji batas memeriksa kotak
    // yang salah — lalu lulus padahal cetakannya keluar lembar.
    final putaran = int.tryParse(a[3].trim()) ?? 0;
    if (putaran == 90 || putaran == 270) {
      return (
        x: x - tinggi,
        y: y,
        w: tinggi,
        h: lebar,
        jenis: 'teks',
        isi: isi
      );
    }
    return (x: x, y: y, w: lebar, h: tinggi, jenis: 'teks', isi: isi);
  }

  List<String> perintah(List<int> bytes) => latin1
      .decode(bytes)
      .split('\r\n')
      .where((b) => b.trim().isNotEmpty)
      .toList();

  /// Semua yang digambar harus berada di dalam lembar.
  void periksaMuat(List<int> bytes, WristbandConfigModel c) {
    final digambar = perintah(bytes)
        .where((b) => b.startsWith('QRCODE') || b.startsWith('TEXT'))
        .map(elemen);

    expect(digambar, isNotEmpty, reason: 'lembar kosong tidak berguna');

    // Tidak ada yang boleh saling menimpa. Ini pernah terjadi sungguhan:
    // "PENDAMPING", nomor tiket, dan masa berlaku tercetak bertindihan sampai
    // nomornya tidak terbaca — jarak antar baris dulu tetap 4 titik untuk semua
    // ukuran huruf, terlalu rapat begitu hurufnya membesar.
    final urut = digambar.toList()..sort((a, b) => a.y.compareTo(b.y));
    for (var i = 0; i < urut.length - 1; i++) {
      for (var j = i + 1; j < urut.length; j++) {
        final a = urut[i];
        final b = urut[j];
        final tumpangTegak = b.y < a.y + a.h;
        final tumpangDatar = b.x < a.x + a.w && a.x < b.x + b.w;
        expect(tumpangTegak && tumpangDatar, isFalse,
            reason: '${a.jenis} "${a.isi}" di (${a.x},${a.y}) ${a.w}x${a.h} '
                'menimpa ${b.jenis} "${b.isi}" di (${b.x},${b.y}) ${b.w}x${b.h}');
      }
    }

    for (final e in digambar) {
      expect(e.x, greaterThanOrEqualTo(0), reason: '${e.jenis} "${e.isi}"');
      expect(e.y, greaterThanOrEqualTo(0), reason: '${e.jenis} "${e.isi}"');
      expect(e.x + e.w, lessThanOrEqualTo(c.widthDots),
          reason: '${e.jenis} "${e.isi}" melewati tepi kanan '
              '(${e.x}+${e.w} > ${c.widthDots})');
      expect(e.y + e.h, lessThanOrEqualTo(c.heightDots),
          reason: '${e.jenis} "${e.isi}" melewati tepi bawah '
              '(${e.y}+${e.h} > ${c.heightDots})');
    }
  }

  group('Byte yang menyeberang ke Android', () {
    test('bukan Uint8List, melainkan List<int> biasa', () {
      // `latin1.encode` mengembalikan Uint8List, dan dari Dart itu terlihat
      // sama saja karena bertipe List<int>. Jembatan Flutter mengirimkannya
      // sebagai `byte[]`, sementara plugin printer hanya menerima `ArrayList` —
      // hasilnya ClassCastException di sisi Android, yang di Dart hanya tampak
      // sebagai "cetak gagal" tanpa sebab. Uji ini menjaga agar tidak kembali.
      final c = WristbandConfigModel();
      for (final bytes in [
        gen.dataWristbandPrint(config: c, qrCode: '300909260012'),
        gen.testPrint(c),
        gen.rulerPrint(c),
      ]) {
        expect(bytes, isNot(isA<Uint8List>()),
            reason: 'byte[] tidak diterima plugin printer');
        expect(bytes, isA<List<int>>());
        expect(bytes, isNotEmpty);
      }
    });
  });

  group('Perintah dasar', () {
    test('kepala lembar memuat ukuran, jarak, kerapatan, dan cetak', () {
      final c = WristbandConfigModel();
      final p = perintah(gen.dataWristbandPrint(
        config: c,
        qrCode: '290809260005',
        ticketNo: '290809260005',
      ));

      expect(p.first, 'SIZE 50 mm,25 mm');
      expect(p, contains('GAP 2 mm,0 mm'));
      expect(p, contains('DIRECTION 1'));
      expect(p, contains('DENSITY 8'));
      expect(p, contains('SPEED 4'));
      expect(p, contains('CLS'));
      expect(p.last, 'PRINT 1,1');
    });

    test('ukuran milimeter tanpa nol di belakang koma', () {
      // Sebagian firmware TSPL menolak "50.0 mm" tapi menerima "50 mm".
      final p = perintah(gen.dataWristbandPrint(
        config: WristbandConfigModel(widthMm: 50, heightMm: 25, gapMm: 2.5),
        qrCode: 'X',
      ));
      expect(p.first, 'SIZE 50 mm,25 mm');
      expect(p, contains('GAP 2.5 mm,0 mm'));
    });

    test('jumlah salinan tidak pernah kurang dari satu', () {
      for (final n in [-3, 0, 1]) {
        final p = perintah(gen.dataWristbandPrint(
          config: WristbandConfigModel(),
          qrCode: 'X',
          salinan: n,
        ));
        expect(p.last, 'PRINT ${n < 1 ? 1 : n},1');
      }
      final p = perintah(gen.dataWristbandPrint(
        config: WristbandConfigModel(),
        qrCode: 'X',
        salinan: 2,
      ));
      expect(p.last, 'PRINT 2,1');
    });
  });

  group('Pemisahan media', () {
    // TSPL tidak punya perintah "potong" yang menyatu dengan cetak seperti
    // ESC/POS. Tanpa perintah pemisah, printer mencetak lalu berhenti di situ —
    // gelang terakhir tertinggal setengah di dalam dan tidak bisa disobek rapi.
    test('bawaan: pemotong mati, media maju ke bilah sobek', () {
      final p = perintah(gen.dataWristbandPrint(
        config: WristbandConfigModel(),
        qrCode: '290809260005',
      ));
      expect(p, contains('SET CUTTER OFF'));
      expect(p, contains('SET TEAR ON'));
    });

    test('potong tiap gelang mematikan maju-sobek', () {
      // Keduanya menyala bersama membuat printer memajukan media lalu memotong
      // di tempat yang salah.
      final p = perintah(gen.dataWristbandPrint(
        config: WristbandConfigModel(potong: ModePotong.tiapGelang),
        qrCode: '290809260005',
      ));
      expect(p, contains('SET CUTTER 1'));
      expect(p, contains('SET TEAR OFF'));
      expect(p, isNot(contains('SET TEAR ON')));
    });

    test('tanpa maju: media tidak digerakkan setelah mencetak', () {
      // Pada media bergelang panjang, memajukan ke bilah sobek memuntahkan sisa
      // gelang sampai jeda berikutnya — terlihat seperti gelang kedua yang
      // tercetak sendiri.
      final p = perintah(gen.dataWristbandPrint(
        config: WristbandConfigModel(potong: ModePotong.tanpaMaju),
        qrCode: '290809260005',
      ));
      expect(p, contains('SET CUTTER OFF'));
      expect(p, contains('SET TEAR OFF'));
      expect(p, isNot(contains('SET TEAR ON')));
    });

    test('potong di akhir cetakan', () {
      final p = perintah(gen.dataWristbandPrint(
        config: WristbandConfigModel(potong: ModePotong.akhirBatch),
        qrCode: '290809260005',
      ));
      expect(p, contains('SET CUTTER BATCH'));
    });

    test('perintah pemisah datang sebelum lembar dimulai', () {
      // SET harus mendahului CLS; sesudahnya printer sudah menyiapkan lembar.
      final p = perintah(gen.dataWristbandPrint(
        config: WristbandConfigModel(),
        qrCode: 'X',
      ));
      expect(p.indexOf('SET CUTTER OFF'), lessThan(p.indexOf('CLS')));
      expect(p.indexOf('SET TEAR ON'), lessThan(p.indexOf('CLS')));
    });

    test('cetak uji memakai setelan pemisah yang sama', () {
      // Cetak uji yang tidak mewakili cetak sungguhan adalah cetak uji yang
      // menyesatkan.
      final c = WristbandConfigModel(potong: ModePotong.tiapGelang);
      expect(perintah(gen.testPrint(c)), contains('SET CUTTER 1'));
    });

    test('mode pemisah bertahan lewat penyimpanan setelan', () {
      final ulang = WristbandConfigModel.fromJson(
          WristbandConfigModel(potong: ModePotong.akhirBatch).toJson());
      expect(ulang.potong, ModePotong.akhirBatch);
    });

    test('saklar gelang pendamping bertahan dan bawaannya menyala', () {
      expect(WristbandConfigModel().gelangPendamping, isTrue);
      expect(WristbandConfigModel.fromJson({}).gelangPendamping, isTrue,
          reason: 'setelan lama tanpa kunci ini tidak boleh mematikannya');
      final ulang = WristbandConfigModel.fromJson(
          WristbandConfigModel(gelangPendamping: false).toJson());
      expect(ulang.gelangPendamping, isFalse);
    });

    test('mode tidak dikenal kembali ke sobek manual', () {
      // Sobek manual jalan di semua printer; memilih potong pada printer tanpa
      // modul pemotong membuat cetakan menggantung.
      expect(WristbandConfigModel.fromJson({'potong': 'entah'}).potong,
          ModePotong.sobek);
    });
  });

  group('Isi gelang', () {
    test('QR berisi nomor tiket, dan nomornya juga dicetak sebagai teks', () {
      // Nomor teks itu yang diketik operator gate saat QR tidak terbaca —
      // alur Keluar Manual bertumpu padanya.
      final p = perintah(gen.dataWristbandPrint(
        config: WristbandConfigModel(),
        qrCode: '290809260005',
        ticketNo: '290809260005',
        berlakuSampai: 's/d 08 Sep 2026',
      ));

      expect(p.any((b) => b.startsWith('QRCODE') && b.contains('"290809260005"')),
          isTrue);
      expect(p.any((b) => b.startsWith('TEXT') && b.contains('"290809260005"')),
          isTrue);
      expect(
          p.any((b) => b.startsWith('TEXT') && b.contains('s/d 08 Sep 2026')),
          isTrue);
    });

    test('gelang pendamping diberi penanda', () {
      final p = perintah(gen.dataWristbandPrint(
        config: WristbandConfigModel(),
        qrCode: '290809260006',
        ticketNo: '290809260006',
        pendamping: true,
      ));
      expect(p.any((b) => b.contains('PENDAMPING')), isTrue);
    });

    test('tanpa pendamping tidak ada penandanya', () {
      final p = perintah(gen.dataWristbandPrint(
        config: WristbandConfigModel(),
        qrCode: '290809260006',
        ticketNo: '290809260006',
      ));
      expect(p.any((b) => b.contains('PENDAMPING')), isFalse);
    });

    test('koreksi galat QR di tingkat M, bukan L', () {
      // Gelang kena air dan gesekan; QR harus tetap terbaca meski rusak sebagian.
      final p = perintah(gen.dataWristbandPrint(
        config: WristbandConfigModel(),
        qrCode: '290809260005',
      ));
      final qr = p.firstWhere((b) => b.startsWith('QRCODE'));
      expect(qr.split(',')[2].trim(), 'M');
    });
  });

  group('Tetap di dalam media', () {
    final ukuran = <String, WristbandConfigModel>{
      'label 50x25mm 203dpi': WristbandConfigModel(),
      'label 40x30mm 203dpi': WristbandConfigModel(widthMm: 40, heightMm: 30),
      'label 100x50mm 203dpi': WristbandConfigModel(widthMm: 100, heightMm: 50),
      'label 50x25mm 300dpi': WristbandConfigModel(dpi: 300),
      'gelang 25x220mm': WristbandConfigModel(widthMm: 25, heightMm: 220),
      'gelang sempit 19x180mm': WristbandConfigModel(widthMm: 19, heightMm: 180),
      'label mungil 25x15mm': WristbandConfigModel(widthMm: 25, heightMm: 15),
    };

    ukuran.forEach((nama, c) {
      test('$nama — semua elemen di dalam lembar', () {
        periksaMuat(
          gen.dataWristbandPrint(
            config: c,
            qrCode: '290809260005',
            ticketNo: '290809260005',
            berlakuSampai: 's/d 08 Sep 2026',
            pendamping: true,
          ),
          c,
        );
      });

      test('$nama — cetak uji juga di dalam lembar', () {
        periksaMuat(gen.testPrint(c), c);
      });
    });

    test('teks panjang dipotong, bukan dibiarkan meluber', () {
      final c = WristbandConfigModel(widthMm: 40, heightMm: 25);
      final bytes = gen.dataWristbandPrint(
        config: c,
        qrCode: '290809260005',
        ticketNo: '290809260005',
        berlakuSampai:
            'Berlaku sampai dengan hari Selasa 8 September 2026 pukul 16:00 WIB',
      );
      periksaMuat(bytes, c);

      final teks = perintah(bytes).where((b) => b.startsWith('TEXT')).toList();
      expect(teks.any((b) => b.contains('Berlaku')), isTrue,
          reason: 'baris tetap dicetak, hanya dipendekkan');
    });

    test('susunannya dipusatkan, tidak menempel ke satu tepi', () {
      // Cetakan yang menempel ke margin terlihat terdorong ke satu sisi padahal
      // separuh medianya kosong — jelas terlihat di gelang yang dipakai.
      final c = WristbandConfigModel(widthMm: 80, heightMm: 25);
      final digambar = perintah(gen.dataWristbandPrint(
        config: c,
        qrCode: '300909260011',
        ticketNo: '300909260011',
        berlakuSampai: 's/d 09 Sep 2026',
      ))
          .where((b) => b.startsWith('QRCODE') || b.startsWith('TEXT'))
          .map(elemen)
          .toList();

      final kiri = digambar.map((e) => e.x).reduce((a, b) => a < b ? a : b);
      final kanan =
          digambar.map((e) => e.x + e.w).reduce((a, b) => a > b ? a : b);
      final sisaKiri = kiri;
      final sisaKanan = c.widthDots - kanan;

      // Media 80mm jauh lebih lebar dari isinya; sisa kiri dan kanan harus
      // seimbang, bukan menumpuk di satu sisi.
      expect((sisaKiri - sisaKanan).abs(), lessThanOrEqualTo(c.dots(2)),
          reason: 'sisa kiri $sisaKiri titik vs kanan $sisaKanan titik');
    });

    test('baris berikutnya boleh memakai huruf besar bila medianya lapang', () {
      // Dulu semua baris selain yang pertama dipaksa maksimal huruf "3",
      // membuat cetakan mengecil tanpa alasan pada media yang sebenarnya luas.
      final p = perintah(gen.dataWristbandPrint(
        config: WristbandConfigModel(widthMm: 100, heightMm: 50),
        qrCode: '300909260011',
        ticketNo: '300909260011',
        berlakuSampai: '09 Sep',
        pendamping: true,
      ));
      final fonts = p
          .where((b) => b.startsWith('TEXT'))
          .map((b) => b.split(',')[2].replaceAll('"', ''))
          .toList();
      expect(fonts.length, 3);
      expect(fonts.skip(1).any((f) => int.parse(f) >= 4), isTrue,
          reason: 'huruf: $fonts');
    });

    test('media sempit beralih ke susunan bertumpuk', () {
      // Pada gelang 25mm tidak ada ruang berguna di samping QR; QR naik ke atas
      // dan teks turun ke bawah.
      final c = WristbandConfigModel(widthMm: 25, heightMm: 220);
      final p = perintah(gen.dataWristbandPrint(
        config: c,
        qrCode: '290809260005',
        ticketNo: '290809260005',
        berlakuSampai: 's/d 08 Sep 2026',
      ));
      final qr = elemen(p.firstWhere((b) => b.startsWith('QRCODE')));
      final teksPertama = elemen(p.firstWhere((b) => b.startsWith('TEXT')));
      expect(teksPertama.y, greaterThanOrEqualTo(qr.y + qr.h),
          reason: 'teks harus di bawah QR, bukan menimpanya');
    });

    test('QR mendapat sel terbesar yang muat, bukan sel minimum', () {
      // QR yang terlalu kecil gagal dipindai; ruang yang ada harus dipakai.
      final c = WristbandConfigModel(widthMm: 50, heightMm: 25);
      final p = perintah(gen.dataWristbandPrint(
        config: c,
        qrCode: '290809260005',
        ticketNo: '290809260005',
      ));
      final sel = int.parse(
          p.firstWhere((b) => b.startsWith('QRCODE')).substring(6).split(',')[3]);
      // 25mm - 2x2mm margin = 168 titik untuk 29 modul (21 + zona sunyi).
      expect(sel, greaterThanOrEqualTo(4));
    });
  });

  group('Putar isi 90 derajat', () {
    // Pada pita 25mm, arah melintang hanya memuat nomor tiket pada huruf kecil.
    // Memutar isi memindahkan keterbatasan itu ke arah panjang gelang, yang
    // tersedia ratusan milimeter.
    List<int> cetak(WristbandConfigModel c) => gen.dataWristbandPrint(
          config: c,
          qrCode: '300909260012',
          ticketNo: '300909260012',
          berlakuSampai: 's/d 09 Sep 2026',
        );

    int tinggiHurufTerbesar(List<int> bytes) => perintah(bytes)
        .where((b) => b.startsWith('TEXT'))
        .map((b) => GenerateWristbandUtil
            .fontDots[b.split(',')[2].replaceAll('"', '')]![1])
        .reduce((a, b) => a > b ? a : b);

    test('putaran menaikkan ukuran huruf pada pita sempit', () {
      final biasa = WristbandConfigModel(widthMm: 25, heightMm: 80, marginMm: 1);
      expect(tinggiHurufTerbesar(cetak(biasa.salin(putarIsi: true))),
          greaterThan(tinggiHurufTerbesar(cetak(biasa))));
    });

    test('putaran tidak mengecilkan QR', () {
      int selQr(List<int> bytes) => int.parse(perintah(bytes)
          .firstWhere((b) => b.startsWith('QRCODE'))
          .substring(6)
          .split(',')[3]
          .trim());
      final c = WristbandConfigModel(widthMm: 25, heightMm: 80, marginMm: 1);
      expect(selQr(cetak(c.salin(putarIsi: true))), selQr(cetak(c)));
    });

    test('QR dan teks sama-sama diberi tanda putaran 90', () {
      final p = perintah(cetak(
          WristbandConfigModel(widthMm: 25, heightMm: 80, putarIsi: true)));
      expect(p.firstWhere((b) => b.startsWith('QRCODE')).split(',')[5].trim(),
          '90');
      for (final b in p.where((b) => b.startsWith('TEXT'))) {
        expect(b.split(',')[3].trim(), '90');
      }
    });

    test('tanpa putaran tidak ada yang bertanda 90', () {
      final p = perintah(
          cetak(WristbandConfigModel(widthMm: 25, heightMm: 80)));
      expect(p.firstWhere((b) => b.startsWith('QRCODE')).split(',')[5].trim(),
          '0');
      for (final b in p.where((b) => b.startsWith('TEXT'))) {
        expect(b.split(',')[3].trim(), '0');
      }
    });

    group('tetap di dalam lembar setelah diputar', () {
      final ukuran = <String, WristbandConfigModel>{
        'gelang 25x60': WristbandConfigModel(widthMm: 25, heightMm: 60),
        'gelang 25x80 margin 1':
            WristbandConfigModel(widthMm: 25, heightMm: 80, marginMm: 1),
        'gelang 19x180': WristbandConfigModel(widthMm: 19, heightMm: 180),
        'label 50x25': WristbandConfigModel(),
        'label mungil 25x15': WristbandConfigModel(widthMm: 25, heightMm: 15),
        '300dpi': WristbandConfigModel(widthMm: 25, heightMm: 80, dpi: 300),
      };
      ukuran.forEach((nama, dasar) {
        final c = dasar.salin(putarIsi: true);
        test(nama, () => periksaMuat(cetak(c), c));
        test('$nama — cetak uji', () => periksaMuat(gen.testPrint(c), c));
        test('$nama — dengan geseran', () {
          final g = c.salin(geserXMm: 3, geserYMm: 8);
          periksaMuat(cetak(g), g);
        });
      });
    });

    test('putaran bertahan lewat penyimpanan, bawaannya mati', () {
      expect(WristbandConfigModel().putarIsi, isFalse);
      expect(WristbandConfigModel.fromJson({}).putarIsi, isFalse,
          reason: 'setelan lama tidak boleh berubah perilaku sendiri');
      expect(
          WristbandConfigModel.fromJson(
              WristbandConfigModel(putarIsi: true).toJson()).putarIsi,
          isTrue);
    });
  });

  group('Cetak penggaris', () {
    // Alat ukur, bukan hasil akhir. Yang dijaga: ia mengikuti media yang
    // benar-benar terpasang, memakai perintah yang terbukti dimengerti printer,
    // dan sumbunya mulai tepat di sudut cetak.
    test('memakai ukuran media dari setelan', () {
      // Versi pertama memaksa 60x60mm, dan printer melaporkan berhasil lalu
      // tidak mengeluarkan apa pun karena ukuran itu tidak cocok dengan
      // medianya. Penggaris yang tidak keluar tidak mengukur apa-apa.
      for (final c in [
        WristbandConfigModel(),
        WristbandConfigModel(widthMm: 25, heightMm: 80),
      ]) {
        expect(perintah(gen.rulerPrint(c)).first,
            'SIZE ${c.widthMm.toInt()} mm,${c.heightMm.toInt()} mm');
      }
    });

    test('tidak memakai perintah BAR sama sekali', () {
      // Setiap cetakan ber-BAR belum pernah keluar dari printer di lapangan,
      // sementara QRCODE dan TEXT selalu keluar. Alat ukur tidak boleh ikut
      // mempertaruhkan hasilnya pada perintah yang belum terbukti.
      final p = perintah(gen.rulerPrint(
          WristbandConfigModel(widthMm: 25, heightMm: 80)));
      expect(p.any((b) => b.startsWith('BAR')), isFalse);
    });

    test('sependek cetakan tiket yang sudah terbukti berhasil', () {
      final c = WristbandConfigModel(widthMm: 25, heightMm: 80);
      final tiket = gen.dataWristbandPrint(
          config: c, qrCode: '300909260029', ticketNo: '300909260029');
      expect(gen.rulerPrint(c).length, lessThan(tiket.length * 2));
    });

    test('margin dan geseran diabaikan, sumbu mulai dekat sudut cetak', () {
      // 1mm masuk ke dalam, bukan tepat di 0: cetakan tiket yang selalu
      // berhasil tidak pernah menggambar di koordinat 0, sementara cetakan yang
      // tidak pernah keluar selalu mulai di sana.
      final c = WristbandConfigModel(
          widthMm: 25, heightMm: 80, marginMm: 5, geserXMm: 15, geserYMm: 5);
      final asal = c.dots(1);
      final p = perintah(gen.rulerPrint(c));
      expect(p.any((b) => b.startsWith('TEXT $asal,$asal,')), isTrue);
      expect(p.any((b) => b.contains(' 0,0,')), isFalse);
    });

    test('kedua sumbu bernomor tiap 20mm sejauh medianya', () {
      final c = WristbandConfigModel(widthMm: 25, heightMm: 80);
      final p = perintah(gen.rulerPrint(c));
      expect(p.any((b) => b.endsWith('"L20"')), isTrue);
      for (var mm = 20; mm <= 60; mm += 20) {
        expect(p.any((b) => b.endsWith('"T$mm"')), isTrue, reason: 'T$mm');
      }
      // Angka yang tidak lagi muat utuh tidak dicetak: L40 melewati lebar 25mm,
      // dan T80 jatuh tepat di tepi bawah lembar 80mm.
      expect(p.any((b) => b.endsWith('"L40"')), isFalse);
      expect(p.any((b) => b.endsWith('"T80"')), isFalse);
    });

    test('nomor sumbu berada di jarak yang benar dari titik nol', () {
      // Penggaris yang angkanya tidak berada di posisi yang ia klaim lebih buruk
      // daripada tidak ada penggaris sama sekali.
      final c = WristbandConfigModel(widthMm: 25, heightMm: 80);
      final p = perintah(gen.rulerPrint(c));
      final asal = c.dots(1);
      expect(p.any((b) => b.startsWith('TEXT ${c.dots(20)},$asal,')), isTrue);
      for (var mm = 20; mm <= 60; mm += 20) {
        expect(
            p.any((b) => b.startsWith('TEXT $asal,${c.dots(mm.toDouble())},')),
            isTrue,
            reason: 'T$mm');
      }
    });

    test('membawa uji putaran R0 dan R90', () {
      final p = perintah(gen.rulerPrint(
          WristbandConfigModel(widthMm: 25, heightMm: 80)));
      expect(p.firstWhere((b) => b.endsWith('"R0"')).split(',')[3].trim(), '0');
      expect(
          p.firstWhere((b) => b.endsWith('"R90"')).split(',')[3].trim(), '90');
    });

    test('seluruh isinya tetap di dalam lembar', () {
      for (final c in [
        WristbandConfigModel(),
        WristbandConfigModel(widthMm: 25, heightMm: 80),
        WristbandConfigModel(widthMm: 19, heightMm: 180),
        WristbandConfigModel(widthMm: 25, heightMm: 80, dpi: 300),
      ]) {
        periksaMuat(gen.rulerPrint(c), c);
      }
    });
  });

  group('Batas ukuran QR', () {
    // Kadang yang langka bukan lebar media, melainkan panjang area yang bersih
    // dari cetakan pabrik gelang. Isi kita harus muat di sisa itu, dan QR satu-
    // satunya bagian yang bisa dikecilkan tanpa kehilangan makna.
    int sisiQr(List<int> bytes) {
      final b = perintah(bytes).firstWhere((t) => t.startsWith('QRCODE'));
      final sel = int.parse(b.substring(6).split(',')[3].trim());
      return GenerateWristbandUtil.modulQr(12) * sel;
    }

    List<int> cetak(WristbandConfigModel c) => gen.dataWristbandPrint(
          config: c,
          qrCode: '300909260039',
          ticketNo: '300909260039',
          berlakuSampai: 's/d 09Sep26',
        );

    test('0 berarti sebesar mungkin, seperti sebelumnya', () {
      final c = WristbandConfigModel(widthMm: 25, heightMm: 30, marginMm: 1);
      expect(sisiQr(cetak(c.salin(qrMaksMm: 0))), sisiQr(cetak(c)));
    });

    test('batas ditaati, tidak dilampaui', () {
      final c = WristbandConfigModel(widthMm: 25, heightMm: 30, marginMm: 1);
      for (final maks in [6.0, 8.0, 10.0]) {
        expect(sisiQr(cetak(c.salin(qrMaksMm: maks))),
            lessThanOrEqualTo(c.dots(maks)),
            reason: 'batas $maks mm');
      }
    });

    test('QR mengecil membebaskan ruang menyusuri gelang', () {
      // Inilah gunanya: isi jadi lebih pendek, sehingga muat di area bersih
      // dan masih menyisakan ruang untuk digeser menjauhi cetakan pabrik.
      int tinggiIsi(List<int> bytes) {
        final e = perintah(bytes)
            .where((b) => b.startsWith('QRCODE') || b.startsWith('TEXT'))
            .map(elemen);
        final atas = e.map((v) => v.y).reduce((a, b) => a < b ? a : b);
        final bawah = e.map((v) => v.y + v.h).reduce((a, b) => a > b ? a : b);
        return bawah - atas;
      }

      final c = WristbandConfigModel(widthMm: 25, heightMm: 30, marginMm: 1);
      expect(tinggiIsi(cetak(c.salin(qrMaksMm: 7))),
          lessThan(tinggiIsi(cetak(c))));
    });

    test('batas yang mustahil tidak membuat QR hilang', () {
      // Setengah milimeter tidak bisa dipenuhi; QR tetap dicetak pada sel
      // terkecil, karena gelang tanpa QR tidak berguna sama sekali.
      final c = WristbandConfigModel(
          widthMm: 25, heightMm: 30, marginMm: 1, qrMaksMm: 0.5);
      expect(sisiQr(cetak(c)), greaterThan(0));
      periksaMuat(cetak(c), c);
    });

    test('batas bertahan lewat penyimpanan, nilai mustahil ditolak', () {
      expect(
          WristbandConfigModel.fromJson(
              WristbandConfigModel(qrMaksMm: 8).toJson()).qrMaksMm,
          8);
      expect(WristbandConfigModel.fromJson({'qrMaksMm': 999}).qrMaksMm, 0);
    });
  });

  group('Geser lembar (SHIFT)', () {
    // Memindahkan lembar terhadap takik gelang — satu-satunya cara mencetak di
    // atas titik awal cetak, yang tidak bisa dijangkau tata letak.
    test('tidak dikirim sama sekali saat 0', () {
      // Perintah asing bisa membuat sebagian firmware menolak seluruh lembar
      // tanpa mengeluh; printer yang tidak membutuhkannya tidak boleh ikut
      // menanggung risikonya.
      final p = perintah(gen.dataWristbandPrint(
          config: WristbandConfigModel(), qrCode: '290809260005'));
      expect(p.any((b) => b.startsWith('SHIFT')), isFalse);
    });

    test('dikirim dalam titik, bukan milimeter', () {
      final c = WristbandConfigModel(shiftMm: -7);
      final p = perintah(
          gen.dataWristbandPrint(config: c, qrCode: '290809260005'));
      expect(p, contains('SHIFT ${c.dots(-7)}'));
    });

    test('mendahului CLS, sebelum lembar disiapkan', () {
      final p = perintah(gen.dataWristbandPrint(
          config: WristbandConfigModel(shiftMm: -7), qrCode: 'X'));
      expect(p.indexWhere((b) => b.startsWith('SHIFT')),
          lessThan(p.indexOf('CLS')));
    });

    test('tidak mengubah tata letak isi sedikit pun', () {
      // Yang bergeser lembarnya, bukan isinya di dalam lembar.
      final c = WristbandConfigModel(widthMm: 25, heightMm: 30, marginMm: 1);
      final tanpa = perintah(gen.dataWristbandPrint(
          config: c, qrCode: '300909260043', ticketNo: '300909260043'));
      final dengan = perintah(gen.dataWristbandPrint(
          config: c.salin(shiftMm: -7),
          qrCode: '300909260043',
          ticketNo: '300909260043'));
      expect(dengan.where((b) => b.startsWith('QRCODE') || b.startsWith('TEXT')),
          tanpa.where((b) => b.startsWith('QRCODE') || b.startsWith('TEXT')));
    });

    test('bertahan lewat penyimpanan, nilai mustahil ditolak', () {
      expect(
          WristbandConfigModel.fromJson(
              WristbandConfigModel(shiftMm: -7).toJson()).shiftMm,
          -7);
      expect(WristbandConfigModel.fromJson({'shiftMm': 999}).shiftMm, 0);
    });
  });

  group('Posisi isi', () {
    // Perataan berbeda dari geseran, dan bedanya itulah gunanya: geser
    // memindahkan isi dengan mengorbankan ruang (QR ikut mengecil), perataan
    // hanya memilih ujung mana yang dipakai.
    List<int> cetak(WristbandConfigModel c) => gen.dataWristbandPrint(
          config: c,
          qrCode: '300909260043',
          ticketNo: '300909260043',
          berlakuSampai: 's/d 10Sep26',
        );

    ({int atas, int bawah, int sel}) ukur(List<int> bytes) {
      final p = perintah(bytes);
      final e = p
          .where((b) => b.startsWith('QRCODE') || b.startsWith('TEXT'))
          .map(elemen)
          .toList();
      return (
        atas: e.map((v) => v.y).reduce((a, b) => a < b ? a : b),
        bawah: e.map((v) => v.y + v.h).reduce((a, b) => a > b ? a : b),
        sel: int.parse(
            p.firstWhere((b) => b.startsWith('QRCODE')).substring(6).split(',')[3]),
      );
    }

    final dasar = WristbandConfigModel(
        widthMm: 25, heightMm: 30, marginMm: 1, qrMaksMm: 9);

    test('rapat ke atas menempel margin, bukan di tengah', () {
      final atas = ukur(cetak(dasar.salin(posisi: PosisiIsi.atas)));
      expect(atas.atas, dasar.marginDots);
      expect(atas.atas,
          lessThan(ukur(cetak(dasar.salin(posisi: PosisiIsi.tengah))).atas));
    });

    test('rapat ke bawah menempel margin bawah', () {
      final bawah = ukur(cetak(dasar.salin(posisi: PosisiIsi.bawah)));
      expect(bawah.bawah, dasar.heightDots - dasar.marginDots);
    });

    test('perataan tidak mengecilkan QR — inilah bedanya dari geser', () {
      final tengah = ukur(cetak(dasar));
      for (final p in PosisiIsi.values) {
        expect(ukur(cetak(dasar.salin(posisi: p))).sel, tengah.sel,
            reason: 'posisi $p');
      }
      // Geser sejauh yang setara justru mengecilkan.
      expect(ukur(cetak(dasar.salin(geserYMm: -6))).sel,
          lessThan(tengah.sel));
    });

    test('bawaannya di tengah, dan setelan lama tidak berubah sendiri', () {
      expect(WristbandConfigModel().posisi, PosisiIsi.tengah);
      expect(WristbandConfigModel.fromJson({}).posisi, PosisiIsi.tengah);
      expect(
          WristbandConfigModel.fromJson(
              WristbandConfigModel(posisi: PosisiIsi.atas).toJson()).posisi,
          PosisiIsi.atas);
    });

    test('semua perataan tetap di dalam lembar', () {
      for (final p in PosisiIsi.values) {
        for (final c in [
          dasar.salin(posisi: p),
          dasar.salin(posisi: p, geserYMm: 3),
          WristbandConfigModel(posisi: p),
          WristbandConfigModel(widthMm: 25, heightMm: 80, posisi: p),
        ]) {
          periksaMuat(cetak(c), c);
        }
      }
    });
  });

  group('Geser cetakan', () {
    // Ada karena bagian yang boleh dicetaki pada gelang jarang di tengah
    // medianya: satu ujungnya perekat.
    //
    // Yang dijaga di sini adalah **titik tengah** isi, bukan tepi kirinya. Isi
    // ditata di tengah ruang yang tersisa, dan ruang itu mengecil saat digeser,
    // jadi tepi kirinya berpindah lebih jauh daripada geseran yang diminta —
    // sementara titik tengahnya berpindah persis sejauh yang diminta.
    ({int x, int y}) tengah(List<int> bytes) {
      final e = perintah(bytes)
          .where((b) => b.startsWith('QRCODE') || b.startsWith('TEXT'))
          .map(elemen)
          .toList();
      int kecil(Iterable<int> v) => v.reduce((a, b) => a < b ? a : b);
      int besar(Iterable<int> v) => v.reduce((a, b) => a > b ? a : b);
      return (
        x: ((kecil(e.map((v) => v.x)) + besar(e.map((v) => v.x + v.w))) / 2)
            .round(),
        y: ((kecil(e.map((v) => v.y)) + besar(e.map((v) => v.y + v.h))) / 2)
            .round(),
      );
    }

    List<int> cetak(WristbandConfigModel c) => gen.dataWristbandPrint(
          config: c,
          qrCode: '300909260011',
          ticketNo: '300909260011',
          berlakuSampai: 's/d 09 Sep 2026',
        );

    // Toleransi ~1,5mm. Bukan kelonggaran asal-asalan: mengecilkan ruang tata
    // letak membuat huruf dan tinggi blok teks ikut berubah, jadi titik tengah
    // isi bergeser satu-dua milimeter dari hitungan ideal. Yang penting bagi
    // operator adalah cetakan benar-benar menepi sejauh yang diminta, bukan
    // ketepatan sampai satu titik.
    const toleransi = 12;

    test('geser positif memindahkan isi sejauh yang diminta', () {
      final asal = WristbandConfigModel(widthMm: 90, heightMm: 25);
      final a = tengah(cetak(asal));
      final b = tengah(cetak(asal.salin(geserXMm: 10)));
      expect((b.x - a.x - asal.dots(10)).abs(), lessThanOrEqualTo(toleransi));
      expect((b.y - a.y).abs(), lessThanOrEqualTo(toleransi),
          reason: 'geser X tidak boleh memindahkan isi secara tegak');
    });

    test('geser negatif menarik ke arah sebaliknya', () {
      final asal = WristbandConfigModel(widthMm: 90, heightMm: 25);
      final a = tengah(cetak(asal));
      final b = tengah(cetak(asal.salin(geserXMm: -8)));
      expect((b.x - a.x + asal.dots(8)).abs(), lessThanOrEqualTo(toleransi));
    });

    test('geser tegak juga bekerja', () {
      final asal = WristbandConfigModel(widthMm: 90, heightMm: 40);
      final a = tengah(cetak(asal));
      final b = tengah(cetak(asal.salin(geserYMm: 5)));
      expect((b.y - a.y - asal.dots(5)).abs(), lessThanOrEqualTo(toleransi));
    });

    test('geser mendatar tidak mengecilkan QR', () {
      // Yang dikorbankan lebar teks, bukan QR — QR dibatasi tinggi lembar, dan
      // QR yang mengecil diam-diam adalah QR yang gagal dipindai di gate.
      int selQr(List<int> bytes) => int.parse(perintah(bytes)
          .firstWhere((b) => b.startsWith('QRCODE'))
          .substring(6)
          .split(',')[3]
          .trim());

      final asal = WristbandConfigModel(widthMm: 90, heightMm: 25);
      expect(selQr(cetak(asal.salin(geserXMm: 15))), selQr(cetak(asal)));
    });

    test('geser berlebihan tidak melempar gambar keluar lembar', () {
      // Ini yang paling penting: TSPL memotong apa pun yang melewati tepi tanpa
      // mengeluh, dan yang hilang biasanya sudut QR.
      for (final mm in [40.0, -40.0, 500.0, -500.0]) {
        final c = WristbandConfigModel(
            widthMm: 90, heightMm: 25, geserXMm: mm, geserYMm: mm / 4);
        periksaMuat(cetak(c), c);
      }
    });

    test('geser nol tidak mengubah apa pun', () {
      final c = WristbandConfigModel(widthMm: 90, heightMm: 25);
      expect(perintah(cetak(c.salin(geserXMm: 0, geserYMm: 0))),
          perintah(cetak(c)));
    });

    test('cetak uji ikut tergeser, supaya mewakili cetak sungguhan', () {
      // Diukur pada QR-nya saja: penanda sudut cetak uji sengaja **tidak**
      // ikut bergeser — ia menandai batas media, bukan isi.
      int xQr(List<int> bytes) => int.parse(perintah(bytes)
          .firstWhere((b) => b.startsWith('QRCODE'))
          .substring(6)
          .split(',')[0]
          .trim());

      final asal = WristbandConfigModel(widthMm: 90, heightMm: 25);
      final selisih = xQr(gen.testPrint(asal.salin(geserXMm: 10))) -
          xQr(gen.testPrint(asal));
      expect((selisih - asal.dots(10)).abs(), lessThanOrEqualTo(toleransi));
    });

    test('geseran bertahan lewat penyimpanan setelan', () {
      final ulang = WristbandConfigModel.fromJson(
          WristbandConfigModel(geserXMm: 7.5, geserYMm: -2).toJson());
      expect(ulang.geserXMm, 7.5);
      expect(ulang.geserYMm, -2);
    });

    test('geseran mustahil ditolak dan kembali nol', () {
      final c = WristbandConfigModel.fromJson({'geserXMm': 9999, 'geserYMm': 'x'});
      expect(c.geserXMm, 0);
      expect(c.geserYMm, 0);
    });
  });

  group('Isi yang berbahaya', () {
    test('tanda kutip dalam isi dilindungi, perintah tidak terpotong', () {
      final p = perintah(gen.dataWristbandPrint(
        config: WristbandConfigModel(),
        qrCode: 'AB"CD',
      ));
      final qr = p.firstWhere((b) => b.startsWith('QRCODE'));
      expect(qr, endsWith(r'"AB\"CD"'));
    });

    test('garis miring balik dilindungi', () {
      final p = perintah(gen.dataWristbandPrint(
        config: WristbandConfigModel(),
        qrCode: r'AB\CD',
      ));
      expect(p.firstWhere((b) => b.startsWith('QRCODE')), endsWith(r'"AB\\CD"'));
    });

    test('karakter di luar ASCII diganti, bukan dikirim apa adanya', () {
      // Halaman kode bawaan TSPL bukan UTF-8; huruf beraksen keluar acak.
      final p = perintah(gen.dataWristbandPrint(
        config: WristbandConfigModel(),
        qrCode: 'X',
        ticketNo: 'Café Anák',
      ));
      final teks = p.firstWhere((b) => b.contains('Caf'));
      expect(teks, contains('Caf An k'));
    });

    test('seluruh keluaran tetap ASCII yang bisa dicetak', () {
      final bytes = gen.dataWristbandPrint(
        config: WristbandConfigModel(),
        qrCode: '290809260005',
        ticketNo: 'Tiket — Playground 2 Jam',
        berlakuSampai: 's/d 08 Sep 2026',
      );
      for (final b in bytes) {
        expect((b >= 0x20 && b <= 0x7E) || b == 0x0D || b == 0x0A, isTrue,
            reason: 'byte $b bukan ASCII yang bisa dicetak');
      }
    });
  });

  group('Penerjemah TSPL untuk simulasi', () {
    test('mengenali TSPL, dan tidak salah mengira ESC/POS sebagai TSPL', () {
      final tspl = gen.dataWristbandPrint(
        config: WristbandConfigModel(),
        qrCode: '290809260005',
      );
      expect(TsplDecoder.sepertinyaTspl(tspl), isTrue);

      // ESC @ (reset) + teks — bentuk khas awal struk ESC/POS.
      expect(TsplDecoder.sepertinyaTspl([0x1B, 0x40, 0x48, 0x69]), isFalse);
      expect(TsplDecoder.sepertinyaTspl([]), isFalse);
    });

    test('isi QR terbaca kembali dari hasil terjemahan', () {
      final baris = TsplDecoder.decode(gen.dataWristbandPrint(
        config: WristbandConfigModel(),
        qrCode: '290809260005',
        ticketNo: '290809260005',
        berlakuSampai: 's/d 08 Sep 2026',
      ));

      expect(baris.any((b) => b.startsWith('[QR') && b.endsWith('290809260005')),
          isTrue);
      expect(baris.any((b) => b.startsWith('[media')), isTrue);
      expect(baris.last, '[cetak 1 lembar]');
    });

    test('isi teks diambil dari kutip terakhir, bukan nama hurufnya', () {
      // TEXT punya dua pasang kutip; yang pertama itu nomor huruf.
      final baris = TsplDecoder.decode(
          latin1.encode('TEXT 136,60,"3",0,1,1,"290809260005"\r\n'));
      expect(baris.single, '[teks di (136,60) huruf 3] 290809260005');
    });

    test('perintah asing tetap ditampilkan, tidak dibuang diam-diam', () {
      final baris = TsplDecoder.decode(latin1.encode('BLINK 3\r\n'));
      expect(baris.single, '[?] BLINK 3');
    });

    test('ringkasan memakai baris yang paling menjelaskan gelangnya', () {
      final r = TsplDecoder.ringkasan(gen.dataWristbandPrint(
        config: WristbandConfigModel(),
        qrCode: '290809260005',
      ));
      expect(r, contains('290809260005'));
    });
  });

  group('Setelan media', () {
    test('nilai mustahil ditolak dan kembali ke bawaan', () {
      // Lembar 0mm membuat printer diam tanpa mencetak dan tanpa memberi tahu.
      final c = WristbandConfigModel.fromJson({
        'widthMm': 0,
        'heightMm': -5,
        'dpi': 'entah',
        'density': 99,
        'speed': null,
      });
      expect(c.widthMm, 50);
      expect(c.heightMm, 25);
      expect(c.dpi, 203);
      expect(c.density, 8);
      expect(c.speed, 4);
    });

    test('nilai wajar dipertahankan', () {
      final asal = WristbandConfigModel(
        dpi: 300,
        widthMm: 25,
        heightMm: 220,
        gapMm: 0,
        density: 12,
        speed: 2,
        direction: 0,
      );
      final ulang = WristbandConfigModel.fromJson(asal.toJson());
      expect(ulang.toJson(), asal.toJson());
    });

    test('titik per milimeter mengikuti resolusi', () {
      expect(WristbandConfigModel(dpi: 203).dots(25), 200); // 8 titik/mm
      expect(WristbandConfigModel(dpi: 300).dots(25), 295); // 11,8 titik/mm
    });
  });
}
