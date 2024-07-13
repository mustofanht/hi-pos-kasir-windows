import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/print_ticket/print_ticket_page_controller.dart';

class PrintTicketPage extends GetView<PrintTicketPageController> {
  const PrintTicketPage({super.key});

  Widget badgeCard({
    required String label,
    required Color colorLabel,
    required Color colorBox,
  }) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(
          layoutStyle.defaultMargin / 2,
        ),
        decoration: BoxDecoration(
          color: colorBox,
          borderRadius: BorderRadius.circular(
            layoutStyle.defaultMargin / 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: colorLabel,
            fontSize: fontSize.small,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget contentTableSection(PrintTicketPageController controller) {
      return Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Container(
              width: layoutStyle.screenWidth,
              height: layoutStyle.screenHeight / 2,
              margin: EdgeInsets.symmetric(
                horizontal: layoutStyle.defaultMargin,
              ),
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
                    child: Container(
                      padding: EdgeInsets.all(layoutStyle.defaultMargin),
                      width: layoutStyle.screenWidth,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.resolveWith(
                            (states) => colorStyle.grey.withOpacity(0.1),
                          ),
                          dataRowColor: MaterialStateProperty.resolveWith(
                            (states) => colorStyle.white,
                          ),
                          border:
                              TableBorder.all(color: colorStyle.transparent),
                          columns: [
                            DataColumn(
                              label: Checkbox(
                                value: false,
                                onChanged: (value) =>
                                    controller.selectAll(value),
                              ),
                            ),
                            const DataColumn(
                              label: Text('ID Order'),
                            ),
                            const DataColumn(
                              label: Text('Nama'),
                            ),
                            const DataColumn(
                              label: Text('Jenis Tiket'),
                            ),
                            const DataColumn(
                              label: Text('Harga (Rp)'),
                            ),
                            const DataColumn(
                              label: Text('Source Order'),
                            ),
                            const DataColumn(
                              label: Text('Status Pembayaran'),
                            ),
                            const DataColumn(
                              label: Text('Status'),
                            ),
                          ],
                          rows: List<DataRow>.generate(
                            100,
                            (index) => DataRow(
                              cells: [
                                DataCell(
                                  Checkbox(
                                    value: false,
                                    onChanged: (value) =>
                                        controller.selectAll(value),
                                  ),
                                ),
                                DataCell(Text('data $index')),
                                DataCell(Text('data $index')),
                                DataCell(Text('data $index')),
                                DataCell(Text('data $index')),
                                DataCell(Text('data $index')),
                                DataCell(
                                  badgeCard(
                                    label: 'Sukses',
                                    colorLabel: colorStyle.white,
                                    colorBox: colorStyle.yellow,
                                  ),
                                ),
                                DataCell(
                                  badgeCard(
                                    label: 'Sukses',
                                    colorLabel: colorStyle.white,
                                    colorBox: colorStyle.yellow,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return GetBuilder(
      init: controller,
      tag: 'PrintTicketPage',
      initState: (state) {
        controller;
      },
      builder: (controller) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(layoutStyle.defaultMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Cetak Ticket',
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
                controller: null,
                decoration: InputDecoration(
                  hintText: 'Masukan nomor ID Order atau ID Ticket',
                  hintStyle: textStyle.greyText,
                  border: InputBorder.none,
                ),
              ),
              SizedBox(height: layoutStyle.defaultMargin),
              contentTableSection(controller),
              SizedBox(height: layoutStyle.defaultMargin),
              CustomButton(
                onPressed: () {},
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(colorStyle.primary),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(colorStyle.white),
                  overlayColor: MaterialStateProperty.all<Color>(
                      colorStyle.white.withOpacity(0.1)),
                  elevation: MaterialStateProperty.all<double>(0),
                ),
                label: const Text('Print Tiket'),
                margin:
                    EdgeInsets.symmetric(horizontal: layoutStyle.defaultMargin),
                width: layoutStyle.screenWidth,
                height: layoutStyle.blockVertical * 6,
              ),
            ],
          ),
        );
      },
    );
  }
}
