import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';

class CustomSelectHoursRentController extends GetxController {
  CustomSelectHoursRentController();

  final totalHoursController = TextEditingController();
  final isExtraTime = RxBool(true);
  
  final selectedExtraTime = RxString('');

  final startTime = Rxn<DateTime>(
    DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      DateTime.now().hour,
      DateTime.now().minute,
      0,
    ),
  );
  final endTime = Rxn<DateTime>(null);

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    totalHoursController.text = '0';
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  doMinHours() {
    int totalHours = int.tryParse(totalHoursController.text) ?? 0;
    if (totalHours > 0) {
      totalHours--;
      totalHoursController.text = totalHours.toString();
      setEndDateTime();
    }
  }

  doAddHours() {
    int totalHours = int.tryParse(totalHoursController.text) ?? 0;
    totalHours++;
    totalHoursController.text = totalHours.toString();
    setEndDateTime();
  }

  setEndDateTime() {
    int totalHours = int.tryParse(totalHoursController.text) ?? 0;
    logger.safeLog('totalHours : $totalHours');
    if (startTime.value != null) {
      DateTime calculatedEndTime =
          startTime.value!.add(Duration(hours: totalHours));

      endTime.value = DateTime(
        calculatedEndTime.year,
        calculatedEndTime.month,
        calculatedEndTime.day,
        calculatedEndTime.hour,
        calculatedEndTime.minute,
        0,
      );
      logger.safeLog('END TIME : ${endTime.value}');
      update();
    }
  }

  doCheckIsExtraTime() {
    isExtraTime.value = !isExtraTime.value;
    update();
  }

  doSelectTransactionBefore() {
    if (isExtraTime.value) {
      dialog.selectListTransaction(
        onNext: () {
          Get.back();
          selectedExtraTime.value = '1';
        },
      );
    }
  }
}
