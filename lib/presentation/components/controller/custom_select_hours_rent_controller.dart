import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/data/models/cart/cart_rent_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/auth/auth_token.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/domain/entities/transaction/transaction_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';

class CustomSelectHoursRentController extends GetxController {
  final AddonEntity entitiy;
  final CartRentModel? detailModel;
  final AuthToken authToken;
  CustomSelectHoursRentController({
    required this.entitiy,
    this.detailModel,
    required this.authToken,
  });

  final _service = MainService();

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
  final minStartTime = Rxn<DateTime>(null);
  final endTime = Rxn<DateTime>(null);
  final minHours = RxInt(0);

  final isLoading = false.obs;

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
    isLoading.value = true;
    totalHoursController.text = '0';
    logger.safeLog('PRODUCT ENTITY : ${entitiy.toJson()}');

    await getLastDateTransactionProduct();

    if (entitiy.minRentPrd != null) {
      // int hours = entitiy.minRentPrd! ~/ 60;
      int hours = entitiy.minRentPrd!;
      minHours.value = hours;
      totalHoursController.text = hours.toString();
    }

    if (detailModel != null) {
      isExtraTime.value = detailModel!.isExtraTime!;
      selectedTransactionExtraTime.value = detailModel?.transactionExtra;
      if (selectedTransactionExtraTime.value?.endDate != null) {
        startTime.value = selectedTransactionExtraTime.value?.endDate!;
        minHours.value = 0;
      } else {
        startTime.value = detailModel?.startDate;
      }
      totalHoursController.text = detailModel!.totalHours.toString();
    }

    setEndDateTime();

    isLoading.value = false;
    update();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  getLastDateTransactionProduct() async {
    try {
      var result;
      result = await _service.transaction.getLastDateTransactionProduct(
        authToken: authToken,
        productId: entitiy.productId!,
      );

      result.fold(
        (l) {
          logger.safeLog(l);
        },
        (r) {
          logger.safeLog(r.data);
          if (r.data != null) {
            DateTime lastTransactionDate = r.data;
            if (lastTransactionDate.isAfter(DateTime.now())) {
              logger.safeLog('LAST TRANSACTION DATE : $lastTransactionDate');
              startTime.value = r.data;
            }
            minStartTime.value = lastTransactionDate;
          }
        },
      );
    } catch (e) {
      logger.safeLog(e);
    }
    update();
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
      logger.safeLog('START TIME : ${startTime.value}');
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
        entitiy: entitiy,
        authToken: authToken,
        onNext: (TransactionEntity selected) {
          Get.back();
          selectedTransactionExtraTime.value = selected;
          if (selected.startDate != null) {
            startTime.value = selected.endDate!;
            totalHoursController.text = '0';
            minHours.value = 0;
            setEndDateTime();
          }
          update();
        },
      );
    }
  }

  Future<bool> checkhour() async {
    bool isValid = false;
    try {
      var result;
      result = await _service.sale.addonService.cekhour(
        authToken: authToken,
        orderAddId: entitiy.productId!,
        startDate: startTime.value!.toIso8601String(),
        endDate: endTime.value!.toIso8601String(),
      );

      result.fold(
        (l) {
          logger.safeLog(l);
          alert.warning('Warning', l);
          isValid = false;
        },
        (r) {
          logger.safeLog(r.data);
          isValid = true;
        },
      );
    } catch (e) {
      logger.safeLog(e);
    }
    return isValid;
  }
}
