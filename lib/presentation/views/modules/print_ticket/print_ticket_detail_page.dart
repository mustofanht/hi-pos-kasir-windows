import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_badge.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/print_ticket/print_ticket_detail_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/print_ticket/print_ticket_page_controller.dart';

class PrintTicketDetailPage extends StatefulWidget {
  final PrintTicketPageController parentController;
  const PrintTicketDetailPage({super.key, required this.parentController});
  @override
  State<PrintTicketDetailPage> createState() => _PrintTicketDetailPageState();
}

class _PrintTicketDetailPageState extends State<PrintTicketDetailPage> {
  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);
    PrintTicketDetailPageController controller =
        Get.isRegistered<PrintTicketDetailPageController>()
            ? Get.find<PrintTicketDetailPageController>()
            : Get.put(
                PrintTicketDetailPageController(
                  parentController: widget.parentController,
                ),
              );

    Widget leftColum({required String column, required Widget value}) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(layoutStyle.defaultMargin / 5),
              child: Text(column),
            ),
            Padding(
              padding: EdgeInsets.all(layoutStyle.defaultMargin / 5),
              child: value,
            ),
          ],
        ),
      );
    }

    Widget leftSection(TrnDetailOrderEntity model) {
      return Container(
        height: layoutStyle.screenHeight,
        width: layoutStyle.screenWidth / 3,
        padding: EdgeInsets.all(layoutStyle.defaultMargin),
        decoration: BoxDecoration(
          color: colorStyle.white,
          borderRadius: BorderRadius.circular(layoutStyle.defaultMargin / 2),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 5,
                ),
                child: Row(
                  children: [
                    leftColum(
                      column: 'Order ID',
                      value: Text(
                        model.orderNumber ?? '',
                        style: TextStyle(
                          fontWeight: fontWeight.bold,
                        ),
                      ),
                    ),
                    leftColum(
                      column: 'Nama',
                      value: Text(
                        model.orderName ?? '',
                        style: TextStyle(
                          fontWeight: fontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 5,
                ),
                child: Row(
                  children: [
                    leftColum(
                      column: 'Order Date',
                      value: Text(
                        model.orderDate == null
                            ? ''
                            : dateTimeUtil.getFormattedDate(
                                date: model.orderDate!,
                                format: dateFormat.withoutSecond,
                              ),
                        style: TextStyle(
                          fontWeight: fontWeight.bold,
                        ),
                      ),
                    ),
                    leftColum(
                      column: 'Source Order',
                      value: Text(
                        model.orderSource ?? '',
                        style: TextStyle(
                          fontWeight: fontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: layoutStyle.defaultMargin / 2,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 5,
                ),
                child: Row(
                  children: [
                    leftColum(
                      column: 'Jumlah Tiket',
                      value: Text(
                        model.orderTotalItem == null
                            ? ''
                            : model.orderTotalItem.toString(),
                        style: TextStyle(
                          fontWeight: fontWeight.bold,
                        ),
                      ),
                    ),
                    // leftColum(
                    //   column: 'Jenis Tiket',
                    //   value: Text(
                    //     'Perorang',
                    //     style: TextStyle(
                    //       fontWeight: fontWeight.bold,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 5,
                ),
                child: Row(
                  children: [
                    leftColum(
                      column: 'Status Pembayaran',
                      value: CustomBadge(
                        label: controller.statusPembayaran.value == 'P'
                            ? 'Paid'
                            : 'Not Paid/Waiting',
                        colorLabel: controller.statusPembayaran.value == 'P'
                            ? colorStyle.white
                            : colorStyle.black,
                        colorBox: controller.statusPembayaran.value == 'P'
                            ? colorStyle.green
                            : colorStyle.creamy,
                        margin: EdgeInsets.zero,
                        // label: model.paymentDetail?.pymntStatus == 'P'
                        //     ? 'Paid'
                        //     : 'Not Paid/Waiting',
                        // colorLabel: model.paymentDetail?.pymntStatus == 'P'
                        //     ? colorStyle.white
                        //     : colorStyle.black,
                        // colorBox: model.paymentDetail?.pymntStatus == 'P'
                        //     ? colorStyle.green
                        //     : colorStyle.creamy,
                        // margin: EdgeInsets.zero,
                      ),
                    ),
                    leftColum(
                      column: 'Status Cetak',
                      value: CustomBadge(
                        label: controller.statusCetak.value == 'Y'
                            ? 'Cetak'
                            : 'Belum Cetak',
                        colorLabel: colorStyle.white,
                        colorBox: controller.statusCetak.value == 'Y'
                            ? colorStyle.green
                            : colorStyle.yellow,
                        margin: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: layoutStyle.defaultMargin / 2,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 5,
                ),
                child: Row(
                  children: [
                    leftColum(
                      column: 'Diskon',
                      value: Text(
                        'Rp.${common.currencyFormat(model.orderDiskon ?? 0)}',
                        style: TextStyle(
                          fontWeight: fontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 5,
                ),
                child: Row(
                  children: [
                    leftColum(
                      column: 'Biaya Admin',
                      value: Text(
                        'Rp.${common.currencyFormat(model.paymentDetail?.pymntAdminFee ?? 0)}',
                        style: TextStyle(
                          fontWeight: fontWeight.bold,
                        ),
                      ),
                    ),
                    leftColum(
                      column: 'Biaya Ppn',
                      value: Text(
                        'Rp.${model.ppn != null ? (common.isNumeric(model.ppn) ? common.currencyFormat(double.parse(model.ppn ?? '0')) : model.ppn) : 0}',
                        style: TextStyle(
                          fontWeight: fontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 5,
                ),
                child: Row(
                  children: [
                    leftColum(
                      column: 'Total',
                      value: Text(
                        'Rp.${common.currencyFormat(model.orderTotalAmt ?? 0)}',
                        style: TextStyle(
                          fontWeight: fontWeight.bold,
                        ),
                      ),
                    ),
                    leftColum(
                      column: 'Total Tagihan',
                      value: Text(
                        'Rp.${common.currencyFormat((model.orderTotalAmt ?? 0) + (model.orderDiskon ?? 0))}',
                        style: TextStyle(
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
      );
    }

    Widget headerSection() {
      return Obx(() {
        return controller.isLoading.value
            ? Container(
                alignment: Alignment.center,
                width: layoutStyle.screenWidth,
                height: layoutStyle.screenHeight,
                child: loading.simpleLoading(),
              )
            : Row(
                children: [
                  // Checkbox(
                  //   fillColor: MaterialStatePropertyAll(colorStyle.blue),
                  //   value: controller.selectAll.value,
                  //   onChanged: (value) => controller.toggleSelectAll(value),
                  // ),
                  ...controller.detailListColumnHeader.map((element) {
                    return element.width != null
                        ? Container(
                            width: element.width,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                              horizontal: layoutStyle.defaultMargin / 2,
                              vertical: layoutStyle.defaultMargin / 4,
                            ),
                            child: Text(
                              element.columnName ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: colorStyle.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        : Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                horizontal: layoutStyle.defaultMargin / 2,
                                vertical: layoutStyle.defaultMargin / 4,
                              ),
                              child: Text(
                                element.columnName ?? '',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colorStyle.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                  }).toList(),
                ],
              );
      });
    }

    Widget dataListSection() {
      return Obx(() {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              if (controller.isLoading.value) {
                return loading.simpleLoading();
              } else if (controller.model.value.detailOrderModels!.isNotEmpty) {
                return GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: colorStyle.lightGrey,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Checkbox(
                        //   fillColor: MaterialStatePropertyAll(colorStyle.blue),
                        //   value: controller.selected.contains(
                        //     controller.model.value.detailOrderModels![index],
                        //   ),
                        //   onChanged: (value) => controller.toggleSelect(
                        //     controller.model.value.detailOrderModels![index],
                        //     value,
                        //   ),
                        // ),
                        ...controller.detailListColumnHeader.map((element) {
                          String val = controller
                              .model.value.detailOrderModels![index]
                              .toJson()[element.id]
                              .toString();

                          if (common.isNumeric(val)) {
                            val = common.currencyFormat(double.parse(val));
                          }

                          return element.width != null
                              ? Container(
                                  width: element.width,
                                  height: layoutStyle.blockVertical * 5,
                                  alignment: element.alignment,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: layoutStyle.defaultMargin / 2,
                                    vertical: layoutStyle.defaultMargin / 4,
                                  ),
                                  child: Text(
                                    val,
                                  ),
                                )
                              : Expanded(
                                  child: Container(
                                    alignment: element.alignment,
                                    height: layoutStyle.blockVertical * 5,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: layoutStyle.defaultMargin / 2,
                                      vertical: layoutStyle.defaultMargin / 4,
                                    ),
                                    child: Text(
                                      val,
                                    ),
                                  ),
                                );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
            childCount: controller.model.value.detailOrderModels!.length,
          ),
        );
      });
    }

    Widget dataTableCustom(TrnDetailOrder e) {
      return Container(
        padding: EdgeInsets.symmetric(
          vertical: layoutStyle.defaultMargin / 2,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorStyle.lightGrey,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: controller.detailListColumnHeader.map(
            (element) {
              String val = e.toJson()[element.id];

              if (common.isNumeric(val)) {
                val = common.currencyFormat(double.parse(val));
              }
              return Expanded(
                child: Container(
                  alignment: element.alignment,
                  height: layoutStyle.blockVertical * 5,
                  margin: EdgeInsets.symmetric(
                    horizontal: layoutStyle.defaultMargin / 3,
                  ),
                  child: Text(val),
                ),
              );
            },
          ).toList(),
        ),
      );
    }

    Widget tableCustom() {
      return Obx(
        () => Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                vertical: layoutStyle.defaultMargin,
                horizontal: layoutStyle.defaultMargin,
              ),
              decoration: BoxDecoration(
                color: colorStyle.lightGrey,
              ),
              child: Row(
                children: controller.detailListColumnHeader
                    .map(
                      (element) => Expanded(
                        child: Container(
                          alignment: element.alignment,
                          margin: EdgeInsets.symmetric(
                            horizontal: layoutStyle.defaultMargin / 3,
                          ),
                          child: Text(
                            element.columnName ?? '',
                            style: textStyle.blackText.copyWith(
                              fontWeight: fontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  // vertical: layoutStyle.defaultMargin,
                  horizontal: layoutStyle.defaultMargin,
                ),
                child: controller.model.value.detailOrderModels == null
                    ? Container()
                    : RefreshIndicator(
                        onRefresh: () async {},
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: controller.model.value.detailOrderModels!
                                .map(
                                  (e) => dataTableCustom(e),
                                )
                                .toList(),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    }

    Widget rightSection() {
      return Obx(
        () => Expanded(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorStyle.white,
                    borderRadius:
                        BorderRadius.circular(layoutStyle.defaultMargin / 2),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                      layoutStyle.defaultMargin,
                    ),
                    child: tableCustom(),
                  ),
                ),
              ),
              controller.parentModel.value.orderStatus == 'V'
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: layoutStyle.defaultMargin / 2),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              margin: EdgeInsets.symmetric(
                                vertical: layoutStyle.defaultMargin / 2,
                                // horizontal: layoutStyle.defaultMargin,
                              ),
                              onPressed: () {
                                controller.doSendEmail();
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith(
                                  (states) => colorStyle.white,
                                ),
                                overlayColor:
                                    MaterialStateProperty.resolveWith(
                                  (states) =>
                                      colorStyle.black.withOpacity(0.1),
                                ),
                                shape: MaterialStateProperty.resolveWith(
                                  (states) => RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      layoutStyle.defaultMargin / 2,
                                    ),
                                  ),
                                ),
                                elevation: const MaterialStatePropertyAll(0),
                              ),
                              label: Text(
                                'Kirim Email',
                                style: textStyle.blackText,
                              ),
                              height: layoutStyle.blockVertical * 6.5,
                            ),
                          ),
                          SizedBox(
                            width: layoutStyle.defaultMargin / 2,
                          ),
                          Expanded(
                            child: CustomButton(
                              margin: EdgeInsets.symmetric(
                                vertical: layoutStyle.defaultMargin / 2,
                                // horizontal: layoutStyle.defaultMargin,
                              ),
                              onPressed: () {
                                controller.doActiveTicket();
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith(
                                  (states) => colorStyle.white,
                                ),
                                overlayColor:
                                    MaterialStateProperty.resolveWith(
                                  (states) =>
                                      colorStyle.black.withOpacity(0.1),
                                ),
                                shape: MaterialStateProperty.resolveWith(
                                  (states) => RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      layoutStyle.defaultMargin / 2,
                                    ),
                                  ),
                                ),
                                elevation: const MaterialStatePropertyAll(0),
                              ),
                              label: Text(
                                'Aktivasi Status Tiket',
                                style: textStyle.blackText,
                              ),
                              height: layoutStyle.blockVertical * 6.5,
                            ),
                          ),
                        ],
                      ),
                    ),
              // (controller.model.value.paymentDetail?.pymntStatus != 'P' &&
              //         controller.model.value.orderStatus != 'C')
              // controller.parentModel.value.otdtlStatus == 'Y' &&
              //         controller.parentModel.value.orderStatus != 'V'
              //     ?
              CustomButton(
                onPressed: () {
                  controller.doPrintTicket();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                    (states) => colorStyle.grey,
                  ),
                  overlayColor: MaterialStateProperty.resolveWith(
                    (states) => colorStyle.black.withOpacity(0.1),
                  ),
                  shape: MaterialStateProperty.resolveWith(
                    (states) => RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        layoutStyle.defaultMargin / 2,
                      ),
                    ),
                  ),
                ),
                label: Text(
                  'Print Tiket',
                  style: textStyle.whiteText,
                ),
                height: layoutStyle.blockVertical * 6.5,
              )
              // : Container(),
            ],
          ),
        ),
      );
    }

    return Obx(
      () => controller.isLoading.value
          ? loading.simpleLoading()
          : Container(
              width: layoutStyle.screenWidth,
              height: layoutStyle.screenHeight,
              padding: EdgeInsets.all(layoutStyle.defaultMargin),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: layoutStyle.blockHorizontal * 4,
                        height: layoutStyle.blockVertical * 6.5,
                        child: CustomButton(
                          onPressed: () {
                            controller.doBack();
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
                                        vertical: layoutStyle.defaultMargin / 5,
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
                        child: Container(
                          padding: EdgeInsets.all(layoutStyle.defaultMargin),
                          alignment: Alignment.center,
                          child: Text(
                            'Order Detail',
                            style: TextStyle(
                              color: colorStyle.black,
                              fontSize: fontSize.header,
                              fontWeight: fontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        leftSection(controller.model.value),
                        SizedBox(
                          width: layoutStyle.defaultMargin,
                        ),
                        rightSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
