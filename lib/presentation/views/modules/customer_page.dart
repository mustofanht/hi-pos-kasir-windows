import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/customer/customer_sale_cart_page_controller.dart';
import 'package:jaya_propertiy/presentation/views/modules/customer/customer_sale_cart_page.dart';
import 'package:presentation_displays/secondary_display.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  @override
  void initState() {
    super.initState();
    Get.put(CustomerSaleCartPageController());
  }

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);
    CustomerSaleCartPageController customerSaleCartPageController =
        Get.put(CustomerSaleCartPageController());

    Widget addsSection() {
      return Expanded(
        child: Container(
          height: layoutStyle.screenHeight,
          padding: EdgeInsets.all(layoutStyle.defaultMargin),
          // child: Image.network('https://picsum.photos/1000/1000'),
          child: FlutterCarousel(
            options: CarouselOptions(
              height: layoutStyle.screenHeight,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              autoPlay: true,
              enableInfiniteScroll: true,
              autoPlayInterval: const Duration(seconds: 5),
              slideIndicator: CircularWaveSlideIndicator(),
            ),
            items: customerSaleCartPageController.sliders,
          ),
        ),
      );
    }

    Widget barcodeSection() {
      return Expanded(
        child: Container(
          height: layoutStyle.screenHeight,
          margin: EdgeInsets.all(layoutStyle.defaultMargin),
          padding: EdgeInsets.all(layoutStyle.defaultMargin),
          decoration: BoxDecoration(
            color: colorStyle.white,
          ),
          child: Column(
            children: [
              Container(
                height: layoutStyle.safeAreaVertical * 3,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1.0,
                      color: colorStyle.grey,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      assetsConstant.icQris,
                      width: layoutStyle.blockHorizontal * 5,
                      height: layoutStyle.blockVertical * 5,
                    ),
                    Text(
                      'QRIS',
                      style: TextStyle(
                        fontSize: fontSize.title,
                        fontWeight: fontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Image.asset(
                    assetsConstant.imgExampleBarcode,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SecondaryDisplay(
        callback: (dynamic argument) {
          logger.safeLog('Data From main display : ${argument}');
          customerSaleCartPageController.updateDataCustomer(argument);
        },
        child: Container(
          width: layoutStyle.screenWidth,
          height: layoutStyle.screenHeight,
          color: colorStyle.lightGrey.withOpacity(0.70),
          child: Row(
            children: [
              const CustomerSaleCartPage(),
              if (customerSaleCartPageController.showBarcode.value) ...[
                barcodeSection(),
              ] else ...[
                addsSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
