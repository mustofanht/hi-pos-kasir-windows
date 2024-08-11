import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
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
        ],
      ),
    );
  }

  Widget contentCart(CustomerSaleCartPageController controller) {
    return Expanded(
      child: (controller.ticketList.isEmpty &&
              controller.voucherList.isEmpty &&
              controller.addonList.isEmpty)
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
                    if (controller.voucherList.isNotEmpty) ...[
                      voucherListComponent(controller)
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
                            e.voucher!.voucherName ?? '',
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
                        '- Rp.${common.currencyFormat(e.totalPrice ?? 0)}',
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

  Widget addonListComponent(CustomerSaleCartPageController controller) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.symmetric(horizontal: layoutStyle.defaultMargin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: controller.addonList
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
