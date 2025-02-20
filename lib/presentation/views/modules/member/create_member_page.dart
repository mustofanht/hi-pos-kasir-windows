import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/member/membership.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_card_payment.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/create_member_page_controller.dart';
import 'package:jaya_propertiy/presentation/views/modules/member/cart_member.dart';

class CreateMemberPage extends GetView<CreateMemberPageController> {
  final Membership membership;
  const CreateMemberPage({
    super.key,
    required this.membership,
  });

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
                'Form Membership',
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

    Widget _leftFormPaymentMethod() {
      return Obx(
        () => Padding(
          padding: EdgeInsets.symmetric(horizontal: layoutStyle.defaultMargin),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: layoutStyle.defaultMargin / 2,
              mainAxisSpacing: layoutStyle.defaultMargin / 2,
              crossAxisCount: 3,
              childAspectRatio: 2,
            ),
            itemCount: controller.paymentType.length,
            itemBuilder: (context, index) {
              return SizedBox(
                height: layoutStyle.blockVertical * 2,
                child: CustomCardPayment(
                  element: controller.paymentType[index],
                  doSelectPaymentType: controller.doSelectPaymentType,
                  mstPayments: controller.mstPayments,
                  selectedPaymentType: controller.selectedPaymentType,
                ),
              );
            },
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
        ),
      );
    }

    Widget _leftFormSection() {
      return Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
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
                  'No Member',
                  style: textStyle.greyText.copyWith(
                    fontSize: fontSize.small,
                  ),
                ),
                controller: controller.noMemberController,
                decoration: InputDecoration(
                  hintText: 'Nomor Member',
                  hintStyle: textStyle.greyText,
                  border: InputBorder.none,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextBox(
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
                        'No KTP',
                        style: textStyle.greyText.copyWith(
                          fontSize: fontSize.small,
                        ),
                      ),
                      controller: controller.noKtpController,
                      decoration: InputDecoration(
                        hintText: 'Nomor KTP',
                        hintStyle: textStyle.greyText,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomTextBox(
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
                        'Nama',
                        style: textStyle.greyText.copyWith(
                          fontSize: fontSize.small,
                        ),
                      ),
                      controller: controller.nameController,
                      decoration: InputDecoration(
                        hintText: 'Nama',
                        hintStyle: textStyle.greyText,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextBox(
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
                        'Alamat',
                        style: textStyle.greyText.copyWith(
                          fontSize: fontSize.small,
                        ),
                      ),
                      controller: controller.addressController,
                      decoration: InputDecoration(
                        hintText: 'Alamat',
                        hintStyle: textStyle.greyText,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomTextBox(
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
                        'Nomor Hp',
                        style: textStyle.greyText.copyWith(
                          fontSize: fontSize.small,
                        ),
                      ),
                      controller: controller.noPhoneController,
                      decoration: InputDecoration(
                        hintText: 'Nama',
                        hintStyle: textStyle.greyText,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              membership.membCheckName != 'Y'
                  ? Container(
                      margin: EdgeInsets.all(layoutStyle.defaultMargin),
                    )
                  : CustomButton(
                      width: layoutStyle.blockHorizontal * 10,
                      height: layoutStyle.blockVertical * 6.5,
                      margin: EdgeInsets.symmetric(
                        horizontal: layoutStyle.defaultMargin,
                        vertical: layoutStyle.defaultMargin / 2,
                      ),
                      onPressed: () {
                        // controller.doBack();
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            colorStyle.primary),
                        foregroundColor: MaterialStateProperty.all<Color>(
                            colorStyle.primary),
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
                      label: Row(
                        children: [
                          Icon(
                            Icons.add,
                            size: fontSize.body,
                            color: colorStyle.white,
                          ),
                          Text(
                            'Anggota',
                            style: textStyle.whiteText,
                          ),
                        ],
                      ),
                    ),
              _leftFormPaymentMethod(),
            ],
          ),
        ),
      );
    }

    Widget _leftSection() {
      return Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: layoutStyle.defaultMargin / 2,
          ),
          child: Column(
            children: [
              _leftHeadSection(),
              _leftFormSection(),
            ],
          ),
        ),
      );
    }

    return GetBuilder(
      init: controller,
      tag: 'CreateMemberPage',
      initState: (state) {},
      builder: (controller) {
        return Container(
          decoration: BoxDecoration(
            color: colorStyle.lightGrey,
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
