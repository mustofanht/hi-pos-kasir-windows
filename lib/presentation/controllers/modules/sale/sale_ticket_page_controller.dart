import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/api_filter_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
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
  final isLoadMore = false.obs;
  final isLoading = false.obs;
  final visibleLoadMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(scrollHandler);
    doPrepareList(page: 0);
  }

  Future<void> doPrepareList({required int page}) async {
    if (page > 0) {
      isLoadMore.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      var result;
      List<FilterQuery> dataFilter = [];
      Map<String, dynamic> param = {
        'page': page.toString(),
        'size': PAGINATIONS_CONSTANT.LIMIT_PAGE.toString(),
        'flMobile': 'Y',
      };

      dataFilter.add(
        apiFilterUtil.addSearch(
          'ticketUnit',
          OPERATOR_CONSTANTS.EQUALS,
          sessionUtil.getUnitId(),
        )!,
      );

      result = await _service.sale.ticketService.getAll(
        authToken: _authToken,
        dataFilter: dataFilter,
        paramsFilter: param,
      );

      result.fold((l) {
        logger.safeLog(l);
        isLoading.value = false;
        isLoadMore.value = false;
      }, (r) {
        if (page == 0) {
          ticketList.value = r.data!;
        } else {
          ticketList.addAll(r.data!);
        }
        pagination.value = r.pagination!;
        isLoading.value = false;
        isLoadMore.value = false;
        visibleLoadMore.value = false;
      });
    } catch (e) {
      logger.safeLog(e);
      isLoading.value = false;
      isLoadMore.value = false;
    }
    update();
  }

  void scrollHandler() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (pagination.value.currentPage! < pagination.value.totalPage!) {
        doPrepareList(page: pagination.value.currentPage! + 1);
      }
    }
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
        existingTicket.qtyOrder = (existingTicket.qtyOrder ?? 0) + 1;
        existingTicket.totalPrice =
            (existingTicket.totalPrice ?? 0) + (ticket.nominal ?? 0);
        saleCartPageController.calculateTotalOrder();
      } else {
        saleCartPageController.addTicket(ticket);
      }
    }
    saleCartPageController.update();
    update();
  }
}
