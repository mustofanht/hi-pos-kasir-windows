import 'dart:async';

import 'package:jaya_propertiy/app/main/app_route.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/menu_item_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/auth/user_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/member_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/print_ticket/print_ticket_detail_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/print_ticket/print_ticket_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/proofofpayment/bukti_pembayaran_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_addon_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_cart_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_ticket_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_voucher_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/setting/setting_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/shift/shift_page_controller.dart';
import 'package:jaya_propertiy/presentation/views/modules/member/member_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/print_ticket/print_ticket_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/proofofpayment/bukti_pembayaran_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/sale_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/presentation/views/modules/setting/setting_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/shift/shift_page.dart';

class HomePageController extends GetxController {
  HomePageController();
  final _authToken = Get.arguments[argConstant.authToken];

  final _service = MainService();
  final authToken = Get.arguments[argConstant.authToken];

  var isOpenDrawer = false.obs;
  var selectedMenu = 1.obs;
  double widthSidebar = 100;
  var username = "".obs;
  var timeString = RxString('');

  final user = UserEntity().obs;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    // // For initial Notification
    // notificationUtil.initializeNotification();
    // notificationUtil.requestPermissions();
    // //

    // notificationUtil.selectNotificationStream.stream
    //     .listen((String? payload) async {
    //   logger.safeLog('Payload : $payload');
    //   // if (payload == inboxPayload) {
    //   //   doClickWFIcon();
    //   // }
    // });
    // notificationUtil.didReceiveLocalNotificationStream.stream
    //     .listen((ReceivedNotification receivedNotification) async {
    //   logger.safeLog('Payload : ${receivedNotification.toJson()}');
    // });

    onSelectedMenu(
        MenuItem(id: 1, name: 'Penjualan', icon: Icons.bar_chart_outlined));

    username.value = sessionUtil.getUserName();
    timeString.value = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    getUser();
    update();
  }

  // @override
  // void onClose() {
  //   notificationUtil.didReceiveLocalNotificationStream.close();
  //   notificationUtil.selectNotificationStream.close();
  //   super.onClose();
  // }

  void toggleDrawer() {
    if (scaffoldKey.currentState?.isDrawerOpen ?? false) {
      scaffoldKey.currentState?.openEndDrawer();
    } else {
      scaffoldKey.currentState?.openDrawer();
    }
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    timeString.value = formattedDateTime;
    update();
  }

  String _formatDateTime(DateTime dateTime) {
    // return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
    return '${dateTimeUtil.getFormattedDate(date: dateTime, format: dateFormat.onlyDays)}, ${dateTimeUtil.getFormattedDate(
      date: dateTime,
      format: dateFormat.dateWithoutTime,
    )}';
  }

  void toogleDrawer() {
    isOpenDrawer.value = !isOpenDrawer.value;
    isOpenDrawer.value ? widthSidebar = 300 : widthSidebar = 100;
    update();
  }

  List<MenuItem> menuItems = [
    MenuItem(id: 1, name: 'Penjualan', icon: Icons.bar_chart_outlined),
    MenuItem(
        id: 2, name: 'Bukti\nPembayaran', icon: Icons.receipt_long_outlined),
    MenuItem(id: 3, name: 'Cek\nOrder', icon: Icons.confirmation_num_outlined),
    MenuItem(id: 4, name: 'Member', icon: Icons.person),
    MenuItem(id: 5, name: 'Shift', icon: Icons.confirmation_num_outlined),
    MenuItem(id: 6, name: 'Pengaturan', icon: Icons.settings),
    MenuItem(id: 7, name: 'Logout', icon: Icons.logout),
  ];

  Future<void> onSelectedMenu(MenuItem menu) async {
    logger.safeLog('CURR MENU : ${selectedMenu.value}');
    clearMemberMenu();
    bool isValid = true;
    if (menu.id == 1) {
      bool isActiveKasir = await common.shiftActive(_authToken);
      if (!isActiveKasir) {
        isValid = false;
        alert.warning(
          'Shift',
          'Tidak bisa melakukan penjualan, shift sudah berakhir',
        );

        if (selectedMenu.value == 1) {
          selectedMenu.value = 2;
        }
      }
    }

    if (isValid) {
      if (menu.id == 7) {
        dialog.dialogDelete(
          title: 'LOGOUT',
          msg: 'Apakah anda yakin akan logout?',
          onYes: () async {
            Get.back();
            await logout();
          },
        );
      } else {
        selectedMenu.value = menu.id;
        update();
      }
    }
  }

  getUser() async {
    try {
      final result = await _service.auth
          .getUserInformation(authToken: authToken, userId: username.value);

      result.fold((l) {
        logger.safeLog(l);
      }, (r) {
        user.value = r.data!;
      });
      update();
    } catch (e) {
      logger.safeLog(e);
    }
  }

  logout() async {
    try {
      final result = await _service.auth
          .lastLogout(authToken: authToken, userId: username.value);

      result.fold(
        (l) {
          alert.error("Terjadi Kesalahan!", l);
        },
        (r) async {
          await sessionUtil.clear();
          Get.offAllNamed(
            RouteName.loginPage,
          );
          alert.success("Berhasil!", 'Logout Success');
        },
      );
      update();
    } catch (e) {
      logger.safeLog(e);
    }
  }

  Widget? get selectedContent {
    Get.delete<PrintTicketPageController>();
    Get.delete<PrintTicketDetailPageController>();
    Get.delete<ShiftPageController>();
    Get.delete<SettingPageController>();
    switch (selectedMenu.value) {
      case 1:
        Get.lazyPut(() => SalePageController());
        Get.lazyPut(() => SaleTicketPageController());
        Get.lazyPut(() => SaleVoucherPageController());
        Get.lazyPut(() => SaleAddonPageController());
        Get.lazyPut(() => SaleCartPageController());

        return const SalePage();
      case 2:
        Get.lazyPut(() => BuktiPembayaranPageController());
        return const BuktiPembayaranPage();
      case 3:
        Get.lazyPut(() => PrintTicketPageController());
        // Get.lazyPut(() => PrintTicketDetailPageController());
        return const PrintTicketPage();
      // return const CekOrderPage();
      case 4:
        Get.lazyPut(() => MemberPageController());
        return const MemberPage();
      case 5:
        Get.lazyPut(() => ShiftPageController());
        return const ShiftPage();
      case 6:
        Get.lazyPut(() => SettingPageController());
        return const SettingPage();
      case 7:
        return null;
      default:
        return common.underConstruction();
    }
  }

  clearMemberMenu() {
    if (Get.isRegistered<MemberPageController>()) {
      final memberController = Get.find<MemberPageController>();
      memberController.clear();
    }
  }
}
