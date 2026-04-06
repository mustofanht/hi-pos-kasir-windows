import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/api_filter_util.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/filter_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/cart/cart_deposit_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_potongan_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_voucher_model.dart';
import 'package:jaya_propertiy/data/models/common/filter_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
import 'package:jaya_propertiy/domain/entities/common/pagination.dart';
import 'package:jaya_propertiy/domain/entities/sale/deposit_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/potongan_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/voucher_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_cart_page_controller.dart';

class SaleVoucherPageController extends GetxController {
  SaleVoucherPageController();
  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];
  final saleCartPageController = SaleCartPageController();
  final scrollController = ScrollController();
  final pagination = Pagination().obs;

  final voucherList = <VoucherEntity>[].obs;
  final potonganList = <PotonganEntity>[].obs;
  final depositList = <DepositEntity>[].obs;
  final isLoading = false.obs;
  final visibleLoadMore = false.obs;

  final typeItemList = <CustomIdNameEntity>[].obs;
  final selectedTypeItemList = Rxn<String>('V');

  final searchController = TextEditingController();

  @override
  Future<void> onInit() async {
    super.onInit();
    scrollController.addListener(scrollHandler);
    selectedTypeItemList.value = 'V';
    await doPrepareList(page: 0);
    doInitializeItemTypeList();
  }

  doInitializeItemTypeList() {
    typeItemList.clear();
    typeItemList.add(CustomIdNameEntity(id: 'V', name: 'Voucher'));
    typeItemList.add(CustomIdNameEntity(id: 'P', name: 'Potongan'));
    typeItemList.add(CustomIdNameEntity(id: 'D', name: 'Deposit'));
    update();
  }

  Future<void> scrollHandler() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (pagination.value.currentPage! < pagination.value.totalPage!) {
        await doPrepareList(page: pagination.value.currentPage! + 1);
      }
    }
  }

  addPotonganToCart({required PotonganEntity voucher}) {
    final SaleCartPageController saleCartPageController =
        Get.find<SaleCartPageController>();

    if (saleCartPageController.potonganList.isNotEmpty) {
      CartPotongan? existing = saleCartPageController.potonganList
          .firstWhereOrNull((e) => e.potongan!.voucherId == voucher.voucherId);

      if (existing != null) {
        alert.warning(
            "Warning", "Potongan ${voucher.voucherName} has been added!");
        return;
      }
    }
    saleCartPageController.addpotongan(voucher);
    saleCartPageController.calculateTotalOrder();
    update();
  }

  addVoucherToCart(VoucherEntity entity) {
    final SaleCartPageController saleCartPageController =
        Get.find<SaleCartPageController>();

    if (saleCartPageController.voucherList.isEmpty) {
      saleCartPageController.addvoucher(entity);
    } else {
      CartVoucher? existing = saleCartPageController.voucherList
          .firstWhereOrNull((e) => e.entity!.vpId == entity.vpId);

      if (existing != null) {
        saleCartPageController.addVoucherCart(existing);
      } else {
        saleCartPageController.addvoucher(entity);
      }
    }
    saleCartPageController.update();
    update();
  }

  addDepositToCart(DepositEntity entity) {
    final SaleCartPageController saleCartPageController =
        Get.find<SaleCartPageController>();

    if (saleCartPageController.depositList.isNotEmpty) {
      CartDeposit? existing = saleCartPageController.depositList
          .firstWhereOrNull((e) => e.deposit!.dpId == entity.dpId);

      if (existing != null) {
        alert.warning("Warning", "Deposit ${entity.dpName} has been added!");
        return;
      }
    }
    saleCartPageController.adddeposit(entity);
    saleCartPageController.calculateTotalOrder();
    update();
  }

  onSelectedType(CustomIdNameEntity element) async {
    logger.safeLog('ON SELECT TYPE : ${element.toJson()}');
    selectedTypeItemList.value = element.id;
    searchController.clear();
    voucherList.clear();
    potonganList.clear();
    depositList.clear();
    await doPrepareList(
      page: 0,
    );
    // logger.safeLog('LENGTH V : ${voucherList.length}');
    // logger.safeLog('LENGTH P : ${potonganList.length}');
    // logger.safeLog('LENGTH D : ${depositList.length}');
    update();
  }

  doPrepareList({
    required int page,
    String? search,
  }) async {
    logger.safeLog('TYPE SELECTED : ${selectedTypeItemList.value}');
    if (selectedTypeItemList.value == 'V') {
      await doPrepareVoucher(page);
    } else if (selectedTypeItemList.value == 'P') {
      await doPreparedPotongan(page);
    } else if (selectedTypeItemList.value == 'D') {
      await doPreparedDeposit(page, search);
    }
  }

  doPrepareVoucher(int page) async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      var result;
      List<FilterQuery> dataFilter = [];
      Map<String, dynamic> param = {
        'page': page.toString(),
        'size': PAGINATIONS_CONSTANT.LIMIT_PAGE.toString(),
        'flMobile': 'Y',
        // 'locationId': sessionUtil.getLocationId().toString(),
      };
      dataFilter.add(
        apiFilterUtil.addSearch(
          'vpLocId',
          OPERATOR_CONSTANTS.EQUALS,
          sessionUtil.getLocationId().toString(),
        )!,
      );
      dataFilter.add(
        apiFilterUtil.addSearch(
          'vpState',
          OPERATOR_CONSTANTS.EQUALS,
          'Y',
        )!,
      );
      dataFilter.add(
        apiFilterUtil.addSearch(
          'vpFlWebsite',
          OPERATOR_CONSTANTS.EQUALS,
          'N',
        )!,
      );
      dataFilter.add(
        apiFilterUtil.addSearch(
          'vpFlMember',
          OPERATOR_CONSTANTS.EQUALS,
          'N',
        )!,
      );
      dataFilter.add(
        apiFilterUtil.addSearch(
          'vpLimit',
          OPERATOR_CONSTANTS.GREATHER_THAN,
          0,
        )!,
      );

      List<FilterQuery> dataFilterDate = [];

      dataFilterDate.add(
        apiFilterUtil.addSearch(
          'vpEndDate',
          OPERATOR_CONSTANTS.GREATHER_THAN_OR_EQUALS,
          '${dateTimeUtil.dateFormat(DateTime.now(), 'yyyy-MM-dd')}:OR',
        )!,
      );
      dataFilterDate.add(
        apiFilterUtil.addSearch(
          'vpEndDate',
          OPERATOR_CONSTANTS.EQUALS,
          '${OPERATOR_CONSTANTS.IS_NULL}:OR',
        )!,
      );

      dataFilter.add(
        apiFilterUtil.addSearch(
          'GROUP_CONDITION_AND',
          OPERATOR_CONSTANTS.EQUALS,
          dataFilterDate,
        )!,
      );
      dataFilter.add(
        apiFilterUtil.addSearch(
          'vpStartDate',
          OPERATOR_CONSTANTS.LESS_THAN_OR_EQUALS,
          dateTimeUtil.dateFormat(DateTime.now(), 'yyyy-MM-dd'),
        )!,
      );

      result = await _service.sale.voucherService.getAllVoucher(
        authToken: _authToken,
        dataFilter: dataFilter,
        paramsFilter: param,
      );

      result.fold((l) {
        logger.safeLog(l);
        isLoading.value = false;
      }, (r) {
        if (page == 0) {
          voucherList.value = r.data!;
        } else {
          voucherList.addAll(r.data!);
        }
        pagination.value = r.pagination!;
        isLoading.value = false;
        visibleLoadMore.value = false;
      });
    } catch (e) {
      logger.safeLog(e);
      isLoading.value = false;
    }
    update();
  }

  doPreparedPotongan(int page) async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      var result;
      List<FilterQuery> dataFilter = [];
      Map<String, dynamic> param = {
        'page': page.toString(),
        'size': PAGINATIONS_CONSTANT.LIMIT_PAGE.toString(),
        'flMobile': 'Y',
        'locationId': sessionUtil.getLocationId().toString(),
      };

      result = await _service.sale.voucherService.getAllPotongan(
        authToken: _authToken,
        dataFilter: dataFilter,
        paramsFilter: param,
      );

      result.fold((l) {
        logger.safeLog(l);
        isLoading.value = false;
      }, (r) {
        if (page == 0) {
          potonganList.value = r.data!;
        } else {
          potonganList.addAll(r.data!);
        }
        pagination.value = r.pagination!;
        isLoading.value = false;
        visibleLoadMore.value = false;
      });
    } catch (e) {
      logger.safeLog(e);
      isLoading.value = false;
    }
    update();
  }

  doPreparedDeposit(int page, String? search) async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      var result;
      List<FilterQuery> dataFilter = [];
      Map<String, dynamic> param = {
        'page': page.toString(),
        'size': PAGINATIONS_CONSTANT.LIMIT_PAGE.toString(),
        'search': search,
        // 'flMobile': 'Y',
        // 'locationId': sessionUtil.getLocationId().toString(),
      };

      dataFilter.add(
        apiFilterUtil.addSearch(
          'dpLocId',
          OPERATOR_CONSTANTS.EQUALS,
          sessionUtil.getLocationId().toString(),
        )!,
      );
      dataFilter.add(
        apiFilterUtil.addSearch(
          'dpState',
          OPERATOR_CONSTANTS.EQUALS,
          'Y',
        )!,
      );

      result = await _service.sale.voucherService.getAllDeposit(
        authToken: _authToken,
        dataFilter: dataFilter,
        paramsFilter: param,
      );

      result.fold((l) {
        logger.safeLog(l);
        isLoading.value = false;
      }, (r) {
        if (page == 0) {
          depositList.value = r.data!;
        } else {
          depositList.addAll(r.data!);
        }
        pagination.value = r.pagination!;
        isLoading.value = false;
        visibleLoadMore.value = false;
      });
    } catch (e) {
      logger.safeLog(e);
      isLoading.value = false;
    }
    update();
  }

  doSearch() async {
    await doPrepareList(page: 0, search: searchController.text);
  }
}
