// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
import 'package:jaya_propertiy/domain/entities/masterdata/mst_payment.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale_page_controller.dart';

class SalePaymentPage extends StatefulWidget {
  const SalePaymentPage({
    super.key,
    required this.controller,
  });
  final SalePageController controller;

  @override
  State<SalePaymentPage> createState() => _SalePaymentPageState();
}

class _SalePaymentPageState extends State<SalePaymentPage> {
  late final SalePageController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    Widget cardPayment(CustomIdNameEntity element) {
      if (element.id == null) {
        return Container();
      }
      MstPayment mstPayment = controller.mstPayments.firstWhere(
        (e) => e.pymntCode == element.id,
      );
      String img = mstPayment.pymntImgPath ?? '';
      String label = mstPayment.pymntName ?? '-';
      // logger.safeLog('IMG : $img');
      return GestureDetector(
        onTap: () {
          controller.doSelectPaymentType(element);
        },
        child: Container(
          height: layoutStyle.blockVertical * 8,
          // margin: EdgeInsets.symmetric(
          //   horizontal: layoutStyle.defaultMargin,
          // ),
          padding: EdgeInsets.symmetric(
            horizontal: layoutStyle.defaultMargin / 2,
            vertical: layoutStyle.defaultMargin / 5,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorStyle.grey,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(
              layoutStyle.defaultMargin / 2,
            ),
            color: controller.selectedPaymentType.value.id == element.id
                ? colorStyle.primary
                : colorStyle.white,
          ),
          child: Row(
            children: [
              img.isNotEmpty
                  ? Image.network(
                      img,
                      width: layoutStyle.blockHorizontal * 3,
                      height: layoutStyle.blockVertical * 3,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        assetsConstant.icPaymentEdc,
                      ),
                    )
                  : Image.asset(
                      assetsConstant.icPaymentEdc,
                    ),
              if (label.isNotEmpty) ...[
                SizedBox(
                  width: layoutStyle.defaultMargin / 2,
                ),
                Expanded(
                  child: Text(
                    label,
                    style: textStyle.blackText.copyWith(
                      color:
                          controller.selectedPaymentType.value.id == element.id
                              ? colorStyle.white
                              : colorStyle.black,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ]
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.symmetric(
          vertical: layoutStyle.defaultMargin / 4,
          horizontal: layoutStyle.defaultMargin,
        ),
        height: layoutStyle.screenHeight,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: layoutStyle.defaultMargin,
                vertical: layoutStyle.defaultMargin / 2,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Row(
                  children: [
                    SizedBox(
                      width: layoutStyle.blockHorizontal * 4,
                      height: layoutStyle.blockVertical * 5,
                      child: CustomButton(
                        onPressed: () {
                          controller.doBackPayment();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              colorStyle.white),
                          foregroundColor: MaterialStateProperty.all<Color>(
                              colorStyle.primary),
                          overlayColor: MaterialStateProperty.all<Color>(
                              colorStyle.primary.withOpacity(0.1)),
                          side: MaterialStateProperty.all<BorderSide>(
                              BorderSide(color: colorStyle.primary, width: 1)),
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  EdgeInsets.symmetric(
                                      vertical: layoutStyle.defaultMargin / 5,
                                      horizontal:
                                          layoutStyle.defaultMargin / 5)),
                          elevation: MaterialStateProperty.all<double>(0),
                          alignment: Alignment.center,
                        ),
                        label: const Icon(
                          Icons.arrow_back,
                        ),
                        height: double.infinity,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            fontSize: fontSize.title,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: layoutStyle.screenWidth,
                margin: EdgeInsets.all(layoutStyle.defaultMargin),
                padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorStyle.primary,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(
                    layoutStyle.defaultMargin / 2,
                  ),
                  color: colorStyle.white,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          common.currencyFormat(
                            controller.totalOrderAmnt.value,
                          ),
                          style: TextStyle(
                            fontSize: fontSize.header * 2,
                            fontWeight: fontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: layoutStyle.defaultMargin / 2,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
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
                                  label: Text(
                                    'Nama Pemesan',
                                    style: textStyle.greyText.copyWith(
                                      fontSize: fontSize.small,
                                    ),
                                  ),
                                  controller: controller.orderNameController,
                                  decoration: InputDecoration(
                                    hintText: 'Tulis Nama',
                                    hintStyle: textStyle.greyText,
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (val) {
                                    logger.safeLog(val);
                                  },
                                ),
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
                                  label: Text(
                                    'Email',
                                    style: textStyle.greyText.copyWith(
                                      fontSize: fontSize.small,
                                    ),
                                  ),
                                  controller: controller.emailController,
                                  decoration: InputDecoration(
                                    hintText: 'Tulis Email',
                                    hintStyle: textStyle.greyText,
                                    border: InputBorder.none,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
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
                                  label: Text(
                                    'No WA',
                                    style: textStyle.greyText.copyWith(
                                      fontSize: fontSize.small,
                                    ),
                                  ),
                                  controller: controller.noWaController,
                                  decoration: InputDecoration(
                                    hintText: 'Nomor Whatsaap',
                                    hintStyle: textStyle.greyText,
                                    border: InputBorder.none,
                                  ),
                                  keyboardType: TextInputType.phone,
                                  maxLength: 13,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
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
                                  label: Text(
                                    'Alamat/Lokasi',
                                    style: textStyle.greyText.copyWith(
                                      fontSize: fontSize.small,
                                    ),
                                  ),
                                  controller: controller.alamatController,
                                  decoration: InputDecoration(
                                    hintText: 'Tulis Alamat/Lokasi',
                                    hintStyle: textStyle.greyText,
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (val) {
                                    logger.safeLog(val);
                                  },
                                  keyboardType: TextInputType.text,
                                ),
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
                                  label: Text(
                                    'Keterangan Voucher ',
                                    style: textStyle.greyText.copyWith(
                                      fontSize: fontSize.small,
                                    ),
                                  ),
                                  controller: controller.keteranganVoucher,
                                  decoration: InputDecoration(
                                    hintText: 'Tulis Keterangan Voucher',
                                    hintStyle: textStyle.greyText,
                                    border: InputBorder.none,
                                  ),
                                  keyboardType: TextInputType.text,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: CustomTextBox(
                                        height: layoutStyle.blockVertical * 6.5,
                                        margin: EdgeInsets.symmetric(
                                          horizontal: layoutStyle.defaultMargin,
                                          vertical:
                                              layoutStyle.defaultMargin / 4,
                                        ),
                                        obscureText: false,
                                        border: Border.all(
                                          color: colorStyle.grey,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          layoutStyle.defaultMargin / 2,
                                        ),
                                        label: Text(
                                          'No Member',
                                          style: textStyle.greyText.copyWith(
                                            fontSize: fontSize.small,
                                          ),
                                        ),
                                        controller: controller.memberNo,
                                        decoration: InputDecoration(
                                          hintText: 'Tulis No Member',
                                          hintStyle: textStyle.greyText,
                                          border: InputBorder.none,
                                        ),
                                        keyboardType: TextInputType.text,
                                        onChanged: (text) {
                                          if (text.isEmpty) {
                                            controller.clearAllVoucherToCart();
                                          }
                                        },
                                      ),
                                    ),
                                    CustomButton(
                                      width:
                                          layoutStyle.safeBlockHorizontal * 8,
                                      height: layoutStyle.blockVertical * 6.5,
                                      margin: EdgeInsets.symmetric(
                                        vertical: layoutStyle.defaultMargin / 2,
                                        // horizontal: layoutStyle.defaultMargin,
                                      ),
                                      onPressed: () async {
                                        controller.onCheckMember();
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.resolveWith(
                                          (states) => colorStyle.blue,
                                        ),
                                        padding: MaterialStateProperty.all<
                                            EdgeInsetsGeometry>(
                                          EdgeInsets.symmetric(
                                            horizontal:
                                                layoutStyle.defaultMargin / 4,
                                          ),
                                        ),
                                        minimumSize:
                                            MaterialStateProperty.all<Size>(
                                          Size.zero,
                                        ),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        overlayColor:
                                            MaterialStateProperty.resolveWith(
                                          (states) =>
                                              colorStyle.black.withOpacity(0.1),
                                        ),
                                        shape:
                                            MaterialStateProperty.resolveWith(
                                          (states) => RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              layoutStyle.defaultMargin / 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      label: Text(
                                        'Cek',
                                        style: textStyle.whiteText,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: layoutStyle.defaultMargin / 2,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: layoutStyle.defaultMargin,
                        ),
                        child: Text(
                          'Pilih Pembayaran',
                          style: textStyle.greyText.copyWith(
                            fontSize: fontSize.small,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      SizedBox(
                        height: layoutStyle.defaultMargin / 2,
                      ),
                      if (controller.isLoadingPayment.value) ...[
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: layoutStyle.defaultMargin / 2,
                          ),
                          alignment: Alignment.centerLeft,
                          width: layoutStyle.blockHorizontal * 3,
                          height: layoutStyle.blockVertical * 5,
                          child: loading.simpleLoading(),
                        )
                      ] else ...[
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: layoutStyle.defaultMargin,
                          ),
                          // child: Wrap(
                          //   spacing: layoutStyle.defaultMargin / 2,
                          //   runSpacing: layoutStyle.defaultMargin / 2,
                          //   children: controller.paymentType
                          //       .map(
                          //         (element) => cardPayment(element),
                          //       )
                          //       .toList(),
                          // ),
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisSpacing: layoutStyle.defaultMargin / 2,
                              mainAxisSpacing: layoutStyle.defaultMargin / 2,
                              crossAxisCount: 3,
                              childAspectRatio: 2,
                              // childAspectRatio: layoutStyle.screenWidth > 800
                              //     ? (400 / 200)
                              //     : (layoutStyle.blockHorizontal * 2) /
                              //         (layoutStyle.blockVertical * 7),
                            ),
                            itemCount: controller.paymentType.length,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                height: layoutStyle.blockVertical * 2,
                                child: cardPayment(
                                  controller.paymentType[index],
                                ),
                              );
                            },
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
