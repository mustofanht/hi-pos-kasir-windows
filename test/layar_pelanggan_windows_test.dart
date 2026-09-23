import 'dart:convert';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:jaya_propertiy/app/utils/common/layar_pelanggan_windows.dart';
import 'package:screen_retriever/screen_retriever.dart';

/// Layar pelanggan di monitor kedua untuk kasir Windows (permintaan 23 Sep 2026).
///
/// Yang diuji di sini adalah bagian yang tidak menyentuh jendela: penanda
/// monitor, namanya di dropdown, dan pembacaan argumen jendela — sisanya hanya
/// bisa diperiksa dengan menjalankan aplikasinya.
Display monitor({
  String id = '',
  String? name,
  Size size = const Size(1920, 1080),
  Offset posisi = Offset.zero,
  num skala = 1,
}) {
  return Display(
    id: id,
    name: name,
    size: size,
    visiblePosition: posisi,
    visibleSize: size,
    scaleFactor: skala,
  );
}

void main() {
  group('Penanda monitor', () {
    test('dua monitor bermerek sama tetap dibedakan', () {
      // Id monitor di Windows diambil dari DeviceID: monitor kembar bisa
      // mendapat nilai yang sama, dan monitor tertentu tidak mendapat id sama
      // sekali. Tanpa posisi, pilihan kasir bisa jatuh ke layar yang salah.
      final kasir = monitor(id: r'MONITOR\GSM5B1F');
      final pelanggan = monitor(
        id: r'MONITOR\GSM5B1F',
        posisi: const Offset(1920, 0),
      );
      expect(
        LayarPelangganWindows.kunciMonitor(kasir),
        isNot(LayarPelangganWindows.kunciMonitor(pelanggan)),
      );
    });

    test('penanda monitor yang sama tidak berubah antar pembacaan', () {
      final sekarang = monitor(id: 'A', posisi: const Offset(1920, 0));
      final nanti = monitor(id: 'A', posisi: const Offset(1920, 0));
      expect(
        LayarPelangganWindows.kunciMonitor(sekarang),
        LayarPelangganWindows.kunciMonitor(nanti),
      );
    });

    test('monitor tanpa id masih punya penanda', () {
      expect(
        LayarPelangganWindows.kunciMonitor(monitor(posisi: const Offset(0, 1080))),
        isNotEmpty,
      );
    });
  });

  group('Nama monitor di dropdown', () {
    test('layar kasir ditandai supaya tidak salah pilih', () {
      final nama = LayarPelangganWindows.namaMonitor(monitor(), 0);
      expect(nama, contains('layar kasir'));
      expect(nama, contains('1920x1080'));
    });

    test('monitor kedua tidak ditandai layar kasir', () {
      final nama = LayarPelangganWindows.namaMonitor(
        monitor(posisi: const Offset(1920, 0)),
        1,
      );
      expect(nama, isNot(contains('layar kasir')));
    });

    test('awalan perangkat Windows tidak ikut dibaca kasir', () {
      final nama = LayarPelangganWindows.namaMonitor(
        monitor(name: r'\\.\DISPLAY2', posisi: const Offset(1920, 0)),
        1,
      );
      expect(nama, startsWith('DISPLAY2'));
    });

    test('tanpa nama perangkat dipakai nomor urut', () {
      expect(
        LayarPelangganWindows.namaMonitor(monitor(posisi: const Offset(1920, 0)), 1),
        startsWith('Monitor 2'),
      );
    });
  });

  group('Argumen jendela', () {
    // Engine jendela kedua menjalankan main() dari awal dengan tiga argumen
    // tetap dari plugin: penanda, id jendela, lalu argumen pembuatnya.
    List<String> argumenJendelaKedua(String isi) => ['multi_window', '1', isi];

    test('jendela kasir dikenali dari argumen kosong', () {
      // Jendela kasir dijalankan tanpa argumen. Salah baca di sini berarti
      // kasirnya yang berubah jadi layar pelanggan dan aplikasi tidak bisa
      // dipakai sama sekali.
      expect(LayarPelangganWindows.bacaArgumen([]), isNull);
    });

    test('argumen baris perintah biasa tetap jendela kasir', () {
      expect(LayarPelangganWindows.bacaArgumen(['--observatory-port=0']), isNull);
    });

    test('argumen yang bukan JSON dianggap jendela kasir', () {
      expect(
        LayarPelangganWindows.bacaArgumen(argumenJendelaKedua('bukan json')),
        isNull,
      );
    });

    test('argumen JSON tanpa penanda dianggap jendela kasir', () {
      expect(
        LayarPelangganWindows.bacaArgumen(
          argumenJendelaKedua(jsonEncode({'mode': 'lain'})),
        ),
        isNull,
      );
    });

    test('argumen jendela pelanggan terbaca', () {
      final hasil = LayarPelangganWindows.bacaArgumen(
        argumenJendelaKedua(jsonEncode({'mode': 'layar-pelanggan'})),
      );
      expect(hasil, isNotNull);
      expect(hasil!['mode'], 'layar-pelanggan');
    });
  });

  group('Bidang monitor', () {
    test('monitor tanpa penskalaan dipakai apa adanya', () {
      final bidang = LayarPelangganWindows.bidangFisik(monitor(
        posisi: const Offset(1920, 0),
      ));
      expect(bidang.left, 1920);
      expect(bidang.width, 1920);
      expect(bidang.height, 1080);
    });

    test('penskalaan Windows dikembalikan ke piksel nyata', () {
      // Pembaca monitor memberi ukuran logis; pemindah jendela memakai piksel
      // nyata. Tanpa dikalikan kembali, di monitor 125% jendelanya berhenti di
      // tengah layar dan menyisakan bagian kanan-bawah kosong.
      final bidang = LayarPelangganWindows.bidangFisik(monitor(
        size: const Size(1536, 864),
        posisi: const Offset(1536, 0),
        skala: 1.25,
      ));
      expect(bidang.left, 1920);
      expect(bidang.width, 1920);
      expect(bidang.height, 1080);
    });
  });
}
