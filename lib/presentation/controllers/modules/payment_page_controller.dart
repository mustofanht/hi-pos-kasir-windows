// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jaya_propertiy/app/utils/common/display_util.dart';
// import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
// import 'package:jaya_propertiy/data/models/customer/customer_display_model.dart';
// import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
// import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
// import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_cart_page_controller.dart';
// import 'package:jaya_propertiy/presentation/controllers/modules/sale_page_controller.dart';

// class PaymentPageController extends GetxController {
//   PaymentPageController();

//   final SalePageController salePageController = Get.find<SalePageController>();
//   DisplayUtil displayUtil = DisplayUtil();

//   final paymentType = <CustomIdNameEntity>[].obs;
//   final selectedPaymentType = CustomIdNameEntity().obs;

//   final orderNameController = TextEditingController();
//   final emailController = TextEditingController();
//   final noWaController = TextEditingController();
//   final referenceIdController = TextEditingController();

//   final showReffId = true.obs;

//   final totalOrder = RxDouble(0);

//   doSelectPaymentType(CustomIdNameEntity value) {
//     selectedPaymentType.value = value;
//     showReffId.value = value.id != 'QRS' && value.id != 'EDC';
//     update();
//   }

//   doPrepared() {
//     showReffId.value = true;
//     // totalOrder.value = saleCartPageController.totalOrder.value;
//     doInitialValueDropdown();
//   }

//   doInitialValueDropdown() {
//     paymentType.clear();
//     paymentType.insert(
//       0,
//       CustomIdNameEntity(
//         id: null,
//         name: ' --- Pilih Pembayaran --- ',
//       ),
//     );
//     paymentType.insert(
//       1,
//       CustomIdNameEntity(
//         id: 'QRS',
//         name: 'Qris',
//       ),
//     );
//     paymentType.insert(
//       2,
//       CustomIdNameEntity(
//         id: 'EDC',
//         name: 'EDC',
//       ),
//     );
//     paymentType.insert(
//       3,
//       CustomIdNameEntity(
//         id: 'TRV',
//         name: 'Traveloka',
//       ),
//     );
//     paymentType.insert(
//       4,
//       CustomIdNameEntity(
//         id: 'TKT',
//         name: 'Tiket',
//       ),
//     );
//     selectedPaymentType.value = paymentType.first;
//   }

//   doPayment() {
//     if (selectedPaymentType.value.id == null) {
//       alert.warning('Warning', 'Pilih Pembayaran terlebih dahulu!');
//       return;
//     }
//     if (selectedPaymentType.value.id == 'QRS') {
//       displayUtil.updateSecondDisplay(
//         CustomerDisplay(
//           key: CustomerDisplayAction.ADD_CART,
//           value: {'BARCODE': 'value barcode'},
//         ).toJson(),
//       );
//     }
//   }
// }
