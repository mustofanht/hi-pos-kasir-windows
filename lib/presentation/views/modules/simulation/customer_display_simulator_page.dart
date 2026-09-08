import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/customer_display_bus.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/views/modules/customer_page.dart';

/// Layar pelanggan versi simulasi: halaman yang sama persis dengan yang tampil
/// di monitor kedua, hanya saja dibuka sebagai jendela di aplikasi kasir.
///
/// Sengaja memakai [CustomerPage] apa adanya, bukan salinan yang disederhanakan.
/// Salinan akan menyimpang dari aslinya dalam hitungan minggu, dan simulasi yang
/// menyimpang dari perangkat asli lebih berbahaya daripada tidak ada simulasi:
/// ia membuat orang yakin sesuatu sudah benar padahal belum diuji.
///
/// Susunannya [Stack], bukan [Column] dengan AppBar. [CustomerPage] menghitung
/// tata letaknya dari tinggi layar penuh (`layoutStyle.screenHeight`), jadi
/// memberi dia ruang yang lebih pendek langsung membuat isinya melimpah — dan
/// yang terlihat rusak justru simulasinya, bukan halaman aslinya. Keterangan dan
/// tombol tutup karena itu diapungkan di atasnya.
class CustomerDisplaySimulatorPage extends StatefulWidget {
  const CustomerDisplaySimulatorPage({super.key});

  @override
  State<CustomerDisplaySimulatorPage> createState() =>
      _CustomerDisplaySimulatorPageState();
}

class _CustomerDisplaySimulatorPageState
    extends State<CustomerDisplaySimulatorPage> {
  Worker? _listener;
  int _diterima = 0;
  bool _tampilkanKeterangan = true;

  @override
  void initState() {
    super.initState();

    // Datanya sudah diterapkan ke controller oleh DisplayUtil begitu kasir
    // mengirimnya — termasuk saat jendela ini tertutup. Di sini cukup menghitung
    // pembaruannya; menerapkan ulang hanya akan memproses payload yang sama dua kali.
    _listener = ever<CustomerDisplayPayload?>(customerDisplayBus.terakhir,
        (payload) {
      if (payload == null || !mounted) return;
      logger.safeLog('SIMULASI layar pelanggan menerima : ${payload.data}');
      setState(() => _diterima = payload.urutan);
    });
  }

  @override
  void dispose() {
    _listener?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Layar pelanggan mendapat seluruh area, persis seperti di monitor kedua.
          const Positioned.fill(child: CustomerPage()),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            right: 8,
            child: _panelKendali(),
          ),
        ],
      ),
    );
  }

  Widget _panelKendali() {
    return Material(
      color: colorStyle.black.withOpacity(0.75),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.desktop_windows, size: 16, color: colorStyle.white),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Layar Pelanggan (Simulasi) · '
                    '${_diterima == 0 ? "menunggu data kasir" : "$_diterima pembaruan"}',
                    style: TextStyle(color: colorStyle.white, fontSize: 12),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: _tampilkanKeterangan
                      ? 'Sembunyikan keterangan'
                      : 'Tampilkan keterangan',
                  onPressed: () => setState(
                      () => _tampilkanKeterangan = !_tampilkanKeterangan),
                  icon: Icon(
                    _tampilkanKeterangan
                        ? Icons.expand_less
                        : Icons.info_outline,
                    size: 18,
                    color: colorStyle.white,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Tutup',
                  onPressed: Get.back,
                  icon: Icon(Icons.close, size: 18, color: colorStyle.white),
                ),
              ],
            ),
            if (_tampilkanKeterangan)
              Padding(
                padding: const EdgeInsets.only(right: 6, bottom: 4),
                child: Text(
                  'Isinya sama dengan yang tampil di layar pelanggan, tetapi '
                  'ukuran dan orientasinya mengikuti perangkat ini — tata letak '
                  'tetap wajib dicek sekali di monitor sungguhan.',
                  style: TextStyle(
                    color: colorStyle.white.withOpacity(0.85),
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
