import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/domain/entities/sale/deposit_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/potongan_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/voucher_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
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

    Widget voucherCard(VoucherEntity e) {
      return InkWell(
        onTap: () {
          controller.addVoucherToCart(e);
        },
        child: Container(
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(
              color: colorStyle.primary,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: colorStyle.white,
          ),
          padding: EdgeInsets.all(layoutStyle.defaultMargin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 3,
                child: Image.asset(
                  'assets/images/coupon.png',
                  fit: BoxFit.fill,
                  errorBuilder: (BuildContext context, Object exception,
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: Container(
                            width: constraints.maxWidth,
                            child: AutoSizeText(
                              e.vpName!,
                              style: TextStyle(
                                fontSize: fontSize.body,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              minFontSize: 8,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            width: constraints.maxWidth,
                            child: AutoSizeText(
                              'Kode:\n${e.vpCode}',
                              style: TextStyle(
                                fontSize: fontSize.body,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              minFontSize: 8,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            width: constraints.maxWidth,
                            child: AutoSizeText(
                              'Disc:\n${e.vpUnitType == UnitType.PERCENT ? ('${e.vpUnitValue} %') : ('Rp.${common.currencyFormat(e.vpUnitValue ?? 0)}')}',
                              style: TextStyle(
                                fontSize: fontSize.body,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              minFontSize: 8,
                              overflow: TextOverflow.ellipsis,
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
      );
    }

    Widget potonganCard(PotonganEntity e) {
      return InkWell(
        onTap: () {
          controller.addPotonganToCart(voucher: e);
        },
        child: Container(
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(
              color: colorStyle.primary,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: colorStyle.white,
          ),
          padding: EdgeInsets.all(layoutStyle.defaultMargin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 3,
                child: Image.asset(
                  'assets/images/coupon.png',
                  fit: BoxFit.fill,
                  errorBuilder: (BuildContext context, Object exception,
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: Container(
                            width: constraints.maxWidth,
                            child: AutoSizeText(
                              e.voucherName!,
                              style: TextStyle(
                                fontSize: fontSize.body,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              minFontSize: 8,
                              overflow: TextOverflow.ellipsis,
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
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              minFontSize: 8,
                              overflow: TextOverflow.ellipsis,
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
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              minFontSize: 8,
                              overflow: TextOverflow.ellipsis,
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
      );
    }

    Widget depositCard(DepositEntity e) {
      return InkWell(
        onTap: () {
          controller.addDepositToCart(e);
        },
        child: Container(
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(
              color: colorStyle.primary,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: colorStyle.white,
          ),
          padding: EdgeInsets.all(layoutStyle.defaultMargin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 1,
                child: Image.asset(
                  'assets/images/coupon.png',
                  fit: BoxFit.fill,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return const Text('Img Not Found');
                  },
                ),
              ),
              SizedBox(
                height: layoutStyle.defaultMargin / 2,
              ),
              Expanded(
                flex: 2,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: Container(
                            width: constraints.maxWidth,
                            child: AutoSizeText(
                              'Reff No: ${e.dpReffno}',
                              style: TextStyle(
                                fontSize: fontSize.body,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              minFontSize: 8,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            width: constraints.maxWidth,
                            child: AutoSizeText(
                              'Nama: ${e.dpName}',
                              style: TextStyle(
                                fontSize: fontSize.body,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              minFontSize: 8,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            width: constraints.maxWidth,
                            child: AutoSizeText(
                              'No. HP: ${e.dpNoHp}',
                              style: TextStyle(
                                fontSize: fontSize.body,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              minFontSize: 8,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            width: constraints.maxWidth,
                            child: AutoSizeText(
                              'Jumlah: Rp.${common.currencyFormat(e.dpAmount ?? 0)}',
                              style: TextStyle(
                                fontSize: fontSize.body,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              minFontSize: 8,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        // Flexible(
                        //   child: Container(
                        //     width: constraints.maxWidth,
                        //     child: AutoSizeText(
                        //       'Kode:\n${e.}',
                        //       style: TextStyle(
                        //         fontSize: fontSize.body,
                        //       ),
                        //       textAlign: TextAlign.center,
                        //       maxLines: 2,
                        //       minFontSize: 8,
                        //       overflow: TextOverflow.ellipsis,
                        //     ),
                        //   ),
                        // ),
                        // Flexible(
                        //   child: Container(
                        //     width: constraints.maxWidth,
                        //     child: AutoSizeText(
                        //       'Disc:\n${e.voucherUnitType == UnitType.PERCENT ? ('${e.voucherUnitValue} %') : ('Rp.${common.currencyFormat(e.voucherUnitValue ?? 0)}')}',
                        //       style: TextStyle(
                        //         fontSize: fontSize.body,
                        //       ),
                        //       textAlign: TextAlign.center,
                        //       maxLines: 2,
                        //       minFontSize: 8,
                        //       overflow: TextOverflow.ellipsis,
                        //     ),
                        //   ),
                        // ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget typeVoucherSection() {
      return Obx(
        () => Container(
          padding: EdgeInsets.all(
            layoutStyle.defaultMargin,
          ),
          child: Row(
            children: controller.typeItemList
                .map(
                  (element) => GestureDetector(
                    onTap: () => controller.onSelectedType(element),
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: layoutStyle.defaultMargin / 5,
                      ),
                      padding: EdgeInsets.all(layoutStyle.defaultMargin),
                      decoration: BoxDecoration(
                        color:
                            controller.selectedTypeItemList.value == element.id
                                ? colorStyle.primary
                                : colorStyle.lightGrey,
                        borderRadius: BorderRadius.circular(
                          layoutStyle.defaultMargin,
                        ),
                        border: Border.all(
                          color: colorStyle.grey,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          element.name ?? '',
                          style: controller.selectedTypeItemList.value ==
                                  element.id
                              ? textStyle.whiteText
                              : textStyle.greyText,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      );
    }

    Widget listContent() {
      return Obx(() {
        // logger.safeLog('LENGTH V : ${controller.voucherList.length}');
        // logger.safeLog('LENGTH P : ${controller.potonganList.length}');
        // logger.safeLog('LENGTH D : ${controller.depositList.length}');
        if (controller.selectedTypeItemList.value == 'V') {
          return controller.voucherList.isEmpty
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
                        (e) => voucherCard(e),
                      )
                      .toList(),
                );
        } else if (controller.selectedTypeItemList.value == 'P') {
          return controller.potonganList.isEmpty
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
                  children: controller.potonganList
                      .map(
                        (e) => potonganCard(e),
                      )
                      .toList(),
                );
        } else if (controller.selectedTypeItemList.value == 'D') {
          return controller.depositList.isEmpty
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
                  children: controller.depositList
                      .map(
                        (e) => depositCard(e),
                      )
                      .toList(),
                );
        } else {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(
                top: layoutStyle.defaultMargin * 4,
              ),
              child: emptyData(),
            ),
          );
        }
      });
    }

    Widget contentSection() {
      return Expanded(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.doPrepareList(
              page: 0,
            );
          },
          child: controller.isLoading.value
              ? loading.simpleLoading()
              : listContent(),
        ),
      );
    }

    Widget searchSection() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: layoutStyle.defaultMargin),
        child: Row(
          children: [
            Expanded(
              child: CustomTextBox(
                height: layoutStyle.blockVertical * 6.5,
                margin: EdgeInsets.symmetric(
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
                controller: controller.searchController,
                onChanged: (val) {},
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: textStyle.greyText,
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.text,
              ),
            ),
            SizedBox(
              width: layoutStyle.defaultMargin,
            ),
            CustomButton(
              width: layoutStyle.safeBlockHorizontal * 5,
              height: layoutStyle.blockVertical * 6.5,
              margin: EdgeInsets.symmetric(
                vertical: layoutStyle.defaultMargin / 2,
              ),
              onPressed: () async {
                await controller.doSearch();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith(
                  (states) => colorStyle.blue,
                ),
                overlayColor: MaterialStateProperty.resolveWith(
                  (states) => colorStyle.black.withOpacity(0.1),
                ),
                shape: MaterialStateProperty.resolveWith(
                  (states) => RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      layoutStyle.defaultMargin / 2,
                    ),
                  ),
                ),
              ),
              label: Icon(
                Icons.search,
                color: colorStyle.white,
              ),
            ),
          ],
        ),
      );
    }

    return GetBuilder(
      init: controller,
      tag: 'SaleVoucherPage',
      initState: (state) {
        controller.scrollController.addListener(controller.scrollHandler);
        controller.selectedTypeItemList.value = 'V';
        controller.doPrepareList(
          page: 0,
        );
      },
      builder: (controller) {
        return Container(
          width: layoutStyle.screenWidth,
          height: layoutStyle.screenHeight,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              typeVoucherSection(),
              if (controller.selectedTypeItemList.value == 'D') searchSection(),
              contentSection(),
            ],
          ),
        );
      },
    );
  }
}
