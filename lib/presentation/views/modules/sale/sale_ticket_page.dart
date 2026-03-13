import 'package:auto_size_text/auto_size_text.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_ticket_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SaleTicketPage extends GetView<SaleTicketPageController> {
  const SaleTicketPage({super.key});

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
                : controller.ticketList.isEmpty
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
                        // crossAxisCount: 4,
                        crossAxisCount: layoutStyle.screenWidth > 1200
                            ? 4
                            : layoutStyle.screenWidth > 800
                                ? 3
                                : 2,
                        children: controller.ticketList
                            .map(
                              (e) => InkWell(
                                onTap: () {
                                  controller.addTicketToCart(ticket: e);
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
                                        Expanded(
                                          child: e.pathImg != null
                                              ? Image.network(
                                                  e.pathImg!,
                                                  fit: BoxFit.fill,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Image.asset(
                                                    'assets/images/ticket.png',
                                                    fit: BoxFit.fill,
                                                    errorBuilder:
                                                        (BuildContext context,
                                                            Object exception,
                                                            StackTrace?
                                                                stackTrace) {
                                                      return const Text(
                                                          'Img Not Found');
                                                    },
                                                  ),
                                                )
                                              : Image.asset(
                                                  'assets/images/ticket.png',
                                                  fit: BoxFit.fill,
                                                  errorBuilder: (BuildContext
                                                          context,
                                                      Object exception,
                                                      StackTrace? stackTrace) {
                                                    return const Text(
                                                        'Img Not Found');
                                                  },
                                                ),
                                        ),
                                        SizedBox(
                                          height: layoutStyle.defaultMargin,
                                        ),
                                        // Text(
                                        //   e.ticketName!,
                                        //   style: TextStyle(
                                        //     fontSize: fontSize.subtitle,
                                        //     // fontWeight: FontWeight.bold,
                                        //   ),
                                        //   softWrap: true,
                                        //   // overflow: TextOverflow.ellipsis,
                                        // ),
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            return Container(
                                              width: constraints.maxWidth,
                                              child: AutoSizeText(
                                                e.ticketName!,
                                                style: TextStyle(
                                                  fontSize: fontSize.body,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 3,
                                                minFontSize: 8,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          },
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
