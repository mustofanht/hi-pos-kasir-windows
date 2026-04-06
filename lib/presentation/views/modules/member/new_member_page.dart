import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_empty_data.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/new_member_page_controller.dart';
import 'package:jaya_propertiy/presentation/views/modules/member/cart_member.dart';

class NewMemberPage extends GetView<NewMemberPageController> {
  const NewMemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    Widget _leftHeadSection() {
      return Row(
        children: [
          SizedBox(
            width: layoutStyle.blockHorizontal * 4,
            height: layoutStyle.blockVertical * 6.5,
            child: CustomButton(
              onPressed: () {
                controller.doBack();
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(colorStyle.white),
                foregroundColor:
                    MaterialStateProperty.all<Color>(colorStyle.primary),
                overlayColor: MaterialStateProperty.all<Color>(
                    colorStyle.primary.withOpacity(0.1)),
                side: MaterialStateProperty.all<BorderSide>(
                    BorderSide(color: colorStyle.primary, width: 1)),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(
                        vertical: layoutStyle.defaultMargin / 5,
                        horizontal: layoutStyle.defaultMargin / 5)),
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
            child: Container(
              alignment: Alignment.center,
              child: Text(
                'Member',
                style: textStyle.blackText.copyWith(
                  fontSize: fontSize.title,
                  fontWeight: fontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget _leftMembershipSection() {
      return Expanded(
        child: controller.isLoading.value
            ? loading.simpleLoading()
            : controller.dataList.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: layoutStyle.defaultMargin * 4,
                      ),
                      child: const CustomEmptyData(),
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
                    children: controller.dataList
                        .map(
                          (e) => InkWell(
                            onTap: () {
                              controller.doSelectMembership(e);
                            },
                            child: Container(
                              height: 20,
                              padding: EdgeInsets.all(
                                layoutStyle.defaultMargin / 5,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    // color: colorStyle.primary,
                                    ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                color: colorStyle.white,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: Image.asset(
                                      assetsConstant.membership,
                                      fit: BoxFit.fill,
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        return const Text('Img Not Found');
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: layoutStyle.defaultMargin,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(
                                      layoutStyle.defaultMargin / 4,
                                    ),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        return Container(
                                          width: constraints.maxWidth,
                                          child: AutoSizeText(
                                            e.membName!,
                                            style: TextStyle(
                                              fontSize: fontSize.body,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 3,
                                            minFontSize: fontSize.small,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
      );
    }

    Widget _leftSection() {
      return Obx(
        () => Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: layoutStyle.defaultMargin / 2,
            ),
            child: Column(
              children: [
                _leftHeadSection(),
                _leftMembershipSection(),
              ],
            ),
          ),
        ),
      );
    }

    return GetBuilder(
      init: controller,
      tag: 'NewMemberPage',
      initState: (state) {
        controller.doPrepareList(page: 0);
      },
      builder: (controller) {
        return Container(
          decoration: BoxDecoration(
            color: colorStyle.white,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: layoutStyle.defaultMargin / 2,
          ),
          child: Row(
            children: [
              _leftSection(),
              CartMember(),
            ],
          ),
        );
      },
    );
  }
}
