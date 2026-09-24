import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/layar_pelanggan_tampilan.dart';
import 'package:jaya_propertiy/app/utils/common/layar_pelanggan_windows.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/customer/customer_sale_cart_page_controller.dart';
import 'package:jaya_propertiy/presentation/views/modules/customer/customer_sale_cart_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/customer/customer_survey_panel.dart';
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
    CustomerSaleCartPageController.instance;
    // Di Android data datang lewat Presentation API (widget SecondaryDisplay di
    // bawah). Di Windows halaman ini adalah jendela kedua aplikasi, jadi
    // datanya datang lewat saluran antar-jendela.
    if (Platform.isWindows) {
      LayarPelangganWindows.pasangPenerima(_terima);
    }
  }

  /// Satu pembaruan dari layar kasir.
  ///
  /// Bentuk muatannya sama di Android maupun Windows, jadi penanganannya satu.
  Future<void> _terima(dynamic argument) async {
    final controller = CustomerSaleCartPageController.instance;
    logger.safeLog('Data From main display : $argument');
    if (argument != null && argument.toString() == constant.refreshAds) {
      await controller.loadImages();
    }
    if (argument != null) {
      controller.updateDataCustomer(argument);
    }
  }

  /// Logo outlet di bilah atas; jatuh ke logo bawaan bila belum disetel.
  ///
  /// Gambarnya diambil dari jaringan, dan layar pelanggan harus tetap wajar
  /// saat jaringan sedang mati — karena itu ada logo bawaan sebagai cadangan,
  /// bukan kotak kosong atau ikon rusak.
  Widget _logoOutlet() {
    final bawaan = Image.asset(
      assetsConstant.imgLogo,
      width: layoutStyle.blockHorizontal * 10,
      height: layoutStyle.blockVertical * 10,
    );

    final alamat = layarPelangganTampilan.logo;
    if (alamat == null) return bawaan;

    return Image.network(
      alamat,
      width: layoutStyle.blockHorizontal * 10,
      height: layoutStyle.blockVertical * 10,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => bawaan,
    );
  }

  /// Teks sambutan outlet; kosong berarti bilah atas tanpa tulisan.
  Widget _sambutan() {
    final teks = layarPelangganTampilan.teks;
    if (teks == null) return const SizedBox.shrink();
    return Text(
      teks,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: colorStyle.white,
        fontSize: fontSize.header,
        fontWeight: fontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);
    CustomerSaleCartPageController customerSaleCartPageController =
        CustomerSaleCartPageController.instance;

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
        leadingWidth: layoutStyle.blockHorizontal * 14,
        leading: Padding(
          padding: EdgeInsets.all(layoutStyle.defaultMargin / 4),
          child: _logoOutlet(),
        ),
        centerTitle: true,
        title: _sambutan(),
      ),
      body: Obx(() {
        final isi = Container(
            width: layoutStyle.screenWidth,
            height: layoutStyle.screenHeight,
            color: colorStyle.lightGrey.withOpacity(0.70),
            // Survei diletakkan sebagai lapisan di atas, bukan menggantikan isi
            // layar. Pelanggan tetap bisa melihat bukti transaksinya sementara
            // menilai, dan menutup survei tidak meninggalkan layar kosong.
            child: Stack(
              children: [
                Positioned.fill(
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
                const Positioned.fill(child: CustomerSurveyPanel()),
              ],
            ),
        );
        // Jendela kedua di Windows tidak lewat Presentation API, jadi tidak
        // dibungkus SecondaryDisplay — pembungkus itu memasang saluran khusus
        // Android yang di Windows tidak akan pernah dijawab.
        return Platform.isWindows
            ? isi
            : SecondaryDisplay(callback: _terima, child: isi);
      }),
    );
  }
}
