import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order_entity.dart';
import 'package:jaya_propertiy/domain/entities/order/trn_order_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/proofofpayment/bukti_pembayaran_page_controller.dart';

class BuktiPembayaranPage extends GetView<BuktiPembayaranPageController> {
  const BuktiPembayaranPage({super.key});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    Widget rightSection(TrnDetailOrderEntity model) {
      return controller.isLoadingDetail.value
          ? Expanded(
              child: Container(
                child: loading.simpleLoading(),
              ),
            )
          : model.orderNumber == null
              ? Expanded(
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
                          'Data Empty',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fontSize.title,
                            fontWeight: fontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: layoutStyle.defaultMargin,
                        ),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: Container(
                    width: layoutStyle.screenWidth,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: colorStyle.grey,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: layoutStyle.defaultMargin / 2,
                            horizontal: layoutStyle.defaultMargin,
                          ),
                          decoration: BoxDecoration(
                            color: colorStyle.lightGrey,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '${model.orderNumber}',
                                    style: TextStyle(
                                      fontWeight: fontWeight.bold,
                                      fontSize: fontSize.subtitle,
                                    ),
                                  ),
                                  // SizedBox(
                                  //   width: layoutStyle.defaultMargin,
                                  // ),
                                  // Icon(Icons.copy),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CustomButton(
                                    onPressed: () {
                                      controller.doPrintTicket();
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              colorStyle.primary),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              colorStyle.white),
                                      overlayColor: MaterialStateProperty.all<
                                              Color>(
                                          colorStyle.white.withOpacity(0.1)),
                                      elevation:
                                          MaterialStateProperty.all<double>(0),
                                    ),
                                    label: Row(
                                      children: [
                                        Icon(Icons.print),
                                        SizedBox(
                                          width: layoutStyle.defaultMargin / 5,
                                        ),
                                        Text('Cetak'),
                                      ],
                                    ),
                                    width: layoutStyle.blockHorizontal * 8,
                                    height: layoutStyle.blockVertical * 5,
                                  ),
                                  SizedBox(
                                    width: layoutStyle.defaultMargin,
                                  ),
                                  CustomButton(
                                    onPressed: () {
                                      controller.doSendMessage();
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              colorStyle.primary),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              colorStyle.white),
                                      overlayColor: MaterialStateProperty.all<
                                              Color>(
                                          colorStyle.white.withOpacity(0.1)),
                                      elevation:
                                          MaterialStateProperty.all<double>(0),
                                    ),
                                    label: Row(
                                      children: [
                                        Icon(Icons.send),
                                        SizedBox(
                                          width: layoutStyle.defaultMargin / 5,
                                        ),
                                        Text('Kirim Bukti Pembayaran'),
                                      ],
                                    ),
                                    width: layoutStyle.blockHorizontal * 18,
                                    height: layoutStyle.blockVertical * 5,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: layoutStyle.screenWidth / 4,
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            layoutStyle.defaultMargin),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'DI TERBITKAN OLEH',
                                              style: TextStyle(
                                                fontSize: fontSize.header,
                                                fontWeight: fontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Petugas: ${model.paymentDetail?.pymntCreatedBy ?? ''}',
                                              style: TextStyle(
                                                fontSize: fontSize.subtitle,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            layoutStyle.defaultMargin),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Invoice #${model.orderNumber}',
                                              style: TextStyle(
                                                fontSize: fontSize.subtitle,
                                              ),
                                            ),
                                            Text(
                                              'Created: ${dateTimeUtil.getFormattedDate(date: model.orderDate!, format: dateFormat.onlyDate)} | ${dateTimeUtil.getFormattedDate(date: model.orderDate!, format: dateFormat.onlyTime)}',
                                              style: TextStyle(
                                                fontSize: fontSize.subtitle,
                                              ),
                                            ),
                                            SizedBox(
                                              height: layoutStyle.defaultMargin,
                                            ),
                                            Text(
                                              'CUSTOMER',
                                              style: TextStyle(
                                                fontSize: fontSize.header,
                                                fontWeight: fontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              height:
                                                  layoutStyle.defaultMargin / 5,
                                            ),
                                            Text(
                                              'Nama: ${model.customerDetail?.custName ?? ''}',
                                              style: TextStyle(
                                                fontSize: fontSize.subtitle,
                                              ),
                                            ),
                                            Text(
                                              'Tanggal Pembayaran: ${dateTimeUtil.getFormattedDate(date: model.orderDate!, format: dateFormat.onlyDate)} | ${dateTimeUtil.getFormattedDate(date: model.orderDate!, format: dateFormat.onlyTime)}',
                                              style: TextStyle(
                                                fontSize: fontSize.subtitle,
                                              ),
                                            ),
                                            Text(
                                              'Metode Pembayaran: ${MapPaymentMethod[model.orderPaidBy]}',
                                              style: TextStyle(
                                                fontSize: fontSize.subtitle,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: layoutStyle.defaultMargin / 2,
                                    horizontal: layoutStyle.defaultMargin,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorStyle.lightGrey,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'INFO TIKET',
                                        style: TextStyle(
                                          fontWeight: fontWeight.bold,
                                          fontSize: fontSize.subtitle,
                                        ),
                                      ),
                                      Text(
                                        'JUMLAH HARGA SATUAN',
                                        style: TextStyle(
                                          fontWeight: fontWeight.bold,
                                          fontSize: fontSize.subtitle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: layoutStyle.screenWidth,
                                  padding:
                                      EdgeInsets.all(layoutStyle.defaultMargin),
                                  child: Column(
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: model.detailOrderModels ==
                                                null
                                            ? []
                                            : model.detailOrderModels!
                                                .map(
                                                  (e) => Padding(
                                                    padding: EdgeInsets.symmetric(
                                                        vertical: layoutStyle
                                                                .defaultMargin /
                                                            5),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              e.productName ??
                                                                  '',
                                                              style: TextStyle(
                                                                fontSize: fontSize
                                                                    .subtitle,
                                                                fontWeight:
                                                                    fontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            // Text(
                                                            //   'Not Set Yet',
                                                            //   style: TextStyle(
                                                            //     fontSize:
                                                            //         fontSize.body,
                                                            //   ),
                                                            // ),
                                                          ],
                                                        ),
                                                        Text(
                                                          'Rp.${common.currencyFormat(e.price ?? 0)}',
                                                          style: TextStyle(
                                                            fontSize:
                                                                fontSize.body,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: model.trnOrderVouchers == null
                                            ? []
                                            : model.trnOrderVouchers!
                                                .map(
                                                  (e) => Padding(
                                                    padding: EdgeInsets.symmetric(
                                                        vertical: layoutStyle
                                                                .defaultMargin /
                                                            5),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              e.voucherName ??
                                                                  '',
                                                              style: TextStyle(
                                                                fontSize: fontSize
                                                                    .subtitle,
                                                                fontWeight:
                                                                    fontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            // Text(
                                                            //   'Not Set Yet',
                                                            //   style: TextStyle(
                                                            //     fontSize:
                                                            //         fontSize.body,
                                                            //   ),
                                                            // ),
                                                          ],
                                                        ),
                                                        Text(
                                                          '- Rp.${common.currencyFormat(e.voucherUnitValue ?? 0)}',
                                                          style: TextStyle(
                                                            fontSize:
                                                                fontSize.body,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: layoutStyle.defaultMargin / 2,
                                    horizontal: layoutStyle.defaultMargin,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorStyle.lightGrey,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Harga Total: Rp.${common.currencyFormat(model.orderTotalAmt ?? 0)}',
                                        style: TextStyle(
                                          fontWeight: fontWeight.bold,
                                          fontSize: fontSize.subtitle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: layoutStyle.screenWidth,
                                  padding:
                                      EdgeInsets.all(layoutStyle.defaultMargin),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(
                                            layoutStyle.defaultMargin / 2),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  'Discount:',
                                                  style: TextStyle(
                                                    fontSize: fontSize.body,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    layoutStyle.defaultMargin /
                                                        2,
                                              ),
                                              child: Text(
                                                'Rp.${common.currencyFormat(model.orderDiskon ?? 0)}',
                                                style: TextStyle(
                                                  fontSize: fontSize.body,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Padding(
                                      //   padding: EdgeInsets.all(
                                      //       layoutStyle.defaultMargin / 2),
                                      //   child: Row(
                                      //     children: [
                                      //       Expanded(
                                      //         child: Align(
                                      //           alignment:
                                      //               Alignment.centerRight,
                                      //           child: Text(
                                      //             'Voucher:',
                                      //             style: TextStyle(
                                      //               fontSize: fontSize.body,
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //       Padding(
                                      //         padding: EdgeInsets.symmetric(
                                      //           horizontal:
                                      //               layoutStyle.defaultMargin /
                                      //                   2,
                                      //         ),
                                      //         child: Text(
                                      //           'Not Set Yet',
                                      //           style: TextStyle(
                                      //             fontSize: fontSize.body,
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                      Padding(
                                        padding: EdgeInsets.all(
                                            layoutStyle.defaultMargin / 2),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  'Biaya Admin:',
                                                  style: TextStyle(
                                                    fontSize: fontSize.body,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    layoutStyle.defaultMargin /
                                                        2,
                                              ),
                                              child: Text(
                                                'Rp.${common.currencyFormat(model.paymentDetail?.pymntAdminFee ?? 0)}',
                                                style: TextStyle(
                                                  fontSize: fontSize.body,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(
                                            layoutStyle.defaultMargin / 2),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  'Biaya Ppn:',
                                                  style: TextStyle(
                                                    fontSize: fontSize.body,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    layoutStyle.defaultMargin /
                                                        2,
                                              ),
                                              child: Text(
                                                'Rp.${common.isNumeric(model.ppn) ? common.currencyFormat(double.parse(model.ppn ?? '0')) : model.ppn}',
                                                style: TextStyle(
                                                  fontSize: fontSize.body,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(
                                            layoutStyle.defaultMargin / 2),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  'Total Tagihan:',
                                                  style: TextStyle(
                                                    fontSize: fontSize.body,
                                                    fontWeight: fontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    layoutStyle.defaultMargin /
                                                        2,
                                              ),
                                              child: Text(
                                                'Rp.${common.currencyFormat(model.orderTotalTgh ?? 0)}',
                                                style: TextStyle(
                                                  fontSize: fontSize.body,
                                                  fontWeight: fontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
    }

    Widget cardSection({
      required TrnOrderEntity model,
      required bool selectedCard,
    }) {
      return GestureDetector(
        onTap: () {
          controller.doSelectedOrder(model);
        },
        child: Container(
          padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
          color: selectedCard ? colorStyle.lightGrey : colorStyle.white,
          width: layoutStyle.screenWidth,
          height: layoutStyle.blockVertical * 25,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 10,
                ),
                margin: EdgeInsets.only(bottom: layoutStyle.defaultMargin / 2),
                child: Container(
                  padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
                  decoration: BoxDecoration(
                    color: model.paymentDetail?.pymntStatus == 'P'
                        ? colorStyle.lime
                        : colorStyle.cloud_blue,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    model.paymentDetail?.pymntStatus == 'P'
                        ? 'Paid'
                        : 'Not Paid',
                    style: TextStyle(
                      color: colorStyle.black,
                      fontSize: fontSize.small,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.topCenter,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            // horizontal: layoutStyle.defaultMargin / 5,
                            vertical: layoutStyle.defaultMargin / 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorStyle.white,
                            border: Border.all(
                              color: colorStyle.grey,
                              width: 1.0,
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(
                                7,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                model.orderPaidBy == PaymentMethod.EDC
                                    ? assetsConstant.imgEdc
                                    : model.orderPaidBy == PaymentMethod.QRIS
                                        ? assetsConstant.imgExampleBarcode
                                        : model.orderPaidBy ==
                                                PaymentMethod.TRAVELOKA
                                            ? assetsConstant.imgTraveloka
                                            : model.orderPaidBy ==
                                                    PaymentMethod.TICKET
                                                ? assetsConstant.imgEdc
                                                : assetsConstant.imgEdc,
                                // fit: BoxFit.fill,
                                width: layoutStyle.blockHorizontal * 8,
                                height: layoutStyle.blockVertical * 10,
                              ),
                              Text(
                                MapPaymentMethod[model.orderPaidBy] ?? '',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: TextStyle(
                                  fontWeight: fontWeight.bold,
                                  fontSize: fontSize.small,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: layoutStyle.defaultMargin / 2,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(model.orderNumber ?? ''),
                                    SizedBox(
                                      height: layoutStyle.defaultMargin,
                                    ),
                                    Text(
                                      model.customerDetail?.custName ?? '',
                                      style: TextStyle(
                                        fontWeight: fontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(dateTimeUtil.getFormattedDate(
                                      date: model.orderDate!,
                                      format: dateFormat.hourMinutes)),
                                  SizedBox(
                                    height: layoutStyle.defaultMargin,
                                  ),
                                  Text(
                                    'Rp.${common.currencyFormat(model.orderTotalAmt ?? 0)}',
                                    style: TextStyle(
                                      color: colorStyle.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget leftSection() {
      return Container(
        width: layoutStyle.safeBlockHorizontal * 30,
        height: layoutStyle.screenHeight,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: colorStyle.grey,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: controller.dataList.isEmpty
            ? Center(
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
                      'Data Empty',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize.title,
                        fontWeight: fontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: layoutStyle.defaultMargin,
                    ),
                  ],
                ),
              )
            : controller.isLoading.value
                ? loading.simpleLoading()
                : RefreshIndicator(
                    onRefresh: () async {
                      await controller.doRefresh();
                    },
                    child: SingleChildScrollView(
                      controller: controller.scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: controller.dataList
                            .map((e) => cardSection(
                                model: e,
                                selectedCard:
                                    controller.selectedData.value.orderNumber !=
                                            null &&
                                        e.orderNumber ==
                                            controller.selectedData.value
                                                .orderNumber))
                            .toList(),
                      ),
                    ),
                  ),
      );
    }

    Widget contentSection(BuktiPembayaranPageController controller) {
      return Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: layoutStyle.defaultMargin),
          child: Row(
            children: [
              leftSection(),
              SizedBox(
                width: layoutStyle.defaultMargin,
              ),
              rightSection(controller.detailModel.value),
            ],
          ),
        ),
      );
    }

    return GetBuilder(
      init: controller,
      tag: 'BuktiPembayaranPage',
      // initState: (state) {
      //   controller.doPrepareList(page: 0);
      // },
      builder: (controller) {
        return Container(
          padding: EdgeInsets.all(layoutStyle.defaultMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Bukti Pembayaran',
                style: TextStyle(
                  fontSize: fontSize.header,
                  fontWeight: fontWeight.bold,
                ),
              ),
              SizedBox(height: layoutStyle.defaultMargin),
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
                controller: controller.searchController,
                decoration: InputDecoration(
                  hintText: 'Masukan nomor ID Order atau ID Ticket',
                  hintStyle: textStyle.greyText,
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    onPressed: () async {
                      await controller
                          .doSearch(controller.searchController.text);
                    },
                    icon: const Icon(
                      Icons.search,
                    ),
                  ),
                  // suffixIcon: const Icon(
                  //   Icons.search,
                  // ),
                ),
                onSubmit: (val) {
                  controller.doSearch(val);
                },
              ),
              SizedBox(height: layoutStyle.defaultMargin),
              contentSection(controller),
            ],
          ),
        );
      },
    );
  }
}
