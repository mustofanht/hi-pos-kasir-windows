import 'package:flutter/material.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_voucher_page_controller.dart';

class SaleVoucherPage extends GetView<SaleVoucherPageController> {
  const SaleVoucherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'SaleVoucherPage',
      initState: (state) {
        controller.scrollController.addListener(controller.scrollHandler);
        controller.doPrepareList(page: 1);
      },
      builder: (controller) {
        return SizedBox(
          width: layoutStyle.screenWidth,
          height: layoutStyle.screenHeight,
          child: controller.isLoading.value
              ? loading.simpleLoading()
              : GridView.count(
                  controller: controller.scrollController,
                  primary: false,
                  padding: EdgeInsets.all(layoutStyle.defaultMargin),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 4,
                  childAspectRatio: (150 / 230),
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
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              color: colorStyle.white, // Move the color here
                            ),
                            padding: EdgeInsets.all(layoutStyle.defaultMargin),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/coupon.png',
                                  // width: 150,
                                  // height: 150,
                                  fit: BoxFit.fill,
                                  errorBuilder: (BuildContext context,
                                      Object exception,
                                      StackTrace? stackTrace) {
                                    return const Text('Img Not Found');
                                  },
                                ),
                                SizedBox(
                                  height: layoutStyle.defaultMargin,
                                ),
                                Text(
                                  e.voucherName!,
                                  style: TextStyle(
                                    fontSize: fontSize.body,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: layoutStyle.defaultMargin,
                                ),
                                Text(
                                  'Kode: ${e.voucherCode}',
                                  style: TextStyle(
                                    fontSize: fontSize.body,
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: layoutStyle.defaultMargin,
                                ),
                                Text(
                                  'Disc: ${e.voucherUnitType == 'PERCENT' ? ('${e.voucherUnitValue} %') : ('Rp${e.voucherUnitValue}')}',
                                  style: TextStyle(
                                    fontSize: fontSize.body,
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        );
      },
    );
  }
}
