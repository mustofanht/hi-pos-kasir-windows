import 'package:flutter/material.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_addon_page_controller.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SaleAddonPage extends GetView<SaleAddonPageController> {
  const SaleAddonPage({super.key});

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

    return GetBuilder(
      init: controller,
      tag: 'SaleTicketPage',
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
                        padding: EdgeInsets.all(layoutStyle.defaultMargin),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: 4,
                        children: controller.addonList
                            .map(
                              (e) => InkWell(
                                onTap: () {
                                  controller.addAddonToCart(val: e);
                                },
                                child: Container(
                                  height: 20,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: colorStyle.primary,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    color: colorStyle.white,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: Container(
                                    padding: EdgeInsets.all(
                                        layoutStyle.defaultMargin),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/images/ticket.png',
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
                                          e.productName!,
                                          style: TextStyle(
                                            fontSize: fontSize.title,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
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
