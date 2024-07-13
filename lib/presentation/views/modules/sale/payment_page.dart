// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jaya_propertiy/app/utils/common/app_common.dart';
// import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
// import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
// import 'package:jaya_propertiy/presentation/components/custom_button.dart';
// import 'package:jaya_propertiy/presentation/components/custom_dropdown_button.dart';
// import 'package:jaya_propertiy/presentation/components/custom_textbox.dart';
// import 'package:jaya_propertiy/presentation/controllers/modules/payment_page_controller.dart';

// class PaymentPage extends GetView<PaymentPageController> {
//   const PaymentPage({super.key});

//   // Widget formPayment(PaymentPageController contro) {}

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<PaymentPageController>(
//       init: controller,
//       initState: (state) {
//         controller.doPrepared();
//       },
//       builder: (controller) {
//         return Expanded(
//           child: ListView(
//             padding: EdgeInsets.symmetric(
//                 vertical: layoutStyle.defaultMargin / 4,
//                 horizontal: layoutStyle.defaultMargin),
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(
//                     horizontal: layoutStyle.defaultMargin,
//                     vertical: layoutStyle.defaultMargin / 2),
//                 child: Align(
//                   alignment: Alignment.topLeft,
//                   child: Row(
//                     children: [
//                       SizedBox(
//                         width: layoutStyle.blockHorizontal * 4,
//                         height: layoutStyle.blockVertical * 5,
//                         child: CustomButton(
//                           onPressed: () {
//                             controller.salePageController.onOpenPayment(false);
//                           },
//                           style: ButtonStyle(
//                             backgroundColor: MaterialStateProperty.all<Color>(
//                                 colorStyle.white),
//                             foregroundColor: MaterialStateProperty.all<Color>(
//                                 colorStyle.primary),
//                             overlayColor: MaterialStateProperty.all<Color>(
//                                 colorStyle.primary.withOpacity(0.1)),
//                             side: MaterialStateProperty.all<BorderSide>(
//                                 BorderSide(
//                                     color: colorStyle.primary, width: 1)),
//                             padding:
//                                 MaterialStateProperty.all<EdgeInsetsGeometry>(
//                                     EdgeInsets.symmetric(
//                                         vertical: layoutStyle.defaultMargin / 5,
//                                         horizontal:
//                                             layoutStyle.defaultMargin / 5)),
//                             elevation: MaterialStateProperty.all<double>(0),
//                             alignment: Alignment.center,
//                           ),
//                           label: const Icon(
//                             Icons.arrow_back,
//                           ),
//                           height: double.infinity,
//                         ),
//                       ),
//                       Expanded(
//                         child: Center(
//                           child: Text(
//                             'Total Pembayaran',
//                             style: TextStyle(
//                               fontSize: fontSize.title,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Center(
//                 child: Text(
//                   common.currencyFormat(controller.totalOrder.value),
//                   style: TextStyle(
//                     fontSize: fontSize.header * 2,
//                     fontWeight: fontWeight.bold,
//                   ),
//                 ),
//               ),
//               CustomTextBox(
//                 height: layoutStyle.blockVertical * 6.5,
//                 margin: EdgeInsets.symmetric(
//                   horizontal: layoutStyle.defaultMargin,
//                   vertical: layoutStyle.defaultMargin / 4,
//                 ),
//                 obscureText: false,
//                 border: Border.all(
//                   color: colorStyle.grey,
//                   width: 1,
//                 ),
//                 borderRadius: BorderRadius.circular(
//                   layoutStyle.defaultMargin / 2,
//                 ),
//                 label: Text(
//                   'Nama Pemesanan',
//                   style: textStyle.greyText.copyWith(
//                     fontSize: fontSize.small,
//                   ),
//                 ),
//                 controller: controller.orderNameController,
//                 decoration: InputDecoration(
//                   hintText: 'Tulis Nama',
//                   hintStyle: textStyle.greyText,
//                   border: InputBorder.none,
//                 ),
//               ),
//               CustomTextBox(
//                 height: layoutStyle.blockVertical * 6.5,
//                 margin: EdgeInsets.symmetric(
//                   horizontal: layoutStyle.defaultMargin,
//                   vertical: layoutStyle.defaultMargin / 4,
//                 ),
//                 obscureText: false,
//                 border: Border.all(
//                   color: colorStyle.grey,
//                   width: 1,
//                 ),
//                 borderRadius: BorderRadius.circular(
//                   layoutStyle.defaultMargin / 2,
//                 ),
//                 label: Text(
//                   'Email',
//                   style: textStyle.greyText.copyWith(
//                     fontSize: fontSize.small,
//                   ),
//                 ),
//                 controller: controller.emailController,
//                 decoration: InputDecoration(
//                   hintText: 'Tulis Email',
//                   hintStyle: textStyle.greyText,
//                   border: InputBorder.none,
//                 ),
//               ),
//               CustomTextBox(
//                 height: layoutStyle.blockVertical * 6.5,
//                 margin: EdgeInsets.symmetric(
//                   horizontal: layoutStyle.defaultMargin,
//                   vertical: layoutStyle.defaultMargin / 4,
//                 ),
//                 obscureText: false,
//                 border: Border.all(
//                   color: colorStyle.grey,
//                   width: 1,
//                 ),
//                 borderRadius: BorderRadius.circular(
//                   layoutStyle.defaultMargin / 2,
//                 ),
//                 label: Text(
//                   'No WA',
//                   style: textStyle.greyText.copyWith(
//                     fontSize: fontSize.small,
//                   ),
//                 ),
//                 controller: controller.noWaController,
//                 decoration: InputDecoration(
//                   hintText: 'Nomor Whatsaap',
//                   hintStyle: textStyle.greyText,
//                   border: InputBorder.none,
//                 ),
//               ),
//               CustomDropdownButton<CustomIdNameEntity>(
//                 height: layoutStyle.blockVertical * 6.5,
//                 items: controller.paymentType
//                     .map(
//                       (e) => DropdownMenuItem(
//                         value: e,
//                         child: Text("${e.name}"),
//                       ),
//                     )
//                     .toList(),
//                 value: controller.selectedPaymentType.value,
//                 label: Text(
//                   'Problem Type',
//                   style: textStyle.greyText.copyWith(
//                     fontSize: fontSize.small,
//                   ),
//                 ),
//                 border: Border.all(
//                   color: colorStyle.lightGrey,
//                   width: 1,
//                 ),
//                 margin: EdgeInsets.symmetric(
//                   vertical: layoutStyle.defaultMargin / 4,
//                   horizontal: layoutStyle.defaultMargin,
//                 ),
//                 onChanged: (value) {
//                   // controller.selectedPaymentType.value = value!;
//                   controller.doSelectPaymentType(value!);
//                 },
//               ),
//               controller.showReffId.value
//                   ? CustomTextBox(
//                       height: layoutStyle.blockVertical * 6.5,
//                       margin: EdgeInsets.symmetric(
//                         horizontal: layoutStyle.defaultMargin,
//                         vertical: layoutStyle.defaultMargin / 4,
//                       ),
//                       obscureText: false,
//                       border: Border.all(
//                         color: colorStyle.grey,
//                         width: 1,
//                       ),
//                       borderRadius: BorderRadius.circular(
//                         layoutStyle.defaultMargin / 2,
//                       ),
//                       label: Text(
//                         'Reference ID',
//                         style: textStyle.greyText.copyWith(
//                           fontSize: fontSize.small,
//                         ),
//                       ),
//                       controller: controller.referenceIdController,
//                       decoration: InputDecoration(
//                         hintText: '-',
//                         hintStyle: textStyle.greyText,
//                         border: InputBorder.none,
//                       ),
//                     )
//                   : Container(),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
