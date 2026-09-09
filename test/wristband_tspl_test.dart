import 'dart:convert';

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
    return (
      x: x,
      y: y,
      w: isi.length * ukuran[0],
      h: ukuran[1],
      jenis: 'teks',
      isi: isi
    );
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
