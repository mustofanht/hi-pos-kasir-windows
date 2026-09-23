import 'dart:io';

import 'package:jaya_propertiy/app/utils/common/layar_pelanggan_windows.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:presentation_displays/display.dart';
import 'package:presentation_displays/displays_manager.dart';

class DisplayUtil {
  DisplayManager displayManager = DisplayManager();
  List<Display?> displays = [];

  /// Layar kedua versi Android (Presentation API).
  ///
  /// Plugin `presentation_displays` hanya punya implementasi Android. Di
  /// Windows layar pelanggan adalah jendela kedua aplikasi — lihat
  /// [LayarPelangganWindows] — jadi seluruh jalur Presentation dilewati, bukan
  /// dibiarkan melempar MissingPluginException dari layar splash.
  bool get _pakaiPresentation => Platform.isAndroid;

  getDisplay() async {
    if (!_pakaiPresentation) return;
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
    if (!_pakaiPresentation) return;
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
    if (Platform.isWindows) {
      await layarPelangganWindows.kirim(data);
      return;
    }
    if (!_pakaiPresentation) return;
    await displayManager
        .transferDataToPresentation(data)!
        .then((value) => logger.safeLog('Send To Second Display : ${value}'))
        .onError((error, stackTrace) =>
            logger.safeLog('Erros Send to second display : ${error}'));
  }

  displayCustomer(Object? val) async {
    if (Platform.isWindows) {
      // Jendela pelanggan dibuka dari menu Setting (atau otomatis saat aplikasi
      // dijalankan); di sini cukup mengirimkan keadaan terakhirnya.
      await layarPelangganWindows.kirim(val);
      return;
    }
    if (!_pakaiPresentation) return;
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

  updateSecondDisplay(Object val) async {
    // await displayCustomer(val);
    // logger.safeLog('TEST ${displayManager.connectedDisplaysChangedStream}');
    logger.safeLog('Value To Second Display :${val}');
    await transferData(val);
  }
}

DisplayUtil displayUtil = DisplayUtil();
