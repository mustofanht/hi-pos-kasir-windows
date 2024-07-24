import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/api_filter_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/filter_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/common/filter_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/data/models/common/custom_table_data.dart';
import 'package:jaya_propertiy/domain/entities/common/pagination.dart';
import 'package:jaya_propertiy/domain/entities/order/trn_order_entity.dart';

class PrintTicketPageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  PrintTicketPageController();
  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];

  var selected = List<bool>.generate(100, (index) => false).obs;
  var selectAll = false.obs;
  final searchController = TextEditingController();
  final listColumnHeader = <CustomTableData>[].obs;
  final openDetail = false.obs;

  TabController? tabController;

  final scrollController = ScrollController();
  final pagination = Pagination().obs;

  final dataList = <TrnOrderEntity>[].obs;
  final isLoadMore = false.obs;
  final isLoading = false.obs;
  final visibleLoadMore = false.obs;

  @override
  onInit() {
    super.onInit();
    tabController = TabController(length: 1, vsync: this, initialIndex: 0);
    tabController?.addListener(_handleTabSelection);
    setListHeaderColumn();
    doPrepareList(page: 0);
  }

  @override
  void onClose() {
    tabController?.dispose();
    super.onClose();
  }

  void _handleTabSelection() {
    if (!tabController!.indexIsChanging) {
      changeTabIndex(tabController!.index);
    }
  }

  var tabIndex = 0.obs;
  changeTabIndex(int index) {
    tabIndex.value = index;
  }

  toggleSelectAll(bool? value) {
    selectAll.value = value ?? false;
    for (int i = 0; i < selected.length; i++) {
      selected[i] = selectAll.value;
    }
    update();
  }

  toggleSelect(int index, bool? value) {
    selected[index] = value ?? false;
    selectAll.value = selected.every((element) => element);
    update();
  }

  setListHeaderColumn() {
    listColumnHeader.clear();
    listColumnHeader.add(
      CustomTableData(
        id: 'orderNumber',
        columnName: 'ID Order',
        alignment: Alignment.centerLeft,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'orderName',
        columnName: 'Nama',
        alignment: Alignment.centerLeft,
      ),
    );
    // listColumnHeader.add(
    //   CustomTableData(
    //     id: 'orderTicket',
    //     columnName: 'Ticket',
    //     data: const Text('Personal'),
    //     alignment: Alignment.centerLeft,
    //   ),
    // );
    listColumnHeader.add(
      CustomTableData(
        id: 'orderTotalItem',
        columnName: 'Jml Tiket',
        alignment: Alignment.center,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'orderTotalAmt',
        columnName: 'Harga(Rp)',
        alignment: Alignment.centerRight,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'orderSource',
        columnName: 'Order Source',
        alignment: Alignment.center,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'orderStatus',
        columnName: 'Status Pembayaran',
        alignment: Alignment.center,
      ),
    );
    // listColumnHeader.add(
    //   CustomTableData(
    //     id: 'tiketStatus',
    //     columnName: 'Status Tiket',
    //     data: CustomBadge(
    //       label: 'Active',
    //       colorLabel: colorStyle.black,
    //       colorBox: colorStyle.green,
    //     ),
    //     alignment: Alignment.centerLeft,
    //   ),
    // );
    // listColumnHeader.add(
    //   CustomTableData(
    //     id: 'printStatus',
    //     columnName: 'Status Cetak',
    //     data: CustomBadge(
    //       label: 'Cetak',
    //       colorLabel: colorStyle.black,
    //       colorBox: colorStyle.green,
    //     ),
    //     alignment: Alignment.centerLeft,
    //   ),
    // );
    // listColumnHeader.add(
    //   CustomTableData(
    //     id: 'scanStatus',
    //     columnName: 'Status Scan',
    //     data: const Text('1/1'),
    //     alignment: Alignment.center,
    //   ),
    // );
    update();
  }

  doPrepareList({required int page}) async {
    //
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

      if (searchController.text != '') {
        dataFilter.add(
          apiFilterUtil.addSearch(
            'orderNumber',
            OPERATOR_CONSTANTS.LIKE,
            searchController.text,
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

  doToDetail() {
    openDetail.value = true;
    update();
  }
}
