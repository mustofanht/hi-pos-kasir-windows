import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/data/models/proofofpayment/proof_of_payment_model.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/proofofpayment/bukti_pembayaran_page_controller.dart';

class BuktiPembayaranPage extends GetView<BuktiPembayaranPageController> {
  const BuktiPembayaranPage({super.key});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    Widget rightSection(ProofOfPaymentModel model) {
      return Expanded(
        child: Container(
          width: layoutStyle.screenWidth,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: colorStyle.grey,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 2,
                  horizontal: layoutStyle.defaultMargin,
                ),
                decoration: BoxDecoration(
                  color: colorStyle.lightGrey,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '#${model.transactionId}',
                          style: TextStyle(
                            fontWeight: fontWeight.bold,
                            fontSize: fontSize.subtitle,
                          ),
                        ),
                        SizedBox(
                          width: layoutStyle.defaultMargin,
                        ),
                        Icon(Icons.copy),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                colorStyle.primary),
                            foregroundColor: MaterialStateProperty.all<Color>(
                                colorStyle.white),
                            overlayColor: MaterialStateProperty.all<Color>(
                                colorStyle.white.withOpacity(0.1)),
                            elevation: MaterialStateProperty.all<double>(0),
                          ),
                          label: Row(
                            children: [
                              Icon(Icons.print),
                              SizedBox(
                                width: layoutStyle.defaultMargin / 5,
                              ),
                              Text('Cetak'),
                            ],
                          ),
                          width: layoutStyle.blockHorizontal * 8,
                          height: layoutStyle.blockVertical * 5,
                        ),
                        SizedBox(
                          width: layoutStyle.defaultMargin,
                        ),
                        CustomButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                colorStyle.primary),
                            foregroundColor: MaterialStateProperty.all<Color>(
                                colorStyle.white),
                            overlayColor: MaterialStateProperty.all<Color>(
                                colorStyle.white.withOpacity(0.1)),
                            elevation: MaterialStateProperty.all<double>(0),
                          ),
                          label: Row(
                            children: [
                              Icon(Icons.send),
                              SizedBox(
                                width: layoutStyle.defaultMargin / 5,
                              ),
                              Text('Kirim Bukti Pembayaran'),
                            ],
                          ),
                          width: layoutStyle.blockHorizontal * 18,
                          height: layoutStyle.blockVertical * 5,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: layoutStyle.screenWidth / 4,
                            child: Padding(
                              padding:
                                  EdgeInsets.all(layoutStyle.defaultMargin),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DI TERBITKAN OLEH',
                                    style: TextStyle(
                                      fontSize: fontSize.header,
                                      fontWeight: fontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Petugas:',
                                    style: TextStyle(
                                      fontSize: fontSize.subtitle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  EdgeInsets.all(layoutStyle.defaultMargin),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Invoice #62374',
                                    style: TextStyle(
                                      fontSize: fontSize.subtitle,
                                    ),
                                  ),
                                  Text(
                                    'Created: 2024-05-12 | 12:01:00',
                                    style: TextStyle(
                                      fontSize: fontSize.subtitle,
                                    ),
                                  ),
                                  SizedBox(
                                    height: layoutStyle.defaultMargin,
                                  ),
                                  Text(
                                    'CUSTOMER',
                                    style: TextStyle(
                                      fontSize: fontSize.header,
                                      fontWeight: fontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: layoutStyle.defaultMargin / 5,
                                  ),
                                  Text(
                                    'Nama: Cholil Cilok',
                                    style: TextStyle(
                                      fontSize: fontSize.subtitle,
                                    ),
                                  ),
                                  Text(
                                    'Tanggal Pembayaran: 2024-05-12 | 12:05:00',
                                    style: TextStyle(
                                      fontSize: fontSize.subtitle,
                                    ),
                                  ),
                                  Text(
                                    'Metode Pembayaran: EDC',
                                    style: TextStyle(
                                      fontSize: fontSize.subtitle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: layoutStyle.defaultMargin / 2,
                          horizontal: layoutStyle.defaultMargin,
                        ),
                        decoration: BoxDecoration(
                          color: colorStyle.lightGrey,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'INFO TIKET',
                              style: TextStyle(
                                fontWeight: fontWeight.bold,
                                fontSize: fontSize.subtitle,
                              ),
                            ),
                            Text(
                              'JUMLAH HARGA SATUAN',
                              style: TextStyle(
                                fontWeight: fontWeight.bold,
                                fontSize: fontSize.subtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: layoutStyle.screenWidth,
                        padding: EdgeInsets.all(layoutStyle.defaultMargin),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: layoutStyle.defaultMargin / 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Long Journey Khusu Member',
                                        style: TextStyle(
                                          fontSize: fontSize.subtitle,
                                          fontWeight: fontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Add-Ons;',
                                        style: TextStyle(
                                          fontSize: fontSize.body,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Rp.100.000',
                                    style: TextStyle(
                                      fontSize: fontSize.body,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: layoutStyle.defaultMargin / 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Long Journey Khusu Member',
                                        style: TextStyle(
                                          fontSize: fontSize.subtitle,
                                          fontWeight: fontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Add-Ons;',
                                        style: TextStyle(
                                          fontSize: fontSize.body,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Rp.100.000',
                                    style: TextStyle(
                                      fontSize: fontSize.body,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: layoutStyle.defaultMargin / 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Long Journey Khusu Member',
                                        style: TextStyle(
                                          fontSize: fontSize.subtitle,
                                          fontWeight: fontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Add-Ons;',
                                        style: TextStyle(
                                          fontSize: fontSize.body,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Rp.100.000',
                                    style: TextStyle(
                                      fontSize: fontSize.body,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: layoutStyle.defaultMargin / 2,
                          horizontal: layoutStyle.defaultMargin,
                        ),
                        decoration: BoxDecoration(
                          color: colorStyle.lightGrey,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Harga Total: Rp 10.000.000',
                              style: TextStyle(
                                fontWeight: fontWeight.bold,
                                fontSize: fontSize.subtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: layoutStyle.screenWidth,
                        padding: EdgeInsets.all(layoutStyle.defaultMargin),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.all(layoutStyle.defaultMargin / 2),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        'Discount:',
                                        style: TextStyle(
                                          fontSize: fontSize.body,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: layoutStyle.defaultMargin / 2,
                                    ),
                                    child: Text(
                                      'Rp. 100.000',
                                      style: TextStyle(
                                        fontSize: fontSize.body,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.all(layoutStyle.defaultMargin / 2),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        'Voucher:',
                                        style: TextStyle(
                                          fontSize: fontSize.body,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: layoutStyle.defaultMargin / 2,
                                    ),
                                    child: Text(
                                      'Rp. 100.000',
                                      style: TextStyle(
                                        fontSize: fontSize.body,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.all(layoutStyle.defaultMargin / 2),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        'Total Tagihan:',
                                        style: TextStyle(
                                          fontSize: fontSize.body,
                                          fontWeight: fontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: layoutStyle.defaultMargin / 2,
                                    ),
                                    child: Text(
                                      'Rp. 200.000',
                                      style: TextStyle(
                                        fontSize: fontSize.body,
                                        fontWeight: fontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget cardSection({
      required ProofOfPaymentModel model,
      required bool selectedCard,
    }) {
      return GestureDetector(
        onTap: () {
          controller.selectedProofOfPayment.value = model;
          controller.update();
        },
        child: Container(
          padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
          color: selectedCard ? colorStyle.lightGrey : colorStyle.white,
          width: layoutStyle.screenWidth,
          height: layoutStyle.blockVertical * 20,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 10,
                ),
                margin: EdgeInsets.only(bottom: layoutStyle.defaultMargin / 2),
                child: Container(
                  padding: EdgeInsets.all(layoutStyle.defaultMargin / 3),
                  decoration: BoxDecoration(
                    color: colorStyle.lime,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Sukses',
                    style: TextStyle(
                      color: colorStyle.black,
                      fontSize: fontSize.small,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.topCenter,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding:
                              EdgeInsets.all(layoutStyle.defaultMargin / 5),
                          decoration: BoxDecoration(
                            color: colorStyle.white,
                            border: Border.all(
                              color: colorStyle.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                7,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                assetsConstant.imgEdc,
                                fit: BoxFit.fill,
                              ),
                              Text('EDC')
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('#21348923'),
                            SizedBox(
                              height: layoutStyle.defaultMargin,
                            ),
                            Text('Name'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('14:67'),
                            SizedBox(
                              height: layoutStyle.defaultMargin,
                            ),
                            Text('Rp.250,000'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget leftSection() {
      return Container(
        width: layoutStyle.safeBlockHorizontal * 30,
        height: layoutStyle.screenHeight,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: colorStyle.grey,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: controller.dummyData
                .map((e) => cardSection(
                    model: e,
                    selectedCard:
                        e.id == controller.selectedProofOfPayment.value.id))
                .toList(),
          ),
        ),
      );
    }

    Widget contentSection(BuktiPembayaranPageController controller) {
      return Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: layoutStyle.defaultMargin),
          child: Row(
            children: [
              leftSection(),
              SizedBox(
                width: layoutStyle.defaultMargin,
              ),
              rightSection(controller.selectedProofOfPayment.value),
            ],
          ),
        ),
      );
    }

    return GetBuilder(
      init: controller,
      tag: 'BuktiPembayaranPage',
      initState: (state) {
        controller;
      },
      builder: (controller) {
        return Container(
          padding: EdgeInsets.all(layoutStyle.defaultMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Bukti Pembayaran',
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
              contentSection(controller),
            ],
          ),
        );
      },
    );
  }
}
