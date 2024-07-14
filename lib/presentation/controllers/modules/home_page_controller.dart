import 'dart:async';

import 'package:jaya_propertiy/app/main/app_route.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
// import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/menu_item_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/auth/user_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/print_ticket/print_ticket_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/proofofpayment/bukti_pembayaran_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_addon_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_cart_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_ticket_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_voucher_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/setting/setting_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/shift/shift_page_controller.dart';
import 'package:jaya_propertiy/presentation/views/modules/print_ticket/print_ticket_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/proofofpayment/bukti_pembayaran_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/sale_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/presentation/views/modules/setting/setting_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/shift/shift_page.dart';

class HomePageController extends GetxController {
  HomePageController();
  // final _authToken = Get.arguments[argConstant.authToken];

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
    username.value = sessionUtil.getUserName();
    timeString.value = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    getUser();
    update();
  }

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
    MenuItem(id: 3, name: 'Cek\nTiket', icon: Icons.confirmation_num_outlined),
    MenuItem(id: 4, name: 'Shift', icon: Icons.confirmation_num_outlined),
    MenuItem(id: 5, name: 'Pengaturan', icon: Icons.settings),
    MenuItem(id: 6, name: 'Logout', icon: Icons.logout),
  ];

  void onSelectedMenu(MenuItem menu) {
    logger.safeLog('ID : ${menu.id}');
    if (menu.id == 6) {
      alert.dialogDelete(
        title: 'LOGOUT',
        msg: 'Apakah anda yakin akan logout?',
        onYes: () {
          logout();
        },
      );
    } else {
      selectedMenu.value = menu.id;
      update();
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

  Widget underConstruction() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            assetsConstant.imgUnderConstruction,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            width: layoutStyle.blockHorizontal * 50,
            height: layoutStyle.blockVertical * 50,
          ),
          SizedBox(
            height: layoutStyle.defaultMargin,
          ),
          Text(
            'Under Construction',
            style: TextStyle(
              fontSize: fontSize.header * 2,
              fontWeight: fontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget? get selectedContent {
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
        return const PrintTicketPage();
      case 4:
        Get.lazyPut(() => ShiftPageController());
        return const ShiftPage();
      case 5:
        Get.lazyPut(() => SettingPageController());
        return const SettingPage();
      case 6:
        return null;
      default:
        return underConstruction();
    }
  }
}
