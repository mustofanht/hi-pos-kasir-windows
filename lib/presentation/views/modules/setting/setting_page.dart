import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_dropdown_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/setting/setting_page_controller.dart';

class SettingPage extends GetView<SettingPageController> {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    return GetBuilder(
      init: controller,
      tag: 'SettingPage',
      initState: (state) {
        controller;
      },
      builder: (controller) {
        // return Column(
        //   children: <Widget>[
        //     Container(
        //       width: layoutStyle.screenWidth,
        //       color: colorStyle.lightGrey,
        //       child: Container(
        //         padding: EdgeInsets.symmetric(
        //           horizontal: layoutStyle.screenWidth / 4,
        //         ),
        //         child: TabBar(
        //           controller: controller.tabController,
        //           indicator: BoxDecoration(
        //               color: colorStyle.white,
        //               border: Border(
        //                 bottom: BorderSide(
        //                   color: colorStyle.primary,
        //                   width: 1.0,
        //                 ),
        //               )),
        //           labelColor: colorStyle.primary,
        //           unselectedLabelColor: colorStyle.black,
        //           tabs: const [
        //             Tab(text: 'User Info'),
        //             Tab(text: 'Server Info'),
        //             Tab(text: 'Customer Display'),
        //             Tab(text: 'Print Setting'),
        //           ],
        //         ),
        //       ),
        //     ),
        //     Expanded(
        //       child: TabBarView(
        //         controller: controller.tabController,
        //         children: const [
        //           UserInfo(),
        //           ServerInfo(),
        //           CustomerDisplay(),
        //           PrintSetting(),
        //         ],
        //       ),
        //     ),
        //   ],
        // );
        return Obx(
          () => Container(
            width: layoutStyle.screenWidth,
            height: layoutStyle.screenHeight,
            padding: EdgeInsets.all(layoutStyle.defaultMargin),
            child: Row(
              children: [
                Expanded(
                  child: controller.isLoading.value
                      ? loading.simpleLoading()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User Information',
                              style: textStyle.blackText.copyWith(
                                fontSize: fontSize.header,
                              ),
                            ),
                            Container(
                              width: layoutStyle.screenWidth,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: colorStyle.grey,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: layoutStyle.defaultMargin,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CustomTextBox(
                                    height: layoutStyle.blockVertical * 6.5,
                                    obscureText: false,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: layoutStyle.defaultMargin,
                                      vertical: layoutStyle.defaultMargin / 4,
                                    ),
                                    border: Border.all(
                                      color: colorStyle.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      layoutStyle.defaultMargin / 2,
                                    ),
                                    label: Text(
                                      'Unit',
                                      style: textStyle.greyText.copyWith(
                                        fontSize: fontSize.small,
                                      ),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Unit',
                                      hintStyle: textStyle.greyText,
                                      border: InputBorder.none,
                                    ),
                                    controller: controller.unitController,
                                    isDisabled: true,
                                  ),
                                ),
                                Expanded(
                                  child: CustomTextBox(
                                    height: layoutStyle.blockVertical * 6.5,
                                    obscureText: false,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: layoutStyle.defaultMargin,
                                      vertical: layoutStyle.defaultMargin / 4,
                                    ),
                                    border: Border.all(
                                      color: colorStyle.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      layoutStyle.defaultMargin / 2,
                                    ),
                                    label: Text(
                                      'Last Login',
                                      style: textStyle.greyText.copyWith(
                                        fontSize: fontSize.small,
                                      ),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Last Login',
                                      hintStyle: textStyle.greyText,
                                      border: InputBorder.none,
                                    ),
                                    controller: controller.lastLoginController,
                                    isDisabled: true,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CustomTextBox(
                                    height: layoutStyle.blockVertical * 6.5,
                                    obscureText: false,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: layoutStyle.defaultMargin,
                                      vertical: layoutStyle.defaultMargin / 4,
                                    ),
                                    border: Border.all(
                                      color: colorStyle.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      layoutStyle.defaultMargin / 2,
                                    ),
                                    label: Text(
                                      'Nama',
                                      style: textStyle.greyText.copyWith(
                                        fontSize: fontSize.small,
                                      ),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Nama',
                                      hintStyle: textStyle.greyText,
                                      border: InputBorder.none,
                                    ),
                                    controller: controller.nameController,
                                    isDisabled: true,
                                  ),
                                ),
                                Expanded(
                                  child: CustomTextBox(
                                    height: layoutStyle.blockVertical * 6.5,
                                    obscureText: false,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: layoutStyle.defaultMargin,
                                      vertical: layoutStyle.defaultMargin / 4,
                                    ),
                                    border: Border.all(
                                      color: colorStyle.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      layoutStyle.defaultMargin / 2,
                                    ),
                                    label: Text(
                                      'Role',
                                      style: textStyle.greyText.copyWith(
                                        fontSize: fontSize.small,
                                      ),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Role',
                                      hintStyle: textStyle.greyText,
                                      border: InputBorder.none,
                                    ),
                                    controller: controller.roleController,
                                    isDisabled: true,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CustomTextBox(
                                    height: layoutStyle.blockVertical * 6.5,
                                    obscureText: false,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: layoutStyle.defaultMargin,
                                      vertical: layoutStyle.defaultMargin / 4,
                                    ),
                                    border: Border.all(
                                      color: colorStyle.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      layoutStyle.defaultMargin / 2,
                                    ),
                                    label: Text(
                                      'No Telepon',
                                      style: textStyle.greyText.copyWith(
                                        fontSize: fontSize.small,
                                      ),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'No Telepon',
                                      hintStyle: textStyle.greyText,
                                      border: InputBorder.none,
                                    ),
                                    controller: controller.noTelpController,
                                    isDisabled: true,
                                  ),
                                ),
                                Expanded(
                                  child: CustomTextBox(
                                    height: layoutStyle.blockVertical * 6.5,
                                    obscureText: false,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: layoutStyle.defaultMargin,
                                      vertical: layoutStyle.defaultMargin / 4,
                                    ),
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
                                    decoration: InputDecoration(
                                      hintText: 'Email',
                                      hintStyle: textStyle.greyText,
                                      border: InputBorder.none,
                                    ),
                                    controller: controller.emailController,
                                    isDisabled: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
                SizedBox(
                  width: layoutStyle.defaultMargin,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Others Information',
                        style: textStyle.blackText.copyWith(
                          fontSize: fontSize.header,
                        ),
                      ),
                      Container(
                        width: layoutStyle.screenWidth,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: colorStyle.grey,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: layoutStyle.defaultMargin,
                      ),
                      // CustomDropdownButton<CustomIdNameEntity>(
                      //   height: layoutStyle.blockVertical * 6.5,
                      //   items: controller.listScreens
                      //       .map(
                      //         (e) => DropdownMenuItem(
                      //           value: e,
                      //           child: Text("${e.name}"),
                      //         ),
                      //       )
                      //       .toList(),
                      //   value: controller.selectedScreens.value,
                      //   label: Text(
                      //     'List Screen Connect',
                      //     style: textStyle.greyText.copyWith(
                      //       fontSize: fontSize.small,
                      //     ),
                      //   ),
                      //   border: Border.all(
                      //     color: colorStyle.lightGrey,
                      //     width: 1,
                      //   ),
                      //   margin: EdgeInsets.symmetric(
                      //     vertical: layoutStyle.defaultMargin / 4,
                      //     horizontal: layoutStyle.defaultMargin,
                      //   ),
                      //   onChanged: (val) {
                      //     controller.selectedCurrPrinter.value = val!;
                      //     controller.update();
                      //   },
                      // ),
                      CustomButton(
                        margin: EdgeInsets.symmetric(
                          vertical: layoutStyle.defaultMargin / 2,
                          horizontal: layoutStyle.defaultMargin,
                        ),
                        onPressed: () {
                          controller.doRefreshCustomerPage();
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
                        prefixIcon: controller.isLoadingRefreshCustScreeen.value
                            ? Container()
                            : Icon(Icons.refresh_outlined, color: colorStyle.white),
                        label: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: layoutStyle.defaultMargin,
                          ),
                          child: controller.isLoadingRefreshCustScreeen.value
                              ? loading.buttonLoading()
                              : Text(
                                  'Refresh Customer Page',
                                  style: textStyle.whiteText,
                                ),
                        ),
                        height: layoutStyle.blockVertical * 6.5,
                      ),
                      // controller.isLoadingPrinter.value
                      //     ? Center(
                      //         child: SizedBox(
                      //           width: layoutStyle.blockVertical * 6.5,
                      //           height: layoutStyle.blockVertical * 6.5,
                      //           child: loading.simpleLoading(),
                      //         ),
                      //       )
                      //     :
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Obx(
                              () => CustomDropdownButton<CustomIdNameEntity>(
                                isLoading: controller.isLoadingPrinter.value,
                                height: layoutStyle.blockVertical * 6.5,
                                items: controller.listPrinter
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text("${e.name}"),
                                      ),
                                    )
                                    .toList(),
                                value: controller.selectedCurrPrinter.value,
                                label: Text(
                                  'Pilih Printer',
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
                                onChanged:
                                    controller.isLoadingConnectPrinter.value
                                        ? null
                                        : controller.doUpdateConnectedPrinter,
                              ),
                            ),
                          ),
                          CustomButton(
                            width: layoutStyle.blockVertical * 6.5,
                            height: layoutStyle.blockVertical * 6.5,
                            margin: EdgeInsets.symmetric(
                              vertical: layoutStyle.defaultMargin / 2,
                              horizontal: layoutStyle.defaultMargin / 5,
                            ),
                            onPressed: () {
                              controller.doInitializePrinter();
                            },
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(Size.zero),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: MaterialStateProperty.all(EdgeInsets.zero),
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
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
                            label: Icon(Icons.refresh, color: colorStyle.white),
                          ),
                          CustomButton(
                            width: layoutStyle.blockVertical * 6.5,
                            height: layoutStyle.blockVertical * 6.5,
                            margin: EdgeInsets.symmetric(
                              vertical: layoutStyle.defaultMargin / 2,
                              horizontal: layoutStyle.defaultMargin / 5,
                            ),
                            onPressed: () {
                              controller.testPrint();
                            },
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(Size.zero),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: MaterialStateProperty.all(EdgeInsets.zero),
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
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
                            label: Icon(Icons.print, color: colorStyle.white),
                            // suffixIcon: const Icon(Icons.print),
                            // prefixIcon: const Icon(Icons.print),
                            // label: controller.isLoading.value
                            //     ? loading.buttonLoading()
                            //     : Padding(
                            //         padding: EdgeInsets.symmetric(
                            //           horizontal: layoutStyle.defaultMargin,
                            //         ),
                            //         child: Text(
                            //           'Test',
                            //           style: textStyle.whiteText,
                            //         ),
                            //       ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: layoutStyle.defaultMargin / 5,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Obx(
                                () => Text(
                                  'Printer Connected : ${controller.currentPrinterConnect}',
                                  style: textStyle.blackText,
                                ),
                              ),
                            ),
                            CustomButton(
                              width: layoutStyle.blockVertical * 6.5,
                              height: layoutStyle.blockVertical * 6.5,
                              margin: EdgeInsets.symmetric(
                                vertical: layoutStyle.defaultMargin / 2,
                                horizontal: layoutStyle.defaultMargin / 5,
                              ),
                              onPressed: () {
                                controller.doDisconnectPrinter();
                              },
                              style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(Size.zero),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: MaterialStateProperty.all(EdgeInsets.zero),
                                backgroundColor:
                                    MaterialStateProperty.resolveWith(
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
                              label: controller.isLoadingPrinterDiconect.value
                                  ? Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(
                                        layoutStyle.defaultMargin / 10,
                                      ),
                                      width: layoutStyle.blockHorizontal * 3,
                                      height: layoutStyle.blockVertical * 3,
                                      child: CircularProgressIndicator(
                                        color: colorStyle.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(Icons.link_off, color: colorStyle.white),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
