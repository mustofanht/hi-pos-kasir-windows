import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/data/models/cart/cart_addon_model.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/customer/customer_sale_cart_page_controller.dart';

class CustomerSaleCartPage extends GetView<CustomerSaleCartPageController> {
  const CustomerSaleCartPage({super.key});

  Widget headerSection(CustomerSaleCartPageController controller) {
    return Container(
      width: layoutStyle.screenWidth,
      padding: EdgeInsets.all(layoutStyle.defaultMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reference No.',
            style: TextStyle(
              color: colorStyle.grey,
              fontSize: fontSize.title,
            ),
          ),
          Text(
            controller.reffNo.value,
            style: TextStyle(
              fontSize: fontSize.title,
              fontWeight: fontWeight.bold,
            ),
          ),
          SizedBox(
            height: layoutStyle.defaultMargin,
          ),
          Text(
            'Total',
            style: TextStyle(
              color: colorStyle.grey,
              fontSize: fontSize.title,
            ),
          ),
          Text(
            'Rp.${common.currencyFormat(controller.totalOrder.value)}',
            style: TextStyle(
              fontSize: fontSize.body * 2,
              fontWeight: fontWeight.bold,
            ),
          ),
          SizedBox(
            height: layoutStyle.defaultMargin,
          ),
          Text(
            'Biaya Admin',
            style: TextStyle(
              color: colorStyle.grey,
              fontSize: fontSize.title,
            ),
          ),
          Text(
            'Rp.${common.currencyFormat(controller.paymentFee.value)}',
            style: TextStyle(
              fontSize: fontSize.title,
            ),
          ),
        ],
      ),
    );
  }

  Widget contentCart(CustomerSaleCartPageController controller) {
    return Expanded(
      child: (controller.ticketList.isEmpty &&
              controller.potonganList.isEmpty &&
              controller.voucherList.isEmpty &&
              controller.depositList.isEmpty &&
              controller.addonList.isEmpty && 
              controller.memberList.isEmpty
              )
          ? notOrder()
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                margin:
                    EdgeInsets.symmetric(vertical: layoutStyle.defaultMargin),
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Container(
                      width: layoutStyle.screenWidth,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: colorStyle.lightGrey,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: layoutStyle.defaultMargin,
                    ),
                    if (controller.ticketList.isNotEmpty) ...[
                      ticketListComponent(controller),
                    ] else
                      Container(),
                    if (controller.addonList.isNotEmpty) ...[
                      addonListComponent(controller)
                    ] else
                      Container(),
                    if (controller.potonganList.isNotEmpty) ...[
                      potonganListComponent(controller)
                    ] else
                      Container(),
                    if (controller.voucherList.isNotEmpty) ...[
                      voucherListComponent(controller)
                    ] else
                      Container(),
                    if (controller.depositList.isNotEmpty) ...[
                      depositListComponent(controller)
                    ] else
                      Container(),
                    if (controller.memberList.isNotEmpty) ...[
                      memberListComponent(controller)
                    ] else
                      Container(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget ticketListComponent(CustomerSaleCartPageController controller) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.symmetric(horizontal: layoutStyle.defaultMargin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: controller.ticketList
            .map(
              (e) => Container(
                margin: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 2,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            e.ticket != null ? e.ticket!.ticketName ?? '' : '',
                            style: TextStyle(
                              fontSize: fontSize.title,
                            ),
                          ),
                          SizedBox(
                            height: layoutStyle.defaultMargin / 5,
                          ),
                          Text(
                            'QTY ${e.qtyOrder}',
                            style: TextStyle(
                              color: colorStyle.grey,
                              fontSize: fontSize.subtitle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.topRight,
                      child: Text(
                        'Rp.${common.currencyFormat(e.totalPrice ?? 0)}',
                        style: TextStyle(
                          fontSize: fontSize.title,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget potonganListComponent(CustomerSaleCartPageController controller) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.symmetric(horizontal: layoutStyle.defaultMargin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: controller.potonganList
            .map(
              (e) => Container(
                margin: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 2,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            e.potongan!.voucherName ?? '',
                            style: TextStyle(
                              fontSize: fontSize.title,
                            ),
                          ),
                          SizedBox(
                            height: layoutStyle.defaultMargin / 5,
                          ),
                          Text(
                            'QTY ${e.qtyOrder}',
                            style: TextStyle(
                              color: colorStyle.grey,
                              fontSize: fontSize.subtitle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.topRight,
                      child: Text(
                        e.potongan!.voucherUnitType == UnitType.PERCENT
                            ? ('${e.potongan!.voucherUnitValue} %')
                            : ('Rp${common.currencyFormat(e.potongan!.voucherUnitValue ?? 0)}'),
                        // '- Rp.${common.currencyFormat(e.totalPrice ?? 0)}',
                        style: TextStyle(
                          fontSize: fontSize.title,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
  
  Widget voucherListComponent(CustomerSaleCartPageController controller) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.symmetric(horizontal: layoutStyle.defaultMargin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: controller.voucherList
            .map(
              (e) => Container(
                margin: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 2,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            e.entity?.vpName ?? '',
                            style: TextStyle(
                              fontSize: fontSize.title,
                            ),
                          ),
                          SizedBox(
                            height: layoutStyle.defaultMargin / 5,
                          ),
                          Text(
                            'QTY ${e.qtyOrder}',
                            style: TextStyle(
                              color: colorStyle.grey,
                              fontSize: fontSize.subtitle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.topRight,
                      child: Text(
                        e.entity?.vpUnitType == UnitType.PERCENT
                            ? ('${e.entity?.vpUnitValue} %')
                            : ('Rp${common.currencyFormat(e.entity?.vpUnitValue ?? 0)}'),
                        // '- Rp.${common.currencyFormat(e.totalPrice ?? 0)}',
                        style: TextStyle(
                          fontSize: fontSize.title,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
  
  Widget depositListComponent(CustomerSaleCartPageController controller) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.symmetric(horizontal: layoutStyle.defaultMargin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: controller.depositList
            .map(
              (e) => Container(
                margin: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 2,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            e.deposit?.dpName ?? '',
                            style: TextStyle(
                              fontSize: fontSize.title,
                            ),
                          ),
                          SizedBox(
                            height: layoutStyle.defaultMargin / 5,
                          ),
                          Text(
                            'QTY ${e.qtyOrder}',
                            style: TextStyle(
                              color: colorStyle.grey,
                              fontSize: fontSize.subtitle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.topRight,
                      child: Text(
                        ('Rp${common.currencyFormat(e.deposit?.dpAmount ?? 0)}'),
                        // e.deposit!.voucherUnitType == UnitType.PERCENT
                        //     ? ('${e.potongan!.voucherUnitValue} %')
                        //     : ('Rp${common.currencyFormat(e.potongan!.voucherUnitValue ?? 0)}'),
                        // '- Rp.${common.currencyFormat(e.totalPrice ?? 0)}',
                        style: TextStyle(
                          fontSize: fontSize.title,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget rentProductCart(CartAddon e) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: layoutStyle.defaultMargin / 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    // Text('${e.qtyOrder} X '),
                    Expanded(
                      child: Text(
                        '${e.addon!.productName ?? ''} (${e.rentModel!.startDate != null && e.rentModel!.endDate != null ? '${dateTimeUtil.getFormattedDate(date: e.rentModel!.startDate!, format: dateFormat.hourMinutes)} - ${dateTimeUtil.getFormattedDate(date: e.rentModel!.endDate!, format: dateFormat.hourMinutes)}' : ''})',
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                if (e.rentModel?.newBuyPrice != null)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Pembelian Baru ',
                          softWrap: true,
                          style: textStyle.greyText,
                        ),
                      ),
                      Text(
                        'Rp.${common.currencyFormat(e.rentModel!.newBuyPrice!)}',
                        style: textStyle.blackText,
                      ),
                    ],
                  ),
                // if (e.rentModel?.extraTimeBuyPrice != null)
                //   Row(
                //     children: [
                //       Expanded(
                //         child: Text(
                //           'Pembelian Extra Time',
                //           softWrap: true,
                //           style: textStyle.greyText,
                //         ),
                //       ),
                //       Text(
                //         'Rp.${common.currencyFormat(e.rentModel!.extraTimeBuyPrice!)}',
                //         style: textStyle.blackText,
                //       ),
                //     ],
                //   ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget addonListComponent(CustomerSaleCartPageController controller) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.symmetric(horizontal: layoutStyle.defaultMargin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: controller.addonList
            .map(
              (e) => e.rentModel != null
                  ? rentProductCart(e)
                  : Container(
                      margin: EdgeInsets.symmetric(
                        vertical: layoutStyle.defaultMargin / 2,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  e.addon!.productName ?? '',
                                  style: TextStyle(
                                    fontSize: fontSize.title,
                                  ),
                                ),
                                SizedBox(
                                  height: layoutStyle.defaultMargin / 5,
                                ),
                                Text(
                                  'QTY ${e.qtyOrder}',
                                  style: TextStyle(
                                    color: colorStyle.grey,
                                    fontSize: fontSize.subtitle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.topRight,
                            child: Text(
                              'Rp.${common.currencyFormat(e.totalPrice ?? 0)}',
                              style: TextStyle(
                                fontSize: fontSize.title,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            )
            .toList(),
      ),
    );
  }

  Widget memberListComponent(CustomerSaleCartPageController controller) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.symmetric(horizontal: layoutStyle.defaultMargin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: controller.memberList
            .map(
              (e) => Container(
                margin: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 2,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            e.membName ?? '',
                            style: TextStyle(
                              fontSize: fontSize.title,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.topRight,
                      child: Text(
                        'Rp.${common.currencyFormat(e.membRegPrice ?? 0)}',
                        style: TextStyle(
                          fontSize: fontSize.title,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget notOrder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            assetsConstant.imgEmptyBox,
            // fit: BoxFit.contain,
            width: layoutStyle.blockHorizontal * 30,
            height: layoutStyle.blockVertical * 30,
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    Get.put(CustomerSaleCartPageController());

    return GetBuilder(
      init: controller,
      tag: 'CustomerSaleCartPage',
      initState: (state) {
        controller;
      },
      builder: (controller) {
        return Container(
          width: layoutStyle.screenWidth / 3,
          // height: layoutStyle.screenHeight,
          color: colorStyle.white,
          child: Column(
            children: [
              headerSection(controller),
              contentCart(controller),
            ],
          ),
        );
      },
    );
  }
}
