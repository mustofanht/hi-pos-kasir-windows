import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/data/models/cart/cart_rent_model.dart';
import 'package:jaya_propertiy/domain/entities/auth/auth_token.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/presentation/components/controller/custom_select_hours_rent_controller.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_card_transaction.dart';
import 'package:jaya_propertiy/presentation/components/custom_date_time_picker.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';

class CustomSelectHoursRent extends StatefulWidget {
  final Function(CartRentModel cartRentModel) onNext;
  final AddonEntity entitiy;
  final CartRentModel? detailModel;
  final AuthToken authToken;
  final bool isExtraTime;
  const CustomSelectHoursRent({
    super.key,
    required this.onNext,
    required this.entitiy,
    required this.authToken,
    this.detailModel,
    this.isExtraTime = false,
  });

  @override
  State<CustomSelectHoursRent> createState() => _CustomSelectHoursRentState();
}

class _CustomSelectHoursRentState extends State<CustomSelectHoursRent> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomSelectHoursRentController(
      entitiy: widget.entitiy,
      detailModel: widget.detailModel,
      authToken: widget.authToken,
    ));

    controller.isExtraTime.value = widget.isExtraTime;
    controller.update();

    List<Widget> headerSection() {
      return [
        Container(
          padding: EdgeInsets.symmetric(
            vertical: layoutStyle.defaultMargin / 2,
            horizontal: layoutStyle.defaultMargin,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Pilih Jam',
                  style: textStyle.blackText.copyWith(
                    fontWeight: fontWeight.bold,
                    fontSize: fontSize.header,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(
                  Icons.close,
                  color: colorStyle.red,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: layoutStyle.screenWidth,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorStyle.lightGrey,
                width: 1,
              ),
            ),
          ),
        ),
      ];
    }

    Widget actionSection() {
      return Container(
        padding: EdgeInsets.all(layoutStyle.defaultMargin),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: CustomButton(
                margin: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 2,
                  horizontal: layoutStyle.defaultMargin,
                ),
                onPressed: () {
                  Get.back();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                    (states) => colorStyle.white,
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
                  side: MaterialStatePropertyAll(
                    BorderSide(
                      color: colorStyle.blue,
                      width: 1,
                    ),
                  ),
                  elevation: const MaterialStatePropertyAll(0),
                ),
                label: Text(
                  'Batal',
                  style: textStyle.blueText,
                ),
                height: layoutStyle.blockVertical * 6.5,
              ),
            ),
            Expanded(
              child: CustomButton(
                margin: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 2,
                  horizontal: layoutStyle.defaultMargin,
                ),
                onPressed: () async {
                  CartRentModel cartRentModel = CartRentModel(
                    startDate: controller.startTime.value,
                    endDate: controller.endTime.value,
                    totalHours: controller.totalHoursController.text.isNotEmpty
                        ? int.parse(controller.totalHoursController.text)
                        : 0,
                    isExtraTime: controller.isExtraTime.value,
                    transactionExtra:
                        controller.selectedTransactionExtraTime.value,
                  );
                  if (await controller.checkhour()) {
                    if (controller.isExtraTime.value) {
                      if (controller.selectedTransactionExtraTime.value ==
                          null) {
                        alert.error(
                          'Error',
                          'Silahkan pilih trnsaksi sebelumnya untuk melakukan Extra Time',
                        );
                      } else {
                        widget.onNext(cartRentModel);
                      }
                    } else {
                      widget.onNext(cartRentModel);
                    }
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                    (states) => colorStyle.primary,
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
                  elevation: const MaterialStatePropertyAll(0),
                ),
                label: Text(
                  'Lanjutkan',
                  style: textStyle.whiteText,
                ),
                height: layoutStyle.blockVertical * 6.5,
              ),
            ),
          ],
        ),
      );
    }

    Widget extraTimeSection() {
      return Obx(
        () => Container(
          margin: EdgeInsets.symmetric(
            vertical: layoutStyle.defaultMargin,
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    controller.doCheckIsExtraTime();
                  },
                  child: Row(
                    children: [
                      Checkbox(
                        value: controller.isExtraTime.value,
                        onChanged: (v) {
                          controller.doCheckIsExtraTime();
                        },
                        activeColor: colorStyle.blue,
                      ),
                      Text(
                        'Extra Time',
                        style: textStyle.blackText,
                      )
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  controller.doSelectTransactionBefore();
                },
                child: Text(
                  'Transaksi Sebelumnya',
                  style: (controller.isExtraTime.value
                          ? textStyle.blueText
                          : textStyle.greyText)
                      .copyWith(
                    fontWeight: fontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Obx(
      () => Column(
        children: [
          ...headerSection(),
          controller.isLoading.value
              ? Expanded(
                  child: loading.simpleLoading(),
                )
              : Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(
                      layoutStyle.defaultMargin,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: colorStyle.lightGrey,
                              borderRadius: BorderRadius.circular(
                                layoutStyle.defaultMargin,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: layoutStyle.defaultMargin / 5,
                              vertical: layoutStyle.defaultMargin / 2,
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  assetsConstant.icInfo,
                                  color: colorStyle.blue,
                                  width: layoutStyle.blockHorizontal * 3,
                                  height: layoutStyle.blockVertical * 3,
                                ),
                                SizedBox(
                                  width: layoutStyle.defaultMargin / 2,
                                ),
                                Text(
                                  // 'Minimal sewa ${(widget.entitiy.minRentPrd != null ? widget.entitiy.minRentPrd! ~/ 60 : 0)} Jam',
                                  'Minimal sewa ${(widget.entitiy.minRentPrd != null ? widget.entitiy.minRentPrd! : 0)} Jam',
                                  style: textStyle.blackText.copyWith(
                                      // fontSize: fontSize.small,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          extraTimeSection(),
                          Obx(
                            () =>
                                controller.selectedTransactionExtraTime.value !=
                                        null
                                    ? Column(
                                        children: [
                                          CustomCardTransaction(
                                            data: controller
                                                .selectedTransactionExtraTime
                                                .value,
                                          ),
                                        ],
                                      )
                                    : Container(),
                          ),
                          Container(
                            width: layoutStyle.screenWidth,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: colorStyle.lightGrey,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: layoutStyle.defaultMargin,
                          ),
                          Text(
                            'Durasi sewa kamu : ',
                            style: textStyle.blackText.copyWith(
                              fontWeight: fontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: layoutStyle.defaultMargin,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Start Time:',
                                      style: textStyle.blackText,
                                    ),
                                    Obx(
                                      () => CustomDateTimePicker(
                                        margin: EdgeInsets.zero,
                                        firstState: false,
                                        newDate: controller.startTime.value,
                                        dateFormat: 'HH:mm',
                                        type: DateTimePickerType.OnlyTime,
                                        borderRadius: BorderRadius.circular(
                                          layoutStyle.defaultMargin,
                                        ),
                                        border: Border.all(
                                          color: colorStyle.lightGrey,
                                          width: 1,
                                        ),
                                        onDateChanged: (val) {
                                          controller.startTime.value = val;
                                          controller.setEndDateTime();
                                        },
                                        minDateTime: DateTime.now().toLocal(),
                                        // enable: widget.isExtraTime
                                        //     ? false
                                        //     : (controller
                                        //             .selectedTransactionExtraTime
                                        //             .value ==
                                        //         null),
                                        // enable: !controller.isExtraTime.value,
                                        // enable: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'End Time:',
                                      style: textStyle.blackText,
                                    ),
                                    Obx(() {
                                      logger.safeLog(
                                          'END TIMEEE : ${controller.endTime.value}');
                                      return CustomDateTimePicker(
                                        margin: EdgeInsets.zero,
                                        firstState: false,
                                        newDate: controller.endTime.value,
                                        dateFormat: 'HH:mm',
                                        type: DateTimePickerType.OnlyTime,
                                        borderRadius: BorderRadius.circular(
                                          layoutStyle.defaultMargin,
                                        ),
                                        border: Border.all(
                                          color: colorStyle.lightGrey,
                                          width: 1,
                                        ),
                                        enable: false,
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: layoutStyle.defaultMargin,
                          ),
                          Text(
                            'Jumlah Jam : ',
                            style: textStyle.blackText.copyWith(
                              fontWeight: fontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: layoutStyle.defaultMargin,
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: controller.doMinHours,
                                child: Container(
                                  width: layoutStyle.blockVertical * 6.5,
                                  height: layoutStyle.blockVertical * 6.5,
                                  padding: EdgeInsets.all(
                                      layoutStyle.defaultMargin / 2),
                                  decoration: BoxDecoration(
                                    color: colorStyle.black,
                                    borderRadius: BorderRadius.circular(
                                      layoutStyle.defaultMargin / 2,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colorStyle.white,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      color: colorStyle.black,
                                      size: fontSize.body,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: CustomTextBox(
                                  height: layoutStyle.blockVertical * 6.5,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: layoutStyle.defaultMargin,
                                    vertical: layoutStyle.defaultMargin / 4,
                                  ),
                                  obscureText: false,
                                  border: Border.all(
                                    color: colorStyle.black,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    layoutStyle.defaultMargin / 2,
                                  ),
                                  controller: controller.totalHoursController,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintStyle: textStyle.greyText,
                                    border: InputBorder.none,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  isDisabled: true,
                                ),
                              ),
                              GestureDetector(
                                onTap: controller.doAddHours,
                                child: Container(
                                  width: layoutStyle.blockVertical * 6.5,
                                  height: layoutStyle.blockVertical * 6.5,
                                  padding: EdgeInsets.all(
                                      layoutStyle.defaultMargin / 2),
                                  decoration: BoxDecoration(
                                    color: colorStyle.black,
                                    borderRadius: BorderRadius.circular(
                                      layoutStyle.defaultMargin / 2,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colorStyle.white,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: colorStyle.black,
                                      size: fontSize.body,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          actionSection(),
        ],
      ),
    );
  }
}
