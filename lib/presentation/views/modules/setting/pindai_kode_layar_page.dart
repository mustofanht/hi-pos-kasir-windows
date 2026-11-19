import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Kamera untuk memindai QR pairing yang tampil di layar pelanggan terpisah
/// (V165). Mengembalikan kode 6 angka lewat `Get.back`, atau `null` bila batal.
///
/// Hanya Android: paket kameranya tidak mendukung Windows, jadi tombolnya
/// disembunyikan di sana.
class PindaiKodeLayarPage extends StatefulWidget {
  const PindaiKodeLayarPage({super.key});

  /// Buka kamera dan tunggu hasilnya.
  static Future<String?> buka() async => await Get.to<String>(() => const PindaiKodeLayarPage());

  @override
  State<PindaiKodeLayarPage> createState() => _PindaiKodeLayarPageState();
}

class _PindaiKodeLayarPageState extends State<PindaiKodeLayarPage> {
  final _kamera = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _selesai = false;
  String? _peringatan;

  @override
  void dispose() {
    _kamera.dispose();
    super.dispose();
  }

  void _terdeteksi(BarcodeCapture hasil) {
    if (_selesai) return;
    for (final b in hasil.barcodes) {
      final isi = (b.rawValue ?? '').trim();
      final kode = isi.replaceAll(RegExp(r'\D'), '');
      if (kode.length == 6 && RegExp(r'^[\d\s]+$').hasMatch(isi)) {
        _selesai = true;
        Get.back(result: kode);
        return;
      }
    }
    // QR lain (mis. struk atau tiket) ikut terbaca: beri tahu, tetap menunggu.
    if (mounted) setState(() => _peringatan = 'Bukan QR layar pelanggan. Arahkan ke kode di tablet.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Pindai Kode Layar Pelanggan'),
        actions: [
          IconButton(
            tooltip: 'Senter',
            icon: const Icon(Icons.flash_on),
            onPressed: () => _kamera.toggleTorch(),
          ),
          IconButton(
            tooltip: 'Ganti kamera',
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _kamera.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _kamera,
            onDetect: _terdeteksi,
            errorBuilder: (context, error, child) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  error.errorCode == MobileScannerErrorCode.permissionDenied
                      ? 'Izin kamera ditolak. Izinkan kamera untuk aplikasi ini di '
                          'Pengaturan Android, atau ketik kodenya manual.'
                      : 'Kamera tidak bisa dibuka (${error.errorCode.name}). '
                          'Ketik kodenya manual.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: Text(
              _peringatan ?? 'Arahkan kamera ke QR yang tampil di layar pelanggan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _peringatan == null ? Colors.white : Colors.amber,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
