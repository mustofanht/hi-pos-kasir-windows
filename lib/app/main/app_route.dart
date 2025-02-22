import 'package:jaya_propertiy/presentation/bindings/auth/login_page_binding.dart';
import 'package:jaya_propertiy/presentation/bindings/default/splash_page_binding.dart';
import 'package:jaya_propertiy/presentation/bindings/modules/home_page_binding.dart';
import 'package:jaya_propertiy/presentation/bindings/modules/member/member_page_binding.dart';
import 'package:jaya_propertiy/presentation/bindings/modules/print_ticket/print_ticket_detail_page_binding.dart';
import 'package:jaya_propertiy/presentation/bindings/modules/print_ticket/print_ticket_page_binding.dart';
import 'package:jaya_propertiy/presentation/bindings/modules/proofofpayment/bukti_pembayaran_page_binding.dart';
import 'package:jaya_propertiy/presentation/bindings/modules/sale/sale_cart_page_binding.dart';
import 'package:jaya_propertiy/presentation/bindings/modules/sale/sale_voucher_page_binding.dart';
import 'package:jaya_propertiy/presentation/bindings/modules/sale_page_binding.dart';
import 'package:jaya_propertiy/presentation/bindings/modules/sale/sale_ticket_page_binding.dart';
import 'package:jaya_propertiy/presentation/bindings/modules/setting/setting_page_binding.dart';
import 'package:jaya_propertiy/presentation/bindings/modules/shift/shift_page_binding.dart';
import 'package:jaya_propertiy/presentation/views/auth/login_page.dart';
import 'package:jaya_propertiy/presentation/views/dafault/splash_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/customer_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/home_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/member/inq_member_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/member/member_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/member/new_member_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/print_ticket/print_ticket_detail_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/print_ticket/print_ticket_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/proofofpayment/bukti_pembayaran_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/sale/sale_cart_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/sale/sale_voucher_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/sale_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/sale/sale_ticket_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/presentation/views/modules/setting/setting_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/shift/shift_page.dart';

class AppRoute {
  static final pages = [
    GetPage(
      name: RouteName.presentationPage,
      page: () => const CustomerPage(),
      curve: Curves.easeInOut,
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 1000),
    ),
    GetPage(
      name: RouteName.splashPage,
      page: () => const SplashPage(),
      binding: SplashPageBinding(),
      curve: Curves.easeInOut,
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 1000),
    ),
    // GetPage(
    //   name: RouteName.slidePage,
    //   page: () => const SlidePage(),
    //   binding: SlidePageBinding(),
    //   curve: Curves.easeInOut,
    //   transition: Transition.rightToLeftWithFade,
    //   transitionDuration: const Duration(milliseconds: 1000),
    // ),
    GetPage(
      name: RouteName.homePage,
      page: () => const HomePage(),
      binding: HomePageBinding(),
      curve: Curves.easeInOut,
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 1000),
    ),

    // auth
    GetPage(
      name: RouteName.loginPage,
      page: () => const LoginPage(),
      binding: LoginPageBinding(),
      curve: Curves.easeInOut,
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 1000),
    ),

    // module
    GetPage(
      name: RouteName.salePage,
      page: () => const SalePage(),
      binding: SalePageBinding(),
      curve: Curves.easeInOut,
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 1000),
    ),
    GetPage(
      name: RouteName.saleTicketPage,
      page: () => const SaleTicketPage(),
      binding: SaleTicketPageBinding(),
      curve: Curves.easeInOut,
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 1000),
    ),
    GetPage(
      name: RouteName.saleVoucherPage,
      page: () => const SaleVoucherPage(),
      binding: SaleVoucherPageBinding(),
      curve: Curves.easeInOut,
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 1000),
    ),
    GetPage(
      name: RouteName.saleCartPage,
      page: () => const SaleCartPage(),
      binding: SaleCartPageBinding(),
      curve: Curves.easeInOut,
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 1000),
    ),
    //print ticket
    GetPage(
      name: RouteName.printTicketPage,
      page: () => const PrintTicketPage(),
      binding: PrintTicketPageBinding(),
      curve: Curves.easeInOut,
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 1000),
    ),
    // GetPage(
    //   name: RouteName.printTicketDetailPage,
    //   page: () => const PrintTicketDetailPage(),
    //   binding: PrintTicketDetailPageBinding(),
    //   curve: Curves.easeInOut,
    //   transition: Transition.cupertino,
    //   transitionDuration: const Duration(milliseconds: 1000),
    // ),
    //Proof Of Payment
    GetPage(
      name: RouteName.buktiPembayaranPage,
      page: () => const BuktiPembayaranPage(),
      binding: BuktiPembayaranPageBinding(),
      curve: Curves.easeInOut,
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 1000),
    ),
    //print ticket
    GetPage(
      name: RouteName.printTicketPage,
      page: () => const PrintTicketPage(),
      binding: PrintTicketPageBinding(),
      curve: Curves.easeInOut,
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 1000),
    ),
    // member
    GetPage(
      name: RouteName.memberPage,
      page: () => const MemberPage(),
      binding: MemberPageBinding(),
      curve: Curves.easeInOut,
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 1000),
    ),
    // shift
    GetPage(
      name: RouteName.shiftPage,
      page: () => const ShiftPage(),
      binding: ShiftPageBinding(),
      curve: Curves.easeInOut,
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 1000),
    ),
    // setting
    GetPage(
      name: RouteName.settingPage,
      page: () => const SettingPage(),
      binding: SettingPageBinding(),
      curve: Curves.easeInOut,
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 1000),
    ),
  ];
}

abstract class RouteName {
  static const splashPage = '/';
  static const presentationPage = '/presentation';
  // static const slidePage = '/';
  static const homePage = '/home';

  // Auth Pages
  static const loginPage = '/login-page';
  static const registerPage = '/register-page';

  // module
  static const salePage = '/sale-page';
  static const saleTicketPage = '/sale-ticket-page';
  static const saleVoucherPage = '/sale-voucher-page';
  static const saleAddonPage = '/sale-addon-page';
  static const saleCartPage = '/sale-cart-page';

  // Proof Of Payment
  static const buktiPembayaranPage = '/bukti-pembayaran-page';

  // Print Ticket
  static const printTicketPage = '/print-ticket-page';
  // static const printTicketDetailPage = '/print-ticket-detail-page';

  // setting
  static const memberPage = '/member-page';
  static const inqMemberPage = '/inq-member-page';
  static const newMemberPage = '/new-member-page';

  // shift
  static const shiftPage = '/shift-page';

  // setting
  static const settingPage = '/setting-page';
}
