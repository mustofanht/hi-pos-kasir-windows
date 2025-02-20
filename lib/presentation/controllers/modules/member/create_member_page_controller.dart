import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/common/filter_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
import 'package:jaya_propertiy/domain/entities/masterdata/mst_payment.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/member_page_controller.dart';

class CreateMemberPageController extends GetxController {
  CreateMemberPageController();
  
  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];

  final noMemberController = TextEditingController();
  final noKtpController = TextEditingController();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final noPhoneController = TextEditingController();

  
  final paymentType = <CustomIdNameEntity>[].obs;
  final selectedPaymentType = CustomIdNameEntity().obs;
  final isLoadingPayment = false.obs;
  final mstPayments = <MstPayment>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    preparePaymentMethod();
  }

  @override
  void dispose() {
    super.dispose();
  }


  doBack() {
    if (Get.isRegistered<MemberPageController>()) {
      final headerController = Get.find<MemberPageController>();
      headerController.gotTo(MemberRouteName.newMember);
    }
    update();
  }

  
  doSelectPaymentType(CustomIdNameEntity value) {
    logger.safeLog('doSelectPaymentType');
    selectedPaymentType.value = value;
    // MstPayment mstPayment = mstPayments.firstWhere(
    //   (e) => e.pymntCode == value.id,
    // );
    // final SaleCartPageController saleCartPageController =
    //     Get.find<SaleCartPageController>();
    // saleCartPageController.selectedMstPayment.value = mstPayment;
    // saleCartPageController.calculateTotalOrder();
    update();
  }

  preparePaymentMethod() async {
    paymentType.clear();
    var result;
    List<FilterQuery> dataFilter = [];
    Map<String, dynamic> param = {
      'page': '0',
      'size': '999',
      'flMobile': 'Y',
    };

    isLoadingPayment.value = true;
    try {
      result = await _service.masterData.getAll(
        authToken: _authToken,
        dataFilter: dataFilter,
        paramsFilter: param,
      );

      result.fold((l) {
        logger.safeLog(l);
        isLoadingPayment.value = false;
      }, (r) {
        if (r.data != null) {
          mstPayments.value = r.data;
          for (var element in mstPayments) {
            paymentType.add(
              CustomIdNameEntity(
                id: element.pymntCode,
                name: element.pymntName,
              ),
            );
          }
        }
        isLoadingPayment.value = false;
      });
    } catch (e) {
      isLoadingPayment.value = false;
      logger.safeLog(e);
    }
    update();
  }
}
