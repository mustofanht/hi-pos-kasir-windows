import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/cart_member_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/member_page_controller.dart';

class CartMember extends GetView<CartMemberController> {
  const CartMember({super.key});

  Widget headerCart() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 0,
        horizontal: layoutStyle.defaultMargin,
      ),
      child: SizedBox(
        height: 50,
        width: layoutStyle.screenWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'PENDAFTARAN',
                  style: TextStyle(
                    color: colorStyle.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize.header,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget notOrder() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetsConstant.imgEmptyBox,
              width: layoutStyle.safeBlockHorizontal * 12,
              height: layoutStyle.safeBlockVertical * 12,
              // width: layoutStyle.,
              fit: BoxFit.contain,
              errorBuilder: (
                BuildContext context,
                Object exception,
                StackTrace? stackTrace,
              ) {
                return const Text('Img Not Found');
              },
            ),
            SizedBox(
              height: layoutStyle.defaultMargin,
            ),
            Text(
              'Belum Ada Pesanan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize.title,
                fontWeight: fontWeight.bold,
              ),
            ),
            SizedBox(
              height: layoutStyle.defaultMargin,
            ),
            Text(
              'Kamu belum melakukan pesanan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize.subtitle,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget footerCart(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(layoutStyle.defaultMargin),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              width: 1,
              color: colorStyle.lightGrey,
            ),
          ),
        ),
        child: Column(
          children: [
            // if (controller.selectedMstPayment.value.pymntFlBbnCust == 'Y')
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Biaya Admin',
                      style: textStyle.blackText,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Obx(
                        () => Text(
                          controller.selectedMstPayment.value.pymntTypeFee ==
                                  UnitType.PERCENT
                              ? 'Rp.${common.currencyFormat(controller.getPricePayemntFee())}'
                              : 'Rp.${common.currencyFormat(controller.getPricePayemntFee())}',
                          style: textStyle.blackText,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: layoutStyle.defaultMargin / 2,
            ),
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Total',
                      style: TextStyle(
                        color: colorStyle.black,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize.header * 1.5,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Rp.${common.currencyFormat(controller.finalTotalOrderAmt.value)}',
                        style: TextStyle(
                          color: colorStyle.black,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize.header * 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: layoutStyle.defaultMargin,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: () {
                      dialog.dialogDelete(
                        title: 'Warning',
                        msg:
                            'Apakah anda yakin akan membatalkan proses order di atas?',
                        onYes: () => controller.cancelOrder(),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(colorStyle.white),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(colorStyle.red),
                      overlayColor: MaterialStateProperty.all<Color>(
                          colorStyle.red.withOpacity(0.1)),
                      side: MaterialStateProperty.all<BorderSide>(
                          BorderSide(color: colorStyle.red, width: 1)),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
                      elevation: MaterialStateProperty.all<double>(
                          0), // Menghilangkan shadow dengan elevation 0
                    ),
                    label: const Text('Batal'),
                    height: layoutStyle.blockVertical * 6.5,
                  ),
                ),
                SizedBox(
                  width: layoutStyle.defaultMargin,
                ),
                Expanded(
                  child: CustomButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      controller.onPayment();
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(colorStyle.primary),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(colorStyle.white),
                      overlayColor: MaterialStateProperty.all<Color>(
                        colorStyle.white.withOpacity(0.1),
                      ),
                      side: MaterialStateProperty.all<BorderSide>(
                        BorderSide(
                          color: colorStyle.primary,
                          width: 1,
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(
                          vertical: layoutStyle.defaultMargin / 2,
                          horizontal: layoutStyle.defaultMargin / 2,
                        ),
                      ),
                      elevation: MaterialStateProperty.all<double>(
                          0), // Menghilangkan shadow dengan elevation 0
                    ),
                    label: const Text('Bayar'),
                    height: layoutStyle.blockVertical * 6.5,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget contentCart(CartMemberController controller) {
    return Expanded(
      child: (controller.membershipList.isEmpty)
          ? notOrder()
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding:
                    EdgeInsets.symmetric(vertical: layoutStyle.defaultMargin),
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    if (controller.membershipList.isNotEmpty) ...[
                      Container(
                        width: layoutStyle.screenWidth,
                        margin: EdgeInsets.symmetric(
                            horizontal: layoutStyle.defaultMargin),
                        padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: colorStyle.lightGrey,
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Text(
                          'Member',
                          style: TextStyle(
                            fontSize: fontSize.subtitle,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: layoutStyle.defaultMargin,
                      ),
                      memberListComponent(controller),
                      SizedBox(
                        height: layoutStyle.defaultMargin,
                      ),
                    ] else
                      Container(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget memberListComponent(CartMemberController controller) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.symmetric(horizontal: layoutStyle.defaultMargin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: controller.membershipList.map((e) {
          return Container(
            margin: EdgeInsets.symmetric(
              vertical: layoutStyle.defaultMargin / 10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    e.membName ?? '',
                    softWrap: true,
                  ),
                ),
                Text(
                  'Rp.${e.membRegPrice != null ? common.currencyFormat(e.membRegPrice!) : ''}',
                  style: textStyle.blackText,
                ),
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: Row(
                //     children: [
                //       Text(
                //         'Rp.${e.membRegPrice != null ? common.currencyFormat(e.membRegPrice!) : ''}',
                //       ),
                //       SizedBox(
                //         width: layoutStyle.defaultMargin,
                //       ),
                //       CustomButton(
                //         onPressed: () {},
                //         margin: EdgeInsets.symmetric(
                //           horizontal: layoutStyle.defaultMargin / 10,
                //         ),
                //         style: ButtonStyle(
                //           backgroundColor: MaterialStateProperty.all<Color>(
                //               colorStyle.transparent),
                //           foregroundColor: MaterialStateProperty.all<Color>(
                //               colorStyle.transparent),
                //           overlayColor: MaterialStateProperty.all<Color>(
                //               colorStyle.transparent),
                //           side: MaterialStateProperty.all<BorderSide>(
                //             BorderSide(
                //               color: colorStyle.transparent,
                //               width: 1,
                //             ),
                //           ),
                //           padding:
                //               MaterialStateProperty.all<EdgeInsetsGeometry>(
                //             const EdgeInsets.all(0),
                //           ),
                //           elevation: MaterialStateProperty.all<double>(0),
                //         ),
                //         label: Container(
                //           padding: EdgeInsets.all(
                //             layoutStyle.defaultMargin / 3,
                //           ),
                //           decoration: BoxDecoration(
                //             color: colorStyle.primary,
                //             borderRadius: BorderRadius.circular(
                //               layoutStyle.defaultMargin / 5,
                //             ),
                //           ),
                //           alignment: Alignment.center,
                //           child: Icon(
                //             Icons.edit,
                //             color: colorStyle.white,
                //             size: fontSize.title,
                //           ),
                //         ),
                //         width: layoutStyle.blockHorizontal * 3,
                //         height: layoutStyle.blockVertical * 5,
                //       ),
                //       CustomButton(
                //         onPressed: () {},
                //         margin: EdgeInsets.symmetric(
                //           horizontal: layoutStyle.defaultMargin / 10,
                //         ),
                //         style: ButtonStyle(
                //           backgroundColor: MaterialStateProperty.all<Color>(
                //               colorStyle.transparent),
                //           foregroundColor: MaterialStateProperty.all<Color>(
                //               colorStyle.transparent),
                //           overlayColor: MaterialStateProperty.all<Color>(
                //               colorStyle.transparent),
                //           side: MaterialStateProperty.all<BorderSide>(
                //             BorderSide(
                //               color: colorStyle.transparent,
                //               width: 1,
                //             ),
                //           ),
                //           padding:
                //               MaterialStateProperty.all<EdgeInsetsGeometry>(
                //             const EdgeInsets.all(0),
                //           ),
                //           elevation: MaterialStateProperty.all<double>(0),
                //         ),
                //         label: Image.asset(
                //           assetsConstant.icDelete,
                //           fit: BoxFit.contain,
                //         ),
                //         width: layoutStyle.blockHorizontal * 3,
                //         height: layoutStyle.blockVertical * 5,
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartMemberController());

    return GetBuilder(
      init: controller,
      tag: 'CartMember',
      initState: (state) {
        controller;
      },
      builder: (controller) {
        return Container(
          width: layoutStyle.screenWidth / 3,
          height: layoutStyle.screenHeight,
          color: colorStyle.white,
          child: Column(
            children: [
              headerCart(),
              contentCart(controller),
              footerCart(context),
            ],
          ),
        );
      },
    );
  }
}
