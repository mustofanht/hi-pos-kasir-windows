import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/auth/auth_token.dart';
import 'package:jaya_propertiy/domain/entities/common/pagination.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/domain/entities/transaction/transaction_entity.dart';

class CustomListTransactionController extends GetxController {
  final AddonEntity entitiy;
  final AuthToken authToken;
  CustomListTransactionController({
    required this.entitiy,
    required this.authToken,
  });

  final _service = MainService();

  final searchController = TextEditingController();

  final selectedTransaction = Rxn<TransactionEntity>(null);

  final listData = <TransactionEntity>[].obs;

  final isLoading = false.obs;

  final scrollController = ScrollController();
  final pagination = Pagination().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    scrollController.addListener(scrollHandler);
    doPrepered(page: 0);
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  void scrollHandler() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (pagination.value.currentPage! < pagination.value.totalPage!) {
        doPrepered(
          page: pagination.value.currentPage! + 1,
        );
      }
    }
  }

  doPrepered({required int page, String? search}) async {
    isLoading.value = true;

    try {
      var result;
      result = await _service.transaction.getTransactionRentalHistory(
        authToken: authToken,
        locId: sessionUtil.getLocationId()!,
        // prodId: entitiy.productId!,
        page: page,
        search: search,
      );

      result.fold(
        (l) {
          logger.safeLog(l);
          isLoading.value = false;
        },
        (r) {
          logger.safeLog(r.data);
          listData.value = r.data;
          isLoading.value = false;
        },
      );
    } catch (e) {
      logger.safeLog(e);
      isLoading.value = false;
    }
    update();
  }

  doSelected(TransactionEntity data) {
    selectedTransaction.value = data;
  }
}
