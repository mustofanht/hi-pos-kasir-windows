import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/paginasi_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/filter_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/cart/cart_ticket_mode.dart';
import 'package:jaya_propertiy/data/models/common/filter_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/common/pagination.dart';
import 'package:jaya_propertiy/domain/entities/sale/ticket_entity.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_cart_page_controller.dart';

class SaleTicketPageController extends GetxController {
  SaleTicketPageController();
  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];
  final saleCartPageController = SaleCartPageController();

  final scrollController = ScrollController();
  final pagination = Pagination().obs;

  final ticketList = <TicketEntity>[].obs;
  final isLoading = false.obs;
  final visibleLoadMore = false.obs;

  /// Kotak pencarian nama tiket (26 Okt 2026).
  final cariController = TextEditingController();
  final kataCari = ''.obs;
  final adaKataCari = false.obs;
  Timer? _tungguKetik;

  /// Kata kunci yang dipakai permintaan yang SEDANG/BARU berjalan.
  ///
  /// Dipakai membandingkan di akhir pemuatan: bila kasir mengetik lagi selagi
  /// permintaan berjalan, pemuatannya diulang. Tanpa itu, huruf terakhir yang
  /// diketik saat daftar sedang dimuat hilang tanpa jejak — penjaga
  /// `if (isLoading) return` membuangnya diam-diam.
  String _kataDimuat = '';

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(scrollHandler);
    doPrepareList(page: 0);
  }

  @override
  void onClose() {
    _tungguKetik?.cancel();
    cariController.dispose();
    super.onClose();
  }

  /// Mengetik di kotak pencarian.
  ///
  /// Ditunda 400 ms: tanpa jeda, setiap huruf menjadi satu permintaan ke
  /// server, dan jawaban permintaan lama bisa tiba belakangan lalu menimpa
  /// hasil yang lebih baru.
  void cari(String teks) {
    adaKataCari.value = teks.trim().isNotEmpty;
    _tungguKetik?.cancel();
    _tungguKetik = Timer(const Duration(milliseconds: 400), () {
      final kata = teks.trim();
      if (kata == kataCari.value) return;
      kataCari.value = kata;
      doPrepareList(page: 0);
    });
  }

  void bersihkanCari() {
    _tungguKetik?.cancel();
    cariController.clear();
    adaKataCari.value = false;
    if (kataCari.value.isEmpty) return;
    kataCari.value = '';
    doPrepareList(page: 0);
  }

  Future<void> doPrepareList({required int page}) async {
    if (isLoading.value) return;
    isLoading.value = true;

    // Refresh halaman Ticket juga menyegarkan bundling tiket yang sudah ada di
    // keranjang, supaya perubahan aturan di back office terlihat tanpa logout.
    if (page == 0 && Get.isRegistered<SaleCartPageController>()) {
      Get.find<SaleCartPageController>().muatUlangBundle();
    }

    try {
      // DAFTARNYA TIDAK DIKOSONGKAN DI SINI. Halaman kedua dan seterusnya
      // ditambahkan ke bawah daftar yang sudah ada; mengosongkannya lebih dulu
      // membuat halaman pertama lenyap begitu kasir menggulir ke bawah — dan
      // bila halaman yang diminta ternyata kosong, layarnya kosong sama sekali
      // (dilaporkan 26 Okt 2026). Halaman 0 diganti seluruhnya di bawah lewat
      // `ticketList.value = ...`.
      var result;
      List<FilterQuery> dataFilter = [];
      final kata = kataCari.value.trim();
      _kataDimuat = kata;
      Map<String, dynamic> param = {
        'page': page.toString(),
        'size': PAGINATIONS_CONSTANT.LIMIT_PAGE.toString(),
        'flMobile': 'Y',
        // Kirim seluruh lokasi user agar tiket semua lokasi tampil sekaligus.
        'locationId': sessionUtil.getLocationIdsQueryParam(),
      };
      // Pencarian dikerjakan server (`search` pada mst_ticket), bukan disaring
      // dari daftar yang kebetulan sudah termuat — daftarnya per halaman.
      if (kata.isNotEmpty) {
        param['search'] = kata;
      }

      result = await _service.sale.ticketService.getAll(
        authToken: _authToken,
        dataFilter: dataFilter,
        paramsFilter: param,
      );

      result.fold((l) {
        logger.safeLog(l);
        isLoading.value = false;
      }, (r) {
        if (page == 0) {
          ticketList.value = r.data!;
        } else {
          ticketList.addAll(r.data!);
        }
        pagination.value = r.pagination!;
        isLoading.value = false;
        visibleLoadMore.value = false;
      });
    } catch (e) {
      logger.safeLog(e);
      isLoading.value = false;
    }
    logger.safeLog('ticketList : ${ticketList.length}');
    update();

    // Kata kuncinya berubah selagi permintaan ini berjalan → muat sekali lagi.
    if (_kataDimuat != kataCari.value.trim()) {
      await doPrepareList(page: 0);
    }
  }

  Future<void> scrollHandler() async {
    if (!scrollController.hasClients) return;
    if (!PaginasiKasir.sudahDiDasar(
      scrollController.position.pixels,
      scrollController.position.maxScrollExtent,
    )) {
      return;
    }
    if (!PaginasiKasir.adaHalamanBerikutnya(
      pagination.value.currentPage,
      pagination.value.totalPage,
    )) {
      return;
    }
    await doPrepareList(page: pagination.value.currentPage! + 1);
  }

  addTicketToCart({required TicketEntity ticket}) {
    final SaleCartPageController saleCartPageController =
        Get.find<SaleCartPageController>();

    if (saleCartPageController.ticketList.isEmpty) {
      saleCartPageController.addTicket(ticket);
    } else {
      CartTicket? existingTicket = saleCartPageController.ticketList
          .firstWhereOrNull((e) => e.ticket!.ticketId == ticket.ticketId);

      if (existingTicket != null) {
        // existingTicket.qtyOrder = (existingTicket.qtyOrder ?? 0) + 1;
        // existingTicket.totalPrice =
        //     (existingTicket.totalPrice ?? 0) + (ticket.ticketPrice ?? 0);
        // saleCartPageController.calculateTotalOrder();
        saleCartPageController.addTicketCart(existingTicket);
      } else {
        saleCartPageController.addTicket(ticket);
      }
    }
    saleCartPageController.update();
    update();
  }
}
