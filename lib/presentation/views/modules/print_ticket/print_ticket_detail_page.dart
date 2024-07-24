import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/table_delgate.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/components/custom_badge.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/print_ticket/print_ticket_detail_page_controller.dart';

class PrintTicketDetailPage extends GetView<PrintTicketDetailPageController> {
  const PrintTicketDetailPage({super.key});

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

  Widget leftSection() {
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
                      'ORD0001',
                      style: TextStyle(
                        fontWeight: fontWeight.bold,
                      ),
                    ),
                  ),
                  leftColum(
                    column: 'Nama',
                    value: Text(
                      'Arthur',
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
                      '17 Jul 2024 : 09:10',
                      style: TextStyle(
                        fontWeight: fontWeight.bold,
                      ),
                    ),
                  ),
                  leftColum(
                    column: 'Source Order',
                    value: Text(
                      'Onsite',
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
                      '1',
                      style: TextStyle(
                        fontWeight: fontWeight.bold,
                      ),
                    ),
                  ),
                  leftColum(
                    column: 'Jenis Tiket',
                    value: Text(
                      'Perorang',
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
                    column: 'Status Pembayaran',
                    value: CustomBadge(
                      label: 'On Process',
                      colorLabel: colorStyle.black,
                      colorBox: colorStyle.creamy,
                      margin: EdgeInsets.zero,
                    ),
                  ),
                  leftColum(
                    column: 'Jenis Tiket',
                    value: CustomBadge(
                      label: 'Belum Cetak',
                      colorLabel: colorStyle.white,
                      colorBox: colorStyle.black,
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
                      'Rp 0',
                      style: TextStyle(
                        fontWeight: fontWeight.bold,
                      ),
                    ),
                  ),
                  leftColum(
                    column: 'Voucher',
                    value: Text(
                      'Rp 0',
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
                      'Rp 0',
                      style: TextStyle(
                        fontWeight: fontWeight.bold,
                      ),
                    ),
                  ),
                  leftColum(
                    column: 'Biaya Ppn',
                    value: Text(
                      'Rp 20,000',
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
                      'Rp 25,000',
                      style: TextStyle(
                        fontWeight: fontWeight.bold,
                      ),
                    ),
                  ),
                  leftColum(
                    column: 'Total Tagihan',
                    value: Text(
                      'Rp 45,000',
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

  Widget rightSection() {
    return Expanded(
      child: Container(
        height: layoutStyle.screenHeight,
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
                  padding: EdgeInsets.all(layoutStyle.defaultMargin),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      // await controller.doPrepareList(page: 1);
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: DataTableDelegate(
                            minHeight: 50.0,
                            maxHeight: 50.0,
                            child: Material(
                              color: colorStyle.lightGrey,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                  layoutStyle.defaultMargin / 2,
                                ),
                                topRight: Radius.circular(
                                  layoutStyle.defaultMargin / 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    fillColor: MaterialStatePropertyAll(
                                        colorStyle.blue),
                                    value: controller.selectAll.value,
                                    onChanged: (value) =>
                                        controller.toggleSelectAll(value),
                                  ),
                                  ...controller.listColumnHeader
                                      .map(
                                        (element) => Expanded(
                                          child: Text(
                                            element.columnName ?? '',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: colorStyle.black,
                                                fontWeight: fontWeight.bold),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: colorStyle.lightGrey,
                                        width: 1.0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      fillColor: MaterialStatePropertyAll(
                                          colorStyle.blue),
                                      value: controller.selected[index],
                                      onChanged: (value) =>
                                          controller.toggleSelect(index, value),
                                    ),
                                    ...controller.listColumnHeader.map(
                                      (element) => Expanded(
                                        child: Container(
                                          alignment: element.alignment,
                                          child: const Text('Value'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            childCount: 100,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(vertical: layoutStyle.defaultMargin / 2),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      margin: EdgeInsets.symmetric(
                        vertical: layoutStyle.defaultMargin / 2,
                        // horizontal: layoutStyle.defaultMargin,
                      ),
                      onPressed: () {},
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
                        elevation: const MaterialStatePropertyAll(0),
                      ),
                      label: Text(
                        'Print Tiket',
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
                      onPressed: () {},
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
                        elevation: const MaterialStatePropertyAll(0),
                      ),
                      label: Text(
                        'Print Tiket',
                        style: textStyle.blackText,
                      ),
                      height: layoutStyle.blockVertical * 6.5,
                    ),
                  ),
                ],
              ),
            ),
            CustomButton(
              onPressed: () {},
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);
    // TODO: implement build
    return GetBuilder(
      init: controller,
      tag: 'PrintTicketDetailPage',
      initState: (state) {},
      builder: (controller) {
        return Container(
          width: layoutStyle.screenWidth,
          height: layoutStyle.screenHeight,
          padding: EdgeInsets.all(layoutStyle.defaultMargin),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: layoutStyle.blockHorizontal * 4,
                    height: layoutStyle.blockVertical * 5,
                    child: CustomButton(
                      onPressed: () {
                        controller.doBack();
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(colorStyle.white),
                        foregroundColor: MaterialStateProperty.all<Color>(
                            colorStyle.primary),
                        overlayColor: MaterialStateProperty.all<Color>(
                            colorStyle.primary.withOpacity(0.1)),
                        side: MaterialStateProperty.all<BorderSide>(
                            BorderSide(color: colorStyle.primary, width: 1)),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                            EdgeInsets.symmetric(
                                vertical: layoutStyle.defaultMargin / 5,
                                horizontal: layoutStyle.defaultMargin / 5)),
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
                    leftSection(),
                    SizedBox(
                      width: layoutStyle.defaultMargin,
                    ),
                    rightSection(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
