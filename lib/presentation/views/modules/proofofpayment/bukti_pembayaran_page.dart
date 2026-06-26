import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order_entity.dart';
import 'package:jaya_propertiy/domain/entities/order/trn_order_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/proofofpayment/bukti_pembayaran_page_controller.dart';
import 'package:jaya_propertiy/presentation/views/modules/proofofpayment/bukti_pembayaran_detail_page.dart';

class BuktiPembayaranPage extends GetView<BuktiPembayaranPageController> {
  const BuktiPembayaranPage({super.key});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    Widget actionSection() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (controller.selectedData.value.paymentDetail?.pymntStatus ==
                  'P')
                CustomButton(
                  onPressed: () {
                    controller.doVoidPayment();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      colorStyle.primary,
                    ),
                    foregroundColor: MaterialStateProperty.all<Color>(
                      colorStyle.white,
                    ),
                    overlayColor: MaterialStateProperty.all<Color>(
                      colorStyle.white.withOpacity(0.1),
                    ),
                    elevation: MaterialStateProperty.all<double>(0),
                  ),
                  label: Row(
                    children: [
                      const Icon(Icons.block_outlined),
                      SizedBox(
                        width: layoutStyle.defaultMargin / 5,
                      ),
                      Text(
                        'Void',
                        style: textStyle.whiteText,
                      ),
                    ],
                  ),
                  width: layoutStyle.blockHorizontal * 12,
                  height: layoutStyle.blockVertical * 5,
                ),
              SizedBox(
                width: layoutStyle.defaultMargin / 2,
              ),
              CustomButton(
                onPressed: controller.selectedData.value.orderStatus == 'C' ||
                        controller.selectedData.value.orderStatus == 'P'
                    ? () {
                        controller.doPrintTicket();
                      }
                    : () {},
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    controller.selectedData.value.orderStatus == 'C' ||
                        controller.selectedData.value.orderStatus == 'P' ? colorStyle.primary : colorStyle.primary.withOpacity(0.50),
                  ),
                  foregroundColor: MaterialStateProperty.all<Color>(
                    colorStyle.white,
                  ),
                  overlayColor: MaterialStateProperty.all<Color>(
                    colorStyle.white.withOpacity(0.1),
                  ),
                  elevation: MaterialStateProperty.all<double>(0),
                ),
                label: Row(
                  children: [
                    Icon(Icons.print),
                    SizedBox(
                      width: layoutStyle.defaultMargin / 5,
                    ),
                    Text(
                      'Cetak',
                      style: textStyle.whiteText,
                    ),
                  ],
                ),
                width: layoutStyle.blockHorizontal * 12,
                height: layoutStyle.blockVertical * 5,
              ),
            ],
          ),
          SizedBox(
            height: layoutStyle.defaultMargin,
          ),
          CustomButton(
            onPressed: () {
              controller.doSendMessage();
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(colorStyle.primary),
              foregroundColor:
                  MaterialStateProperty.all<Color>(colorStyle.white),
              overlayColor: MaterialStateProperty.all<Color>(
                  colorStyle.white.withOpacity(0.1)),
              elevation: MaterialStateProperty.all<double>(0),
            ),
            label: Row(
              children: [
                Icon(Icons.send),
                SizedBox(
                  width: layoutStyle.defaultMargin / 5,
                ),
                Text(
                  'Kirim Bukti Pembayaran',
                  style: textStyle.whiteText,
                ),
              ],
            ),
            width: layoutStyle.blockHorizontal * 25,
            height: layoutStyle.blockVertical * 5,
          ),
        ],
      );
    }

    Widget rightSection(TrnDetailOrderEntity model) {
      return Obx(
        () => controller.isLoadingDetail.value
            ? Expanded(
                child: Container(
                  child: loading.simpleLoading(),
                ),
              )
            : model.orderNumber == null
                ? Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              assetsConstant.imgEmptyBox,
                              fit: BoxFit.fill,
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
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
                                controller.detailModel.value.orderStatus == 'V'
                                    ? Container()
                                    : actionSection()
                              ],
                            ),
                          ),
                          Expanded(
                            child: BuktiPembayaranDetailPage(model: model),
                          ),
                        ],
                      ),
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
          constraints: BoxConstraints(
            minHeight: layoutStyle.blockVertical * 30,
          ),
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
                    // color: model.paymentDetail?.pymntStatus == 'P'
                    //     ? colorStyle.lime
                    //     : colorStyle.cloud_blue,
                    color: model.orderStatus == 'P' || model.orderStatus == 'C'
                        ? colorStyle.lime
                        : model.orderStatus == 'S'
                            ? colorStyle.blue
                            : model.orderStatus == 'V'
                                ? colorStyle.red
                                : colorStyle.cloud_blue,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    // model.paymentDetail?.pymntStatus == 'P'
                    //     ? 'Paid'
                    //     : 'Not Paid',
                    model.orderStatus == 'P' || model.orderStatus == 'C'
                        ? 'Paid'
                        : model.orderStatus == 'S'
                            ? 'Request Void'
                            : model.orderStatus == 'V'
                                ? 'Void'
                                : 'Not Paid',
                    style: TextStyle(
                      // color: colorStyle.black,

                      color:
                          model.orderStatus == 'P' || model.orderStatus == 'C'
                              ? colorStyle.black
                              : model.orderStatus == 'S'
                                  ? colorStyle.white
                                  : model.orderStatus == 'V'
                                      ? colorStyle.white
                                      : colorStyle.black,
                      fontSize: fontSize.small,
                    ),
                  ),
                ),
              ),
              Container(
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
                            Expanded(
                              child: Text(
                                // MapPaymentMethod[model.orderPaidBy] ?? '',
                                model.orderPaidByName ?? '',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: TextStyle(
                                  fontWeight: fontWeight.bold,
                                  fontSize: fontSize.small,
                                ),
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
                                    model.orderName ?? '',
                                    // model.customerDetail?.custName ?? '',
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
        child: controller.isLoading.value
            ? loading.simpleLoading()
            : RefreshIndicator(
                onRefresh: () async {
                  await controller.doRefresh();
                },
                child: SingleChildScrollView(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: controller.dataList.isEmpty
                      ? Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(
                            top: layoutStyle.defaultMargin * 4,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  assetsConstant.imgEmptyBox,
                                  fit: BoxFit.fill,
                                  errorBuilder: (BuildContext context,
                                      Object exception,
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
                      : Column(
                          children: controller.dataList
                              .map((e) => cardSection(
                                  model: e,
                                  selectedCard: controller
                                              .selectedData.value.orderNumber !=
                                          null &&
                                      e.orderNumber ==
                                          controller
                                              .selectedData.value.orderNumber))
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
