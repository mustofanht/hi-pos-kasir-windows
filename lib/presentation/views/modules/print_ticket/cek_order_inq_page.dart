import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/components/custom_badge.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/print_ticket/print_ticket_page_controller.dart';

class CekOrderInqPage extends StatelessWidget {
  final PrintTicketPageController controller;
  const CekOrderInqPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    Widget dataValue({required String id, required String val}) {
      if (id == 'pymntStatus') {
        return CustomBadge(
          label: val == 'P' ? 'Paid' : 'Not Paid',
          colorLabel: (val == 'P' ? colorStyle.black : colorStyle.white),
          colorBox: (val == 'P' ? colorStyle.green : colorStyle.red),
        );
      } else if (id == 'otdtlStatus') {
        String? voidStatus = val;
        if (voidStatus.isNotEmpty && voidStatus == 'V') {
          return CustomBadge(
            label: 'Void',
            colorLabel: colorStyle.white,
            colorBox: colorStyle.grey,
          );
        } else {
          return CustomBadge(
            label: val == 'Y' ? 'Aktif' : 'Not Aktif',
            colorLabel: (val == 'Y' ? colorStyle.black : colorStyle.white),
            colorBox: (val == 'Y' ? colorStyle.green : colorStyle.red),
          );
        }
      } else if (id == 'statusCetak') {
        return CustomBadge(
          label: val == 'Y' ? 'Cetak' : 'Belum Cetak',
          colorLabel: (val == 'Y' ? colorStyle.black : colorStyle.white),
          colorBox: (val == 'Y' ? colorStyle.green : colorStyle.grey),
          // label: val == 'C' ? 'Cetak' : 'Belum Cetak',
          // colorLabel: (val == 'C' ? colorStyle.black : colorStyle.white),
          // colorBox: (val == 'C' ? colorStyle.green : colorStyle.grey),
        );
      } else {
        return Text(val);
      }
    }

    Widget contentTableSection() {
      return Expanded(
        child: controller.isLoading.value
            ? loading.simpleLoading()
            : Container(
                width: layoutStyle.screenWidth,
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: colorStyle.black),
                  borderRadius: BorderRadius.all(
                    Radius.circular(layoutStyle.defaultMargin / 5),
                  ),
                  color: colorStyle.white,
                ),
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.all(layoutStyle.defaultMargin),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await controller.doRefresh();
                    },
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        dataRowHeight: layoutStyle.defaultMargin * 3,
                        columnSpacing: layoutStyle.defaultMargin * 2,
                        showCheckboxColumn: false,
                        headingRowColor: MaterialStatePropertyAll(
                          colorStyle.lightGrey,
                        ),
                        columns: controller.listColumnHeader
                            .map(
                              (element) => DataColumn(
                                label: Text(
                                  element.columnName ?? '',
                                ),
                              ),
                            )
                            .toList(),
                        rows: controller.dataList
                            .map(
                              (element) => DataRow(
                                // onLongPress: () {
                                //   controller.doToDetail(element);
                                // },
                                onSelectChanged: null,
                                cells: [
                                  DataCell(
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: layoutStyle.defaultMargin * 5,
                                        maxWidth: double.infinity,
                                      ),
                                      child: Text(element.orderNumber ?? ''),
                                    ),
                                    onTap: () => controller.doToDetail(element),
                                  ),
                                  DataCell(
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: layoutStyle.defaultMargin * 5,
                                        maxWidth: double.infinity,
                                      ),
                                      child: Text(element.ticketName ?? ''),
                                    ),
                                    onTap: () => controller.doToDetail(element),
                                  ),
                                  DataCell(
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: layoutStyle.defaultMargin * 5,
                                        maxWidth: double.infinity,
                                      ),
                                      child: const Text('Onsite'),
                                    ),
                                    onTap: () => controller.doToDetail(element),
                                  ),
                                  DataCell(
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: layoutStyle.defaultMargin * 5,
                                        maxWidth: double.infinity,
                                      ),
                                      child: dataValue(
                                        id: 'pymntStatus',
                                        val: element.pymntStatus ?? '',
                                      ),
                                    ),
                                    onTap: () => controller.doToDetail(element),
                                  ),
                                  DataCell(
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: layoutStyle.defaultMargin * 5,
                                        maxWidth: double.infinity,
                                      ),
                                      child: dataValue(
                                        id: 'otdtlStatus',
                                        val: element.otdtlStatus ?? '',
                                      ),
                                    ),
                                    onTap: () => controller.doToDetail(element),
                                  ),
                                  DataCell(
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: layoutStyle.defaultMargin * 5,
                                        maxWidth: double.infinity,
                                      ),
                                      child: dataValue(
                                        id: 'statusCetak',
                                        val: element.statusCetak ?? '',
                                      ),
                                    ),
                                    onTap: () => controller.doToDetail(element),
                                  ),
                                  DataCell(
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: layoutStyle.defaultMargin * 5,
                                        maxWidth: double.infinity,
                                      ),
                                      child: Text(
                                        element.countScan ?? '',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    onTap: () => controller.doToDetail(element),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
      );
    }

    return Obx(
      () => Container(
        padding: EdgeInsets.all(layoutStyle.defaultMargin),
        child: Column(
          children: [
            Text(
              'Cetak Order',
              style: TextStyle(
                fontSize: fontSize.header,
                fontWeight: fontWeight.bold,
              ),
            ),
            SizedBox(height: layoutStyle.defaultMargin),
            CustomTextBox(
              height: layoutStyle.blockVertical * 6.5,
              margin: EdgeInsets.symmetric(
                // horizontal: layoutStyle.defaultMargin,
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
              onChanged: (val) {
                controller.searchController.text = val;
                controller.searchController.selection =
                    TextSelection.fromPosition(
                  TextPosition(offset: controller.searchController.text.length),
                );
                // controller.update();
              },
              decoration: InputDecoration(
                hintText: 'Masukan nomor ID Order atau ID Ticket',
                hintStyle: textStyle.greyText,
                border: InputBorder.none,
                suffixIcon: IconButton(
                  onPressed: () async {
                    // await controller.doSearch(controller.searchController.text);
                    // controller.update();
                  },
                  icon: const Icon(
                    Icons.search,
                  ),
                ),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: layoutStyle.defaultMargin),
            contentTableSection(),
          ],
        ),
      ),
    );
  }
}
