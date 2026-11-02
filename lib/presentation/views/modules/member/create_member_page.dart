import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
// import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/ribuan_input_formatter.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
import 'package:jaya_propertiy/domain/entities/masterdata/mst_payment.dart';
import 'package:jaya_propertiy/domain/entities/member/membership.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_card_payment.dart';
import 'package:jaya_propertiy/presentation/components/custom_date_time_picker.dart';
import 'package:jaya_propertiy/presentation/components/custom_dropdown_button.dart';
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

    Widget _splitAmountDanReffno({
      required MstPayment? mstPayment,
      required bool isLegKedua,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isLegKedua)
            CustomTextBox(
              height: layoutStyle.blockVertical * 6.5,
              margin: EdgeInsets.symmetric(
                horizontal: layoutStyle.defaultMargin,
                vertical: layoutStyle.defaultMargin / 4,
              ),
              obscureText: false,
              border: Border.all(color: colorStyle.grey, width: 1),
              borderRadius:
                  BorderRadius.circular(layoutStyle.defaultMargin / 2),
              label: Text(
                'Nominal Metode 1',
                style: textStyle.greyText.copyWith(fontSize: fontSize.small),
              ),
              controller: controller.splitAmount1Controller,
              decoration: InputDecoration(
                hintText: 'mis. 50.000',
                hintStyle: textStyle.greyText,
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [RibuanInputFormatter()],
              onChanged: (_) => controller.update(),
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: layoutStyle.defaultMargin,
                vertical: layoutStyle.defaultMargin / 2,
              ),
              child: Text(
                'Sisa Metode 2 : ${common.currencyFormat(controller.splitAmount2)}',
                style: textStyle.blackText.copyWith(
                  fontSize: fontSize.small,
                  fontWeight: fontWeight.bold,
                ),
              ),
            ),
          if (controller.splitLegNeedsReffno(mstPayment))
            CustomTextBox(
              height: layoutStyle.blockVertical * 6.5,
              margin: EdgeInsets.symmetric(
                horizontal: layoutStyle.defaultMargin,
                vertical: layoutStyle.defaultMargin / 4,
              ),
              obscureText: false,
              border: Border.all(color: colorStyle.grey, width: 1),
              borderRadius:
                  BorderRadius.circular(layoutStyle.defaultMargin / 2),
              label: Text(
                isLegKedua ? 'No. Reference Metode 2' : 'No. Reference Metode 1',
                style: textStyle.greyText.copyWith(fontSize: fontSize.small),
              ),
              controller: isLegKedua
                  ? controller.splitReffno2Controller
                  : controller.splitReffno1Controller,
              decoration: InputDecoration(
                hintText: 'Tulis No Reference',
                hintStyle: textStyle.greyText,
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.text,
            ),
        ],
      );
    }

    Widget _splitPaymentSection() {
      return Obx(
        () => Padding(
          padding: EdgeInsets.symmetric(horizontal: layoutStyle.defaultMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomDropdownButton<MstPayment>(
                height: layoutStyle.blockVertical * 6.5,
                label: Text(
                  'Metode 1',
                  style: textStyle.greyText.copyWith(fontSize: fontSize.small),
                ),
                value: controller.mstPayments.any((e) =>
                        e.pymntCode == controller.splitPayment1.value?.pymntCode)
                    ? controller.splitPayment1.value
                    : null,
                items: controller.mstPayments
                    .where((e) =>
                        e.pymntCode != controller.splitPayment2.value?.pymntCode)
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.pymntName ?? '-'),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) controller.doSelectSplitPayment1(val);
                },
              ),
              _splitAmountDanReffno(
                mstPayment: controller.splitPayment1.value,
                isLegKedua: false,
              ),
              SizedBox(height: layoutStyle.defaultMargin / 2),
              CustomDropdownButton<MstPayment>(
                height: layoutStyle.blockVertical * 6.5,
                label: Text(
                  'Metode 2',
                  style: textStyle.greyText.copyWith(fontSize: fontSize.small),
                ),
                value: controller.mstPayments.any((e) =>
                        e.pymntCode == controller.splitPayment2.value?.pymntCode)
                    ? controller.splitPayment2.value
                    : null,
                items: controller.mstPayments
                    .where((e) =>
                        e.pymntCode != controller.splitPayment1.value?.pymntCode)
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.pymntName ?? '-'),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) controller.doSelectSplitPayment2(val);
                },
              ),
              _splitAmountDanReffno(
                mstPayment: controller.splitPayment2.value,
                isLegKedua: true,
              ),
              SizedBox(height: layoutStyle.defaultMargin / 2),
            ],
          ),
        ),
      );
    }

    Widget _leftFormPaymentMethod() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: layoutStyle.defaultMargin,
              vertical: layoutStyle.defaultMargin / 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Split Pembayaran',
                  style: textStyle.greyText.copyWith(fontSize: fontSize.small),
                ),
                Obx(
                  () => Switch(
                    value: controller.isSplitPayment.value,
                    activeColor: colorStyle.primary,
                    onChanged: (val) => controller.doToggleSplitPayment(val),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => controller.isSplitPayment.value
                ? _splitPaymentSection()
                : Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: layoutStyle.defaultMargin),
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
          ),
        ],
      );
    }

    Widget _leftDynamicAnggota() {
      return Obx(
        () => Column(
          children: List.generate(
            controller.anggotaList.length,
            (index) => Row(
              children: [
                Expanded(
                  child: CustomTextBox(
                    isMandatory: true,
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
                    controller: controller.anggotaNamaControllers[index],
                    decoration: InputDecoration(
                      hintText: 'Nama',
                      hintStyle: textStyle.greyText,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Expanded(
                  child: CustomDropdownButton<CustomIdNameEntity>(
                    isMandatory: true,
                    height: layoutStyle.blockVertical * 6.5,
                    items: controller.listRelation
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text("${e.name}"),
                          ),
                        )
                        .toList(),
                    value: controller.isValidValueRelation(
                            controller.anggotaSelectedRelations[index],
                            controller.listRelation)
                        ? controller.anggotaSelectedRelations[index]
                        : null,
                    label: Text(
                      'Hubungan',
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
                    onChanged: (p0) {
                      if (p0 != null) {
                        controller.anggotaSelectedRelations[index] = p0;
                      }
                    },
                  ),
                ),
                CustomButton(
                  width: layoutStyle.blockHorizontal * 4,
                  height: layoutStyle.blockVertical * 5,
                  margin: EdgeInsets.only(
                    right: layoutStyle.defaultMargin,
                    top: layoutStyle.defaultMargin * 2,
                  ),
                  onPressed: () {
                    controller.removeAnggota(index);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(colorStyle.red),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(colorStyle.red),
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
                  label: Icon(
                    Icons.remove,
                    size: fontSize.body,
                    color: colorStyle.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget _leftAnggotaSection() {
      return membership.membCheckName != 'Y'
          ? Container(
              margin: EdgeInsets.all(layoutStyle.defaultMargin),
            )
          : Padding(
              padding:
                  EdgeInsets.symmetric(vertical: layoutStyle.defaultMargin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomButton(
                    width: layoutStyle.blockHorizontal * 10,
                    height: layoutStyle.blockVertical * 6.5,
                    margin: EdgeInsets.symmetric(
                      horizontal: layoutStyle.defaultMargin,
                      // vertical: layoutStyle.defaultMargin / 2,
                    ),
                    onPressed: () {
                      controller.addAnggota();
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(colorStyle.primary),
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
                  _leftDynamicAnggota(),
                ],
              ),
            );
    }

    Widget _leftFormSection() {
      return Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          // Beri ruang ekstra setinggi keyboard supaya field paling bawah
          // (Alamat/Anggota/metode bayar) bisa di-scroll naik di atas keyboard,
          // sama seperti halaman penjualan (SalePaymentPage).
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomTextBox(
                      height: layoutStyle.blockVertical * 6.5,
                      isDisabled: true,
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
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ],
                      maxLength: 16,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: CustomTextBox(
                      isMandatory: true,
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
                  Expanded(
                    child: Obx(
                      () => CustomDateTimePicker(
                        // Opsional: tidak diberi tanda "*" dan tidak diperiksa
                        // validateForm(). Mode ketik dipakai karena menelusuri
                        // kalender mundur puluhan tahun terlalu lama di kasir.
                        firstState: controller.tglLahir.value == null,
                        newDate: controller.tglLahir.value,
                        placeholder: 'Pilih Tgl Lahir',
                        useInputEntryMode: true,
                        // Pemilik kartu bisa lahir sebelum 1980 (batas bawaan
                        // pemilihnya), dan tidak ada yang lahir besok.
                        firstDate: DateTime(1920),
                        lastDate: DateTime.now(),
                        dateFormat: 'dd-MM-yyyy',
                        onDateChanged: (nilai) {
                          controller.tglLahir.value = nilai;
                        },
                        padding: EdgeInsets.symmetric(
                          horizontal: layoutStyle.defaultMargin,
                          vertical: layoutStyle.defaultMargin / 4,
                        ),
                        borderRadius: BorderRadius.circular(
                          layoutStyle.defaultMargin / 2,
                        ),
                        border: Border.all(
                          color: colorStyle.grey,
                          width: 1,
                        ),
                        label: Text(
                          'Tgl Lahir',
                          style: textStyle.greyText.copyWith(
                            fontSize: fontSize.small,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextBox(
                      isMandatory: true,
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
                        hintText: 'Email',
                        hintStyle: textStyle.greyText,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomTextBox(
                      isMandatory: true,
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
                        hintText: 'Nomor Hp',
                        hintStyle: textStyle.greyText,
                        border: InputBorder.none,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(13),
                      ],
                      maxLength: 13,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              CustomTextBox(
                isMandatory: true,
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
                  'Address',
                  style: textStyle.greyText.copyWith(
                    fontSize: fontSize.small,
                  ),
                ),
                controller: controller.addressController,
                decoration: InputDecoration(
                  hintText: 'Address',
                  hintStyle: textStyle.greyText,
                  border: InputBorder.none,
                ),
              ),
              _leftAnggotaSection(),
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
