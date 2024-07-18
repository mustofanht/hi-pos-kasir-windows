import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_dynamic_dot.dart';
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

    Widget leftSection() {
      return Expanded(
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
              cardShift(
                date: '17 Jul 2024',
                time: 'Sedang Berlangsung',
                selected: true,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(layoutStyle.defaultMargin / 2),
                  bottomRight: Radius.circular(layoutStyle.defaultMargin / 2),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: layoutStyle.defaultMargin),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
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
                        cardShift(
                          date: '17 Jul 2024',
                          time: '10:00 - 15:00',
                          selected: false,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                              layoutStyle.defaultMargin / 2,
                            ),
                            topRight: Radius.circular(
                              layoutStyle.defaultMargin / 2,
                            ),
                          ),
                        ),
                        cardShift(
                          date: '17 Jul 2024',
                          time: '10:00 - 15:00',
                          selected: false,
                          borderRadius: BorderRadius.zero,
                        ),
                        cardShift(
                          date: '17 Jul 2024',
                          time: '10:00 - 15:00',
                          selected: false,
                          borderRadius: BorderRadius.zero,
                        ),
                        cardShift(
                          date: '17 Jul 2024',
                          time: '10:00 - 15:00',
                          selected: false,
                          borderRadius: BorderRadius.zero,
                        ),
                        cardShift(
                          date: '17 Jul 2024',
                          time: '10:00 - 15:00',
                          selected: false,
                          borderRadius: BorderRadius.zero,
                        ),
                        cardShift(
                          date: '17 Jul 2024',
                          time: '10:00 - 15:00',
                          selected: false,
                          borderRadius: BorderRadius.zero,
                        ),
                        cardShift(
                          date: '17 Jul 2024',
                          time: '10:00 - 15:00',
                          selected: false,
                          borderRadius: BorderRadius.zero,
                        ),
                        cardShift(
                          date: '17 Jul 2024',
                          time: '10:00 - 15:00',
                          selected: false,
                          borderRadius: BorderRadius.zero,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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

    Widget rightSection() {
      return Expanded(
        child: Container(
          height: layoutStyle.screenHeight,
          padding: EdgeInsets.all(layoutStyle.defaultMargin),
          decoration: BoxDecoration(
            color: colorStyle.white,
          ),
          child: Column(
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
                        value: 'Arthur Morgan',
                        head: false,
                      ),
                      columnShift(
                        key: 'Shift Mulai',
                        value: 'Senin, 17 Juli 2024 | 09:00',
                        head: false,
                      ),
                      columnShift(
                        key: 'Lokasi',
                        value: 'Jakarta',
                        head: false,
                      ),
                      columnShift(
                        key: 'Shift Berakhir',
                        value: 'Shift sedang berlangsung',
                        colorValue: colorStyle.primary,
                        head: false,
                      ),
                      columnShift(
                        key: 'Tiket',
                        value: '124',
                        head: false,
                      ),
                      columnShift(
                        key: 'Item',
                        value: '5',
                        head: false,
                      ),
                      columnShift(
                        key: 'Card',
                        head: true,
                      ),
                      columnShift(
                        key: 'Debit/Card',
                        value: 'IDR 2.300.000',
                        head: false,
                        paddingKey: EdgeInsets.only(
                          left: layoutStyle.defaultMargin,
                        ),
                      ),
                      columnShift(
                        key: 'Voided',
                        value: 'IDR 0',
                        head: false,
                        paddingKey: EdgeInsets.only(
                          left: layoutStyle.defaultMargin,
                        ),
                      ),
                      columnShift(
                        key: 'E-Wallet',
                        head: true,
                      ),
                      columnShift(
                        key: 'Gopay',
                        value: 'IDR 1.200.000',
                        head: false,
                        paddingKey: EdgeInsets.only(
                          left: layoutStyle.defaultMargin,
                        ),
                      ),
                      columnShift(
                        key: 'OVO',
                        value: 'IDR 1.000.000',
                        head: false,
                        paddingKey: EdgeInsets.only(
                          left: layoutStyle.defaultMargin,
                        ),
                      ),
                      columnShift(
                        key: 'Dana',
                        value: 'IDR 100.000',
                        head: false,
                        paddingKey: EdgeInsets.only(
                          left: layoutStyle.defaultMargin,
                        ),
                      ),
                      columnShift(
                        key: 'Link Aja',
                        value: 'IDR 0',
                        head: false,
                        paddingKey: EdgeInsets.only(
                          left: layoutStyle.defaultMargin,
                        ),
                      ),
                      columnShift(
                        key: 'Shopee Pay',
                        value: 'IDR 0',
                        head: false,
                        paddingKey: EdgeInsets.only(
                          left: layoutStyle.defaultMargin,
                        ),
                      ),
                      columnShift(
                        key: 'Kredivo',
                        value: 'IDR 0',
                        head: false,
                        paddingKey: EdgeInsets.only(
                          left: layoutStyle.defaultMargin,
                        ),
                      ),
                      columnShift(
                        key: 'Akulaku',
                        value: 'IDR 0',
                        head: false,
                        paddingKey: EdgeInsets.only(
                          left: layoutStyle.defaultMargin,
                        ),
                      ),
                      columnShift(
                        key: 'Total',
                        value: 'IDR 4.600.000',
                        head: true,
                      ),
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
              CustomButton(
                onPressed: () {},
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
                label: const Text('Akhiri Shift & Mulai Settlement'),
                width: layoutStyle.blockHorizontal * 20,
                height: layoutStyle.blockVertical * 5,
              ),
            ],
          ),
        ),
      );
    }

    return GetBuilder(
      init: controller,
      tag: 'ShiftPage',
      initState: (state) {
        controller;
      },
      builder: (controller) {
        return Container(
          height: layoutStyle.screenHeight,
          child: Row(
            children: [
              leftSection(),
              rightSection(),
            ],
          ),
        );
      },
    );
  }
}
