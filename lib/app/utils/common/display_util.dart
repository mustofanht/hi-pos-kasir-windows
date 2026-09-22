import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
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
    await displayManager
        .transferDataToPresentation(data)!
        .then((value) => logger.safeLog('Send To Second Display : ${value}'))
        .onError((error, stackTrace) =>
            logger.safeLog('Erros Send to second display : ${error}'));
  }

  displayCustomer(Object? val) async {
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
