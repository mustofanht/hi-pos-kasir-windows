import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/filter_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/cart/cart_addon_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_rent_model.dart';
import 'package:jaya_propertiy/data/models/common/filter_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
import 'package:jaya_propertiy/domain/entities/common/pagination.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_cart_page_controller.dart';

class SaleAddonPageController extends GetxController {
  SaleAddonPageController();
  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];

  final scrollController = ScrollController();
  final pagination = Pagination().obs;

  final addonList = <AddonEntity>[].obs;
  final isLoading = false.obs;
  final visibleLoadMore = false.obs;

  final typeItemList = <CustomIdNameEntity>[].obs;
  final selectedTypeItemList = CustomIdNameEntity().obs;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(scrollHandler);
    doPrepareList(page: 0, typeProduct: 'H');
    doInitializeItemTypeList();
  }

  doInitializeItemTypeList() {
    typeItemList.clear();
    typeItemList.add(CustomIdNameEntity(id: 'H', name: 'Sewa Per Jam'));
    typeItemList.add(CustomIdNameEntity(id: 'S', name: 'Sewa Harian'));
    typeItemList.add(CustomIdNameEntity(id: 'J', name: 'Jual'));
    update();
  }

  Future<void> doPrepareList({
    required int page,
    required String typeProduct,
  }) async {
    if (isLoading.value) return;
    isLoading.value = true;

    if (typeProduct == 'H') {
      await prepareItemHourly(page);
    } else {
      await prepareItem(page: page, typeProduct: typeProduct);
    }
    logger.safeLog('IS LOADING >>> ${isLoading.value}');
    update();
  }

  Future<void> prepareItem({
    required int page,
    required String typeProduct,
  }) async {
    try {
      var result;
      List<FilterQuery> dataFilter = [];
      Map<String, dynamic> param = {
        'page': page.toString(),
        'size': PAGINATIONS_CONSTANT.LIMIT_PAGE.toString(),
        'flMobile': 'Y',
        'locationId': sessionUtil.getLocationId().toString(),
        'typeProduct': typeProduct,
      };

      result = await _service.sale.addonService.getAll(
        authToken: _authToken,
        dataFilter: dataFilter,
        paramsFilter: param,
      );

      result.fold((l) {
        logger.safeLog(l);
        isLoading.value = false;
      }, (r) {
        if (page == 0) {
          addonList.value = r.data!;
        } else {
          addonList.addAll(r.data!);
        }
        pagination.value = r.pagination!;
        isLoading.value = false;
        visibleLoadMore.value = false;
      });
    } catch (e) {
      logger.safeLog(e);
      isLoading.value = false;
    }
  }

  Future<void> prepareItemHourly(int page) async {
    try {
      var result;
      result = await _service.sale.addonService.getHourly(
        authToken: _authToken,
        locationId: sessionUtil.getLocationId(),
        page: page,
      );

      result.fold((l) {
        logger.safeLog(l);
        isLoading.value = false;
      }, (r) {
        if (page == 0) {
          addonList.value = r.data!;
        } else {
          addonList.addAll(r.data!);
        }
        pagination.value = r.pagination!;
        isLoading.value = false;
        visibleLoadMore.value = false;
      });
    } catch (e) {
      logger.safeLog(e);
      isLoading.value = false;
    }
  }

  Future<void> scrollHandler() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (pagination.value.currentPage! < pagination.value.totalPage!) {
        await doPrepareList(
            page: pagination.value.currentPage! + 1,
            typeProduct: selectedTypeItemList.value.id!);
      }
    }
  }

  onNextRental(
    SaleCartPageController saleCartPageController,
    CartRentModel cartRentModel,
    AddonEntity val,
    CartAddon? exists,
  ) async {
    if (cartRentModel.totalHours == 0) {
      alert.error('Error', 'Total Jam tidak boleh kosong!');
      return;
    }

    Get.back();

    var result;
    val.productPrice = 0;

    if (exists != null) {
      saleCartPageController.addonList.remove(exists);
    }

    result = await _service.rental.getPriceRental(
      authToken: _authToken,
      hours: cartRentModel.totalHours!,
      productId: val.productId!,
      orderNoExtra: cartRentModel.transactionExtra?.orderNumber,
    );

    CartRentModel cartRentModelAdded = cartRentModel;

    result.fold(
      (l) {
        logger.safeLog(l);
      },
      (r) {
        logger.safeLog(r.data);
        if (ProductRentalType.HOURS == val.productType) {
          // if (cartRentModelAdded.isExtraTime!) {
          //   cartRentModelAdded.extraTimeBuyPrice = r.data;
          // } else {
          //   cartRentModelAdded.newBuyPrice = r.data;
          // }
          cartRentModelAdded.newBuyPrice = r.data;
        } else {}
        val.productPrice = r.data;

        saleCartPageController.addAddonRent(
          val,
          cartRentModelAdded,
        );

        saleCartPageController.update();
        update();
      },
    );
  }

  addAddonToCart({required AddonEntity val}) async {
    final SaleCartPageController saleCartPageController;
    if (Get.isRegistered<SaleCartPageController>()) {
      saleCartPageController = Get.find<SaleCartPageController>();
    } else {
      saleCartPageController = Get.put(SaleCartPageController());
    }
    CartAddon? exists = saleCartPageController.addonList.firstWhereOrNull(
      (e) => e.addon!.productId == val.productId,
    );

    if (val.isBooked == 'Y') {
      closedRental(
        addonEntity: val,
        saleCartPageController: saleCartPageController,
        exists: exists,
      );
      return;
    }

    if (val.productType == ProductRentalType.HOURS) {
      // CartAddon? exists = saleCartPageController.addonList.firstWhereOrNull(
      //   (e) => e.addon!.productId == val.productId,
      // );

      await dialog.selectHourRent(
        authToken: _authToken,
        entitiy: val,
        detailModel: exists?.rentModel,
        onNext: (cartRentModel) => onNextRental(
          saleCartPageController,
          cartRentModel,
          val,
          exists,
        ),
      );
    } else {
      if (saleCartPageController.addonList.isEmpty) {
        saleCartPageController.addAddon(val);
      } else {
        // CartAddon? exists = saleCartPageController.addonList.firstWhereOrNull(
        //   (e) => e.addon!.productId == val.productId,
        // );

        if (exists != null) {
          exists.qtyOrder = (exists.qtyOrder ?? 0) + 1;
          exists.totalPrice =
              (exists.totalPrice ?? 0) + (val.productPrice ?? 0);
          saleCartPageController.calculateTotalOrder();
        } else {
          saleCartPageController.addAddon(val);
        }
      }
      saleCartPageController.update();
      update();
    }
  }

  Future<void> closedRental({
    required SaleCartPageController saleCartPageController,
    required AddonEntity addonEntity,
    CartAddon? exists,
  }) async {
    await dialog.dialodExtraTimeOrClosedRent(
      onExtraTime: () async {
        await dialog.selectHourRent(
          authToken: _authToken,
          entitiy: addonEntity,
          detailModel: exists?.rentModel,
          isExtraTime: true,
          onNext: (cartRentModel) => onNextRental(
            saleCartPageController,
            cartRentModel,
            addonEntity,
            exists,
          ),
        );
      },
      onClosed: () async {
        await dialog.closedRent(
          onNext: () async {
            try {
              var result;
              result = await _service.sale.addonService.closedRent(
                authToken: _authToken,
                orderAddId: addonEntity.productId,
              );

              result.fold((l) {
                logger.safeLog(l);
              }, (r) {
                logger.safeLog('r: $r');
              });
            } catch (e) {
              logger.safeLog(e);
            }
            Get.back();
            doPrepareList(page: 0, typeProduct: 'H');
          },
          entitiy: addonEntity,
          authToken: _authToken,
        );
      },
    );
  }
}
