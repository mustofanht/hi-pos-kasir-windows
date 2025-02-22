import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/common/filter_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
import 'package:jaya_propertiy/domain/entities/masterdata/mst_payment.dart';
import 'package:jaya_propertiy/domain/entities/member/membership.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/cart_member_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/member_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/new_member_page_controller.dart';

class CreateMemberPageController extends GetxController {
  final Membership membership;
  CreateMemberPageController({
    required this.membership,
  });

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

  var anggotaList = <int>[].obs;
  var anggotaNamaControllers = <TextEditingController>[].obs;
  var anggotaSelectedRelations = <CustomIdNameEntity>[].obs;

  var listRelation = <CustomIdNameEntity>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    preparePaymentMethod();
    doInitializeMemberRelation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  doInitializeMemberRelation() {
    listRelation.add(
      CustomIdNameEntity(
        id: MemberRelation.ANAK,
        name: MemberRelation.getName(MemberRelation.ANAK),
      ),
    );
    listRelation.add(
      CustomIdNameEntity(
        id: MemberRelation.SAUDARA,
        name: MemberRelation.getName(MemberRelation.SAUDARA),
      ),
    );
    update();
  }

  bool isValidValueRelation(
      CustomIdNameEntity? value, List<CustomIdNameEntity> items) {
    return value == null || items.any((item) => item.id == value.id);
  }

  doBack() {
    if (Get.isRegistered<CartMemberController>()) {
      final cartController = Get.find<CartMemberController>();
      cartController.cancelOrder();
    }
    if (Get.isRegistered<MemberPageController>()) {
      final headerController = Get.find<MemberPageController>();
      headerController.goBack();
    }
    update();
  }

  doSelectPaymentType(CustomIdNameEntity value) {
    logger.safeLog('doSelectPaymentType');
    selectedPaymentType.value = value;
    MstPayment mstPayment = mstPayments.firstWhere(
      (e) => e.pymntCode == value.id,
    );
    final CartMemberController saleCartPageController =
        Get.find<CartMemberController>();
    saleCartPageController.selectedMstPayment.value = mstPayment;
    saleCartPageController.calculateMemberAmount();
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

  void addAnggota() {
    int index = anggotaList.length;
    if (index < (membership.membMaxKuota ?? 0)) {
      anggotaList.add(index);
      anggotaNamaControllers.add(TextEditingController());
      anggotaSelectedRelations
          .add(CustomIdNameEntity(id: '', name: 'Pilih Printer'));
    } else {
      alert.warning('Warning', 'Maximal 2 anggota');
    }
  }

  void removeAnggota(int index) {
    if (index < anggotaList.length) {
      anggotaList.removeAt(index);
      anggotaNamaControllers.removeAt(index);
      anggotaSelectedRelations.removeAt(index);
    }
  }
}
