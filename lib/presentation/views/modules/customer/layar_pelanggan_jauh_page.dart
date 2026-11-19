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
  runApp(const LayarPelangganJauhApp());
}

/// Aplikasi untuk perangkat yang menjadi layar pelanggan terpisah: tanpa
/// login dan tanpa halaman kasir, hanya pairing lalu halaman pelanggan.
class LayarPelangganJauhApp extends StatelessWidget {
  const LayarPelangganJauhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Layar Pelanggan',
      debugShowCheckedModeBanner: false,
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
    _lp.mulai();
    // Hitung mundur masa berlaku kode.
    _detik = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _lp.status.value == StatusLayarJauh.menunggu)
        setState(() {});
    });
  }

  @override
  void dispose() {
    _detik?.cancel();
    super.dispose();
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

  Future<void> _tanyaKeluar() async {
    final ya = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Keluar dari mode layar pelanggan?'),
        content: const Text(
            'Perangkat ini akan dilepas dari kasir dan kembali ke halaman login. '
            'Untuk memakainya lagi sebagai layar pelanggan, pasangkan ulang dengan kode baru.'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Keluar')),
        ],
      ),
    );
    if (ya != true) return;
    await _lp.nonaktifkan();
    await _layarPenuh(false);
    kembaliKeKasir?.call();
  }

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);
    return Obx(() {
      final s = _lp.status.value;
      final pernahTerpasang =
          s == StatusLayarJauh.terpasang || s == StatusLayarJauh.terputus;
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
                behavior: HitTestBehavior.translucent,
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
        sisa =
            '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
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
                Image.asset(assetsConstant.imgLogo,
                    width: 120, height: 120, fit: BoxFit.contain),
                const SizedBox(height: 12),
                Text('Layar Pelanggan',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorStyle.black)),
                const SizedBox(height: 4),
                Text(_lp.namaPerangkat,
                    style: const TextStyle(fontSize: 16, color: Colors.grey)),
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
                    Text(
                        'Berlaku $sisa — kode baru dibuat otomatis bila habis.',
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ] else ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    s == StatusLayarJauh.memintaKode
                        ? 'Meminta kode pairing…'
                        : 'Menyambung ke server…',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
                if (_lp.pesan.value != null) ...[
                  const SizedBox(height: 16),
                  Text(_lp.pesan.value!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red)),
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
