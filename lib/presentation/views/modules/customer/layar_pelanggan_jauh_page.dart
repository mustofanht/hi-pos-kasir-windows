import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/layar_pelanggan_jarak_jauh.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/app/utils/translation/app_translation.dart';
import 'package:jaya_propertiy/presentation/views/modules/customer_page.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:window_manager/window_manager.dart';

/// Kembali ke aplikasi kasir setelah keluar dari mode layar pelanggan.
/// Diisi `main.dart` (yang memiliki `MyApp`) supaya berkas ini tidak perlu
/// mengimpornya.
VoidCallback? kembaliKeKasir;

/// Jadikan perangkat ini layar pelanggan terpisah (V165) dan langsung pindah
/// ke modenya. Dipanggil dari halaman login.
Future<void> masukModeLayarPelanggan({String? nama}) async {
  await layarPelangganPerangkat.aktifkan(nama: nama);
  if (Platform.isWindows) await windowManager.ensureInitialized();
  runApp(LayarPelangganJauhApp());
}

/// Aplikasi untuk perangkat yang menjadi layar pelanggan terpisah: tanpa
/// login dan tanpa halaman kasir, hanya pairing lalu halaman pelanggan.
class LayarPelangganJauhApp extends StatelessWidget {
  LayarPelangganJauhApp({super.key});

  // Kunci sendiri, bukan Get.key bawaan: lihat catatan di MyApp. Tanpa ini
  // Navigator halaman login ikut terbawa dan halaman pairing tidak tampil.
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Layar Pelanggan',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _messengerKey,
      theme: theme.light(),
      translations: AppTranslation(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('id', 'ID'),
      fallbackLocale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID')],
      home: const LayarPelangganJauhPage(),
    );
  }
}

class LayarPelangganJauhPage extends StatefulWidget {
  const LayarPelangganJauhPage({super.key});

  @override
  State<LayarPelangganJauhPage> createState() => _LayarPelangganJauhPageState();
}

class _LayarPelangganJauhPageState extends State<LayarPelangganJauhPage> {
  final _lp = layarPelangganPerangkat;
  Timer? _detik;

  @override
  void initState() {
    super.initState();
    _layarPenuh(true);
    _kunciLayar(true);
    _lp.mulai();
    // Hitung mundur masa berlaku kode.
    _detik = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _lp.status.value == StatusLayarJauh.menunggu) setState(() {});
    });
  }

  @override
  void dispose() {
    _detik?.cancel();
    super.dispose();
  }

  static const _kanalKunci = MethodChannel('hipos/kunci_layar');

  /// Kunci layar selama mode ini: di Android aplikasi disematkan (screen
  /// pinning) dan layar dijaga tetap menyala; di Windows jendela selalu di
  /// atas dan tidak bisa ditutup dengan Alt+F4. Satu-satunya jalan keluar
  /// adalah tekan lama sudut kiri atas.
  Future<void> _kunciLayar(bool kunci) async {
    try {
      if (Platform.isAndroid) {
        await _kanalKunci.invokeMethod(kunci ? 'kunci' : 'buka');
      } else if (Platform.isWindows) {
        await windowManager.setPreventClose(kunci);
        await windowManager.setAlwaysOnTop(kunci);
      }
    } catch (e) {
      // Kunci hanya pengaman tambahan; halaman tetap jalan tanpa itu.
      debugPrint('LAYAR JAUH kunci layar gagal : $e');
    }
  }

  Future<void> _layarPenuh(bool penuh) async {
    try {
      if (Platform.isAndroid) {
        await SystemChrome.setEnabledSystemUIMode(
            penuh ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge);
      } else if (Platform.isWindows) {
        await windowManager.setFullScreen(penuh);
      }
    } catch (_) {
      // Layar penuh hanya kenyamanan; jangan sampai menggagalkan halaman.
    }
  }

  bool _keluar = false;

  Future<void> _tanyaKeluar() async {
    if (_keluar) return;
    final pilihan = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Keluar dari layar pelanggan?'),
        content: const Text(
            'Tutup aplikasi: pemasangan ke kasir tetap tersimpan, saat dibuka lagi '
            'langsung menjadi layar pelanggan.\n\n'
            'Kembali ke login: perangkat dilepas dari kasir. Untuk memakainya lagi '
            'sebagai layar pelanggan, pasangkan ulang dengan kode baru.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: 'batal'), child: const Text('Batal')),
          TextButton(onPressed: () => Get.back(result: 'login'), child: const Text('Kembali ke login')),
          TextButton(onPressed: () => Get.back(result: 'tutup'), child: const Text('Tutup aplikasi')),
        ],
      ),
    );
    if (pilihan == 'tutup') {
      _keluar = true;
      _lp.berhenti();
      await _kunciLayar(false);
      await _tutupAplikasi();
    } else if (pilihan == 'login') {
      _keluar = true;
      // Melepas di server tidak ditunggu: perangkat langsung kembali ke login
      // walau internetnya lambat.
      unawaited(_lp.nonaktifkan());
      await _kunciLayar(false);
      await _layarPenuh(false);
      kembaliKeKasir?.call();
    }
  }

  Future<void> _tutupAplikasi() async {
    if (Platform.isWindows) {
      try {
        await windowManager.setFullScreen(false);
        await windowManager.destroy();
      } catch (_) {}
      exit(0);
    }
    await SystemNavigator.pop();
    // Beberapa tablet (mode kiosk/launcher) mengabaikan pop.
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);
    // Tombol kembali Android tidak boleh menutup layar pelanggan.
    return PopScope(canPop: false, child: _isi());
  }

  Widget _isi() {
    return Obx(() {
      final s = _lp.status.value;
      final pernahTerpasang = s == StatusLayarJauh.terpasang || s == StatusLayarJauh.terputus;
      if (pernahTerpasang) {
        return Stack(
          children: [
            const Positioned.fill(child: CustomerPage(jarakJauh: true)),
            if (s == StatusLayarJauh.terputus)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: const Text(
                    'Menyambung ulang ke kasir…',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            // Pintu keluar tersembunyi: tekan lama sudut kiri atas.
            Positioned(
              left: 0,
              top: 0,
              width: 72,
              height: 72,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onLongPress: _tanyaKeluar,
              ),
            ),
          ],
        );
      }
      return _pairing(s);
    });
  }

  Widget _pairing(StatusLayarJauh s) {
    final kode = _lp.kode.value;
    final sampai = _lp.berlakuSampai.value;
    String? sisa;
    if (sampai != null) {
      final d = sampai.difference(DateTime.now());
      if (!d.isNegative) {
        sisa = '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
      }
    }
    final siapDipasang = s == StatusLayarJauh.menunggu && kode != null;

    return Scaffold(
      backgroundColor: colorStyle.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(assetsConstant.imgLogo, width: 120, height: 120, fit: BoxFit.contain),
                const SizedBox(height: 12),
                Text('Layar Pelanggan',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorStyle.black)),
                const SizedBox(height: 4),
                Text(_lp.namaPerangkat, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 24),
                if (siapDipasang) ...[
                  const Text(
                    'Di perangkat kasir buka Setting › Layar Pelanggan Terpisah,\n'
                    'lalu ketik atau pindai kode ini:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${kode.substring(0, 3)} ${kode.substring(3)}',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6,
                          color: colorStyle.blue,
                        ),
                      ),
                      const SizedBox(width: 32),
                      QrImageView(
                        data: kode,
                        version: QrVersions.auto,
                        size: 160,
                        backgroundColor: Colors.white,
                      ),
                    ],
                  ),
                  if (sisa != null) ...[
                    const SizedBox(height: 8),
                    Text('Berlaku $sisa — kode baru dibuat otomatis bila habis.',
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ] else ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    s == StatusLayarJauh.memintaKode ? 'Meminta kode pairing…' : 'Menyambung ke server…',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
                if (_lp.pesan.value != null) ...[
                  const SizedBox(height: 16),
                  Text(_lp.pesan.value!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 32),
                TextButton.icon(
                  onPressed: _tanyaKeluar,
                  icon: const Icon(Icons.logout),
                  label: const Text('Keluar dari mode layar pelanggan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
