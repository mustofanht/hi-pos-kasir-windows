import 'dart:async';

import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/device_simulation_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/survey/survey_reason_entity.dart';

/// Survei kepuasan pelanggan di layar pelanggan.
///
/// Beberapa keputusan yang membentuk alurnya:
///
/// - **Nilai 4-5 langsung terkirim, tanpa layar tambahan.** Pelanggan yang puas
///   tidak punya alasan untuk bertahan di depan layar; meminta konfirmasi hanya
///   menurunkan jumlah jawaban yang masuk.
/// - **Nilai 1-3 menampilkan pilihan alasan.** Di situlah satu-satunya informasi
///   yang bisa ditindaklanjuti berada.
/// - **Selalu ada cara keluar** (tombol lewati + tutup otomatis). Layar pelanggan
///   dipakai bergantian oleh orang berikutnya; survei yang menyangkut di layar
///   akan menghambat transaksi berikutnya, dan itu jauh lebih merugikan daripada
///   satu jawaban yang hilang.
/// - **Gagal kirim tidak ditampilkan sebagai kesalahan pelanggan.** Mereka tidak
///   bisa berbuat apa-apa soal itu; kesalahannya dicatat di log, layarnya tetap
///   mengucapkan terima kasih.
class CustomerSurveyController extends GetxController {
  /// Satu-satunya pintu untuk mendapatkan controller ini.
  ///
  /// Didaftarkan **permanen**. GetX secara bawaan membuang controller yang
  /// didaftarkan saat sebuah halaman dibangun begitu halaman itu ditutup — dan
  /// di mode simulasi, jendela layar pelanggan memang dibuka-tutup terus.
  /// Tanpa `permanent`, survei yang sedang menunggu ikut hilang setiap kali
  /// jendelanya ditutup, sehingga tidak pernah bisa diisi pada perangkat berlayar
  /// tunggal.
  static CustomerSurveyController get instance =>
      Get.isRegistered<CustomerSurveyController>()
          ? Get.find<CustomerSurveyController>()
          : Get.put(CustomerSurveyController(), permanent: true);

  static const Duration _durasiTerimaKasih = Duration(seconds: 3);
  static const Duration _batasDiam = Duration(seconds: 45);

  /// Di perangkat sungguhan layar pelanggan selalu terlihat, jadi 45 detik sudah
  /// cukup. Saat disimulasikan, satu layar dipakai bergantian — penguji harus
  /// kembali dari layar kasir dulu, dan batas 45 detik akan menutup survei
  /// sebelum sempat dilihat.
  static const Duration _batasDiamSimulasi = Duration(minutes: 5);

  Duration get _batasTutupOtomatis =>
      deviceSimulation.customerDisplay ? _batasDiamSimulasi : _batasDiam;

  final _service = MainService();

  final tampil = RxBool(false);
  final rating = RxnInt(null);
  final reasonCode = RxnString(null);
  final reasons = <SurveyReasonEntity>[].obs;
  final mengirim = RxBool(false);
  final selesai = RxBool(false);

  String? _orderNo;
  Timer? _timerTutup;
  Timer? _timerDiam;

  @override
  void onClose() {
    _timerTutup?.cancel();
    _timerDiam?.cancel();
    super.onClose();
  }

  /// Dipanggil saat pembayaran dinyatakan berhasil di layar pelanggan.
  Future<void> buka({String? orderNo}) async {
    _orderNo = orderNo;
    rating.value = null;
    reasonCode.value = null;
    selesai.value = false;
    mengirim.value = false;
    tampil.value = true;
    _mulaiTimerDiam();
    await _muatAlasan();
  }

  void tutup() {
    _timerTutup?.cancel();
    _timerDiam?.cancel();
    tampil.value = false;
    rating.value = null;
    reasonCode.value = null;
    selesai.value = false;
  }

  /// Nilai dipilih. Puas (4-5) langsung dikirim; sisanya menunggu alasan.
  Future<void> pilihNilai(int nilai) async {
    rating.value = nilai;
    reasonCode.value = null;
    _mulaiTimerDiam();
    if (nilai >= 4) {
      await kirim();
    }
  }

  void pilihAlasan(String? code) {
    // Ketuk ulang pada alasan yang sama membatalkannya — pelanggan sering salah
    // tekan, dan tidak ada jalan mundur membuat mereka menutup survei begitu saja.
    reasonCode.value = reasonCode.value == code ? null : code;
    _mulaiTimerDiam();
  }

  Future<void> kirim() async {
    final nilai = rating.value;
    if (nilai == null || mengirim.value) return;

    mengirim.value = true;
    _timerDiam?.cancel();

    final locationId = sessionUtil.getLocationId();
    if (locationId == null) {
      logger.safeLog('SURVEI: lokasi aktif tidak diketahui, jawaban tidak dikirim');
      _tampilkanTerimaKasih();
      return;
    }

    try {
      final hasil = await _service.survey.submit(
        authToken: sessionUtil.getToken(),
        locationId: locationId,
        rating: nilai,
        reasonCode: reasonCode.value,
        orderNo: _orderNo,
        cashier: sessionUtil.getUserName(),
      );
      hasil.fold(
        (gagal) => logger.safeLog('SURVEI gagal dikirim : $gagal'),
        (sukses) => logger.safeLog('SURVEI terkirim : ${sukses.message}'),
      );
    } catch (e) {
      logger.safeLog('SURVEI gagal dikirim : $e');
    }

    _tampilkanTerimaKasih();
  }

  void _tampilkanTerimaKasih() {
    mengirim.value = false;
    selesai.value = true;
    _timerTutup?.cancel();
    _timerTutup = Timer(_durasiTerimaKasih, tutup);
  }

  /// Survei menutup diri bila ditinggal, supaya tidak menghalangi pelanggan
  /// berikutnya.
  void _mulaiTimerDiam() {
    _timerDiam?.cancel();
    _timerDiam = Timer(_batasTutupOtomatis, tutup);
  }

  Future<void> _muatAlasan() async {
    if (reasons.isNotEmpty) return;
    try {
      final hasil = await _service.survey.getReasons(authToken: sessionUtil.getToken());
      hasil.fold(
        (gagal) => logger.safeLog('SURVEI gagal memuat alasan : $gagal'),
        (sukses) => reasons.assignAll(sukses.data ?? []),
      );
    } catch (e) {
      logger.safeLog('SURVEI gagal memuat alasan : $e');
    }
  }
}
