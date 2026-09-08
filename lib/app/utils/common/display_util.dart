import 'package:jaya_propertiy/app/utils/common/customer_display_bus.dart';
import 'package:jaya_propertiy/app/utils/common/device_simulation_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/customer/customer_sale_cart_page_controller.dart';
import 'package:presentation_displays/display.dart';
import 'package:presentation_displays/displays_manager.dart';

class DisplayUtil {
  DisplayManager displayManager = DisplayManager();
  List<Display?> displays = [];

  getDisplay() async {
    final values = await displayManager.getDisplays();
    displays.clear();
    displays.addAll(values!);
  }

  // hideDisplay(int? displayId) {
  //   if (displayId != null) {
  //     for (final display in displays) {
  //       if (display?.displayId == displayId) {
  //         displayManager.hideSecondaryDisplay(displayId: displayId);
  //       }
  //     }
  //   }
  // }

  showDisplay(String? displayId) {
    if (displayId != null) {
      for (final display in displays) {
        if (display?.a == displayId) {
          displayManager.showSecondaryDisplay(
              displayId: displayId, routerName: "presentation");
        }
      }
    }
  }

  transferData(Object? data) async {
    // Saat disimulasikan, "layar kedua" adalah jendela di dalam aplikasi ini,
    // jadi datanya dilewatkan lewat bus — bukan method channel yang tidak akan
    // dijawab siapa pun bila memang tidak ada perangkat kedua.
    if (deviceSimulation.customerDisplay) {
      _terapkanSimulasi(data);
      logger.safeLog('Send To Second Display (SIMULASI) : $data');
      return;
    }
    await displayManager
        .transferDataToPresentation(data)!
        .then((value) => logger.safeLog('Send To Second Display : ${value}'))
        .onError((error, stackTrace) =>
            logger.safeLog('Erros Send to second display : ${error}'));
  }

  displayCustomer(Object? val) async {
    if (deviceSimulation.customerDisplay) {
      _terapkanSimulasi(val);
      return;
    }
    await getDisplay();
    logger.safeLog('list display : ${displays}');
    if (displays.isNotEmpty) {
      for (var element in displays) {
        String? id = element?.a;
        if (id != null) {
          logger.safeLog('Display ID : ${id}');
          logger.safeLog('Display NAME : ${element?.d}');
          if (int.parse(id) != 0) {
            // await hideDisplay(id);
            await showDisplay(id);
            await transferData(val);
          }
        } else {
          logger.safeLog('ID DISPLAY NULL');
        }
      }
    }
  }

  /// Terapkan data ke layar pelanggan versi simulasi.
  ///
  /// Datanya dimasukkan LANGSUNG ke controller, bukan sekadar dititipkan ke bus.
  /// Pada perangkat sungguhan layar kedua selalu menyala; di simulasi, satu-satunya
  /// layar dipakai bergantian — jendela layar pelanggan hampir selalu tertutup
  /// tepat ketika kasir mengirim datanya. Kalau penerapannya menunggu jendela itu
  /// terbuka, seluruh transaksi akan terlewat dan jendelanya tampak kosong saat
  /// akhirnya dibuka.
  ///
  /// Bus tetap diisi untuk penghitung "n pembaruan diterima" di jendela simulator.
  void _terapkanSimulasi(Object? data) {
    customerDisplayBus.push(data);
    if (data == null) return;
    CustomerSaleCartPageController.instance.updateDataCustomer(data);
  }

  updateSecondDisplay(Object val) async {
    // await displayCustomer(val);
    // logger.safeLog('TEST ${displayManager.connectedDisplaysChangedStream}');
    logger.safeLog('Value To Second Display :${val}');
    await transferData(val);
  }
}

DisplayUtil displayUtil = DisplayUtil();
