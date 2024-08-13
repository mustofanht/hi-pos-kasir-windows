import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/table_delgate.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/data/models/common/custom_table_data.dart';
import 'package:jaya_propertiy/presentation/components/custom_badge.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/print_ticket/print_ticket_page_controller.dart';
import 'package:jaya_propertiy/presentation/views/modules/print_ticket/print_ticket_detail_page.dart';

class PrintTicketPage extends GetView<PrintTicketPageController> {
  const PrintTicketPage({super.key});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    Widget headerSection(PrintTicketPageController controller) {
      return Row(
        children: controller.listColumnHeader.map((element) {
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
                        color: colorStyle.black, fontWeight: FontWeight.bold),
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
      );
    }

    Widget dataValue({required CustomTableData element, required int index}) {
      String id = element.id!;
      String val = controller.dataList[index].toJson()[id].toString();
      if (id == 'pymntStatus') {
        return CustomBadge(
          label: val == 'P' ? 'Paid' : 'Not Paid',
          colorLabel: (val == 'P' ? colorStyle.black : colorStyle.white),
          colorBox: (val == 'P' ? colorStyle.green : colorStyle.red),
        );
      } else if (id == 'otdtlStatus') {
        return CustomBadge(
          label: val == 'Y' ? 'Aktif' : 'Not Aktif',
          colorLabel: (val == 'Y' ? colorStyle.black : colorStyle.white),
          colorBox: (val == 'Y' ? colorStyle.green : colorStyle.red),
        );
      } else if (id == 'orderStatus') {
        return CustomBadge(
          label: val == 'C' ? 'Cetak' : 'Belum Cetak',
          colorLabel: (val == 'C' ? colorStyle.black : colorStyle.white),
          colorBox: (val == 'C' ? colorStyle.green : colorStyle.grey),
        );
      } else {
        return Text(element.defaultValue ?? val);
      }
    }

    Widget dataListSection(PrintTicketPageController controller) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            if (controller.dataList.isNotEmpty) {
              return GestureDetector(
                onTap: () {
                  controller.doToDetail(controller.dataList[index]);
                },
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
                    children: controller.listColumnHeader.map((element) {
                      return element.width != null
                          ? Container(
                              width: element.width,
                              height: layoutStyle.blockVertical * 5,
                              alignment: element.alignment,
                              padding: EdgeInsets.symmetric(
                                horizontal: layoutStyle.defaultMargin / 2,
                                vertical: layoutStyle.defaultMargin / 4,
                              ),
                              child: dataValue(
                                element: element,
                                index: index,
                              ),
                            )
                          : Expanded(
                              child: Container(
                                alignment: element.alignment,
                                padding: EdgeInsets.symmetric(
                                  horizontal: layoutStyle.defaultMargin / 2,
                                  vertical: layoutStyle.defaultMargin / 4,
                                ),
                                child: dataValue(
                                  element: element,
                                  index: index,
                                ),
                              ),
                            );
                    }).toList(),
                  ),
                ),
              );
            } else {
              return Container();
            }
          },
          childCount: controller.dataList.length,
        ),
      );
    }

    Widget contentTableSection(PrintTicketPageController controller) {
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
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(layoutStyle.defaultMargin),
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await controller.doRefresh();
                          },
                          child: Obx(
                            () => CustomScrollView(
                              controller: controller.scrollController,
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
                                          layoutStyle.defaultMargin / 5,
                                        ),
                                        topRight: Radius.circular(
                                          layoutStyle.defaultMargin / 5,
                                        ),
                                      ),
                                      child: headerSection(controller),
                                    ),
                                  ),
                                ),
                                dataListSection(controller),
                              ],
                            ),
                          ),
                        ),
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
              controller.update();
            },
            // onSubmit: (val) async {
            //   await controller.doSearch(val);
            // },
            decoration: InputDecoration(
              hintText: 'Masukan nomor ID Order atau ID Ticket',
              hintStyle: textStyle.greyText,
              border: InputBorder.none,
              suffixIcon: IconButton(
                onPressed: () async {
                  await controller.doSearch(controller.searchController.text);
                  controller.update();
                },
                icon: const Icon(
                  Icons.search,
                ),
              ),
              // suffixIcon: const Icon(
              //   Icons.search,
              // ),
            ),
          ),
          SizedBox(height: layoutStyle.defaultMargin),
          contentTableSection(controller),
        ],
      );
    }

    // Widget contentSection(PrintTicketPageController controller) {
    //   return Column(
    //     children: [
    //       Container(
    //         width: layoutStyle.screenWidth,
    //         color: colorStyle.lightGrey,
    //         child: Container(
    //           padding: EdgeInsets.symmetric(
    //             horizontal: layoutStyle.screenWidth / 3,
    //           ),
    //           child: TabBar(
    //             controller: controller.tabController,
    //             indicator: BoxDecoration(
    //               color: colorStyle.white,
    //               border: Border(
    //                 bottom: BorderSide(
    //                   color: colorStyle.primary,
    //                   width: 1.0,
    //                 ),
    //               ),
    //             ),
    //             labelColor: colorStyle.primary,
    //             unselectedLabelColor: colorStyle.black,
    //             tabs: const [
    //               Tab(text: 'Ticket'),
    //             ],
    //           ),
    //         ),
    //       ),
    //       Expanded(
    //         child: Padding(
    //           padding: EdgeInsets.all(
    //             layoutStyle.defaultMargin * 1.5,
    //           ),
    //           child: TabBarView(
    //             controller: controller.tabController,
    //             children: [
    //               ticketSection(),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ],
    //   );
    // }

    return GetBuilder<PrintTicketPageController>(
      init: controller,
      tag: 'PrintTicketPage',
      // initState: (state) {
      //   controller.setListHeaderColumn();
      //   controller.doPrepareList(page: 0);
      // },
      builder: (controller) {
        return controller.openDetail.value
            ? const PrintTicketDetailPage()
            : Container(
                padding: EdgeInsets.all(layoutStyle.defaultMargin),
                child: ticketSection());
        // : contentSection(controller);
      },
    );
  }
}
