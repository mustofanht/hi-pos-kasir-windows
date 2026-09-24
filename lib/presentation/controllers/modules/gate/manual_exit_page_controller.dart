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

/// Keluar manual (PRD Poin 5): dipakai operator gate untuk mengeluarkan
/// pelanggan yang tidak bisa keluar lewat scan.
///
/// Sejak persetujuan supervisor dihapus, pengajuan LANGSUNG berlaku — server
/// menutup sesi tiket saat itu juga. Karena itu tidak ada lagi kode
/// persetujuan, hitung mundur, maupun antrean menunggu di sini. Yang tersisa
/// sebagai kontrol adalah jejak audit di `trn_manual_exit_log`, yang bisa
/// dilihat di back-office (Gate > Keluar Manual).
class ManualExitPageController extends GetxController {
  final _service = MainService();

  final isProcessing = false.obs;
  final isPrinting = false.obs;

  final reasons = <ManualExitReasonEntity>[].obs;
  final reasonCode = RxnString(null);

  @override
  void onInit() {
    super.onInit();
    muatAlasan();
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

  /// Mengembalikan true bila tiket benar-benar ditandai keluar, supaya layar
  /// tahu kapan boleh mengosongkan formulir.
  Future<bool> ajukan({
    required String ticketNo,
    String? catatan,
  }) async {
    if (ticketNo.trim().isEmpty) {
      alert.warning('Belum Lengkap', 'Nomor tiket wajib diisi.');
      return false;
    }
    if (reasonCode.value == null) {
      alert.warning('Belum Lengkap', 'Pilih alasan keluar manual.');
      return false;
    }
    if (isProcessing.value) return false;

    isProcessing.value = true;
    try {
      final hasil = await _service.gate.requestManualExit(
        authToken: sessionUtil.getToken(),
        ticketNo: ticketNo.trim(),
        reasonCode: reasonCode.value!,
        notes: catatan,
      );
      return hasil.fold(
        (gagal) {
          alert.error('Tidak Bisa Diproses', gagal);
          return false;
        },
        (sukses) {
          // Server langsung menutup sesi tiket — tidak ada lagi kode yang perlu
          // dibacakan maupun antrean yang perlu ditunggu.
          alert.success('Berhasil', sukses.message ?? 'Tiket sudah ditandai keluar.');
          reasonCode.value = null;
          return true;
        },
      );
    } catch (e) {
      logger.safeLog('MANUAL EXIT ajukan gagal : $e');
      alert.error('Gagal', 'Permintaan tidak bisa dikirim.');
      return false;
    } finally {
      isProcessing.value = false;
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
    // Printer aktif ternyata printer gelang. Ini bukan kesalahan mengetik:
    // kasir yang sedang menguji gelang memang pernah memilih perangkat gelang
    // sebagai printer aktif, dan kalau diteruskan, lembar QR tercetak di pita
    // gelang — terbuang, dan tidak terbaca.
    final gelang = printerUtil.wristbandPrinter;
    if (gelang != null && gelang.kunci == printerUtil.currPrinter!.kunci) {
      alert.error(
        'Printer Aktif Masih Printer Gelang',
        'Cetak ulang tiket hanya ke printer struk. Ganti printer aktif di '
            'Setting ke printer struk, lalu ulangi.',
      );
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
}
