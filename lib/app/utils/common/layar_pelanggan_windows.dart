import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

/// Layar pelanggan untuk kasir Windows.
///
/// Di Android layar kedua digambar lewat Presentation API (plugin
/// `presentation_displays`), dan itu tidak ada padanannya di Windows. Di sini
/// layar pelanggan adalah **jendela kedua milik aplikasi yang sama**, dipasang
/// penuh di monitor yang dipilih kasir.
///
/// Jendela kedua berjalan pada engine Flutter terpisah — sama seperti
/// Presentation di Android — jadi datanya tidak bisa dibagi lewat memori.
/// Semuanya dikirim sebagai JSON lewat saluran antar-jendela, memakai bentuk
/// muatan yang persis sama dengan jalur Android supaya halaman pelanggannya
/// tidak perlu tahu sedang berjalan di mana.
class LayarPelangganWindows {
  /// Nama metode antar-jendela untuk satu pembaruan layar pelanggan.
  static const String metodeKirim = 'layar-pelanggan';

  /// Perintah agar jendela pelanggan menutup dirinya sendiri.
  ///
  /// Jendela hanya bisa ditutup dari dalam engine-nya; pengelola di jendela
  /// kasir tidak punya cara menutup jendela lain.
  static const String metodeTutup = 'layar-pelanggan-tutup';

  /// Penanda di argumen jendela: inilah yang membedakan jendela pelanggan dari
  /// jendela kasir saat `main()` dijalankan ulang untuk engine baru.
  static const String _penanda = 'layar-pelanggan';

  static const String _kunciMonitor = 'layar_pelanggan_monitor';
  static const String _kunciAktif = 'layar_pelanggan_aktif';

  final GetStorage _store = GetStorage('perangkat');

  String? _windowId;

  bool get didukung => Platform.isWindows;

  bool get terbuka => _windowId != null;

  /// Id monitor pilihan kasir, bila pernah dipilih.
  String? get monitorTersimpan {
    final nilai = _store.read(_kunciMonitor);
    return nilai is String && nilai.isNotEmpty ? nilai : null;
  }

  /// true bila kasir terakhir kali meninggalkan layar pelanggan dalam keadaan
  /// menyala — dipakai untuk membukanya lagi saat aplikasi dijalankan.
  bool get seharusnyaTerbuka => _store.read(_kunciAktif) == true;

  /// Penanda satu monitor yang dipakai menyimpan pilihan kasir.
  ///
  /// Id monitor di Windows berasal dari DeviceID kartu grafis: bisa kosong,
  /// dan dua monitor bermerek sama bisa mendapat nilai yang sama. Posisinya di
  /// desktop tidak pernah kembar — monitor tidak bisa saling menumpuk — jadi
  /// keduanya digabung.
  static String kunciMonitor(Display monitor) {
    final posisi = monitor.visiblePosition ?? Offset.zero;
    return '${monitor.id}@${posisi.dx.round()},${posisi.dy.round()}';
  }

  /// Nama monitor yang dibaca kasir di dropdown.
  static String namaMonitor(Display monitor, int urutan) {
    final ukuran = monitor.visibleSize ?? monitor.size;
    final posisi = monitor.visiblePosition ?? Offset.zero;
    final utama = posisi == Offset.zero ? ' (layar kasir)' : '';
    final nama = (monitor.name ?? '').replaceAll('\\\\.\\', '').trim();
    final label = nama.isEmpty ? 'Monitor ${urutan + 1}' : nama;
    return '$label - ${ukuran.width.round()}x${ukuran.height.round()}$utama';
  }

  Future<List<Display>> daftarMonitor() async {
    if (!didukung) return [];
    try {
      return await screenRetriever.getAllDisplays();
    } catch (e) {
      logger.safeLog('DAFTAR MONITOR GAGAL : $e');
      return [];
    }
  }

  /// Membuka jendela layar pelanggan di [idMonitor].
  ///
  /// Mengembalikan pesan kesalahan bila gagal, atau null bila berhasil.
  Future<String?> buka({String? idMonitor}) async {
    if (!didukung) return 'Layar pelanggan kedua hanya tersedia di Windows.';
    if (terbuka) return null;

    final monitors = await daftarMonitor();
    if (monitors.isEmpty) {
      return 'Tidak ada monitor yang terbaca. Periksa sambungan layar kedua.';
    }

    final diminta = idMonitor ?? monitorTersimpan;
    final pilihan = monitors.firstWhere(
      (m) => kunciMonitor(m) == diminta,
      // Tanpa pilihan tersimpan, monitor yang bukan layar kasir lebih masuk
      // akal: layar pelanggan yang terbuka di monitor kasir menutupi kasirnya.
      orElse: () => monitors.firstWhere(
        (m) => (m.visiblePosition ?? Offset.zero) != Offset.zero,
        orElse: () => monitors.first,
      ),
    );

    final posisi = pilihan.visiblePosition ?? Offset.zero;
    final ukuran = pilihan.visibleSize ?? pilihan.size;

    try {
      final jendela = await WindowController.create(
        WindowConfiguration(
          arguments: jsonEncode({
            'mode': _penanda,
            'x': posisi.dx,
            'y': posisi.dy,
            'w': ukuran.width,
            'h': ukuran.height,
          }),
          hiddenAtLaunch: true,
        ),
      );
      _windowId = jendela.windowId;
      _store.write(_kunciMonitor, kunciMonitor(pilihan));
      _store.write(_kunciAktif, true);
      // Jendela dibuat tersembunyi supaya tidak berkedip di monitor kasir
      // sebelum pindah ke monitor pelanggan; jendela itu memunculkan dirinya
      // sendiri setelah menempati posisinya. Perintah ini pengaman kalau
      // pengatur jendela di dalamnya gagal — lebih baik tampil di tempat yang
      // salah daripada layar pelanggan tinggal hitam.
      Future.delayed(const Duration(seconds: 2), () async {
        try {
          await jendela.show();
        } catch (e) {
          logger.safeLog('LAYAR PELANGGAN GAGAL DIMUNCULKAN : $e');
        }
      });
      logger.safeLog('LAYAR PELANGGAN dibuka di monitor '
          '${kunciMonitor(pilihan)} '
          '(${ukuran.width.round()}x${ukuran.height.round()} '
          'di ${posisi.dx.round()},${posisi.dy.round()}) '
          'window=${jendela.windowId}');
      return null;
    } catch (e) {
      logger.safeLog('LAYAR PELANGGAN GAGAL DIBUKA : $e');
      return 'Layar pelanggan gagal dibuka: $e';
    }
  }

  Future<void> tutup() async {
    _store.write(_kunciAktif, false);
    final id = _windowId;
    _windowId = null;
    if (id == null) return;
    try {
      await WindowController.fromWindowId(id).invokeMethod(metodeTutup);
      logger.safeLog('LAYAR PELANGGAN ditutup');
    } catch (e) {
      logger.safeLog('LAYAR PELANGGAN gagal ditutup : $e');
    }
  }

  /// Mengirim satu pembaruan ke jendela pelanggan.
  ///
  /// Diam saja bila jendelanya tidak terbuka: layar pelanggan memang boleh
  /// tidak dipakai, dan transaksi tidak boleh gagal karenanya.
  Future<void> kirim(Object? data) async {
    final id = _windowId;
    if (id == null) return;

    // Muatan yang tidak bisa diubah ke JSON adalah salah bentuk data, bukan
    // jendela yang hilang — jangan sampai jendelanya ikut dilupakan.
    final String muatan;
    try {
      muatan = jsonEncode(data);
    } catch (e) {
      logger.safeLog('MUATAN LAYAR PELANGGAN TIDAK BISA DIKIRIM : $e');
      return;
    }

    try {
      await WindowController.fromWindowId(id)
          .invokeMethod(metodeKirim, muatan);
    } catch (e) {
      // Jendela sudah ditutup orang lewat tombol X: lupakan penunjuknya supaya
      // pembaruan berikutnya tidak terus mencoba jendela yang tidak ada.
      logger.safeLog('KIRIM KE LAYAR PELANGGAN GAGAL : $e');
      _windowId = null;
    }
  }

  // ===========================================================================
  // Sisi jendela pelanggan
  // ===========================================================================

  /// Membaca argumen jendela; null berarti ini jendela kasir, bukan pelanggan.
  static Map<String, dynamic>? bacaArgumen(String argumen) {
    if (argumen.isEmpty) return null;
    try {
      final isi = jsonDecode(argumen);
      if (isi is Map && isi['mode'] == _penanda) {
        return Map<String, dynamic>.from(isi);
      }
    } catch (_) {
      // Argumen yang tidak dikenal diperlakukan sebagai jendela kasir.
    }
    return null;
  }

  /// Menempatkan jendela pelanggan memenuhi monitor yang dipilih.
  static Future<void> siapkanJendela(Map<String, dynamic> argumen) async {
    final x = (argumen['x'] as num?)?.toDouble() ?? 0;
    final y = (argumen['y'] as num?)?.toDouble() ?? 0;
    final w = (argumen['w'] as num?)?.toDouble() ?? 1280;
    final h = (argumen['h'] as num?)?.toDouble() ?? 720;
    try {
      await windowManager.setTitle('Layar Pelanggan');
      // Urutannya penting: diletakkan dulu di monitor tujuan, ditampilkan, baru
      // dipenuhkan. Penuh layar mengikuti monitor tempat jendelanya berada saat
      // itu, dan jendela yang masih tersembunyi tidak selalu ikut dipenuhkan.
      await windowManager.setBounds(Rect.fromLTWH(x, y, w, h));
      await windowManager.show();
      await windowManager.setFullScreen(true);
    } catch (e) {
      logger.safeLog('SIAPKAN JENDELA PELANGGAN GAGAL : $e');
    }
  }

  /// Memasang penerima data di jendela pelanggan.
  ///
  /// [onData] menerima muatan yang bentuknya sama dengan jalur Android: sebuah
  /// Map hasil `CustomerDisplay.toJson()`, atau String penanda seperti
  /// `refreshAds`.
  static Future<void> pasangPenerima(
      Future<void> Function(Object? data) onData) async {
    try {
      final jendela = await WindowController.fromCurrentEngine();
      await jendela.setWindowMethodHandler((call) async {
        switch (call.method) {
          case metodeKirim:
            final mentah = call.arguments;
            await onData(mentah is String ? jsonDecode(mentah) : mentah);
            break;
          case metodeTutup:
            await windowManager.close();
            break;
        }
        return null;
      });
    } catch (e) {
      logger.safeLog('PENERIMA LAYAR PELANGGAN GAGAL DIPASANG : $e');
    }
  }
}

LayarPelangganWindows layarPelangganWindows = LayarPelangganWindows();
