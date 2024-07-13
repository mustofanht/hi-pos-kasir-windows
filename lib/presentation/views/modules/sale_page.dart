import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_dropdown_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale_page_controller.dart';
import 'package:jaya_propertiy/presentation/views/modules/sale/sale_addon_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/sale/sale_cart_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/sale/sale_ticket_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/sale/sale_voucher_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SalePage extends StatefulWidget {
  const SalePage({super.key});

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  final SalePageController controller = Get.find();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    tabController!.addListener(_handleTabSelection);
    controller.doPrepared();
    logger.safeLog('SALE PAGE 1');
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (!tabController!.indexIsChanging) {
      controller.changeTabIndex(tabController!.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    Widget saleSection() {
      return Expanded(
        flex: 1,
        child: Column(
          children: <Widget>[
            Container(
              width: layoutStyle.screenWidth,
              color: colorStyle.lightGrey,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: layoutStyle.screenWidth / 6),
                child: TabBar(
                  controller: tabController,
                  indicator: BoxDecoration(
                      color: colorStyle.white,
                      border: Border(
                        bottom: BorderSide(
                          color: colorStyle.primary,
                          width: 1.0,
                        ),
                      )),
                  labelColor: colorStyle.primary,
                  unselectedLabelColor: colorStyle.black,
                  tabs: const [
                    Tab(text: 'Ticket'),
                    Tab(text: 'Voucher'),
                    Tab(text: 'Add On'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: const [
                  SaleTicketPage(),
                  SaleVoucherPage(),
                  SaleAddonPage(),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget paymentSection() {
      return Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: layoutStyle.defaultMargin / 4,
              horizontal: layoutStyle.defaultMargin),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              // padding: EdgeInsets.symmetric(
              //     vertical: layoutStyle.defaultMargin / 4,
              //     horizontal: layoutStyle.defaultMargin),
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: layoutStyle.defaultMargin,
                      vertical: layoutStyle.defaultMargin / 2),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: layoutStyle.blockHorizontal * 4,
                          height: layoutStyle.blockVertical * 5,
                          child: CustomButton(
                            onPressed: () {
                              controller.openPayment.value =
                                  !controller.openPayment.value;
                              controller.update();
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  colorStyle.white),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  colorStyle.primary),
                              overlayColor: MaterialStateProperty.all<Color>(
                                  colorStyle.primary.withOpacity(0.1)),
                              side: MaterialStateProperty.all<BorderSide>(
                                  BorderSide(
                                      color: colorStyle.primary, width: 1)),
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                      EdgeInsets.symmetric(
                                          vertical:
                                              layoutStyle.defaultMargin / 5,
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
                Center(
                  child: Text(
                    common.currencyFormat(controller.totalOrderAmnt.value),
                    style: TextStyle(
                      fontSize: fontSize.header * 2,
                      fontWeight: fontWeight.bold,
                    ),
                  ),
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
                ),
                CustomDropdownButton<CustomIdNameEntity>(
                  height: layoutStyle.blockVertical * 6.5,
                  items: controller.paymentType
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text("${e.name}"),
                        ),
                      )
                      .toList(),
                  value: controller.selectedPaymentType.value,
                  label: Text(
                    'Pilih Pembayaran',
                    style: textStyle.greyText.copyWith(
                      fontSize: fontSize.small,
                    ),
                  ),
                  border: Border.all(
                    color: colorStyle.lightGrey,
                    width: 1,
                  ),
                  margin: EdgeInsets.symmetric(
                    vertical: layoutStyle.defaultMargin / 4,
                    horizontal: layoutStyle.defaultMargin,
                  ),
                  onChanged: (val) {
                    controller.doSelectPaymentType(val!);
                  },
                ),
                // controller.showReffId.value
                //     ? CustomTextBox(
                //         height: layoutStyle.blockVertical * 6.5,
                //         margin: EdgeInsets.symmetric(
                //           horizontal: layoutStyle.defaultMargin,
                //           vertical: layoutStyle.defaultMargin / 4,
                //         ),
                //         obscureText: false,
                //         border: Border.all(
                //           color: colorStyle.grey,
                //           width: 1,
                //         ),
                //         borderRadius: BorderRadius.circular(
                //           layoutStyle.defaultMargin / 2,
                //         ),
                //         label: Text(
                //           'Reference ID',
                //           style: textStyle.greyText.copyWith(
                //             fontSize: fontSize.small,
                //           ),
                //         ),
                //         controller: controller.referenceIdController,
                //         decoration: InputDecoration(
                //           hintText: '-',
                //           hintStyle: textStyle.greyText,
                //           border: InputBorder.none,
                //         ),
                //         keyboardType: TextInputType.text,
                //       )
                //     : Container(),
              ],
            ),
          ),
        ),
      );
    }

    return Obx(
      () => Row(
        children: [
          if (!controller.openPayment.value) ...[
            saleSection(),
          ] else
            paymentSection(),
          const SaleCartPage()
        ],
      ),
    );
  }
}
