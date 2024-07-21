import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_cart_page_controller.dart';

class SaleCartPage extends GetView<SaleCartPageController> {
  const SaleCartPage({super.key});

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
                  'Pesanan',
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

  Widget contentCart(SaleCartPageController controller) {
    return Expanded(
      child: (controller.ticketList.isEmpty &&
              controller.voucherList.isEmpty &&
              controller.addonList.isEmpty)
          ? notOrder()
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding:
                    EdgeInsets.symmetric(vertical: layoutStyle.defaultMargin),
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    if (controller.ticketList.isNotEmpty) ...[
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
                          'Tiket',
                          style: TextStyle(
                            fontSize: fontSize.subtitle,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: layoutStyle.defaultMargin,
                      ),
                      ticketListComponent(controller),
                      SizedBox(
                        height: layoutStyle.defaultMargin,
                      ),
                    ] else
                      Container(),
                    if (controller.addonList.isNotEmpty) ...[
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
                          'Item',
                          style: TextStyle(
                            fontSize: fontSize.subtitle,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: layoutStyle.defaultMargin,
                      ),
                      addonListComponent(controller),
                      SizedBox(
                        height: layoutStyle.defaultMargin,
                      ),
                    ] else
                      Container(),
                    if (controller.voucherList.isNotEmpty) ...[
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
                          'Voucher',
                          style: TextStyle(
                            fontSize: fontSize.subtitle,
                          ),
                        ),
                      ),
                      voucherListComponent(controller)
                    ] else
                      Container(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget ticketListComponent(SaleCartPageController controller) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.symmetric(horizontal: layoutStyle.defaultMargin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: controller.ticketList
            .map(
              (e) => Container(
                margin: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text('${e.qtyOrder} X '),
                          Text(e.ticket!.ticketName ?? ''),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        children: [
                          Text(
                              'Rp.${e.totalPrice != null ? common.currencyFormat(e.totalPrice!) : ''}'),
                          SizedBox(
                            width: layoutStyle.defaultMargin,
                          ),
                          (e.qtyOrder ?? 0) > (e.ticket!.minimum ?? 0)
                              ? CustomButton(
                                  onPressed: () {
                                    controller.removeTicket(e);
                                  },
                                  margin: EdgeInsets.symmetric(
                                    horizontal: layoutStyle.defaultMargin / 10,
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            colorStyle.transparent),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            colorStyle.transparent),
                                    overlayColor:
                                        MaterialStateProperty.all<Color>(
                                            colorStyle.transparent),
                                    side: MaterialStateProperty.all<BorderSide>(
                                      BorderSide(
                                        color: colorStyle.transparent,
                                        width: 1,
                                      ),
                                    ),
                                    padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry>(
                                      const EdgeInsets.all(0),
                                    ),
                                    elevation:
                                        MaterialStateProperty.all<double>(0),
                                  ),
                                  label: Image.asset(
                                    assetsConstant.icMinus,
                                    fit: BoxFit.contain,
                                  ),
                                  width: layoutStyle.blockHorizontal * 3,
                                  height: layoutStyle.blockVertical * 5,
                                )
                              : Container(),
                          CustomButton(
                            onPressed: () {
                              controller.addTicketCart(e);
                            },
                            margin: EdgeInsets.symmetric(
                              horizontal: layoutStyle.defaultMargin / 10,
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  colorStyle.transparent),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  colorStyle.transparent),
                              overlayColor: MaterialStateProperty.all<Color>(
                                  colorStyle.transparent),
                              side: MaterialStateProperty.all<BorderSide>(
                                BorderSide(
                                  color: colorStyle.transparent,
                                  width: 1,
                                ),
                              ),
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                const EdgeInsets.all(0),
                              ),
                              elevation: MaterialStateProperty.all<double>(0),
                            ),
                            label: Image.asset(
                              assetsConstant.icPlus,
                              fit: BoxFit.contain,
                            ),
                            width: layoutStyle.blockHorizontal * 3,
                            height: layoutStyle.blockVertical * 5,
                          ),
                          CustomButton(
                            onPressed: () {
                              controller.removeListTicket(e);
                            },
                            margin: EdgeInsets.symmetric(
                              horizontal: layoutStyle.defaultMargin / 10,
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  colorStyle.transparent),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  colorStyle.transparent),
                              overlayColor: MaterialStateProperty.all<Color>(
                                  colorStyle.transparent),
                              side: MaterialStateProperty.all<BorderSide>(
                                BorderSide(
                                  color: colorStyle.transparent,
                                  width: 1,
                                ),
                              ),
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                const EdgeInsets.all(0),
                              ),
                              elevation: MaterialStateProperty.all<double>(0),
                            ),
                            label: Image.asset(
                              assetsConstant.icDelete,
                              fit: BoxFit.contain,
                            ),
                            width: layoutStyle.blockHorizontal * 3,
                            height: layoutStyle.blockVertical * 5,
                          ),
                        ],
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

  Widget addonListComponent(SaleCartPageController controller) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.symmetric(horizontal: layoutStyle.defaultMargin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: controller.addonList
            .map(
              (e) => Container(
                margin: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text('${e.qtyOrder} X '),
                          Text(e.addon!.productName ?? ''),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        children: [
                          Text(
                              'Rp.${e.totalPrice != null ? common.currencyFormat(e.totalPrice!) : ''}'),
                          SizedBox(
                            width: layoutStyle.defaultMargin,
                          ),
                          CustomButton(
                            onPressed: () {
                              controller.removeAddon(e);
                            },
                            margin: EdgeInsets.symmetric(
                              horizontal: layoutStyle.defaultMargin / 10,
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  colorStyle.transparent),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  colorStyle.transparent),
                              overlayColor: MaterialStateProperty.all<Color>(
                                  colorStyle.transparent),
                              side: MaterialStateProperty.all<BorderSide>(
                                BorderSide(
                                  color: colorStyle.transparent,
                                  width: 1,
                                ),
                              ),
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                const EdgeInsets.all(0),
                              ),
                              elevation: MaterialStateProperty.all<double>(0),
                            ),
                            label: Image.asset(
                              assetsConstant.icMinus,
                              fit: BoxFit.contain,
                            ),
                            width: layoutStyle.blockHorizontal * 3,
                            height: layoutStyle.blockVertical * 5,
                          ),
                          CustomButton(
                            onPressed: () {
                              controller.addAddonCart(e);
                            },
                            margin: EdgeInsets.symmetric(
                              horizontal: layoutStyle.defaultMargin / 10,
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  colorStyle.transparent),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  colorStyle.transparent),
                              overlayColor: MaterialStateProperty.all<Color>(
                                  colorStyle.transparent),
                              side: MaterialStateProperty.all<BorderSide>(
                                BorderSide(
                                  color: colorStyle.transparent,
                                  width: 1,
                                ),
                              ),
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                const EdgeInsets.all(0),
                              ),
                              elevation: MaterialStateProperty.all<double>(0),
                            ),
                            label: Image.asset(
                              assetsConstant.icPlus,
                              fit: BoxFit.contain,
                            ),
                            width: layoutStyle.blockHorizontal * 3,
                            height: layoutStyle.blockVertical * 5,
                          ),
                          CustomButton(
                            onPressed: () {
                              controller.removeListAddon(e);
                            },
                            margin: EdgeInsets.symmetric(
                              horizontal: layoutStyle.defaultMargin / 10,
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  colorStyle.transparent),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  colorStyle.transparent),
                              overlayColor: MaterialStateProperty.all<Color>(
                                  colorStyle.transparent),
                              side: MaterialStateProperty.all<BorderSide>(
                                BorderSide(
                                  color: colorStyle.transparent,
                                  width: 1,
                                ),
                              ),
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                const EdgeInsets.all(0),
                              ),
                              elevation: MaterialStateProperty.all<double>(0),
                            ),
                            label: Image.asset(
                              assetsConstant.icDelete,
                              fit: BoxFit.contain,
                            ),
                            width: layoutStyle.blockHorizontal * 3,
                            height: layoutStyle.blockVertical * 5,
                          ),
                        ],
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

  Widget voucherListComponent(SaleCartPageController controller) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.symmetric(horizontal: layoutStyle.defaultMargin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: controller.voucherList
            .map(
              (e) => Container(
                margin: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(e.voucher!.voucherName ?? ''),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        children: [
                          Text(
                            e.voucher!.unitType == 'PERCENT'
                                ? ('${e.voucher!.unitValue} %')
                                : ('Rp${e.voucher!.unitValue}'),
                          ),
                          SizedBox(
                            width: layoutStyle.defaultMargin,
                          ),
                          CustomButton(
                            margin: EdgeInsets.symmetric(
                              vertical: layoutStyle.defaultMargin / 10,
                            ),
                            onPressed: () {
                              controller.removeListVoucher(e);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  colorStyle.transparent),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  colorStyle.transparent),
                              overlayColor: MaterialStateProperty.all<Color>(
                                  colorStyle.transparent),
                              side: MaterialStateProperty.all<BorderSide>(
                                BorderSide(
                                  color: colorStyle.transparent,
                                  width: 1,
                                ),
                              ),
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                const EdgeInsets.all(0),
                              ),
                              elevation: MaterialStateProperty.all<double>(0),
                            ),
                            label: Image.asset(
                              assetsConstant.icDelete,
                              fit: BoxFit.contain,
                            ),
                            width: layoutStyle.blockHorizontal * 3,
                            height: layoutStyle.blockVertical * 5,
                          ),
                        ],
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
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetsConstant.imgEmptyBox,
              fit: BoxFit.fill,
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
      ),
    );
  }

  Widget footerCart(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(layoutStyle.defaultMargin),
        child: Column(
          children: [
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
                        'Rp.${common.currencyFormat(controller.totalOrderAmnt.value)}',
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
                CustomButton(
                  onPressed: () {
                    alert.dialogDelete(
                      title: 'Warning',
                      msg:
                          'Apakah anda yakin akan membatalkan proses order di atas?',
                      onYes: () {
                        controller.clearCartOrder();
                      },
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
                  width: layoutStyle.blockHorizontal * 14,
                  height: layoutStyle.blockVertical * 5,
                ),
                SizedBox(
                  width: layoutStyle.defaultMargin,
                ),
                CustomButton(
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
                  width: layoutStyle.blockHorizontal * 14,
                  height: layoutStyle.blockVertical * 5,
                ),
              ],
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    // layoutStyle.init(context);

    return GetBuilder(
      init: controller,
      tag: 'SaleCartPage',
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
