import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/gate/gate_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';

/// TakeOut: checkout pelanggan yang pulang lebih awal (PRD Poin 9).
///
/// Dua cara menemukan pelanggan, dan keduanya memang perlu: daftar aktif untuk
/// keadaan normal, pencarian untuk saat kasir hanya memegang secarik nomor atau
/// nama. Memaksa lewat satu jalur saja akan membuat salah satu keadaan itu jadi
/// menyusahkan.
class TakeOutPageController extends GetxController {
  final _service = MainService();

  final isLoading = false.obs;
  final isProcessing = false.obs;
  final daftar = <TakeOutCustomerEntity>[].obs;
  final kataKunci = RxString('');
  final modeCari = RxBool(false);

  @override
  void onInit() {
    super.onInit();
    muatAktif();
  }

  Future<void> muatAktif() async {
    modeCari.value = false;
    kataKunci.value = '';
    isLoading.value = true;
    try {
      final hasil = await _service.gate.activeCustomers(
        authToken: sessionUtil.getToken(),
        locationId: sessionUtil.getLocationId(),
      );
      hasil.fold(
        (gagal) {
          logger.safeLog('TAKEOUT daftar aktif gagal : $gagal');
          alert.error('Gagal', gagal);
          daftar.clear();
        },
        (sukses) => daftar.assignAll(sukses.data ?? []),
      );
    } catch (e) {
      logger.safeLog('TAKEOUT daftar aktif gagal : $e');
      alert.error('Gagal', 'Tidak bisa memuat daftar pelanggan aktif.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cari(String keyword) async {
    kataKunci.value = keyword;
    if (keyword.trim().length < 3) {
      // Batas 3 huruf ditegakkan juga di server; di sini supaya kasir tidak
      // menunggu jaringan hanya untuk mendapat penolakan.
      alert.warning('Kata Kunci Terlalu Pendek', 'Ketik minimal 3 huruf.');
      return;
    }
    modeCari.value = true;
    isLoading.value = true;
    try {
      final hasil = await _service.gate.searchCustomers(
        authToken: sessionUtil.getToken(),
        keyword: keyword.trim(),
        locationId: sessionUtil.getLocationId(),
      );
      hasil.fold(
        (gagal) {
          alert.error('Gagal', gagal);
          daftar.clear();
        },
        (sukses) => daftar.assignAll(sukses.data ?? []),
      );
    } catch (e) {
      logger.safeLog('TAKEOUT cari gagal : $e');
      alert.error('Gagal', 'Pencarian tidak bisa dijalankan.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Jalankan checkout. Mengembalikan hasilnya bila berhasil, null bila gagal —
  /// pemanggil yang memutuskan cara menampilkannya.
  Future<TakeOutResultEntity?> checkout(String ticketNo, String? alasan) async {
    if (isProcessing.value) return null;
    isProcessing.value = true;
    try {
      final hasil = await _service.gate.executeTakeOut(
        authToken: sessionUtil.getToken(),
        ticketNo: ticketNo,
        reason: alasan,
      );
      return hasil.fold(
        (gagal) {
          alert.error('Tidak Bisa Checkout', gagal);
          return null;
        },
        (sukses) => sukses.data,
      );
    } catch (e) {
      logger.safeLog('TAKEOUT eksekusi gagal : $e');
      alert.error('Gagal', 'Checkout tidak bisa diproses.');
      return null;
    } finally {
      isProcessing.value = false;
      await (modeCari.value ? cari(kataKunci.value) : muatAktif());
    }
  }
}
