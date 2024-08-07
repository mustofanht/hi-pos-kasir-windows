import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/display_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/printer_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/common/printer_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/auth/user_entity.dart';
import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';

class SettingPageController extends GetxController
    with SingleGetTickerProviderMixin {
  SettingPageController();
  // var printController = Get.find<PrintController>();

  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];
  final isLoading = false.obs;

  TabController? tabController;
  var tabIndex = 0.obs;

  final unitController = TextEditingController();
  final lastLoginController = TextEditingController();
  final nameController = TextEditingController();
  final roleController = TextEditingController();
  final noTelpController = TextEditingController();
  final emailController = TextEditingController();

  final model = UserEntity().obs;

  final listPrinter = <CustomIdNameEntity>[].obs;

  @override
  void onInit() {
    doInitializePrinter();
    doPrepared();
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    tabController!.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (!tabController!.indexIsChanging) {
      changeTabIndex(tabController!.index);
    }
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  doPrepared() async {
    try {
      var result;
      result = await _service.auth.getUserInformation(
          authToken: _authToken, userId: sessionUtil.getUserName());
      result.fold((l) {
        logger.safeLog(l);
        isLoading.value = false;
      }, (r) {
        model.value = r.data;
        unitController.text = model.value.unitName!;
        lastLoginController.text = dateTimeUtil.getFormattedDate(
          date: model.value.userLastLogon!,
          format: dateFormat.dateTime,
        );
        nameController.text = model.value.userFullName!;
        roleController.text = '';
        noTelpController.text = model.value.userPhone!;
        emailController.text = model.value.userEmail!;
        isLoading.value = false;
      });
    } catch (e) {
      logger.safeLog(e);
      isLoading.value = false;
    }
    update();
  }

  doInitializePrinter() async {
    var noneSelectedPrint = CustomIdNameEntity(
      id: null,
      name: '--- Select Printer ---',
    );
    listPrinter.clear();
    listPrinter.add(noneSelectedPrint);
    List<PrinterModel> printers = await printerUtil.getListDevices();
    for (var element in printers) {
      logger.safeLog('PRINTER : ${element.deviceName}');
      listPrinter.add(
        CustomIdNameEntity(
          id: element.vendorId,
          name: element.deviceName,
        ),
      );
    }
    update();
  }

  doRefreshCustomerPage() {
    displayUtil.displayCustomer(null);
  }
}
