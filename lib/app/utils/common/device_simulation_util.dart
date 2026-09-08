import 'package:get_storage/get_storage.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';

/// Mode simulasi perangkat keras.
///
/// Fitur BXRink Phase 1 menyentuh dua perangkat yang belum ada di tangan tim:
/// printer gelang dan layar pelanggan. Tanpa keduanya, pengembangan berhenti
/// menunggu barang datang. Mode ini menggantikan perangkat itu dengan tiruan:
/// hasil cetak ditangkap dan ditampilkan sebagai pratinjau, layar pelanggan
/// dibuka sebagai jendela di dalam aplikasi.
///
/// Dua saklar terpisah karena kebutuhannya memang bisa berbeda — printer sungguhan
/// sudah ada tapi layar kedua belum, atau sebaliknya.
///
/// Sifatnya sengaja **mati secara bawaan** dan menampilkan penanda mencolok saat
/// menyala, supaya tidak ada perangkat produksi yang diam-diam berjalan dengan
/// printer tiruan.
class DeviceSimulationUtil {
  static final GetStorage _store = GetStorage("sessions");

  bool get printer => _store.read(constant.simulatePrinter) == true;

  bool get customerDisplay => _store.read(constant.simulateCustomerDisplay) == true;

  /// true bila salah satu saklar menyala — dipakai untuk penanda di layar.
  bool get anyActive => printer || customerDisplay;

  void setPrinter(bool value) {
    _store.write(constant.simulatePrinter, value);
    logger.safeLog('SIMULASI PRINTER : $value');
  }

  void setCustomerDisplay(bool value) {
    _store.write(constant.simulateCustomerDisplay, value);
    logger.safeLog('SIMULASI LAYAR PELANGGAN : $value');
  }

  void disableAll() {
    setPrinter(false);
    setCustomerDisplay(false);
  }
}

DeviceSimulationUtil deviceSimulation = DeviceSimulationUtil();
