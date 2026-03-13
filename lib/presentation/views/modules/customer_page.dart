import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
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
    logger.safeLog('CUSTOMER PAGE');
    super.initState();
    Get.put(CustomerSaleCartPageController());
  }

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);
    CustomerSaleCartPageController customerSaleCartPageController =
        Get.put(CustomerSaleCartPageController());

    Widget addsSection() {
      return Obx(
        () => Expanded(
          child: Container(
            height: layoutStyle.screenHeight,
            padding: EdgeInsets.all(layoutStyle.defaultMargin),
            // child: Image.network('https://picsum.photos/1000/1000'),
            child: FlutterCarousel(
              options: FlutterCarouselOptions(
                height: layoutStyle.screenHeight,
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                autoPlay: true,
                enableInfiniteScroll: true,
                autoPlayInterval: const Duration(seconds: 5),
                slideIndicator: CircularWaveSlideIndicator(),
              ),
              items: customerSaleCartPageController.images.map((e) {
                logger.safeLog('PATH : ${e.path}');
                return Padding(
                  // padding: EdgeInsets.symmetric(
                  //   horizontal: layoutStyle.defaultMargin / 5,
                  // ),
                  padding: EdgeInsets.all(
                    layoutStyle.defaultMargin / 20,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    child: Container(
                      width: double.infinity,
                      child: Image.file(
                        e,
                        fit: BoxFit.fill,
                        // width: layoutStyle.screenWidth,
                        // height: layoutStyle.screenHeight,
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return const Text('Img Not Found');
                        },
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
    }

    Widget qrisSection() {
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
                height: layoutStyle.blockVertical * 6,
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
                        color: colorStyle.black,
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: customerSaleCartPageController.getQrImg(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget paymentQrisSuccess() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            assetsConstant.icPaymentSuccess,
            width: layoutStyle.blockHorizontal * 20,
            height: layoutStyle.blockVertical * 20,
          ),
          Text(
            'Thank You',
            style: TextStyle(
              fontWeight: fontWeight.bold,
              fontSize: fontSize.header,
            ),
          ),
          Text(
            'Pembayaran QRIS Sukses',
            style: TextStyle(
              fontSize: fontSize.subtitle,
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: layoutStyle.blockVertical * 10,
        backgroundColor: colorStyle.primary,
        foregroundColor: colorStyle.white,
        shadowColor: colorStyle.transparent,
        elevation: layoutStyle.defaultMargin,
        leadingWidth: 100,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              assetsConstant.imgLogo,
              width: layoutStyle.blockHorizontal * 10,
              height: layoutStyle.blockVertical * 10,
            ),
          ],
        ),
      ),
      body: Obx(
        () => SecondaryDisplay(
          callback: (dynamic argument) async {
            logger.safeLog('Data From main display : ${argument}');
            if (argument != null &&
                argument.toString() == constant.refreshAds) {
              await customerSaleCartPageController.loadImages();
            }
            if (argument != null) {
              customerSaleCartPageController.updateDataCustomer(argument);
            }
          },
          child: Container(
            width: layoutStyle.screenWidth,
            height: layoutStyle.screenHeight,
            color: colorStyle.lightGrey.withOpacity(0.70),
            child: customerSaleCartPageController.showPaymentSuccess.value
                ? paymentQrisSuccess()
                : Row(
                    children: [
                      const CustomerSaleCartPage(),
                      if (customerSaleCartPageController.qrCode.value !=
                          null) ...[
                        qrisSection(),
                      ] else ...[
                        addsSection(),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
