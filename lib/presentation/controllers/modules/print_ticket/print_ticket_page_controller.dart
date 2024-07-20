import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/common/custom_table_data.dart';
import 'package:jaya_propertiy/presentation/components/custom_badge.dart';

class PrintTicketPageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  PrintTicketPageController();

  var selected = List<bool>.generate(100, (index) => false).obs;
  var selectAll = false.obs;
  final searchController = TextEditingController();
  final listColumnHeader = <CustomTableData>[].obs;
  final openDetail = false.obs;

  TabController? tabController;

  @override
  void onInit() {
    // TODO: implement onInit
    tabController = TabController(length: 1, vsync: this);
    tabController?.addListener(_handleTabSelection);
    setListHeaderColumn();
    super.onInit();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    tabController?.dispose();
    super.onClose();
  }

  void _handleTabSelection() {
    if (!tabController!.indexIsChanging) {
      changeTabIndex(tabController!.index);
    }
  }

  var tabIndex = 0.obs;
  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  void toggleSelectAll(bool? value) {
    selectAll.value = value ?? false;
    for (int i = 0; i < selected.length; i++) {
      selected[i] = selectAll.value;
    }
    update();
  }

  void toggleSelect(int index, bool? value) {
    selected[index] = value ?? false;
    selectAll.value = selected.every((element) => element);
    update();
  }

  // Widget badgeCard({
  //   required String label,
  //   required Color colorLabel,
  //   required Color colorBox,
  // }) {
  //   return Center(
  //     child: Container(
  //       padding: EdgeInsets.all(
  //         layoutStyle.defaultMargin / 2,
  //       ),
  //       decoration: BoxDecoration(
  //         color: colorBox,
  //         borderRadius: BorderRadius.circular(
  //           layoutStyle.defaultMargin / 2,
  //         ),
  //       ),
  //       child: Text(
  //         label,
  //         style: TextStyle(
  //           color: colorLabel,
  //           fontSize: fontSize.small,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  setListHeaderColumn() {
    listColumnHeader.add(
      CustomTableData(
        id: 'orderId',
        columnName: 'ID Order',
        data: const Text('ORD0001'),
        alignment: Alignment.centerLeft,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'orderName',
        columnName: 'Nama',
        data: const Text('Arthur'),
        alignment: Alignment.centerLeft,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'orderTicket',
        columnName: 'Ticket',
        data: const Text('Personal'),
        alignment: Alignment.centerLeft,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'orderJml',
        columnName: 'Jml Tiket',
        data:  const Text('1'),
        alignment: Alignment.center,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'orderAmnt',
        columnName: 'Harga(Rp)',
        data: const Text('Rp.25,000'),
        alignment: Alignment.centerRight,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'orderSource',
        columnName: 'Order Source',
        data: const Text('Onsite'),
        alignment: Alignment.centerLeft,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'orderStatus',
        columnName: 'Status Pembayaran',
        data: CustomBadge(
          label: 'Sukses',
          colorLabel: colorStyle.black,
          colorBox: colorStyle.green,
        ),
        alignment: Alignment.center,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'tiketStatus',
        columnName: 'Status Tiket',
        data: CustomBadge(
          label: 'Active',
          colorLabel: colorStyle.black,
          colorBox: colorStyle.green,
        ),
        alignment: Alignment.centerLeft,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'printStatus',
        columnName: 'Status Cetak',
        data: CustomBadge(
          label: 'Cetak',
          colorLabel: colorStyle.black,
          colorBox: colorStyle.green,
        ),
        alignment: Alignment.centerLeft,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'scanStatus',
        columnName: 'Status Scan',
        data: const Text('1/1'),
        alignment: Alignment.center,
      ),
    );
    update();
  }

  doPrepareList() {
    //
  }

  doToDetail() {
    openDetail.value = !openDetail.value;
    update();
  }
}
