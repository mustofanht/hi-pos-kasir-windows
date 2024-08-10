import 'package:either_dart/either.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/api_filter_util.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_print_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/message_util.dart';
import 'package:jaya_propertiy/app/utils/common/printer_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/filter_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/common/filter_model.dart';
import 'package:jaya_propertiy/data/models/order/order_addon_model.dart';
import 'package:jaya_propertiy/data/models/order/order_model.dart';
import 'package:jaya_propertiy/data/models/order/order_ticket_model.dart';
import 'package:jaya_propertiy/data/models/order/order_voucher_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/auth/user_entity.dart';
import 'package:jaya_propertiy/domain/entities/common/pagination.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order_entity.dart';
import 'package:jaya_propertiy/domain/entities/order/trn_order_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';

class BuktiPembayaranPageController extends GetxController with GetSingleTickerProviderStateMixin {
  BuktiPembayaranPageController();
  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];
  final searchController = TextEditingController();
  final selectedData = TrnOrderEntity().obs;

  final dataList = <TrnOrderEntity>[].obs;
  final detailModel = TrnDetailOrderEntity().obs;
  final isLoadMore = false.obs;
  final isLoading = false.obs;
  final isLoadingDetail = false.obs;
  final visibleLoadMore = false.obs;

  final ScrollController scrollController = ScrollController();
  late AnimationController animationController;
  
  final pagination = Pagination().obs;
  
  @override
  void onInit() {
    scrollController.addListener(_onScroll);
    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    doPrepareList(page: 0);

    super.onInit();
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      // logger.safeLog('CURR PAGE : ${pagination.value.currentPage}');
      // logger.safeLog('DATA LIST : ${dataList.length}');
      if (dataList.isNotEmpty &&
          pagination.value.currentPage! < dataList.length) {
        loadNextPage();
      }
    }
  }

  loadNextPage() async {
    isLoading.value = true;
    animationController.repeat(reverse: true);
    logger.safeLog("NEXT PAGE : ${((pagination.value.currentPage ?? 0) + 1)}");
    doPrepareList(page: ((pagination.value.currentPage ?? 0) + 1), search: searchController.text);
    isLoading.value = false;
    update();
  }

  doSearch(String search) {
    dataList.clear();
    detailModel.value = TrnDetailOrderEntity();
    doPrepareList(page: 0, search: search);
    update();
  }

  doPrepareList({required int page, String? search}) async {
    detailModel.value = TrnDetailOrderEntity();
    selectedData.value = TrnOrderEntity();
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
        'desc': 'orderDate',
      };

      dataFilter.add(
        apiFilterUtil.addSearch(
          'orderDate',
          OPERATOR_CONSTANTS.GREATHER_THAN_OR_EQUALS,
          dateTimeUtil.getFormattedDate(
            date: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day, 0, 0, 0)
                .toLocal(),
            format: dateFormat.dateStripedYYYYMMDDHHMMSS,
          ),
        )!,
      );

      dataFilter.add(
        apiFilterUtil.addSearch(
          'orderDate',
          OPERATOR_CONSTANTS.LESS_THAN_OR_EQUALS,
          dateTimeUtil.getFormattedDate(
            date: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day + 1, 0, 0, 0)
                .toLocal(),
            format: dateFormat.dateStripedYYYYMMDDHHMMSS,
          ),
        )!,
      );
      if (search != '' && search != null) {
        dataFilter.add(
          apiFilterUtil.addSearch(
            'orderNumber',
            OPERATOR_CONSTANTS.LIKE,
            search,
          )!,
        );
      }

      result = await _service.order.orderService.getAllOrder(
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
          dataList.value = r.data!;
        } else {
          dataList.addAll(r.data!);
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

  doSelectedOrder(TrnOrderEntity val) {
    selectedData.value = val;
    detailModel.value = TrnDetailOrderEntity();
    _getDetailOrder();
    update();
  }

  _getDetailOrder() async {
    isLoadingDetail.value = true;
    try {
      var result;
      result = await _service.order.orderService.getDetailOrder(
          authToken: _authToken, orderNo: selectedData.value.orderNumber);
      result.fold((l) {
        logger.safeLog(l);
      }, (r) {
        detailModel.value = r.data;
      });
    } catch (e) {
      logger.safeLog(e);
    }
    isLoadingDetail.value = false;
    update();
  }

  doSendMessage() {
    dialog.paymentSendProofOfPayment(
      title: 'Send Email WA',
      labelButton: 'Close',
      onSendEmail: (val) {
        logger.safeLog('Email : ${val}');
        var result = _service.message.sendEmail(
          authToken: _authToken,
          phoneNumber: int.parse(val),
          message: messageUtil.buildBodyMessageDetailOrder([]),
        );
        result.fold(
          (left) => alert.error('Error', 'Send Wa Internal Server Error'),
          (right) => alert.success('Success', 'Send Wa Sucess'),
        );
      },
      onSendWa: (val) {
        logger.safeLog('WA : ${val}');
        var result = _service.message.sendWa(
          authToken: _authToken,
          phoneNumber: int.parse(val),
          message: messageUtil.buildBodyMessageDetailOrder([]),
        );
        result.fold(
          (left) => alert.error('Error', 'Send Wa Internal Server Error'),
          (right) => alert.success('Success', 'Send Wa Sucess'),
        );
      },
      onNewOrder: () {
        Get.back();
      },
    );
  }

  doPrintTicket() async {
    try {
      if (printerUtil.currPrinter != null) {
        String locationName = "";
        UserEntity? user = await common.getUser(
          authToken: _authToken,
        );
        if (user != null) {
          locationName = user.locationName!;
        }

        List<OrderTicketModel> ticketList = detailModel.value.detailOrderModels!
            .map(
              (e) => OrderTicketModel(
                totalTicket: e.quantity!,
                totalAmount: e.total!,
              ),
            )
            .toList();
        List<OrderAddonModel> productList = detailModel.value.detailOrderModels!
            .map(
              (e) => OrderAddonModel(
                ordadTotalAddon: e.quantity!,
                ordadTotalAmount: e.total!,
              ),
            )
            .toList();
        List<OrderVoucherModel> voucherList =
            detailModel.value.detailOrderModels!
                .map(
                  (e) => OrderVoucherModel(
                    ordvcTotalVoucher: e.quantity!,
                    ordvcTotalAmount: e.total!,
                  ),
                )
                .toList();

        OrderModel orderModel = OrderModel(
          orderTotalItem: detailModel.value.orderTotalItem!,
          orderTotalAmt: detailModel.value.orderTotalAmt!,
          orderUnitId: 0,
          orderLoacationId: 0,
          orderPaidBy: detailModel.value.orderPaidBy!,
          orderStatus: detailModel.value.orderStatus!,
          listTicket: ticketList,
          listProduct: productList,
          listVoucher: voucherList,
        );

        List<int> data = [];
        data = await generatePrintUtil.dataPaymentTiketPrint(
          locationName: locationName,
          paperSize: PaperSize.mm80,
          body: orderModel,
        );
        if (orderModel.listCreateTicket != null) {
          int count = 1;
          int totalPak = orderModel.listCreateTicket!.length;
          for (var element in orderModel.listCreateTicket!) {
            List<int> dataPrint = await generatePrintUtil.dataGatePrint(
              locationName: locationName,
              paperSize: PaperSize.mm80,
              reffNo: element.ticketNo!,
              pakOf: count,
              pakTotal: totalPak,
              qrCode: element.ticketNo!,
              expiredAt: dateTimeUtil.now(format: dateFormat.dateDDMMMMYYYY),
              ticketName: element.ticketName,
            );
            data.addAll(dataPrint);
            count++;
          }
        }

        await printerUtil.print(printerUtil.currPrinter!, data);
        Get.back();
      } else {
        alert.error('Error', 'please check connection printer');
      }
    } catch (e) {
      logger.safeLog(e);
      alert.error('Error', 'Terjadi Kesalahan , hubungi admin');
    }
  }
}
