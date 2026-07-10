import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/data/models/common/custom_table_data.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/common/pagination.dart';
import 'package:jaya_propertiy/domain/entities/member/member_card.dart';
import 'package:jaya_propertiy/domain/entities/member/member_valid.dart';
import 'package:jaya_propertiy/domain/entities/member/membership.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/cart_member_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/member_page_controller.dart';

class InqMemberPageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  InqMemberPageController();

  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];

  final searchController = TextEditingController();
  final listColumnHeader = <CustomTableData>[].obs;
  // final selectedData = Member().obs;

  final ScrollController scrollController = ScrollController();
  late AnimationController animationController;

  final pagination = Pagination().obs;

  final dataList = <MemberCard>[].obs;
  final isLoading = false.obs;

  final selectedMemberValid = MemberValid().obs;

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
    selectedMemberValid.value = MemberValid();
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
        id: 'cardNo',
        columnName: 'Nomer',
        width: layoutStyle.blockHorizontal * 20,
        alignment: Alignment.centerLeft,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'cardName',
        columnName: 'Nama',
        alignment: Alignment.centerLeft,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'membName',
        columnName: 'Membership',
        alignment: Alignment.centerLeft,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'expiredDate',
        columnName: 'Masa Berlaku',
        alignment: Alignment.center,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'status',
        columnName: 'Status',
        alignment: Alignment.center,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'cardKuota',
        columnName: 'Kuota',
        alignment: Alignment.center,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'resetPeriodName',
        columnName: 'Perpanjang',
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
      result = await _service.member.getMemberCardInq(
        authToken: _authToken,
        page: page,
        search: search,
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
    update();
  }

  goToDetail(MemberCard? val) async {
    // selectedData.value = val!;
    bool isExists = await checkMemberValidation(val);
    if (isExists) return;

    if (Get.isRegistered<MemberPageController>()) {
      final headerController = Get.find<MemberPageController>();
      headerController.gotTo(MemberRouteName.newMember);
    }
    update();
  }

  Future<bool> checkMemberValidation(MemberCard? val) async {
    bool isExists = false;
    // logger.safeLog('val.cardKuota : ${val?.cardKuota}');
    // if (val != null && val.cardKuota != null) {
    if (val != null) {
      try {
        var result;
        result = await _service.member.memberValid(
          authToken: _authToken,
          cardNo: val.cardNo!,
        );
        result.fold(
          (l) {
            logger.safeLog(l);
          },
          (r) {
            logger.safeLog(r);
            MemberValid memberValid = r.data;
            Membership membership = memberValid.mstMembership ?? Membership();
            selectedMemberValid.value = memberValid;

            if (Get.isRegistered<MemberPageController>()) {
              final headerController = Get.find<MemberPageController>();
              headerController.gotTo(MemberRouteName.createMember);
            }

            if (Get.isRegistered<CartMemberController>()) {
              final cartController = Get.find<CartMemberController>();
              cartController.addCartMembership(membership);
            }
            isExists = true;
          },
        );
      } catch (e) {
        logger.safeLog(e);
      }
    }
    return isExists;
  }
}
