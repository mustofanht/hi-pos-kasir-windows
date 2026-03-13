import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/display_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_print_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/printer_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/common/printer_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/auth/user_entity.dart';
import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:presentation_displays/display.dart';

class SettingPageController extends GetxController
    with SingleGetTickerProviderMixin {
  SettingPageController();
  // var printController = Get.find<PrintController>();

  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];
  final isLoading = false.obs;
  final isLoadingPrinter = false.obs;
  final isLoadingPrinterDiconect = false.obs;
  final isLoadingConnectPrinter = false.obs;
  final isLoadingRefreshCustScreeen = false.obs;

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
  final printers = <PrinterModel>[].obs;
  final selectedCurrPrinter = CustomIdNameEntity().obs;
  final listScreens = <CustomIdNameEntity>[].obs;
  final selectedScreens = CustomIdNameEntity().obs;

  final currentPrinterConnect = RxString('');

  @override
  Future<void> onInit() async {
    doPrepared();
    await doInitializeScreen();
    await doInitializePrinter();
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    tabController!.addListener(_handleTabSelection);
    currentPrinterConnect.value = printerUtil.currPrinter?.deviceName ?? '';
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
    isLoading.value = true;
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
        roleController.text = model.value.roleName ?? '';
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
    isLoadingConnectPrinter.value = false;
    isLoadingPrinter.value = true;
    var noneSelectedPrint = CustomIdNameEntity(
      id: null,
      name: '--- Select Printer ---',
    );
    selectedCurrPrinter.value = noneSelectedPrint;
    listPrinter.clear();
    listPrinter.insert(0, noneSelectedPrint);

    // List<PrinterModel> printers = await printerUtil.getListDevices();
    await printerUtil.init();
    await printerUtil.initBt();
    printers.value = await printerUtil.getListDevices();
    printerUtil.printerList = printers;
    logger.safeLog('PRINTERS : ${printers.length}');

    for (var element in printers) {
      logger.safeLog('PRINTER : ${element.toJson()}');
      // logger.safeLog('PRINTER : ${element.deviceName}');
      listPrinter.add(
        CustomIdNameEntity(
          id: element.vendorId ?? element.address,
          name: element.deviceName,
        ),
      );
    }

    // logger.safeLog('SELECT PRINTER : ${printerUtil.currPrinter?.toJson()}');

    if (printerUtil.currPrinter != null) {
      selectedCurrPrinter.value = listPrinter.firstWhere(
        (element) =>
            element.id.toString() ==
            printerUtil.currPrinter?.vendorId.toString(),
      );
    }
    // logger.safeLog('LIST PRINTER : ${listPrinter.length}');

    isLoadingPrinter.value = false;

    currentPrinterConnect.value = printerUtil.currPrinter?.deviceName ?? '';

    update();
  }

  doInitializeScreen() async {
    displayUtil.getDisplay();
    var noneSelectedScreen = CustomIdNameEntity(
      id: null,
      name: '--- None ---',
    );
    selectedScreens.value = noneSelectedScreen;
    listScreens.clear();
    listScreens.add(noneSelectedScreen);
    List<Display?> screens = displayUtil.displays;
    for (var element in screens) {
      logger.safeLog('SCREENS : ${element!.a}');
      listScreens.add(
        CustomIdNameEntity(
          id: element.a.toString(),
          name: '${element.a} - ${element.b} - ${element.c} - ${element.d}',
        ),
      );
    }
    update();
  }

  doUpdateConnectedPrinter(CustomIdNameEntity? val) async {
    if (val != null && val.id != null) {
      isLoadingConnectPrinter.value = true;
      // List<PrinterModel> printers = await printerUtil.getListDevices();
      if (printers.isNotEmpty) {
        PrinterModel selected = printers.firstWhere(
          (element) => (element.vendorId ?? element.address) == val.id,
        );
        // await printerUtil.init();
        // await printerUtil.disconnect(selected);
        await printerUtil.disconnectAll();
        await printerUtil.connect(selected);
        await printerUtil.stopSubscription();
        // logger.safeLog("CONNECTED CURR : ${printerUtil.currPrinter?.toJson()}");
        // logger.safeLog("listPrinter : ${listPrinter.length}");
        selectedCurrPrinter.value = listPrinter.firstWhere(
          (element) =>
              element.id.toString() ==
              (printerUtil.currPrinter?.vendorId ??
                      printerUtil.currPrinter?.address)
                  .toString(),
          orElse: () => CustomIdNameEntity(
            id: null,
            name: '--- Select Printer ---',
          ),
        );
        alert.success('Success', 'Set Printer ${val.name} Active');
        isLoadingConnectPrinter.value = false;
      }
    } else {
      alert.error('Error', 'please select active printer');
      isLoadingConnectPrinter.value = false;
    }

    currentPrinterConnect.value = printerUtil.currPrinter?.deviceName ?? '';

    update();
  }

  doRefreshCustomerPage() async {
    isLoadingRefreshCustScreeen.value = true;
    // displayUtil.showDisplay(selectedScreens.value.id);
    await common.doRefreshAds(_authToken);
    // await common.getImagePromo(_authToken);
    // await displayUtil.updateSecondDisplay(constant.refreshAds);
    // await orderUtil.doRefreshCustomerDisplay(paymentMethod: PaymentMethod.QRIS);
    isLoadingRefreshCustScreeen.value = false;
    update();
  }

  testPrint() async {
    try {
      logger.safeLog('TEST PRINT TO : ${printerUtil.currPrinter?.toJson()}');
      if (printerUtil.currPrinter != null) {
        List<int> data = [];
        data = await generatePrintUtil.testPrint(
          paperSize: PaperSize.mm80,
        );
        // await printerUtil.init();
        await printerUtil.print(printerUtil.currPrinter!, data);
        Get.back();
      } else {
        alert.error('Error', 'please check connection printer');
        printerUtil.connectPrinter();
      }
    } catch (e) {
      logger.safeLog(e);
      alert.error('Error', 'Terjadi Kesalahan , hubungi admin');
    }
  }

  doDisconnectPrinter() async {
    isLoadingPrinterDiconect.value = true;
    await printerUtil.disconnectAll();
    await printerUtil.stopSubscription();
    currentPrinterConnect.value = printerUtil.currPrinter?.deviceName ?? '';
    var noneSelectedScreen = CustomIdNameEntity(
      id: null,
      name: '--- None ---',
    );
    selectedScreens.value = noneSelectedScreen;
    isLoadingPrinterDiconect.value = false;
    update();
  }
}
