import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/components/controller/custom_select_hours_rent_controller.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_card_transaction.dart';
import 'package:jaya_propertiy/presentation/components/custom_date_time_picker.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';

class CustomSelectHoursRent extends StatefulWidget {
  const CustomSelectHoursRent({super.key});

  @override
  State<CustomSelectHoursRent> createState() => _CustomSelectHoursRentState();
}

class _CustomSelectHoursRentState extends State<CustomSelectHoursRent> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomSelectHoursRentController());

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
                onPressed: () {},
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

    return Column(
      children: [
        ...headerSection(),
        Expanded(
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
                          'Minimal sewa 3 jam',
                          style: textStyle.blackText.copyWith(
                              // fontSize: fontSize.small,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
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
                  ),
                  Obx(
                    () => controller.selectedExtraTime.isNotEmpty
                        ? Column(
                            children: [
                              CustomCardTransaction(
                                isSelected: false,
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
                    'Durasi ewa kamu : ',
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
                      CustomButton(
                        width: layoutStyle.blockVertical * 6.5,
                        height: layoutStyle.blockVertical * 4.5,
                        margin: EdgeInsets.all(
                          layoutStyle.defaultMargin / 2,
                        ),
                        onPressed: controller.doMinHours,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => colorStyle.black,
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
                        label: Container(
                          width: layoutStyle.blockHorizontal * 1.5,
                          height: layoutStyle.blockHorizontal * 1.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: colorStyle.white,
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.remove,
                              color: colorStyle.black,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CustomTextBox(
                          height: layoutStyle.blockVertical * 4.5,
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
                      CustomButton(
                        width: layoutStyle.blockVertical * 6.5,
                        height: layoutStyle.blockVertical * 4.5,
                        margin: EdgeInsets.all(
                          layoutStyle.defaultMargin / 2,
                        ),
                        onPressed: controller.doAddHours,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => colorStyle.black,
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
                        label: Container(
                          width: layoutStyle.blockHorizontal * 1.5,
                          height: layoutStyle.blockHorizontal * 1.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: colorStyle.white,
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.add,
                              color: colorStyle.black,
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
    );
  }
}
