import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/auth/auth_token.dart';
import 'package:jaya_propertiy/domain/entities/otorisasi/otorisasi_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';

/// Meminta otorisasi leader/SPV sebelum aksi kasir dijalankan — cetak ulang
/// struk, cetak tiket di menu Cek Order, dan pemakaian deposit (syspos V136).
///
/// Bentuknya **antre persetujuan**, sama seperti void: kasir mengajukan, leader
/// menyetujui di back office, baru aksinya jalan. Karena itu kasir menunggu di
/// depan satu kotak yang statusnya ikut berubah sendiri — tanpa itu ia akan
/// menekan tombol aksinya berulang kali dan mengajukan permintaan beruntun.
///
/// Dipakai dari controller seperti ini:
///
/// ```dart
/// final izin = await otorisasiUtil.minta(
///   authToken: _authToken,
///   jenis: OtorisasiEntity.jenisCetakUlangStruk,
///   ref: orderNo,
///   keterangan: namaPembeli,
/// );
/// if (izin == null) return;          // ditolak / dibatalkan / gagal
/// await cetakStruk();                 // aksinya
/// await otorisasiUtil.tandaiDipakai(authToken: _authToken, id: izin);
/// ```
///
/// Urutannya penting: penandaan "dipakai" dilakukan SESUDAH aksinya berhasil.
/// Kalau ditandai lebih dulu lalu printer macet, kasir kehilangan izinnya untuk
/// pekerjaan yang belum terjadi dan harus mengganggu leader lagi.
class OtorisasiUtil {
  final MainService _service = MainService();

  /// Jeda antar-pemeriksaan selama kasir menunggu.
  ///
  /// Lima detik: cukup cepat supaya kasir tidak merasa layarnya mati, cukup
  /// jarang supaya satu loket yang menunggu lima menit tidak mengirim ratusan
  /// permintaan.
  static const Duration jedaPeriksa = Duration(seconds: 5);

  /// Mengajukan izin dan menunggu keputusan leader.
  ///
  /// Mengembalikan **id persetujuan** bila aksinya boleh dijalankan, atau
  /// `null` bila ditolak, kedaluwarsa, dibatalkan kasir, atau gagal
  /// dihubungkan. Pemanggilnya hanya perlu memeriksa null.
  Future<int?> minta({
    required AuthToken authToken,
    required String jenis,
    required String ref,
    String? keterangan,
    int? locationId,
  }) async {
    final hasil = await _service.otorisasi.ajukan(
      authToken: authToken,
      jenis: jenis,
      ref: ref,
      keterangan: keterangan,
      locationId: locationId,
    );

    OtorisasiEntity? izin;
    String? galat;
    hasil.fold((l) => galat = l, (r) => izin = r);

    if (izin == null) {
      alert.error('Otorisasi gagal', galat ?? 'Permintaan tidak bisa dikirim.');
      return null;
    }
    // Izin yang sudah disetujui dan belum dipakai langsung dipakai: kasir yang
    // mengajukan lalu printernya macet tidak perlu meminta izin kedua kali.
    if (izin!.bolehJalan) {
      return izin!.id;
    }
    if (izin!.ditolak || izin!.kedaluwarsa) {
      alert.error('Tidak bisa dilanjutkan', izin!.pesan);
      return null;
    }

    return _tunggu(authToken: authToken, awal: izin!, jenis: jenis, ref: ref);
  }

  /// Menandai izin sudah dipakai.
  ///
  /// Kegagalannya **tidak** dilemparkan: aksinya sudah terjadi, dan memberi
  /// tahu kasir bahwa "pencatatan izin gagal" hanya akan membuatnya mencetak
  /// ulang. Yang dilakukan: dicatat di log supaya bisa ditelusuri.
  Future<void> tandaiDipakai({
    required AuthToken authToken,
    required int id,
  }) async {
    try {
      final hasil = await _service.otorisasi.pakai(authToken: authToken, id: id);
      hasil.fold(
        (l) => logger.safeLog('OTORISASI gagal ditandai dipakai ($id): $l'),
        (r) => logger.safeLog('OTORISASI $id ditandai dipakai'),
      );
    } catch (e) {
      logger.safeLog('OTORISASI gagal ditandai dipakai ($id): $e');
    }
  }

  /// Void milik kasir ini yang belum disetujui; null bila gagal diperiksa.
  ///
  /// Kegagalan memeriksa dikembalikan sebagai null, BUKAN sebagai "terblokir":
  /// jaringan yang sedang terganggu tidak boleh menghentikan penjualan, dan
  /// server tetap menolak transaksinya kalau memang ada void tertunda.
  Future<VoidTertundaEntity?> voidTertunda({required AuthToken authToken}) async {
    try {
      final hasil = await _service.otorisasi.voidTertunda(authToken: authToken);
      VoidTertundaEntity? data;
      hasil.fold((l) => logger.safeLog('VOID TERTUNDA gagal diperiksa: $l'),
          (r) => data = r);
      return data;
    } catch (e) {
      logger.safeLog('VOID TERTUNDA gagal diperiksa: $e');
      return null;
    }
  }

  /// Kotak tunggu yang statusnya diperiksa ulang sendiri tiap 5 detik.
  Future<int?> _tunggu({
    required AuthToken authToken,
    required OtorisasiEntity awal,
    required String jenis,
    required String ref,
  }) async {
    final keadaan = awal.obs;
    final memeriksa = false.obs;
    final selesai = Completer<int?>();
    Timer? timer;

    void tutup(int? id) {
      if (selesai.isCompleted) return;
      timer?.cancel();
      selesai.complete(id);
      if (Get.isDialogOpen ?? false) Get.back();
    }

    Future<void> periksa() async {
      if (memeriksa.value || selesai.isCompleted) return;
      memeriksa.value = true;
      try {
        final hasil = await _service.otorisasi
            .periksa(authToken: authToken, jenis: jenis, ref: ref);
        hasil.fold(
          (l) => logger.safeLog('OTORISASI gagal diperiksa: $l'),
          (r) {
            if (r == null) return;
            keadaan.value = r;
            if (r.bolehJalan) {
              tutup(r.id);
            } else if (r.ditolak || r.kedaluwarsa) {
              // Dibiarkan terbuka dengan pesan penolakannya: kasir harus
              // membaca alasannya, bukan menemukan kotaknya hilang begitu saja.
              timer?.cancel();
            }
          },
        );
      } finally {
        memeriksa.value = false;
      }
    }

    timer = Timer.periodic(jedaPeriksa, (_) => periksa());

    await Get.dialog(
      PopScope(
        // Tombol kembali tidak boleh meninggalkan timer yang masih hidup.
        canPop: false,
        onPopInvokedWithResult: (_, __) => tutup(null),
        child: AlertDialog(
          title: const Text('Menunggu Otorisasi Leader'),
          content: Obx(() {
            final k = keadaan.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(k.jenisLabel ?? jenis,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Referensi: $ref'),
                if ((k.keterangan ?? '').isNotEmpty) Text('${k.keterangan}'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (k.menunggu)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    if (k.menunggu) const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        k.pesan,
                        style: TextStyle(
                          color: k.ditolak || k.kedaluwarsa
                              ? Colors.red
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Minta leader membuka menu Order Management → Otorisasi Kasir '
                  'di back office. Permintaan berlaku 30 menit.',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            );
          }),
          actions: [
            TextButton(
              onPressed: () => tutup(null),
              child: const Text('Tutup'),
            ),
            Obx(() => TextButton(
                  onPressed: memeriksa.value ? null : periksa,
                  child: Text(memeriksa.value ? 'Memeriksa…' : 'Periksa sekarang'),
                )),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    // Kotaknya ditutup dengan cara lain (mis. Get.back dari luar): timer tetap
    // harus mati, kalau tidak ia memeriksa terus sepanjang aplikasi hidup.
    tutup(null);
    return selesai.future;
  }
}

OtorisasiUtil otorisasiUtil = OtorisasiUtil();
