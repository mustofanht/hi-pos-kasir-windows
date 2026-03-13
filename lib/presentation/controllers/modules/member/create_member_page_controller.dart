import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/common/filter_model.dart';
import 'package:jaya_propertiy/data/models/order/order_member_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
import 'package:jaya_propertiy/domain/entities/masterdata/mst_payment.dart';
import 'package:jaya_propertiy/domain/entities/member/member_list.dart';
import 'package:jaya_propertiy/domain/entities/member/member_valid.dart';
import 'package:jaya_propertiy/domain/entities/member/membership.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/cart_member_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/member_page_controller.dart';

class CreateMemberPageController extends GetxController {
  final MemberValid? memberValid;
  final Membership membership;
  CreateMemberPageController({
    this.memberValid,
    required this.membership,
  });

  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];

  final noMemberController = TextEditingController();
  final noKtpController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
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
    prepareData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  prepareData() {
    if (memberValid != null) {
      noMemberController.text = memberValid?.cardNo ?? '';
      noKtpController.text = memberValid?.cardIdentityNo ?? '';
      nameController.text = memberValid?.cardName ?? '';
      emailController.text = memberValid?.cardEmail ?? '';
      addressController.text = memberValid?.cardAddress ?? '';
      noPhoneController.text = memberValid?.cardNoHp ?? '';

      if (memberValid!.memberListResponses != null &&
          memberValid!.memberListResponses!.isNotEmpty) {
        int index = anggotaList.length;
        for (var element in memberValid!.memberListResponses!) {
          anggotaList.add(index);
          TextEditingController nameValueController = TextEditingController(
            text: element.lsName,
          );
          CustomIdNameEntity relationValue = listRelation.firstWhere(
            (e) => e.id == element.lsRelCode,
          );

          anggotaNamaControllers.add(nameValueController);
          anggotaSelectedRelations.add(relationValue);
        }
      }
    }
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
    listRelation.add(
      CustomIdNameEntity(
        id: MemberRelation.ORANG_TUA,
        name: MemberRelation.getName(MemberRelation.ORANG_TUA),
      ),
    );
    listRelation.add(
      CustomIdNameEntity(
        id: MemberRelation.TEMAN,
        name: MemberRelation.getName(MemberRelation.TEMAN),
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
      cartController.clearOrder();
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
          .add(CustomIdNameEntity(id: '', name: 'Pilih Relasi'));
    } else {
      alert.warning('Warning', 'Maximal ${membership.membMaxKuota} anggota');
    }
  }

  void removeAnggota(int index) {
    if (index < anggotaList.length) {
      anggotaList.removeAt(index);
      anggotaNamaControllers.removeAt(index);
      anggotaSelectedRelations.removeAt(index);
    }
  }

  List<MemberListResponse> getSelectedRelations() {
    List<MemberListResponse> memberList = [];
    if (anggotaList.isNotEmpty) {
      for (var index in anggotaList) {
        TextEditingController nameRelations = anggotaNamaControllers[index];
        CustomIdNameEntity selectedRelations = anggotaSelectedRelations[index];
        memberList.add(
          MemberListResponse(
            lsName: nameRelations.text,
            lsRelCode: selectedRelations.id,
          ),
        );
      }
    }
    return memberList;
  }

  bool validateForm() {
    bool isValid = true;
    // if (isValid && noKtpController.text.isEmpty) {
    //   isValid = false;
    //   alert.warning('Warning', 'NO KTP Harus Di isi!');
    // }
    if (isValid && nameController.text.isEmpty) {
      isValid = false;
      alert.warning('Warning', 'Name Harus Di isi!');
    }
    if (isValid && emailController.text.isEmpty) {
      isValid = false;
      alert.warning('Warning', 'Email Harus Di isi!');
    }
    if (isValid && addressController.text.isEmpty) {
      isValid = false;
      alert.warning('Warning', 'Alamat Harus Di isi!');
    }
    if (isValid && noPhoneController.text.isEmpty) {
      isValid = false;
      alert.warning('Warning', 'No HP Harus Di isi!');
    }

    if (isValid && membership.membCheckName == 'Y' && anggotaList.isEmpty) {
      isValid = false;
      alert.warning('Warning', 'Minimal harus memiliki 1 Anggota!');
    }
    if (isValid && anggotaList.isNotEmpty) {
      for (var index in anggotaList) {
        TextEditingController nameRelations = anggotaNamaControllers[index];
        CustomIdNameEntity selectedRelations = anggotaSelectedRelations[index];
        if (isValid && nameRelations.text.isEmpty) {
          isValid = false;
          alert.warning('Warning', 'List data anggota harus lengkap!');
          break;
        }
        if (isValid &&
            (selectedRelations.id == null || selectedRelations.id!.isEmpty)) {
          isValid = false;
          alert.warning('Warning', 'List data anggota harus lengkap!');
          break;
        }
      }
    }
    return isValid;
  }

  OrderMemberModel getFormBodyOrder(
    String paymentMethod,
    String paymentMethodName,
  ) {
    return OrderMemberModel(
      custIdentityNo: noKtpController.text,
      orderName: nameController.text,
      orderPhoneNumber: noPhoneController.text,
      memberId: membership.membId,
      custAddres: addressController.text,
      orderEmail: emailController.text,
      orderMemberNo:
          noMemberController.text.isNotEmpty ? noMemberController.text : null,
      orderReffno: null,
      orderPaidBy: paymentMethod,
      membership: membership,
      listMember: getSelectedRelations(),
      // orderEmail: '',
    );
  }
}
