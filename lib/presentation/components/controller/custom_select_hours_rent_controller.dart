import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/domain/entities/transaction/transaction_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';

class CustomSelectHoursRentController extends GetxController {
  final AddonEntity entitiy;
  CustomSelectHoursRentController({required this.entitiy});

  final totalHoursController = TextEditingController();
  final isExtraTime = RxBool(false);

  final selectedTransactionExtraTime = Rxn<TransactionEntity>(null);

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
  final minHours = RxInt(0);

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    totalHoursController.text = '0';
    logger.safeLog('PRODUCT ENTITY : ${entitiy.toJson()}');
    if (entitiy.minRentPrd != null) {
      int hours = entitiy.minRentPrd! ~/ 60;
      minHours.value = hours;
      totalHoursController.text = hours.toString();
    }
    setEndDateTime();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  doMinHours() {
    int totalHours = int.tryParse(totalHoursController.text) ?? 0;
    if (totalHours > minHours.value) {
      if (totalHours > 0) {
        totalHours--;
        totalHoursController.text = totalHours.toString();
        setEndDateTime();
      }
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
      endTime.value = startTime.value;
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
        onNext: (TransactionEntity selected) {
          Get.back();
          selectedTransactionExtraTime.value = selected;
        },
      );
    }
  }
}
