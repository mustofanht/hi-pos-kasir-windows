import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/api_filter_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/filter_constant.dart';
import 'package:jaya_propertiy/data/models/common/filter_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/common/pagination.dart';
import 'package:jaya_propertiy/domain/entities/member/membership.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/cart_member_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/member_page_controller.dart';

class NewMemberPageController extends GetxController {
  NewMemberPageController();

  final _service = MainService();
  // final _authToken = Get.arguments[argConstant.authToken];

  final headerController = Get.find<MemberPageController>();

  final scrollController = ScrollController();
  final pagination = Pagination().obs;

  final dataList = <Membership>[].obs;
  final selectedMembership = Membership().obs;
  final isLoading = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    scrollController.addListener(scrollHandler);
    await doPrepareList(page: 0);
  }

  Future<void> scrollHandler() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (pagination.value.currentPage! < pagination.value.totalPage!) {
        await doPrepareList(page: pagination.value.currentPage! + 1);
      }
    }
  }

  Future<void> doPrepareList({required int page}) async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      var result;
      List<FilterQuery> dataFilter = [];
      Map<String, dynamic> param = {
        'page': page.toString(),
        'size': PAGINATIONS_CONSTANT.LIMIT_PAGE.toString(),
      };

      dataFilter.add(
        apiFilterUtil.addSearch(
          'membLocId',
          OPERATOR_CONSTANTS.EQUALS,
          sessionUtil.getLocationId(),
        )!,
      );
      dataFilter.add(
        apiFilterUtil.addSearch(
          'membState',
          OPERATOR_CONSTANTS.EQUALS,
          'Y',
        )!,
      );

      result = await _service.member.getMembership(
        authToken: headerController.authToken,
        dataFilter: dataFilter,
        paramsFilter: param,
      );

      result.fold((l) {
        logger.safeLog(l);
        isLoading.value = false;
      }, (r) {
        if (page == 0) {
          dataList.value = r.data!;
        } else {
          dataList.addAll(r.data!);
        }
        pagination.value = r.pagination!;
        isLoading.value = false;
      });
    } catch (e) {
      logger.safeLog(e);
      isLoading.value = false;
    }
    update();
    logger.safeLog('END Prepared List MemberShip');
    logger.safeLog('isLoading: ${isLoading.value}');
  }

  doBack() {
    if (Get.isRegistered<MemberPageController>()) {
      final headerController = Get.find<MemberPageController>();
      headerController.goBack();
    }
    update();
  }

  doSelectMembership(Membership membership) {
    selectedMembership.value = membership;
    headerController.gotTo(MemberRouteName.createMember);

    if (Get.isRegistered<CartMemberController>()) {
      final cartController = Get.find<CartMemberController>();
      cartController.addCartMembership(selectedMembership.value);
    }
    update();
  }
}
