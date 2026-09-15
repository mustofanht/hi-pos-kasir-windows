import 'dart:async';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_print_util.dart';
import 'package:jaya_propertiy/app/utils/common/printer_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/gate/gate_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';

/// Keluar manual (PRD Poin 5): pengajuan oleh operator gate dan keputusan oleh
/// penyetuju, dalam satu controller karena keduanya memakai data yang sama.
///
/// Kode persetujuan sengaja ditampilkan besar dan disertai hitung mundur:
/// operator harus membacakannya lewat radio, dan ia perlu tahu berapa lama lagi
/// kode itu masih berlaku sebelum permintaannya kedaluwarsa.
class ManualExitPageController extends GetxController {
  final _service = MainService();

  final isLoading = false.obs;
  final isProcessing = false.obs;
  final isPrinting = false.obs;

  /// Apakah user yang login boleh memutuskan. Dibaca sekali saat controller
  /// dibuat — kewenangan tidak berubah di tengah sesi; kalau role diubah admin,
  /// user harus login ulang, dan server tetap memeriksanya sendiri.
  final bolehMemutuskan = sessionUtil.isVerificator().obs;

  // Pengajuan
  final reasons = <ManualExitReasonEntity>[].obs;
  final reasonCode = RxnString(null);
  final terakhirDiajukan = Rxn<ManualExitEntity>(null);
  final sisaDetik = RxInt(0);

  // Persetujuan
  final pending = <ManualExitEntity>[].obs;

  Timer? _timerHitungMundur;

  @override
  void onInit() {
    super.onInit();
    muatAlasan();
    muatPending();
  }

  @override
  void onClose() {
    _timerHitungMundur?.cancel();
    super.onClose();
  }

  Future<void> muatAlasan() async {
    try {
      final hasil = await _service.gate.manualExitReasons(authToken: sessionUtil.getToken());
      hasil.fold(
        (gagal) => logger.safeLog('MANUAL EXIT alasan gagal : $gagal'),
        (sukses) => reasons.assignAll(sukses.data ?? []),
      );
    } catch (e) {
      logger.safeLog('MANUAL EXIT alasan gagal : $e');
    }
  }

  Future<void> muatPending() async {
    isLoading.value = true;
    try {
      final hasil = await _service.gate.pendingManualExit(
        authToken: sessionUtil.getToken(),
        locationId: sessionUtil.getLocationId(),
      );
      hasil.fold(
        (gagal) {
          logger.safeLog('MANUAL EXIT pending gagal : $gagal');
          pending.clear();
        },
        (sukses) => pending.assignAll(sukses.data ?? []),
      );
    } catch (e) {
      logger.safeLog('MANUAL EXIT pending gagal : $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> ajukan({
    required String ticketNo,
    String? catatan,
  }) async {
    if (ticketNo.trim().isEmpty) {
      alert.warning('Belum Lengkap', 'Nomor tiket wajib diisi.');
      return;
    }
    if (reasonCode.value == null) {
      alert.warning('Belum Lengkap', 'Pilih alasan keluar manual.');
      return;
    }
    if (isProcessing.value) return;

    isProcessing.value = true;
    try {
      final hasil = await _service.gate.requestManualExit(
        authToken: sessionUtil.getToken(),
        ticketNo: ticketNo.trim(),
        reasonCode: reasonCode.value!,
        notes: catatan,
      );
      hasil.fold(
        (gagal) => alert.error('Tidak Bisa Diajukan', gagal),
        (sukses) {
          terakhirDiajukan.value = sukses.data;
          _mulaiHitungMundur();
          muatPending();
        },
      );
    } catch (e) {
      logger.safeLog('MANUAL EXIT ajukan gagal : $e');
      alert.error('Gagal', 'Permintaan tidak bisa dikirim.');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<bool> putuskan({
    required ManualExitEntity permintaan,
    required String kode,
    required bool setuju,
    String? alasanTolak,
  }) async {
    if (isProcessing.value) return false;
    if (kode.trim().isEmpty) {
      alert.warning('Kode Kosong', 'Masukkan kode yang disebutkan operator gate.');
      return false;
    }
    if (!setuju && (alasanTolak == null || alasanTolak.trim().isEmpty)) {
      alert.warning('Alasan Kosong', 'Alasan penolakan wajib diisi.');
      return false;
    }

    isProcessing.value = true;
    try {
      final hasil = await _service.gate.decideManualExit(
        authToken: sessionUtil.getToken(),
        requestId: permintaan.requestId!,
        approvalCode: kode.trim(),
        approve: setuju,
        rejectionReason: alasanTolak,
      );
      return hasil.fold(
        (gagal) {
          alert.error(setuju ? 'Tidak Bisa Disetujui' : 'Tidak Bisa Ditolak', gagal);
          return false;
        },
        (sukses) {
          alert.success('Berhasil', sukses.message ?? '');
          return true;
        },
      );
    } catch (e) {
      logger.safeLog('MANUAL EXIT keputusan gagal : $e');
      alert.error('Gagal', 'Keputusan tidak bisa diproses.');
      return false;
    } finally {
      isProcessing.value = false;
      await muatPending();
    }
  }

  /// Cetak ulang kertas QR tiket dengan **nomor tiket yang sama**, selalu di
  /// printer struk (thermal) — tidak pernah di printer gelang, walaupun tiketnya
  /// tiket playground. Cetak ulang ini untuk pelanggan yang tiket/gelangnya rusak
  /// dan perlu bukti QR yang bisa dipindai; mengeluarkan gelang baru juga akan
  /// memotong stok gelang lagi.
  ///
  /// Datanya dibaca dari server tanpa mengubah status order.
  Future<void> cetakUlangTiket(String ticketNo) async {
    final nomor = ticketNo.trim();
    if (nomor.isEmpty) {
      alert.warning('Belum Lengkap', 'Isi nomor tiket yang akan dicetak ulang.');
      return;
    }
    if (isPrinting.value) return;
    if (printerUtil.currPrinter == null) {
      alert.error('Printer Struk Belum Siap',
          'Pilih printer struk di Setting terlebih dahulu.');
      printerUtil.connectPrinter();
      return;
    }

    isPrinting.value = true;
    try {
      final hasil = await _service.gate.ticketForReprint(
        authToken: sessionUtil.getToken(),
        ticketNo: nomor,
      );
      final tiket = hasil.fold((gagal) {
        alert.error('Tidak Bisa Dicetak', gagal);
        return null;
      }, (sukses) => sukses.data);
      if (tiket == null || tiket.ticketNo == null) return;

      if (!await _konfirmasiCetak(tiket)) return;

      final user = await common.getUser(authToken: sessionUtil.getToken());
      final data = await generatePrintUtil.dataGatePrint(
        locationName: user?.locationName,
        paperSize: PaperSize.mm80,
        orderNo: tiket.orderNo ?? '',
        reffNo: tiket.reffNo ?? '',
        pakOf: 1,
        pakTotal: 1,
        qrCode: tiket.ticketNo!,
        expiredAt: tiket.activeDate == null
            ? '-'
            : dateTimeUtil.getFormattedDate(
                date: tiket.activeDate!,
                format: dateFormat.dateDDMMMMYYYY,
              ),
        ticketName: tiket.ticketName,
        isCompanion: tiket.isCompanion,
        paymentDate: tiket.orderDate,
      );
      await printerUtil.print(printerUtil.currPrinter!, data);
      alert.success('Tercetak', 'Tiket ${tiket.ticketNo} dicetak ulang di printer struk.');
    } catch (e) {
      logger.safeLog('CETAK ULANG TIKET gagal : $e');
      alert.error('Gagal', 'Tiket tidak bisa dicetak ulang. Periksa sambungan printer struk.');
    } finally {
      isPrinting.value = false;
    }
  }

  Future<bool> _konfirmasiCetak(ManualExitTicketEntity tiket) async {
    final berlaku = tiket.activeDate == null
        ? '-'
        : dateTimeUtil.getFormattedDate(
            date: tiket.activeDate!,
            format: dateFormat.dateDDMMMMYYYY,
          );
    final yakin = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cetak Ulang Tiket?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No. tiket : ${tiket.ticketNo}'),
            Text('Tiket     : ${tiket.ticketName ?? '-'}'
                '${tiket.pendamping ? ' (pendamping)' : ''}'),
            Text('Order     : ${tiket.orderNo ?? '-'}'),
            Text('Berlaku   : $berlaku'),
            const SizedBox(height: 8),
            const Text('Dicetak di printer struk dengan nomor tiket yang sama.'),
            if (tiket.alreadyTakeout) ...[
              const SizedBox(height: 8),
              const Text(
                'Perhatian: tiket ini sudah tercatat keluar.',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Cetak'),
          ),
        ],
      ),
    );
    return yakin == true;
  }

  void bersihkanPengajuan() {
    _timerHitungMundur?.cancel();
    terakhirDiajukan.value = null;
    reasonCode.value = null;
    sisaDetik.value = 0;
  }

  void _mulaiHitungMundur() {
    _timerHitungMundur?.cancel();
    final e = terakhirDiajukan.value;
    if (e == null) return;
    sisaDetik.value = e.sisaWaktu.inSeconds;
    _timerHitungMundur = Timer.periodic(const Duration(seconds: 1), (t) {
      final sisa = e.sisaWaktu.inSeconds;
      sisaDetik.value = sisa > 0 ? sisa : 0;
      if (sisa <= 0) {
        t.cancel();
        muatPending();
      }
    });
  }
}
