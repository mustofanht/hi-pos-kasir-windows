import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';
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

  Widget contentCart(SaleCartPageController controller) {
    return Expanded(
      child: (controller.ticketList.isEmpty &&
              controller.addonList.isEmpty &&
              controller.voucherList.isEmpty &&
              controller.potonganList.isEmpty &&
              controller.depositList.isEmpty)
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
                            fontWeight: fontWeight.bold,
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
                            fontWeight: fontWeight.bold,
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
                            fontWeight: fontWeight.bold,
                          ),
                        ),
                      ),
                      voucherListComponent(controller)
                    ] else
                      Container(),
                    if (controller.potonganList.isNotEmpty) ...[
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
                          'Potongan',
                          style: TextStyle(
                            fontSize: fontSize.subtitle,
                            fontWeight: fontWeight.bold,
                          ),
                        ),
                      ),
                      potonganListComponent(controller)
                    ] else
                      Container(),
                    if (controller.depositList.isNotEmpty) ...[
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
                          'Deposit',
                          style: TextStyle(
                            fontSize: fontSize.subtitle,
                            fontWeight: fontWeight.bold,
                          ),
                        ),
                      ),
                      depositListComponent(controller)
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
        children: controller.ticketList.map((e) {
          TextEditingController qtyController = controller.getTicketController(
            e.ticket!.ticketId!,
            e.qtyOrder ?? e.ticket!.ticketMinimum!,
          );

          return Container(
            margin: EdgeInsets.symmetric(
              vertical: layoutStyle.defaultMargin / 10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Text('${e.qtyOrder} X '),
                      Container(
                        width: layoutStyle.safeBlockHorizontal * 2.5,
                        child: TextField(
                          controller: qtyController,
                          onChanged: (val) => val.isNotEmpty
                              ? controller.onChangeQtyTicketCart(
                                  e,
                                  int.parse(val),
                                )
                              : null,
                          onEditingComplete: () =>
                              controller.onCompleteQtyTicketCart(e),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      Text(
                        'X ',
                        style: textStyle.blackText,
                      ),
                      Expanded(
                        child: Text(
                          e.ticket!.ticketName ?? '',
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    children: [
                      Text(
                        'Rp.${e.ticket?.ticketPrice != null ? common.currencyFormat(e.ticket!.ticketPrice!) : ''}',
                      ),
                      SizedBox(
                        width: layoutStyle.defaultMargin,
                      ),
                      (e.qtyOrder ?? 0) > (e.ticket!.ticketMinimum ?? 0)
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
                                overlayColor: MaterialStateProperty.all<Color>(
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
                                elevation: MaterialStateProperty.all<double>(0),
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
          );
        }).toList(),
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
                if (e.rentModel != null && e.rentModel!.isExtraTime!) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Pembelian Extra Time',
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
                ] else ...[
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
                ],
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              children: [
                SizedBox(
                  width: layoutStyle.defaultMargin,
                ),
                CustomButton(
                  onPressed: () {
                    controller.doUpdateRent(e);
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
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.all(0),
                    ),
                    elevation: MaterialStateProperty.all<double>(0),
                  ),
                  label: Container(
                    padding: EdgeInsets.all(
                      layoutStyle.defaultMargin / 3,
                    ),
                    decoration: BoxDecoration(
                      color: colorStyle.primary,
                      borderRadius: BorderRadius.circular(
                        layoutStyle.defaultMargin / 5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.edit,
                      color: colorStyle.white,
                      size: fontSize.title,
                    ),
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
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
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
              (e) => e.rentModel != null
                  ? rentProductCart(e)
                  : Container(
                      margin: EdgeInsets.symmetric(
                        vertical: layoutStyle.defaultMargin / 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text('${e.qtyOrder} X '),
                                Expanded(
                                  child: Text(
                                    e.addon!.productName ?? '',
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              children: [
                                Text(
                                  'Rp.${e.addon?.productPrice != null ? common.currencyFormat(e.addon!.productPrice!) : ''}',
                                ),
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
                                ),
                                CustomButton(
                                  onPressed: () {
                                    controller.addAddonCart(e);
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
                    Text(
                      '${e.qtyOrder ?? 0} X ',
                      style: textStyle.blackText,
                    ),
                    Expanded(
                      child: AutoSizeText(
                        e.entity!.vpName ?? '',
                        // softWrap: true,
                        // overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        children: [
                          Text(
                            e.entity!.vpUnitType == UnitType.PERCENT
                                ? ('${e.entity!.vpUnitValue} %')
                                : ('Rp${common.currencyFormat(e.entity!.vpUnitValue ?? 0)}'),
                          ),
                          SizedBox(
                            width: layoutStyle.defaultMargin,
                          ),
                          if (controller.memberVoucher.isFalse)
                            (e.qtyOrder ?? 0) > 0
                                ? CustomButton(
                                    onPressed: () {
                                      controller.removeVoucher(e);
                                    },
                                    margin: EdgeInsets.symmetric(
                                      horizontal:
                                          layoutStyle.defaultMargin / 10,
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
                                      side:
                                          MaterialStateProperty.all<BorderSide>(
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
                          if (controller.memberVoucher.isFalse)
                            CustomButton(
                              onPressed: () {
                                controller.addVoucherCart(e);
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
                                overlayColor: MaterialStateProperty.all<Color>(
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
                            margin: EdgeInsets.symmetric(
                              vertical: layoutStyle.defaultMargin / 10,
                            ),
                            onPressed: () {
                              controller.removeListvoucher(e);
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

  Widget potonganListComponent(SaleCartPageController controller) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.symmetric(horizontal: layoutStyle.defaultMargin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: controller.potonganList
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
                          Text(
                            e.potongan!.voucherName ?? '',
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        children: [
                          Text(
                            e.potongan!.voucherUnitType == UnitType.PERCENT
                                ? ('${e.potongan!.voucherUnitValue} %')
                                : ('Rp${common.currencyFormat(e.potongan!.voucherUnitValue ?? 0)}'),
                          ),
                          SizedBox(
                            width: layoutStyle.defaultMargin,
                          ),
                          CustomButton(
                            margin: EdgeInsets.symmetric(
                              vertical: layoutStyle.defaultMargin / 10,
                            ),
                            onPressed: () {
                              controller.removeListpotongan(e);
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

  Widget depositListComponent(SaleCartPageController controller) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.symmetric(horizontal: layoutStyle.defaultMargin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: controller.depositList
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
                          Text(
                            e.deposit!.dpName ?? '',
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        children: [
                          Text(
                            ('Rp${common.currencyFormat(e.deposit!.dpAmount ?? 0)}'),
                          ),
                          SizedBox(
                            width: layoutStyle.defaultMargin,
                          ),
                          CustomButton(
                            margin: EdgeInsets.symmetric(
                              vertical: layoutStyle.defaultMargin / 10,
                            ),
                            onPressed: () {
                              controller.removeListdeposit(e);
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

  Widget footerCart(BuildContext context) {
    return Container(
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
            if (controller.selectedMstPayment.value.pymntFlBbnCust == 'Y')
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
