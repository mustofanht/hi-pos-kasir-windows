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

  /// Gelang contoh dengan semua baris teks terisi — isi terpanjang yang bisa
  /// muncul, jadi paling mungkin meluber.
  List<int> contohGelang(WristbandConfigModel c) => gen.dataGelangPlayground(
        config: c,
        qrCode: 'TES-GELANG',
        lokasi: 'UJI GELANG',
        nama: 'Pendamping (nama anak)',
        nomorOrder: '0000/UJI/TIX/2026',
        waktu: '2026-01-01 00:00:00',
      );

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
    if (putaran == 90) {
      return (x: x - tinggi, y: y, w: tinggi, h: lebar, jenis: 'teks', isi: isi);
    }
    // 270: badan huruf menjulur ke kanan jangkar, tulisan berjalan ke atas.
    if (putaran == 270) {
      return (x: x, y: y - lebar, w: tinggi, h: lebar, jenis: 'teks', isi: isi);
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
    // penanda pendamping, nomor tiket, dan masa berlaku tercetak bertindihan
    // sampai nomornya tidak terbaca — jarak antar baris dulu tetap 4 titik
    // untuk semua ukuran huruf, terlalu rapat begitu hurufnya membesar.
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
        contohGelang(c),
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
      final c = WristbandConfigModel(sensor: SensorMedia.celah);
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
        config: WristbandConfigModel(
            widthMm: 50,
            heightMm: 25,
            gapMm: 2.5,
            sensor: SensorMedia.celah),
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

  group('Sensor batas gelang', () {
    // `GAP` dan `BLINE` saling menggantikan. Mengirim keduanya membuat sensor
    // mana yang aktif bergantung urutan perintah — jenis kesalahan yang baru
    // terlihat saat merek gulungannya berganti.
    List<String> kepala(SensorMedia sensor, double gapMm) => perintah(
          gen.dataWristbandPrint(
            config: WristbandConfigModel(sensor: sensor, gapMm: gapMm),
            qrCode: '290809260005',
          ),
        );

    test('menyambung mengirim GAP nol, bukan diam', () {
      // Printer menyimpan setelan sensor terakhirnya — termasuk dari kalibrasi
      // tombol FEED. Diam berarti mewarisi keadaan yang tidak diketahui.
      final p = kepala(SensorMedia.menerus, 3);
      expect(p, contains('GAP 0 mm,0 mm'));
      expect(p.any((b) => b.startsWith('BLINE')), isFalse);
    });

    test('celah memakai GAP setinggi kolom Jarak', () {
      final p = kepala(SensorMedia.celah, 2.5);
      expect(p.any((b) => b.startsWith('GAP 2.5 mm')), isTrue,
          reason: p.toString());
      expect(p.any((b) => b.startsWith('BLINE')), isFalse);
    });

    test('tanda hitam memakai BLINE, dan GAP tidak ikut dikirim', () {
      final p = kepala(SensorMedia.tandaHitam, 3);
      expect(p.any((b) => b.startsWith('BLINE 3 mm')), isTrue,
          reason: p.toString());
      expect(p.any((b) => b.startsWith('GAP')), isFalse);
    });

    test('bawaannya menyambung dan bertahan disimpan', () {
      expect(WristbandConfigModel().sensor, SensorMedia.menerus);
      expect(
          WristbandConfigModel.fromJson(
                  WristbandConfigModel(sensor: SensorMedia.tandaHitam).toJson())
              .sensor,
          SensorMedia.tandaHitam);
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
      expect(perintah(contohGelang(c)), contains('SET CUTTER 1'));
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

    test('tanpa nomor dan tanggal, QR mengambil seluruh pita', () {
      // Bentuk yang dipilih outlet playground: gelang hanya berisi QR, sebesar
      // yang muat di 20mm pita bersih sebelum merek pabrik. Uji ini menjaga dua
      // hal sekaligus — QR-nya benar-benar membesar, dan tidak ada teks tersisa
      // yang diam-diam ikut tercetak.
      final media = WristbandConfigModel(
        widthMm: 25,
        heightMm: 30,
        gapMm: 0,
        marginMm: 1,
        posisi: PosisiIsi.atas,
      );

      final penuh = perintah(gen.dataWristbandPrint(
        config: media,
        qrCode: '301009260015',
        ticketNo: '301009260015',
        berlakuSampai: 's/d 10Sep26',
      ));
      final polos = perintah(gen.dataWristbandPrint(
        config: media,
        qrCode: '301009260015',
      ));

      int sel(List<String> p) => int.parse(p
          .firstWhere((b) => b.startsWith('QRCODE'))
          .substring(6)
          .split(',')[3]
          .trim());

      expect(sel(polos), greaterThan(sel(penuh)));
      expect(polos.any((b) => b.startsWith('TEXT')), isFalse);
      expect(polos.any((b) => b.startsWith('QRCODE')), isTrue);
    });

    test('gelang QR-saja tetap menghormati perataan', () {
      // Cabang QR-saja dulu memusatkan tanpa melihat perataan, dan pada gelang
      // bermerek itu berarti QR meluncur turun ke atas cetakan pabrik justru
      // pada mode yang dipilih supaya QR sebesar mungkin.
      ({int y, int sel}) qr(PosisiIsi posisi) {
        final b = perintah(gen.dataWristbandPrint(
          config: WristbandConfigModel(
            widthMm: 25,
            heightMm: 30,
            gapMm: 0,
            marginMm: 1,
            posisi: posisi,
          ),
          qrCode: '301009260015',
        )).firstWhere((b) => b.startsWith('QRCODE'));
        final a = b.substring(6).split(',');
        return (y: int.parse(a[1].trim()), sel: int.parse(a[3].trim()));
      }

      expect(qr(PosisiIsi.atas).y, lessThan(qr(PosisiIsi.tengah).y));
      expect(qr(PosisiIsi.tengah).y, lessThan(qr(PosisiIsi.bawah).y));
      // Rapat ke atas berarti kotaknya tepat di margin. Yang dikirim ke printer
      // adalah pojok simbolnya, jadi margin ditambah zona sunyi kiri-atas.
      final atas = qr(PosisiIsi.atas);
      expect(atas.y, 8 + 2 * atas.sel);
    });

    test('gelang pendamping tidak diberi penanda tercetak', () {
      // Penandanya dibuang dengan sengaja: satu baris "PENDAMPING" mendorong
      // isi sampai 26,8mm pada pita 25mm, menimpa cetakan pabrik yang justru
      // tertutup saat gelang dilipat. Pembedaan anak/pendamping tetap ada di
      // `otdtl_is_companion` dan terbaca gate saat QR dipindai.
      final p = perintah(gen.dataWristbandPrint(
        config: WristbandConfigModel(widthMm: 25, heightMm: 30, marginMm: 1),
        qrCode: '301009260016',
      ));
      expect(p.any((b) => b.startsWith('TEXT')), isFalse);
    });

    test('isi QR selalu nomor tiket apa adanya', () {
      // Gate mencari tiket dengan string hasil pindai sebagai **kunci utama**:
      // `TakeOutService.findTicket` memanggil `findById(ticketNo)` atas
      // `otdtl_no`. Satu karakter tambahan di dalam QR — durasi, tanggal,
      // pemisah apa pun — membuat pencarian gagal, dan gagalnya baru terlihat
      // saat pelanggan sudah berdiri di pintu masuk.
      //
      // Durasi bermain tidak perlu ikut: `PlaygroundTvService` membacanya dari
      // `mst_ticket.ticket_duration_minutes` saat gelang discan, dan argonya
      // memang baru mulai di gate — bukan saat gelang dicetak di kasir.
      for (final c in [
        WristbandConfigModel(),
        WristbandConfigModel(widthMm: 25, heightMm: 30, marginMm: 1),
      ]) {
        final p = perintah(gen.dataWristbandPrint(
          config: c,
          qrCode: '301009260015',
          ticketNo: '301009260015',
          berlakuSampai: 's/d 10Sep26',
        ));
        final qr = p.firstWhere((b) => b.startsWith('QRCODE'));
        expect(RegExp(r'"([^"]*)"$').firstMatch(qr)!.group(1), '301009260015');
      }
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
          ),
          c,
        );
      });

      test('$nama — cetak uji juga di dalam lembar', () {
        periksaMuat(contohGelang(c), c);
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
      ));
      final fonts = p
          .where((b) => b.startsWith('TEXT'))
          .map((b) => b.split(',')[2].replaceAll('"', ''))
          .toList();
      expect(fonts.length, 2);
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
        test('$nama — isi lengkap', () => periksaMuat(contohGelang(c), c));
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
      // Geser sejauh yang setara justru mengecilkan. Geseran memakan ruang dua
      // kali lipat jaraknya — sekali di tiap tepi — jadi 10mm menyisakan
      // sepertiga lembar dan sudah cukup untuk
      // menjatuhkan sel QR pada lembar 30mm.
      expect(ukur(cetak(dasar.salin(geserYMm: -10))).sel,
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
      // Diukur pada QR-nya: posisi QR yang dicari operator saat menggeser.
      int xQr(List<int> bytes) => int.parse(perintah(bytes)
          .firstWhere((b) => b.startsWith('QRCODE'))
          .substring(6)
          .split(',')[0]
          .trim());

      final asal = WristbandConfigModel(widthMm: 90, heightMm: 25);
      final selisih = xQr(contohGelang(asal.salin(geserXMm: 10))) -
          xQr(contohGelang(asal));
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
    test('bawaan perangkat baru = setelan terbukti di outlet (dokumen 14 §C.2)',
        () {
      final c = WristbandConfigModel.terbukti();
      expect([c.widthMm, c.heightMm, c.gapMm, c.marginMm], [25, 200, 3, 0]);
      expect([c.dpi, c.density, c.speed, c.direction], [203, 12, 2, 1]);
      expect([c.qrMaksMm, c.geserXMm, c.geserYMm, c.shiftMm], [19, 0, 0, 25]);
      expect(c.sensor, SensorMedia.tandaHitam);
      expect(c.posisi, PosisiIsi.atas);
      expect(c.potong, ModePotong.sobek);
      expect(c.putarIsi, isFalse);
      expect(c.gelangPendamping, isTrue);
    });

    test('status bawaan bertahan lewat penyimpanan dan mengabaikan pendamping',
        () {
      final simpan = WristbandConfigModel.fromJson(
          WristbandConfigModel.terbukti(gelangPendamping: false).toJson());
      expect(simpan.samaDenganTerbukti, isTrue);
      expect(simpan.salin(density: 10).samaDenganTerbukti, isFalse);
      expect(WristbandConfigModel().samaDenganTerbukti, isFalse);
    });

    test('setelan terbukti menghasilkan gelang yang muat di lembarnya', () {
      final c = WristbandConfigModel.terbukti();
      periksaMuat(contohGelang(c), c);
    });

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
  group('Gelang playground — teks menyusuri gelang', () {
    // Setelan yang sudah terbukti di Blueprint MEDIC 25mm.
    final media = WristbandConfigModel(
      widthMm: 25,
      heightMm: 200,
      gapMm: 3,
      marginMm: 0,
      qrMaksMm: 19,
      posisi: PosisiIsi.atas,
      sensor: SensorMedia.tandaHitam,
    );

    List<int> bytesGelang(
      WristbandConfigModel c, {
      String? lokasi = 'Arena Playground Bekasi',
      String? nama = 'rita',
      String? order = '0161/IV/TIX/2025',
      String? waktu = '2026-04-03 13:52:46',
    }) =>
        gen.dataGelangPlayground(
          config: c,
          qrCode: '301009260015',
          lokasi: lokasi,
          nama: nama,
          nomorOrder: order,
          waktu: waktu,
        );

    String teks(List<String> p, String isi) =>
        p.firstWhere((b) => b.startsWith('TEXT') && b.endsWith('"$isi"'));
    String qr(List<String> p) => p.firstWhere((b) => b.startsWith('QRCODE'));
    int sel(List<String> p) => int.parse(qr(p).substring(6).split(',')[3].trim());
    int putaran(String b) => int.parse(b.substring(4).split(',')[3].trim());
    int huruf(String b) =>
        int.parse(b.substring(4).split(',')[2].replaceAll('"', '').trim());
    final qrSaja =
        perintah(gen.dataWristbandPrint(config: media, qrCode: '301009260015'));

    test('semua elemen di dalam lembar dan tidak bertumpuk', () {
      periksaMuat(bytesGelang(media), media);
    });

    test('QR sama besar dengan gelang QR-saja — teks tidak mengecilkannya', () {
      expect(sel(perintah(bytesGelang(media))), sel(qrSaja));
      expect(sel(qrSaja), 7, reason: 'QR 18,4 mm pada setelan terbukti');
    });

    test('isi QR tetap nomor tiket, dan QR-nya tidak diputar', () {
      // Gate mencari tiket dengan string ini sebagai kunci utama. QR tidak
      // diputar karena jangkar QRCODE berputar berbeda antar firmware.
      final b = qr(perintah(bytesGelang(media)));
      expect(RegExp(r'"([^"]*)"$').firstMatch(b)!.group(1), '301009260015');
      expect(b.substring(6).split(',')[5].trim(), '0');
    });

    test('semua teks diputar 90 derajat — arah yang terbukti di printer', () {
      // 270 derajat pernah dipakai dan tercetak terbalik di gelang sungguhan.
      final semua = perintah(bytesGelang(media))
          .where((b) => b.startsWith('TEXT'))
          .toList();
      expect(semua.length, 4);
      expect(semua.every((b) => putaran(b) == 90), isTrue, reason: '$semua');
    });

    test('urutan sepanjang gelang: lokasi, QR, lalu nomor order', () {
      final p = perintah(bytesGelang(media));
      final yLokasi = elemen(teks(p, 'ARENA PLAYGROUND BEKASI')).y;
      final yQr = elemen(qr(p)).y;
      final yOrder = elemen(teks(p, '0161/IV/TIX/2025')).y;
      expect(yLokasi, lessThan(yQr));
      expect(yQr, lessThan(yOrder));
    });

    test('baris pertama tiap blok berada di sisi atas bacaan', () {
      // 90: badan huruf menjulur ke kiri, jadi "atas" bacaan ada di kanan.
      final p = perintah(bytesGelang(media));
      expect(elemen(teks(p, 'ARENA PLAYGROUND BEKASI')).x,
          greaterThan(elemen(teks(p, 'rita')).x));
      expect(elemen(teks(p, '0161/IV/TIX/2025')).x,
          greaterThan(elemen(teks(p, '2026-04-03 13:52:46')).x));
    });

    test('baris dalam satu blok rata ke awal bacaan yang sama', () {
      // 90 berjalan ke bawah: awal bacaan adalah ujung atas kotaknya.
      final p = perintah(bytesGelang(media));
      expect(elemen(teks(p, '0161/IV/TIX/2025')).y,
          elemen(teks(p, '2026-04-03 13:52:46')).y);
      expect(elemen(teks(p, 'ARENA PLAYGROUND BEKASI')).y,
          elemen(teks(p, 'rita')).y);
    });

    test('lokasi ditulis kapital dengan huruf lebih besar dari nama', () {
      final p = perintah(bytesGelang(media));
      expect(huruf(teks(p, 'ARENA PLAYGROUND BEKASI')),
          greaterThan(huruf(teks(p, 'rita'))));
    });

    test('baris pendamping tercetak utuh di dalam lembar', () {
      final bytes = bytesGelang(media, nama: 'Pendamping (rita)');
      expect(
          perintah(bytes).any(
              (b) => b.startsWith('TEXT') && b.endsWith('"Pendamping (rita)"')),
          isTrue);
      periksaMuat(bytes, media);
    });

    test('tanpa data teks hasilnya persis gelang QR-saja yang sudah terbukti', () {
      expect(
          perintah(bytesGelang(media,
              lokasi: null, nama: null, order: null, waktu: null)),
          qrSaja);
    });

    test('lembar terlalu pendek: teks dibuang, QR tidak mengecil', () {
      final pendek = media.salin(heightMm: 30);
      periksaMuat(bytesGelang(pendek), pendek);
      expect(
          sel(perintah(bytesGelang(pendek))),
          sel(perintah(
              gen.dataWristbandPrint(config: pendek, qrCode: '301009260015'))));
    });

    test('nama yang sangat panjang dipotong, bukan membuang seluruh blok', () {
      final p = perintah(bytesGelang(media, nama: 'x' * 80));
      expect(p.any((b) => b.startsWith('TEXT') && b.contains('x' * 32)), isTrue);
      expect(p.any((b) => b.contains('x' * 33)), isFalse);
    });

    test('geser Y memindahkan seluruh isi tanpa keluar lembar', () {
      final c = media.salin(geserYMm: 10);
      periksaMuat(bytesGelang(c), c);
      expect(
          elemen(qr(perintah(bytesGelang(c)))).y -
              elemen(qr(perintah(bytesGelang(media)))).y,
          c.dots(10));
    });
  });
}
