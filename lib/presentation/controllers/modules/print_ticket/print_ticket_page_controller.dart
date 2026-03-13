import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/api_filter_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/filter_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/data/models/common/filter_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/data/models/common/custom_table_data.dart';
import 'package:jaya_propertiy/domain/entities/common/pagination.dart';
import 'package:jaya_propertiy/domain/entities/order/vw_order_entity.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/print_ticket/print_ticket_detail_page_controller.dart';

class PrintTicketPageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  PrintTicketPageController();

  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];

  final searchController = TextEditingController();
  final listColumnHeader = <CustomTableData>[].obs;
  final openDetail = false.obs;
  final selectedData = VwOrderEntity().obs;

  final ScrollController scrollController = ScrollController();
  late AnimationController animationController;

  final pagination = Pagination().obs;

  final dataList = <VwOrderEntity>[].obs;
  final isLoading = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    scrollController.addListener(_onScroll);
    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    await setListHeaderColumn();
    await doRefresh();
    logger.safeLog(' --- INITIALIZE PAGE INQ --- ');
    logger.safeLog(' openDetail : ${openDetail.value} ');
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
      logger.safeLog('CURR PAGE : ${pagination.value.currentPage}');
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
    doPrepareList(
      page: ((pagination.value.currentPage ?? 0) + 1),
      search: searchController.text,
    );
    isLoading.value = false;
    update();
  }

  setListHeaderColumn() {
    listColumnHeader.clear();
    listColumnHeader.add(
      CustomTableData(
        id: 'orderNumber',
        columnName: 'ID Order',
        width: layoutStyle.blockHorizontal * 20,
        alignment: Alignment.centerLeft,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'ticketName',
        columnName: 'Nama',
        alignment: Alignment.centerLeft,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'orderSource',
        columnName: 'Source Order',
        alignment: Alignment.center,
        defaultValue: 'Onsite',
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'pymntStatus',
        columnName: 'Status Pembayaran',
        alignment: Alignment.center,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'otdtlStatus',
        columnName: 'Status Tiket',
        alignment: Alignment.center,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'statusCetak',
        columnName: 'Status Cetak',
        alignment: Alignment.center,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'countScan',
        columnName: 'Status Scan',
        alignment: Alignment.center,
      ),
    );
  }

  doSearch() async {
    logger.safeLog('SEARCH -- : ${searchController.text}');
    setListHeaderColumn();
    dataList.clear();
    await doPrepareList(page: 0, search: searchController.text);
    update();
  }

  doRefresh() async {
    setListHeaderColumn();
    dataList.clear();
    await doPrepareList(page: 0);
    update();
  }

  doPrepareList({required int page, String? search}) async {
    logger.safeLog("PAGE : $page");
    logger.safeLog("SEARCH : $search");
    isLoading.value = true;

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
          'locId',
          OPERATOR_CONSTANTS.EQUALS,
          sessionUtil.getLocationId(),
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

      result = await _service.order.orderService.getVwOrderTicket(
        authToken: _authToken,
        dataFilter: dataFilter,
        paramsFilter: param,
      );
      result.fold(
        (l) {
          logger.safeLog(l);
          isLoading.value = false;
        },
        (r) {
          if (r.data != null) {
            if (page == 0) {
              dataList.value = r.data!;
            } else {
              dataList.addAll(r.data);
            }
          }
          pagination.value = r.pagination!;
          isLoading.value = false;
        },
      );
    } catch (e) {
      logger.safeLog(e);
      isLoading.value = false;
    }
    logger.safeLog('LENGHT DATA CEK ORDER : ${dataList.length}');
    update();
  }

  doToDetail(VwOrderEntity? val) {
    selectedData.value = val!;
    openDetail.value = true;
    if (Get.isRegistered<PrintTicketDetailPageController>()) {
      final detailController = Get.find<PrintTicketDetailPageController>();
      detailController.doPrepared();
    }
    update();
  }
}
