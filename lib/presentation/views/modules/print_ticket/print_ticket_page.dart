import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/table_delgate.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/print_ticket/print_ticket_page_controller.dart';
import 'package:jaya_propertiy/presentation/views/modules/print_ticket/print_ticket_detail_page.dart';

class PrintTicketPage extends GetView<PrintTicketPageController> {
  const PrintTicketPage({super.key});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    Widget contentTableSection(PrintTicketPageController controller) {
      return Obx(
        () => Expanded(
          child: Container(
            width: layoutStyle.screenWidth,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: colorStyle.black,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
              color: colorStyle.white,
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: layoutStyle.defaultMargin,
                    vertical: layoutStyle.defaultMargin,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: layoutStyle.defaultMargin,
                        ),
                        child: Row(
                          children: [
                            const Text('Nama Pembeli:'),
                            Text(
                              'Arthur Morgan',
                              style: TextStyle(
                                fontWeight: fontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: layoutStyle.defaultMargin,
                        ),
                        child: Row(
                          children: [
                            const Text('Order ID:'),
                            Text(
                              '1000230123678',
                              style: TextStyle(
                                fontWeight: fontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: layoutStyle.defaultMargin,
                      left: layoutStyle.defaultMargin,
                      right: layoutStyle.defaultMargin,
                    ),
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
                                return GestureDetector(
                                  onTap: () {
                                    controller.doToDetail();
                                  },
                                  child: Container(
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
                                          onChanged: (value) => controller
                                              .toggleSelect(index, value),
                                        ),
                                        ...controller.listColumnHeader.map(
                                          (element) => Expanded(
                                            child: Container(
                                              alignment: element.alignment,
                                              child: element.data ??
                                                  const Text(''),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
              ],
            ),
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
            decoration: InputDecoration(
                hintText: 'Masukan nomor ID Order atau ID Ticket',
                hintStyle: textStyle.greyText,
                border: InputBorder.none,
                suffixIcon: Icon(Icons.search)),
          ),
          SizedBox(height: layoutStyle.defaultMargin),
          contentTableSection(controller),
        ],
      );
    }

    return GetBuilder(
      init: controller,
      tag: 'PrintTicketPage',
      initState: (state) {},
      builder: (controller) {
        return controller.openDetail.value
            ? const PrintTicketDetailPage()
            : Column(
                children: [
                  Container(
                    width: layoutStyle.screenWidth,
                    color: colorStyle.lightGrey,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: layoutStyle.screenWidth / 3,
                      ),
                      child: TabBar(
                        controller: controller.tabController,
                        indicator: BoxDecoration(
                          color: colorStyle.white,
                          border: Border(
                            bottom: BorderSide(
                              color: colorStyle.primary,
                              width: 1.0,
                            ),
                          ),
                        ),
                        labelColor: colorStyle.primary,
                        unselectedLabelColor: colorStyle.black,
                        tabs: const [
                          Tab(text: 'Ticket'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(layoutStyle.defaultMargin * 1.5),
                      child: TabBarView(
                        controller: controller.tabController,
                        children: [
                          ticketSection(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
      },
    );
  }
}