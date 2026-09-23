import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

/// Layar pelanggan untuk kasir Windows.
///
/// Di Android layar kedua digambar lewat Presentation API (plugin
/// `presentation_displays`), dan itu tidak ada padanannya di Windows. Di sini
/// layar pelanggan adalah **jendela kedua milik aplikasi yang sama**, dipasang
/// memenuhi monitor yang dipilih kasir.
///
/// Jendela kedua berjalan pada engine Flutter terpisah — sama seperti
/// Presentation di Android — jadi datanya tidak bisa dibagi lewat memori.
/// Semuanya dikirim sebagai JSON lewat saluran antar-jendela, memakai bentuk
/// muatan yang persis sama dengan jalur Android supaya halaman pelanggannya
/// tidak perlu tahu sedang berjalan di mana.
class LayarPelangganWindows {
  /// Nama metode antar-jendela untuk satu pembaruan layar pelanggan.
  static const String metodeKirim = 'layar-pelanggan';

  /// Penanda di argumen jendela: inilah yang membedakan jendela pelanggan dari
  /// jendela kasir saat `main()` dijalankan ulang untuk engine baru.
  static const String _penanda = 'layar-pelanggan';

  /// Argumen pertama yang selalu dikirim plugin ke engine jendela kedua.
  static const String penandaJendelaKedua = 'multi_window';

  static const String _kunciMonitor = 'layar_pelanggan_monitor';
  static const String _kunciAktif = 'layar_pelanggan_aktif';

  final GetStorage _store = GetStorage('perangkat');

  int? _windowId;

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

  /// Letak dan ukuran monitor dalam piksel nyata.
  ///
  /// Pembaca monitor memberi ukuran logis — sudah dibagi penskalaan Windows —
  /// sedangkan pemindah jendela memakai piksel nyata. Tanpa dikalikan kembali,
  /// di monitor berpenskalaan 125% jendelanya berhenti di tengah layar dan
  /// menyisakan bagian kanan-bawah kosong.
  static Rect bidangFisik(Display monitor) {
    final skala = (monitor.scaleFactor ?? 1).toDouble();
    final posisi = monitor.visiblePosition ?? Offset.zero;
    final ukuran = monitor.size;
    return Rect.fromLTWH(
      posisi.dx * skala,
      posisi.dy * skala,
      ukuran.width * skala,
      ukuran.height * skala,
    );
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

    final bidang = bidangFisik(pilihan);

    try {
      // Jendela baru belum tampil sampai diminta: ditempatkan dulu di monitor
      // pelanggan, baru ditampilkan, supaya tidak berkedip di layar kasir.
      final jendela = await DesktopMultiWindow.createWindow(jsonEncode({
        'mode': _penanda,
      }));
      await jendela.setTitle('Layar Pelanggan');
      await jendela.setFrame(bidang);
      await jendela.show();
      _windowId = jendela.windowId;
      _store.write(_kunciMonitor, kunciMonitor(pilihan));
      _store.write(_kunciAktif, true);
      logger.safeLog('LAYAR PELANGGAN dibuka di monitor '
          '${kunciMonitor(pilihan)} '
          '(${bidang.width.round()}x${bidang.height.round()} '
          'di ${bidang.left.round()},${bidang.top.round()}) '
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
      await WindowController.fromWindowId(id).close();
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
      await DesktopMultiWindow.invokeMethod(id, metodeKirim, muatan);
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

  /// Membaca argumen `main()`; null berarti ini jendela kasir.
  ///
  /// Engine jendela kedua menjalankan `main()` dari awal dengan tiga argumen
  /// tetap dari plugin: penanda, id jendela, lalu argumen dari pembuatnya.
  static Map<String, dynamic>? bacaArgumen(List<String> args) {
    if (args.length < 3 || args.first != penandaJendelaKedua) return null;
    try {
      final isi = jsonDecode(args[2]);
      if (isi is Map && isi['mode'] == _penanda) {
        return Map<String, dynamic>.from(isi);
      }
    } catch (_) {
      // Argumen yang tidak dikenal diperlakukan sebagai jendela kasir.
    }
    return null;
  }

  /// Merapikan jendela pelanggan dari dalam engine-nya sendiri.
  ///
  /// Letak dan ukurannya sudah diatur jendela kasir saat membuat jendela ini;
  /// yang belum adalah menghilangkan bilah judul supaya pelanggan tidak bisa
  /// menggeser atau menutup layarnya. Kalau gagal, jendelanya tetap benar —
  /// hanya masih berbingkai — jadi kegagalannya cukup dicatat.
  static Future<void> siapkanJendela() async {
    try {
      await windowManager.setFullScreen(true);
    } catch (e) {
      logger.safeLog('LAYAR PELANGGAN GAGAL DIPENUHKAN : $e');
    }
  }

  /// Memasang penerima data di jendela pelanggan.
  ///
  /// [onData] menerima muatan yang bentuknya sama dengan jalur Android: sebuah
  /// Map hasil `CustomerDisplay.toJson()`, atau String penanda seperti
  /// `refreshAds`.
  static void pasangPenerima(Future<void> Function(Object? data) onData) {
    DesktopMultiWindow.setMethodHandler(
      (MethodCall call, int fromWindowId) async {
        if (call.method != metodeKirim) return null;
        final mentah = call.arguments;
        await onData(mentah is String ? jsonDecode(mentah) : mentah);
        return null;
      },
    );
  }
}

LayarPelangganWindows layarPelangganWindows = LayarPelangganWindows();
