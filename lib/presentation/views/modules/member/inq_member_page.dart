import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/data/models/common/custom_table_data.dart';
import 'package:jaya_propertiy/domain/entities/member/member.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/inq_member_page_controller.dart';

class InqMemberPage extends GetView<InqMemberPageController> {
  const InqMemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    Widget _headerSection() {
      return Row(
        children: [
          Expanded(
            child: CustomTextBox(
              height: layoutStyle.blockVertical * 6.5,
              margin: EdgeInsets.symmetric(
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
              onChanged: (val) {},
              decoration: InputDecoration(
                hintText: 'Masukan nomor Member',
                hintStyle: textStyle.greyText,
                border: InputBorder.none,
                suffixIcon: IconButton(
                  onPressed: () async {},
                  icon: const Icon(
                    Icons.search,
                  ),
                ),
              ),
              keyboardType: TextInputType.text,
            ),
          ),
          CustomButton(
            width: layoutStyle.safeBlockHorizontal * 5,
            margin: EdgeInsets.symmetric(
              vertical: layoutStyle.defaultMargin / 2,
              horizontal: layoutStyle.defaultMargin,
            ),
            onPressed: () {
              controller.doToDetail(null);
            },
            style: ButtonStyle(
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
            label: Icon(Icons.add, color: colorStyle.white),
            height: layoutStyle.blockVertical * 6.5,
          ),
        ],
      );
    }

    Widget _dataValueCustom({
      required CustomTableData element,
      required Member entity,
    }) {
      String id = element.id!;
      String val = entity.toJson()[id].toString();
      // if (id == 'pymntStatus') {
      //   return CustomBadge(
      //     label: val == 'P' ? 'Paid' : 'Not Paid',
      //     colorLabel: (val == 'P' ? colorStyle.black : colorStyle.white),
      //     colorBox: (val == 'P' ? colorStyle.green : colorStyle.red),
      //   );
      // } else if (id == 'otdtlStatus') {
      //   String? voidStatus = entity.toJson()['orderStatus'].toString();
      //   if (voidStatus.isNotEmpty && voidStatus == 'V') {
      //     return CustomBadge(
      //       label: 'Void',
      //       colorLabel: colorStyle.white,
      //       colorBox: colorStyle.grey,
      //     );
      //   } else {
      //     return CustomBadge(
      //       label: val == 'Y' ? 'Aktif' : 'Not Aktif',
      //       colorLabel: (val == 'Y' ? colorStyle.black : colorStyle.white),
      //       colorBox: (val == 'Y' ? colorStyle.green : colorStyle.red),
      //     );
      //   }
      // } else if (id == 'statusCetak') {
      //   return CustomBadge(
      //     label: val == 'Y' ? 'Cetak' : 'Belum Cetak',
      //     colorLabel: (val == 'Y' ? colorStyle.black : colorStyle.white),
      //     colorBox: (val == 'Y' ? colorStyle.green : colorStyle.grey),
      //     // label: val == 'C' ? 'Cetak' : 'Belum Cetak',
      //     // colorLabel: (val == 'C' ? colorStyle.black : colorStyle.white),
      //     // colorBox: (val == 'C' ? colorStyle.green : colorStyle.grey),
      //   );
      // } else {
      //   return Text(element.defaultValue ?? val);
      // }
      return Text(element.defaultValue ?? val);
    }

    Widget _dataTableCustom(Member e) {
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
                    child: _dataValueCustom(
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

    Widget _tableCustom() {
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
                                  (e) => _dataTableCustom(e),
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

    Widget _contentTableSection() {
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
                  child: _tableCustom(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GetBuilder(
      init: controller,
      tag: 'InqMemberPage',
      initState: (state) {
        controller;
      },
      builder: (controller) {
        return Container(
          padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
          child: Column(
            children: [
              _headerSection(),
              SizedBox(height: layoutStyle.defaultMargin),
              _contentTableSection(),
            ],
          ),
        );
      },
    );
  }
}
