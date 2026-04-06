import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_addon_page_controller.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SaleAddonPage extends GetView<SaleAddonPageController> {
  const SaleAddonPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget cardItem(AddonEntity e) {
      return InkWell(
        onTap: () {
          controller.addAddonToCart(val: e);
        },
        child: Container(
          height: 20,
          decoration: BoxDecoration(
            border: e.isBooked == null
                ? Border.all(
                    color: colorStyle.primary,
                  )
                : e.isBooked == 'Y'
                    ? Border.all(
                        color: colorStyle.red,
                      )
                    : Border.all(
                        color: colorStyle.green,
                      ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: e.isBooked == null
                ? colorStyle.white
                : e.isBooked == 'Y'
                    ? colorStyle.red.withOpacity(0.20)
                    : colorStyle.green.withOpacity(0.20),
          ),
          // padding: const EdgeInsets.all(2),
          child: Container(
            padding: EdgeInsets.all(layoutStyle.defaultMargin),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: e.pathImg != null
                      ? Image.network(
                          e.pathImg!,
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            'assets/images/ticket.png',
                            fit: BoxFit.fill,
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return const Text('Img Not Found');
                            },
                          ),
                        )
                      : Image.asset(
                          'assets/images/ticket.png',
                          fit: BoxFit.fill,
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return const Text('Img Not Found');
                          },
                        ),
                ),
                SizedBox(
                  height: layoutStyle.defaultMargin,
                ),
                // Text(
                //   e.productName!,
                //   style: TextStyle(
                //     fontSize: fontSize.title,
                //     // fontWeight: FontWeight.bold,
                //   ),
                //   overflow: TextOverflow.ellipsis,
                //   maxLines: 1,
                // ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        Container(
                          width: constraints.maxWidth,
                          child: AutoSizeText(
                            e.productName!,
                            style: TextStyle(
                              fontSize: fontSize.body,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            minFontSize: 8,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          height: layoutStyle.defaultMargin / 2,
                        ),
                        e.isBooked == 'Y'
                            ? Column(
                                children: [
                                  // Row(
                                  //   children: [
                                  //     AutoSizeText(
                                  //       'Durasi: ',
                                  //       style: textStyle.blackText
                                  //           .copyWith(fontSize: fontSize.small),
                                  //     ),
                                  //     AutoSizeText(
                                  //       '${e.endDate!.difference(e.startDate!).inHours} (Jam)',
                                  //       style: textStyle.blackText
                                  //           .copyWith(fontSize: fontSize.small),
                                  //     ),
                                  //   ],
                                  // ),
                                  Row(
                                    children: [
                                      AutoSizeText(
                                        'Check In: ',
                                        style: textStyle.blackText
                                            .copyWith(fontSize: fontSize.small),
                                      ),
                                      AutoSizeText(
                                        dateTimeUtil.dateFormat(
                                            e.startDate!, 'HH:mm'),
                                        style: textStyle.blackText
                                            .copyWith(fontSize: fontSize.small),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      AutoSizeText(
                                        'Check Out: ',
                                        style: textStyle.blackText
                                            .copyWith(fontSize: fontSize.small),
                                      ),
                                      AutoSizeText(
                                        dateTimeUtil.dateFormat(
                                            e.endDate!, 'HH:mm'),
                                        style: textStyle.blackText
                                            .copyWith(fontSize: fontSize.small),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Container()
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget emptyData() {
      return Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                assetsConstant.imgEmptyBox,
                fit: BoxFit.fill,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return const Text('Img Not Found');
                },
              ),
              SizedBox(
                height: layoutStyle.defaultMargin,
              ),
              Text(
                'Data Empty',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize.title,
                  fontWeight: fontWeight.bold,
                ),
              ),
              SizedBox(
                height: layoutStyle.defaultMargin,
              ),
            ],
          ),
        ),
      );
    }

    return GetBuilder(
      init: controller,
      tag: 'SaleTicketPage',
      initState: (state) {
        controller.scrollController.addListener(controller.scrollHandler);
        controller.doPrepareList(page: 0, typeProduct: 'H');
        controller.doInitializeItemTypeList();
        controller.selectedTypeItemList.value.id = 'H';
      },
      builder: (controller) {
        return Container(
          width: layoutStyle.screenWidth,
          height: layoutStyle.screenHeight,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Container(
                  padding: EdgeInsets.all(
                    layoutStyle.defaultMargin,
                  ),
                  child: Row(
                    children: controller.typeItemList
                        .map(
                          (element) => GestureDetector(
                            onTap: () {
                              controller.selectedTypeItemList.value = element;
                              controller.doPrepareList(
                                  page: 0, typeProduct: element.id!);
                              controller.update();
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: layoutStyle.defaultMargin / 5,
                              ),
                              padding:
                                  EdgeInsets.all(layoutStyle.defaultMargin),
                              decoration: BoxDecoration(
                                color:
                                    controller.selectedTypeItemList.value.id ==
                                            element.id
                                        ? colorStyle.primary
                                        : colorStyle.lightGrey,
                                borderRadius: BorderRadius.circular(
                                  layoutStyle.defaultMargin,
                                ),
                                border: Border.all(
                                  color: colorStyle.grey,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  element.name ?? '',
                                  style: controller
                                              .selectedTypeItemList.value.id ==
                                          element.id
                                      ? textStyle.whiteText
                                      : textStyle.greyText,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              Expanded(
                // width: layoutStyle.screenWidth,
                // height: layoutStyle.screenHeight,
                child: RefreshIndicator(
                  onRefresh: () async {
                    await controller.doPrepareList(
                        page: 0,
                        typeProduct: controller.selectedTypeItemList.value.id!);
                  },
                  child: controller.isLoading.value
                      ? loading.simpleLoading()
                      : controller.addonList.isEmpty
                          ? SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: layoutStyle.defaultMargin * 4,
                                ),
                                child: emptyData(),
                              ),
                            )
                          : GridView.count(
                              controller: controller.scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              primary: false,
                              padding:
                                  EdgeInsets.all(layoutStyle.defaultMargin),
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              // crossAxisCount: 4,
                              crossAxisCount: layoutStyle.screenWidth > 1200
                                  ? 4
                                  : layoutStyle.screenWidth > 800
                                      ? 3
                                      : 2,
                              children: controller.addonList
                                  .map(
                                    (e) => cardItem(e),
                                  )
                                  .toList(),
                            ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
