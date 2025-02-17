import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_voucher_page_controller.dart';

class SaleVoucherPage extends GetView<SaleVoucherPageController> {
  const SaleVoucherPage({super.key});

  @override
  Widget build(BuildContext context) {
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

    // return GetBuilder(
    //   init: controller,
    //   tag: 'SaleVoucherPage',
    //   initState: (state) {
    //     controller.scrollController.addListener(controller.scrollHandler);
    //     controller.doPrepareList(page: 0);
    //   },
    //   builder: (controller) {
    //     return SizedBox(
    //       width: layoutStyle.screenWidth,
    //       height: layoutStyle.screenHeight,
    //       child: RefreshIndicator(
    //         onRefresh: () async {
    //           await controller.doPrepareList(page: 0);
    //         },
    //         child: controller.isLoading.value
    //             ? loading.simpleLoading()
    //             : controller.voucherList.isEmpty
    //                 ? SingleChildScrollView(
    //                     physics: const AlwaysScrollableScrollPhysics(),
    //                     child: Padding(
    //                       padding: EdgeInsets.only(
    //                         top: layoutStyle.defaultMargin * 4,
    //                       ),
    //                       child: emptyData(),
    //                     ),
    //                   )
    //                 : GridView.count(
    //                     controller: controller.scrollController,
    //                     primary: false,
    //                     physics: const AlwaysScrollableScrollPhysics(),
    //                     padding: EdgeInsets.all(layoutStyle.defaultMargin),
    //                     crossAxisSpacing: 10,
    //                     mainAxisSpacing: 10,
    //                     // crossAxisCount: 4,
    //                     // childAspectRatio: (150 / 230),
    //                     childAspectRatio: layoutStyle.screenWidth > 800
    //                         ? (150 / 230)
    //                         : (layoutStyle.blockHorizontal * 10) /
    //                             (layoutStyle.blockVertical * 15),
    //                     crossAxisCount: layoutStyle.screenWidth > 1200
    //                         ? 4
    //                         : layoutStyle.screenWidth > 800
    //                             ? 3
    //                             : 2,
    //                     children: controller.voucherList
    //                         .map(
    //                           (e) => InkWell(
    //                             onTap: () {
    //                               controller.addVoucherToCart(voucher: e);
    //                             },
    //                             child: Container(
    //                               height: 250,
    //                               decoration: BoxDecoration(
    //                                 border: Border.all(
    //                                   color: colorStyle.primary,
    //                                 ),
    //                                 borderRadius: const BorderRadius.all(
    //                                     Radius.circular(10)),
    //                                 color:
    //                                     colorStyle.white, // Move the color here
    //                               ),
    //                               padding:
    //                                   EdgeInsets.all(layoutStyle.defaultMargin),
    //                               child: Column(
    //                                 mainAxisSize: MainAxisSize.min,
    //                                 children: [
    //                                   Image.asset(
    //                                     'assets/images/coupon.png',
    //                                     fit: BoxFit.fill,
    //                                     errorBuilder: (BuildContext context,
    //                                         Object exception,
    //                                         StackTrace? stackTrace) {
    //                                       return const Text('Img Not Found');
    //                                     },
    //                                   ),
    //                                   SizedBox(
    //                                     height: layoutStyle.defaultMargin,
    //                                   ),
    //                                   Text(
    //                                     e.voucherName!,
    //                                     style: TextStyle(
    //                                       fontSize: fontSize.body,
    //                                       fontWeight: FontWeight.bold,
    //                                     ),
    //                                     overflow: TextOverflow.ellipsis,
    //                                   ),
    //                                   SizedBox(
    //                                     height: layoutStyle.defaultMargin,
    //                                   ),
    //                                   Text(
    //                                     'Kode: ${e.voucherCode}',
    //                                     style: TextStyle(
    //                                       fontSize: fontSize.body,
    //                                       // fontWeight: FontWeight.bold,
    //                                     ),
    //                                     overflow: TextOverflow.ellipsis,
    //                                   ),
    //                                   SizedBox(
    //                                     height: layoutStyle.defaultMargin,
    //                                   ),
    //                                   Text(
    //                                     'Disc: ${e.voucherUnitType == UnitType.PERCENT ? ('${e.voucherUnitValue} %') : ('Rp.${common.currencyFormat(e.voucherUnitValue ?? 0)}')}',
    //                                     style: TextStyle(
    //                                       fontSize: fontSize.body,
    //                                       // fontWeight: FontWeight.bold,
    //                                     ),
    //                                     overflow: TextOverflow.ellipsis,
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                           ),
    //                         )
    //                         .toList(),
    //                   ),
    //       ),
    //     );
    //   },
    // );

    return GetBuilder(
      init: controller,
      tag: 'SaleVoucherPage',
      initState: (state) {
        controller.scrollController.addListener(controller.scrollHandler);
        controller.doPrepareList(page: 0);
      },
      builder: (controller) {
        return SizedBox(
          width: layoutStyle.screenWidth,
          height: layoutStyle.screenHeight,
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.doPrepareList(page: 0);
            },
            child: controller.isLoading.value
                ? loading.simpleLoading()
                : controller.voucherList.isEmpty
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
                        primary: false,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(layoutStyle.defaultMargin),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: layoutStyle.screenWidth > 800
                            ? (150 / 230)
                            : (layoutStyle.blockHorizontal * 10) /
                                (layoutStyle.blockVertical * 15),
                        crossAxisCount: layoutStyle.screenWidth > 1200
                            ? 4
                            : layoutStyle.screenWidth > 800
                                ? 3
                                : 2,
                        children: controller.voucherList
                            .map(
                              (e) => InkWell(
                                onTap: () {
                                  controller.addVoucherToCart(voucher: e);
                                },
                                child: Container(
                                  height: 250,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: colorStyle.primary,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    color: colorStyle.white,
                                  ),
                                  padding:
                                      EdgeInsets.all(layoutStyle.defaultMargin),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Image.asset(
                                          'assets/images/coupon.png',
                                          fit: BoxFit.fill,
                                          errorBuilder: (BuildContext context,
                                              Object exception,
                                              StackTrace? stackTrace) {
                                            return const Text('Img Not Found');
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: layoutStyle.defaultMargin,
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Flexible(
                                                  child: Container(
                                                    width: constraints.maxWidth,
                                                    child: AutoSizeText(
                                                      e.voucherName!,
                                                      style: TextStyle(
                                                        fontSize: fontSize.body,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 3,
                                                      minFontSize: 8,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Container(
                                                    width: constraints.maxWidth,
                                                    child: AutoSizeText(
                                                      'Kode:\n${e.voucherCode}',
                                                      style: TextStyle(
                                                        fontSize: fontSize.body,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 2,
                                                      minFontSize: 8,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Container(
                                                    width: constraints.maxWidth,
                                                    child: AutoSizeText(
                                                      'Disc:\n${e.voucherUnitType == UnitType.PERCENT ? ('${e.voucherUnitValue} %') : ('Rp.${common.currencyFormat(e.voucherUnitValue ?? 0)}')}',
                                                      style: TextStyle(
                                                        fontSize: fontSize.body,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 2,
                                                      minFontSize: 8,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
          ),
        );
      },
    );
  }
}
