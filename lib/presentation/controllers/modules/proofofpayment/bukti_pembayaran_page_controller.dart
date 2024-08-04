import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/api_filter_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/message_util.dart';
import 'package:jaya_propertiy/app/utils/constant/filter_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/common/filter_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/common/pagination.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order_entity.dart';
import 'package:jaya_propertiy/domain/entities/order/trn_order_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';
import 'package:jaya_propertiy/presentation/controllers/common/print_controller.dart';

class BuktiPembayaranPageController extends GetxController {
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

  final scrollController = ScrollController();
  final pagination = Pagination().obs;

  doSearch(String search) {
    dataList.clear();
    detailModel.value = TrnDetailOrderEntity();
    doPrepareList(page: 0, search: search);
    update();
  }

  doPrepareList({required int page, String? search}) async {
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
      };

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
          authToken: _authToken, dataFilter: dataFilter, paramsFilter: param);
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
    var printController = Get.put(PrintController());
    bool bluetoothIsEnabled = await printController.bluetoothIsEnabled();
    if (bluetoothIsEnabled) {
      // var paymentPrintController = Get.put(PaymentPrintController());
      // var gatePrintController = Get.put(GatePrintController());
      // await printController.printPaymentTiket(
      //   body,
      //   paymentPrintController,
      //   gatePrintController,
      // );;
      alert.warning('Warning', 'Action on under construction');
    } else {
      alert.error('Error', 'bluetooth is off, please turn it on first');
    }
  }
}
