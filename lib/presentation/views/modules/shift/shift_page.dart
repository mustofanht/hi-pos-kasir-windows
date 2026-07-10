import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_detail_entity.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_dynamic_dot.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/shift/shift_page_controller.dart';

class ShiftPage extends GetView<ShiftPageController> {
  const ShiftPage({super.key});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    Widget cardShift({
      required BorderRadiusGeometry borderRadius,
      required bool selected,
      required String date,
      required String time,
    }) {
      return Container(
        padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
        decoration: BoxDecoration(
          color: selected
              ? colorStyle.primary.withOpacity(0.10)
              : colorStyle.white,
          border: Border(
            left: BorderSide(
              color: colorStyle.primary,
              width: selected ? layoutStyle.defaultMargin / 2 : 1.0,
            ),
            bottom: BorderSide(
              color: colorStyle.primary,
              width: 1.0,
            ),
            right: BorderSide(
              color: colorStyle.primary,
              width: 1.0,
            ),
            top: BorderSide(
              color: colorStyle.primary,
              width: 1.0,
            ),
          ),
          borderRadius: borderRadius,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(
                      layoutStyle.defaultMargin / 5,
                    ),
                    child: Text(
                      date,
                      style: TextStyle(
                        color: colorStyle.black,
                        fontSize: fontSize.body,
                        fontWeight: fontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(
                      layoutStyle.defaultMargin / 5,
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        color: colorStyle.primary,
                        fontSize: fontSize.body,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.chevron_right,
                size: fontSize.header,
              ),
            ),
          ],
        ),
      );
    }

    Widget leftSection({
      required ShiftEntity shiftCurrent,
      required List<ShiftEntity>? listShiftEnded,
    }) {
      return Obx(
        () => Expanded(
          child: Container(
            height: layoutStyle.screenHeight,
            padding: EdgeInsets.all(layoutStyle.defaultMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Shift',
                  style: TextStyle(
                    color: colorStyle.black,
                    fontSize: fontSize.header,
                    fontWeight: fontWeight.bold,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: layoutStyle.defaultMargin / 2,
                  ),
                  child: Text(
                    'Berlangsung',
                    style: TextStyle(
                      color: colorStyle.black,
                      fontSize: fontSize.body,
                    ),
                  ),
                ),
                controller.isLoadingShiftCurrent.value
                    ? loading.simpleLoading()
                    : shiftCurrent.shftDate == null
                        ? Container()
                        : GestureDetector(
                            onTap: () {
                              controller.doSelectedShift(shiftCurrent);
                            },
                            child: cardShift(
                              date: dateTimeUtil.getFormattedDate(
                                date: dateTimeUtil.convertToDateTime(
                                  shiftCurrent.shftDate!,
                                ),
                                format: dateFormat.dateWithoutTime,
                              ),
                              time: 'Sedang Berlangsung',
                              selected: shiftCurrent.shftDate ==
                                  controller.selectedShift.value.shftDate,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(
                                    layoutStyle.defaultMargin / 2),
                                bottomRight: Radius.circular(
                                    layoutStyle.defaultMargin / 2),
                              ),
                            ),
                          ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: layoutStyle.defaultMargin),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: controller.isLoadingShiftEnded.value
                          ? loading.simpleLoading()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: layoutStyle.defaultMargin / 2,
                                  ),
                                  child: Text(
                                    'History',
                                    style: TextStyle(
                                      color: colorStyle.black,
                                      fontSize: fontSize.body,
                                    ),
                                  ),
                                ),
                                if (listShiftEnded != null &&
                                    listShiftEnded.isNotEmpty)
                                  ...listShiftEnded
                                      .map(
                                        (element) => GestureDetector(
                                          onTap: () {
                                            controller.doSelectedShift(element);
                                          },
                                          child: cardShift(
                                            date: dateTimeUtil.getFormattedDate(
                                              date: dateTimeUtil
                                                  .convertToDateTime(
                                                element.shftDate!,
                                              ),
                                              format:
                                                  dateFormat.dateWithoutTime,
                                            ),
                                            time:
                                                '${dateTimeUtil.getFormattedDate(
                                              date: element.shftStart!,
                                              format: dateFormat.hourMinutes,
                                            )} - ${dateTimeUtil.getFormattedDate(
                                              date: element.shftEnd!,
                                              format: dateFormat.hourMinutes,
                                            )}',
                                            selected: element.shftDate ==
                                                controller.selectedShift.value
                                                    .shftDate,
                                            borderRadius: BorderRadius.zero,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                // cardShift(
                                //   date: '17 Jul 2024',
                                //   time: '10:00 - 15:00',
                                //   selected: false,
                                //   borderRadius: BorderRadius.only(
                                //     topLeft: Radius.circular(
                                //       layoutStyle.defaultMargin / 2,
                                //     ),
                                //     topRight: Radius.circular(
                                //       layoutStyle.defaultMargin / 2,
                                //     ),
                                //   ),
                                // ),
                                // cardShift(
                                //   date: '17 Jul 2024',
                                //   time: '10:00 - 15:00',
                                //   selected: false,
                                //   borderRadius: BorderRadius.zero,
                                // ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget columnShift({
      required String key,
      String? value,
      required bool head,
      Color? colorValue,
      EdgeInsetsGeometry? paddingKey,
    }) {
      return Container(
        padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorStyle.black,
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: paddingKey ?? EdgeInsets.zero,
              child: Text(
                key,
                style: TextStyle(
                  color: colorStyle.black,
                  fontSize: fontSize.body,
                  fontWeight: head ? fontWeight.bold : fontWeight.regular,
                ),
              ),
            ),
            Text(
              value ?? '',
              style: TextStyle(
                color: colorValue ?? colorStyle.black,
                fontSize: fontSize.body,
                fontWeight: fontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    Widget rightSection({ShiftDetailEntity? detail}) {
      return Obx(
        () => Expanded(
          child: Container(
            height: layoutStyle.screenHeight,
            padding: EdgeInsets.all(layoutStyle.defaultMargin),
            decoration: BoxDecoration(
              color: colorStyle.white,
            ),
            child: controller.isLoadingShiftDetail.value
                ? loading.simpleLoading()
                : detail == null || detail.shftDate == null
                    ? Container()
                    : Column(
                        children: [
                          Text(
                            'Rincian Shift',
                            style: TextStyle(
                              color: colorStyle.black,
                              fontSize: fontSize.header,
                              fontWeight: fontWeight.bold,
                            ),
                          ),
                          DynamicDotLine(
                            dotCount: layoutStyle.defaultMargin.toInt() * 2,
                            direction: Axis.horizontal,
                            dotColor: colorStyle.black.withOpacity(0.20),
                            padding: EdgeInsets.symmetric(
                              vertical: layoutStyle.defaultMargin,
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                children: [
                                  columnShift(
                                    key: 'Name',
                                    value: detail.userFullName ?? '',
                                    head: false,
                                  ),
                                  columnShift(
                                    key: 'Shift Mulai',
                                    // value: 'Senin, 17 Juli 2024 | 09:00',
                                    value: detail.shftStart == null
                                        ? ''
                                        : controller
                                            .formatShiftDate(detail.shftStart!),
                                    // value: controller.formatShiftDate(
                                    //   dateTimeUtil.convertToDateTime(
                                    //     detail.shftDate!,
                                    //   ),
                                    // ),
                                    head: false,
                                  ),
                                  columnShift(
                                    key: 'Lokasi',
                                    value: detail.lokasiName,
                                    head: false,
                                  ),
                                  columnShift(
                                    key: 'Shift Berakhir',
                                    value: detail.shftEnd != null
                                        ? controller.formatShiftDate(
                                            detail.shftEnd!,
                                          )
                                        : 'Shift sedang berlangsung',
                                    colorValue: colorStyle.primary,
                                    head: false,
                                  ),
                                  columnShift(
                                    key: 'Tiket',
                                    value: (detail.tiketCount ?? 0).toString(),
                                    head: false,
                                  ),
                                  columnShift(
                                    key: 'Item',
                                    value: (detail.itemCount ?? 0).toString(),
                                    head: false,
                                  ),
                                  columnShift(
                                    key: 'Potongan',
                                    value:
                                        (detail.potonganCount ?? 0).toString(),
                                    head: false,
                                  ),
                                  columnShift(
                                    key: 'Voucher',
                                    value:
                                        (detail.voucherCount ?? 0).toString(),
                                    head: false,
                                  ),
                                  columnShift(
                                    key: '',
                                    head: true,
                                  ),
                                  if (detail.listSumPayment != null)
                                    ...detail.listSumPayment!
                                        .map(
                                          (e) => columnShift(
                                              key: e.name ?? '',
                                              value:
                                                  'Rp.${common.currencyFormat(e.amount ?? 0)}',
                                              head: false),
                                        )
                                        .toList(),
                                  columnShift(
                                    key: 'Voucher',
                                    head: true,
                                  ),
                                  if (detail.listSumVoucher != null)
                                    ...detail.listSumVoucher!
                                        .map(
                                          (e) => columnShift(
                                              key: e.name ?? '',
                                              value:
                                                  'Rp.${common.currencyFormat(e.amount ?? 0)}',
                                              head: false),
                                        )
                                        .toList(),
                                  columnShift(
                                    key: 'Potongan',
                                    head: true,
                                  ),
                                  if (detail.listSumPotongan != null)
                                    ...detail.listSumPotongan!
                                        .map(
                                          (e) => columnShift(
                                              key: e.name ?? '',
                                              value:
                                                  'Rp.${common.currencyFormat(e.amount ?? 0)}',
                                              head: false),
                                        )
                                        .toList(),
                                  // columnShift(
                                  //   key: 'QRIS',
                                  //   value: (detail.qrisSum ?? 0).toString(),
                                  //   head: false,
                                  //   // paddingKey: EdgeInsets.only(
                                  //   //   left: layoutStyle.defaultMargin,
                                  //   // ),
                                  // ),
                                  // columnShift(
                                  //   key: 'EDC',
                                  //   value: (detail.edcSum ?? 0).toString(),
                                  //   head: false,
                                  //   // paddingKey: EdgeInsets.only(
                                  //   //   left: layoutStyle.defaultMargin,
                                  //   // ),
                                  // ),
                                  // columnShift(
                                  //   key: 'TRAVELOKA',
                                  //   value:
                                  //       (detail.travelokaSum ?? 0).toString(),
                                  //   head: false,
                                  //   // paddingKey: EdgeInsets.only(
                                  //   //   left: layoutStyle.defaultMargin,
                                  //   // ),
                                  // ),
                                  // columnShift(
                                  //   key: 'TICKET.COM',
                                  //   value: (detail.ticketdotcomSum ?? 0)
                                  //       .toString(),
                                  //   head: false,
                                  //   // paddingKey: EdgeInsets.only(
                                  //   //   left: layoutStyle.defaultMargin,
                                  //   // ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                          DynamicDotLine(
                            dotCount: layoutStyle.defaultMargin.toInt() * 2,
                            direction: Axis.horizontal,
                            dotColor: colorStyle.black.withOpacity(0.20),
                            padding: EdgeInsets.symmetric(
                              vertical: layoutStyle.defaultMargin,
                            ),
                          ),
                          detail.shftEnd == null
                              ? CustomButton(
                                  onPressed: () {
                                    controller.doShiftEnded(detail);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            colorStyle.primary),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            colorStyle.white),
                                    overlayColor:
                                        MaterialStateProperty.all<Color>(
                                      colorStyle.white.withOpacity(0.1),
                                    ),
                                    side: MaterialStateProperty.all<BorderSide>(
                                      BorderSide(
                                        color: colorStyle.primary,
                                        width: 1,
                                      ),
                                    ),
                                    padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry>(
                                      EdgeInsets.symmetric(
                                        vertical: layoutStyle.defaultMargin / 2,
                                        horizontal:
                                            layoutStyle.defaultMargin / 2,
                                      ),
                                    ),
                                    elevation: MaterialStateProperty.all<
                                            double>(
                                        0), // Menghilangkan shadow dengan elevation 0
                                  ),
                                  label: const Text(
                                      'Akhiri Shift & Mulai Settlement'),
                                  width: layoutStyle.screenWidth,
                                  height: layoutStyle.blockVertical * 7,
                                )
                              : Container(),
                        ],
                      ),
          ),
        ),
      );
    }

    return GetBuilder(
      init: controller,
      tag: 'ShiftPage',
      initState: (state) async {
        await controller.doPrepared();
      },
      builder: (controller) {
        return Container(
          height: layoutStyle.screenHeight,
          child: Row(
            children: [
              leftSection(
                shiftCurrent: controller.shiftCurrent.value,
                listShiftEnded: controller.dataListShiftEnded,
              ),
              rightSection(
                detail: controller.shiftDetail.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
