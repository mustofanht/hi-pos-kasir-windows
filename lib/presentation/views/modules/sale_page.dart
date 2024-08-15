import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale_page_controller.dart';
import 'package:jaya_propertiy/presentation/views/modules/sale/sale_addon_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/sale/sale_cart_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/sale/sale_ticket_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/sale/sale_voucher_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SalePage extends GetView<SalePageController> {
  const SalePage({super.key});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    Widget saleSection() {
      return Expanded(
        flex: 1,
        child: Column(
          children: <Widget>[
            Container(
              width: layoutStyle.screenWidth,
              color: colorStyle.lightGrey,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: layoutStyle.screenWidth / 6),
                child: TabBar(
                  controller: controller.tabController,
                  indicator: BoxDecoration(
                      color: colorStyle.white,
                      border: Border(
                        bottom: BorderSide(
                          color: colorStyle.primary,
                          width: 1.0,
                        ),
                      )),
                  labelColor: colorStyle.primary,
                  unselectedLabelColor: colorStyle.black,
                  tabs: const [
                    Tab(text: 'Ticket'),
                    Tab(text: 'Voucher'),
                    Tab(text: 'Item'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: const [
                  SaleTicketPage(),
                  SaleVoucherPage(),
                  SaleAddonPage(),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget paymentSection() {
      return Expanded(
        child: Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.symmetric(
            vertical: layoutStyle.defaultMargin / 4,
            horizontal: layoutStyle.defaultMargin,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              // padding: EdgeInsets.symmetric(
              //     vertical: layoutStyle.defaultMargin / 4,
              //     horizontal: layoutStyle.defaultMargin),
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: layoutStyle.defaultMargin,
                      vertical: layoutStyle.defaultMargin / 2),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: layoutStyle.blockHorizontal * 4,
                          height: layoutStyle.blockVertical * 5,
                          child: CustomButton(
                            onPressed: () {
                              controller.openPayment.value =
                                  !controller.openPayment.value;
                              controller.update();
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  colorStyle.white),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  colorStyle.primary),
                              overlayColor: MaterialStateProperty.all<Color>(
                                  colorStyle.primary.withOpacity(0.1)),
                              side: MaterialStateProperty.all<BorderSide>(
                                  BorderSide(
                                      color: colorStyle.primary, width: 1)),
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                      EdgeInsets.symmetric(
                                          vertical:
                                              layoutStyle.defaultMargin / 5,
                                          horizontal:
                                              layoutStyle.defaultMargin / 5)),
                              elevation: MaterialStateProperty.all<double>(0),
                              alignment: Alignment.center,
                            ),
                            label: const Icon(
                              Icons.arrow_back,
                            ),
                            height: double.infinity,
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Total Pembayaran',
                              style: TextStyle(
                                fontSize: fontSize.title,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    common.currencyFormat(controller.totalOrderAmnt.value),
                    style: TextStyle(
                      fontSize: fontSize.header * 2,
                      fontWeight: fontWeight.bold,
                    ),
                  ),
                ),
                CustomTextBox(
                  height: layoutStyle.blockVertical * 6.5,
                  margin: EdgeInsets.symmetric(
                    horizontal: layoutStyle.defaultMargin,
                    vertical: layoutStyle.defaultMargin / 4,
                  ),
                  obscureText: false,
                  border: Border.all(
                    color: colorStyle.grey,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(
                    layoutStyle.defaultMargin / 2,
                  ),
                  label: Text(
                    'Nama Pemesan',
                    style: textStyle.greyText.copyWith(
                      fontSize: fontSize.small,
                    ),
                  ),
                  controller: controller.orderNameController,
                  decoration: InputDecoration(
                    hintText: 'Tulis Nama',
                    hintStyle: textStyle.greyText,
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    logger.safeLog(val);
                  },
                ),
                CustomTextBox(
                  height: layoutStyle.blockVertical * 6.5,
                  margin: EdgeInsets.symmetric(
                    horizontal: layoutStyle.defaultMargin,
                    vertical: layoutStyle.defaultMargin / 4,
                  ),
                  obscureText: false,
                  border: Border.all(
                    color: colorStyle.grey,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(
                    layoutStyle.defaultMargin / 2,
                  ),
                  label: Text(
                    'Email',
                    style: textStyle.greyText.copyWith(
                      fontSize: fontSize.small,
                    ),
                  ),
                  controller: controller.emailController,
                  decoration: InputDecoration(
                    hintText: 'Tulis Email',
                    hintStyle: textStyle.greyText,
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                CustomTextBox(
                  height: layoutStyle.blockVertical * 6.5,
                  margin: EdgeInsets.symmetric(
                    horizontal: layoutStyle.defaultMargin,
                    vertical: layoutStyle.defaultMargin / 4,
                  ),
                  obscureText: false,
                  border: Border.all(
                    color: colorStyle.grey,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(
                    layoutStyle.defaultMargin / 2,
                  ),
                  label: Text(
                    'No WA',
                    style: textStyle.greyText.copyWith(
                      fontSize: fontSize.small,
                    ),
                  ),
                  controller: controller.noWaController,
                  decoration: InputDecoration(
                    hintText: 'Nomor Whatsaap',
                    hintStyle: textStyle.greyText,
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 13,
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: layoutStyle.defaultMargin,
                    vertical: layoutStyle.defaultMargin / 2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Pembayaran',
                        style: textStyle.greyText.copyWith(
                          fontSize: fontSize.small,
                        ),
                      ),
                      SizedBox(
                        height: layoutStyle.defaultMargin / 2,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: layoutStyle.defaultMargin / 2,
                        ),
                        child: Row(
                          children: controller.paymentType.map((element) {
                            String ic = assetsConstant.icPaymentQr;
                            String label = '';
                            if (PaymentMethod.QRIS == element.id) {
                              ic = assetsConstant.icPaymentQr;
                            } else if (PaymentMethod.EDC == element.id) {
                              ic = assetsConstant.icPaymentEdc;
                              label = 'EDC';
                            } else if (PaymentMethod.TRAVELOKA == element.id) {
                              ic = assetsConstant.icPaymentTraveloka;
                              label = 'Traveloka';
                            } else if (PaymentMethod.TICKET == element.id) {
                              ic = assetsConstant.icPaymentTiket;
                              label = 'Ticket.com';
                            }
                            if (element.id == null) {
                              return Container();
                            }
                            return GestureDetector(
                              onTap: () {
                                controller.doSelectPaymentType(element);
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: layoutStyle.defaultMargin,
                                ),
                                padding: EdgeInsets.all(
                                    layoutStyle.defaultMargin / 2),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: colorStyle.grey,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    layoutStyle.defaultMargin / 2,
                                  ),
                                  color:
                                      controller.selectedPaymentType.value.id ==
                                              element.id
                                          ? colorStyle.primary
                                          : colorStyle.white,
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(ic),
                                    if (label.isNotEmpty) ...[
                                      SizedBox(
                                        width: layoutStyle.defaultMargin / 2,
                                      ),
                                      Text(
                                        label,
                                        style: textStyle.blackText.copyWith(
                                            color: controller
                                                        .selectedPaymentType
                                                        .value
                                                        .id ==
                                                    element.id
                                                ? colorStyle.white
                                                : colorStyle.black),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                // CustomDropdownButton<CustomIdNameEntity>(
                //   height: layoutStyle.blockVertical * 6.5,
                //   items: controller.paymentType
                //       .map(
                //         (e) => DropdownMenuItem(
                //           value: e,
                //           child: Text("${e.name}"),
                //         ),
                //       )
                //       .toList(),
                //   value: controller.selectedPaymentType.value,
                //   label: Text(
                //     'Pilih Pembayaran',
                //     style: textStyle.greyText.copyWith(
                //       fontSize: fontSize.small,
                //     ),
                //   ),
                //   border: Border.all(
                //     color: colorStyle.lightGrey,
                //     width: 1,
                //   ),
                //   margin: EdgeInsets.symmetric(
                //     vertical: layoutStyle.defaultMargin / 4,
                //     horizontal: layoutStyle.defaultMargin,
                //   ),
                //   onChanged: (val) {
                //     controller.doSelectPaymentType(val!);
                //   },
                // ),
                // controller.showReffId.value
                //     ? CustomTextBox(
                //         height: layoutStyle.blockVertical * 6.5,
                //         margin: EdgeInsets.symmetric(
                //           horizontal: layoutStyle.defaultMargin,
                //           vertical: layoutStyle.defaultMargin / 4,
                //         ),
                //         obscureText: false,
                //         border: Border.all(
                //           color: colorStyle.grey,
                //           width: 1,
                //         ),
                //         borderRadius: BorderRadius.circular(
                //           layoutStyle.defaultMargin / 2,
                //         ),
                //         label: Text(
                //           'Reference ID',
                //           style: textStyle.greyText.copyWith(
                //             fontSize: fontSize.small,
                //           ),
                //         ),
                //         controller: controller.referenceIdController,
                //         decoration: InputDecoration(
                //           hintText: '-',
                //           hintStyle: textStyle.greyText,
                //           border: InputBorder.none,
                //         ),
                //         keyboardType: TextInputType.text,
                //       )
                //     : Container(),
              ],
            ),
          ),
        ),
      );
    }

    return GetBuilder(
      init: controller,
      tag: 'SaleCartPage',
      initState: (state) {},
      builder: (controller) {
        return Obx(
          () => Row(
            children: [
              if (!controller.openPayment.value) ...[
                saleSection(),
              ] else
                paymentSection(),
              const SaleCartPage()
            ],
          ),
        );
      },
    );
  }
}
