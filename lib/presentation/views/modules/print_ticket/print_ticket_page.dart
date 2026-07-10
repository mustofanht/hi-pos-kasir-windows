import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/data/models/common/custom_table_data.dart';
import 'package:jaya_propertiy/domain/entities/order/vw_order_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_badge.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/print_ticket/print_ticket_page_controller.dart';
import 'package:jaya_propertiy/presentation/views/modules/print_ticket/print_ticket_detail_page.dart';

// class PrintTicketPage extends GetView<PrintTicketPageController> {
class PrintTicketPage extends StatelessWidget {
  const PrintTicketPage({super.key});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);
    final controller = Get.find<PrintTicketPageController>();

    Widget dataValueCustom({
      required CustomTableData element,
      required VwOrderEntity entity,
    }) {
      String id = element.id!;
      String val = entity.toJson()[id].toString();
      if (id == 'pymntStatus') {
        return CustomBadge(
          label: val == 'P' ? 'Paid' : 'Not Paid',
          colorLabel: (val == 'P' ? colorStyle.black : colorStyle.white),
          colorBox: (val == 'P' ? colorStyle.green : colorStyle.red),
        );
      } else if (id == 'otdtlStatus') {
        String? voidStatus = entity.toJson()['orderStatus'].toString();
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
        return Text(element.defaultValue ?? val);
      }
    }

    Widget dataTableCustom(VwOrderEntity e) {
      return GestureDetector(
        onTap: () {
          controller.doToDetail(e);
        },
        child: Container(
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
            children: controller.listColumnHeader.map(
              (element) {
                String val = e.toJson()[element.id] ?? '';

                if (common.isNumeric(val)) {
                  val = common.currencyFormat(double.parse(val));
                }
                return Expanded(
                  child: Container(
                    alignment: element.alignment,
                    padding: EdgeInsets.symmetric(
                      horizontal: layoutStyle.defaultMargin / 2,
                      vertical: layoutStyle.defaultMargin / 4,
                    ),
                    child: dataValueCustom(
                      element: element,
                      entity: e,
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ),
      );
    }

    Widget tableCustom() {
      // logger.safeLog('DATA NYA : ${controller.dataList.length}');
      return Column(
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
              children: controller.listColumnHeader
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
            child: Obx(
              () => controller.isLoading.value
                  ? Center(
                      child: loading.simpleLoading(),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: layoutStyle.defaultMargin,
                      ),
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await controller.doRefresh();
                        },
                        child: SingleChildScrollView(
                          controller: controller.scrollController,
                          // physics: const AlwaysScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: controller.dataList
                                .map(
                                  (e) => dataTableCustom(e),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      );
    }

    Widget contentTableSection(PrintTicketPageController controller) {
      return Expanded(
        child: Container(
          width: layoutStyle.screenWidth,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: colorStyle.black),
            borderRadius: BorderRadius.all(
              Radius.circular(layoutStyle.defaultMargin / 5),
            ),
            color: colorStyle.white,
          ),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(layoutStyle.defaultMargin),
                  child: tableCustom(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget ticketSection() {
      return Column(
        children: [
          Text(
            'Cetak Order',
            style: TextStyle(
              fontSize: fontSize.header,
              fontWeight: fontWeight.bold,
            ),
          ),
          SizedBox(height: layoutStyle.defaultMargin),
          Padding(
            padding: EdgeInsets.zero,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: layoutStyle.blockVertical * 6.5,
                    margin: EdgeInsets.symmetric(
                      vertical: layoutStyle.defaultMargin / 4,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: layoutStyle.defaultMargin / 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorStyle.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(
                        layoutStyle.defaultMargin / 2,
                      ),
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      obscureText: false,
                      decoration: InputDecoration(
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: layoutStyle.blockVertical * 1.5,
                          horizontal: layoutStyle.blockHorizontal * 2,
                        ),
                        hintText: 'Masukan nomor ID Order atau ID Ticket',
                        hintStyle: textStyle.greyText,
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ),
                SizedBox(
                  width: layoutStyle.defaultMargin,
                ),
                CustomButton(
                  height: layoutStyle.blockVertical * 6,
                  width: layoutStyle.blockVertical * 6,
                  margin: EdgeInsets.symmetric(
                    vertical: layoutStyle.defaultMargin / 2,
                  ),
                  onPressed: () async {
                    await controller.doSearch();
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size.zero),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    backgroundColor: MaterialStateProperty.resolveWith(
                      (states) => colorStyle.blue,
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
                  label: Icon(
                    Icons.search,
                    color: colorStyle.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: layoutStyle.defaultMargin),
          contentTableSection(controller),
        ],
      );
    }

    return Obx(
      () {
        return controller.openDetail.value
            ? PrintTicketDetailPage(
                parentController: controller,
              )
            : Container(
                padding: EdgeInsets.all(layoutStyle.defaultMargin),
                child: ticketSection(),
              );
      },
    );
  }
}
