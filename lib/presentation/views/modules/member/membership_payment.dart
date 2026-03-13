import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/auth/auth_token.dart';
import 'package:jaya_propertiy/domain/entities/member/member_detail.dart';
import 'package:jaya_propertiy/domain/entities/member/member_list.dart';
import 'package:jaya_propertiy/domain/entities/member/member_valid.dart';
import 'package:jaya_propertiy/domain/entities/member/membership.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_cart_page_controller.dart';

class MembershipPayment extends StatefulWidget {
  const MembershipPayment({
    super.key,
    required this.onNext,
    required this.authToken,
    required this.memberValid,
    required this.memberNo,
  });

  final Function(List<MemberListResponse> selectedMemberAnggota) onNext;
  final AuthToken authToken;
  final MemberValid memberValid;
  final String memberNo;

  @override
  State<MembershipPayment> createState() => _MembershipPaymentState();
}

class _MembershipPaymentState extends State<MembershipPayment> {
  final membershipController = TextEditingController();
  final exptController = TextEditingController();
  final kuotaController = TextEditingController();
  final namaController = TextEditingController();
  final resetController = TextEditingController();
  final maxController = TextEditingController();
  List<MemberListResponse> selectedMemberAnggota = [];

  @override
  void initState() {
    super.initState();
    if (widget.memberValid.mstMembership != null) {
      Membership membership = widget.memberValid.mstMembership!;
      MemberDetail? memberDetail = widget.memberValid.memberDetail;
      membershipController.text = membership.membName ?? '';
      exptController.text =
          (memberDetail != null && memberDetail!.regEffTo != null)
              ? dateTimeUtil.dateFormat(memberDetail!.regEffTo!, 'yyyy-MM-dd')
              : '';
      kuotaController.text = (membership.membKuota ?? '').toString();
      namaController.text = widget.memberValid.cardName ?? '';
      resetController.text = PERIODE.getName(membership.membResetPeriod ?? '');
      maxController.text =
          '${membership.membMaxKuota} / ${PERIODE.getName(memberDetail?.regMaxPeriod ?? '')}';
    }
    setMemberAnggotaSelected();
  }

  setMemberAnggotaSelected() {
    final cartController = Get.find<SaleCartPageController>();
    logger.safeLog('memberVoucher : ${cartController.memberVoucher}');
    if (cartController.memberVoucher.isTrue &&
        cartController.voucherList.isNotEmpty) {
      logger.safeLog('MEMBER NO : ${widget.memberNo}');
      logger.safeLog(
          'MEMBER NO SELECTED : ${cartController.voucherList.first.memberNo}');
      logger.safeLog(
          'SIZE SELECTED ANGGOTA : ${cartController.voucherList.first.selectedMemberAnggota?.length}');
      if (cartController.voucherList.first.memberNo == widget.memberNo) {
        setState(() {
          selectedMemberAnggota =
              cartController.voucherList.first.selectedMemberAnggota ?? [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> formSection() {
      return <Widget>[
        Row(
          children: [
            Expanded(
              child: CustomTextBox(
                height: layoutStyle.blockVertical * 6.5,
                isReadonly: true,
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
                  'Membership',
                  style: textStyle.greyText.copyWith(
                    fontSize: fontSize.small,
                  ),
                ),
                style: textStyle.blackText.copyWith(
                  fontSize: fontSize.small,
                ),
                controller: membershipController,
                decoration: InputDecoration(
                  hintText: 'Membership',
                  hintStyle: textStyle.greyText,
                  border: InputBorder.none,
                ),
              ),
              // child: Container(
              //   margin: EdgeInsets.symmetric(
              //     horizontal: layoutStyle.defaultMargin,
              //     vertical: layoutStyle.defaultMargin / 4,
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Padding(
              //         padding: EdgeInsets.symmetric(
              //           vertical: layoutStyle.defaultMargin / 2,
              //         ),
              //         child: Row(
              //           children: [
              //             Text(
              //               'Membership',
              //               style: textStyle.greyText.copyWith(
              //                 fontSize: fontSize.small,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //       Container(
              //         height: layoutStyle.blockVertical * 6.5,
              //         child: AutoSizeText(
              //           membershipController.text,
              //           style: textStyle.blackText.copyWith(
              //             fontSize: fontSize.body,
              //           ),
              //           textAlign: TextAlign.start,
              //           maxLines: 3,
              //           minFontSize: 8,
              //           overflow: TextOverflow.ellipsis,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ),
            Expanded(
              child: CustomTextBox(
                height: layoutStyle.blockVertical * 6.5,
                isReadonly: true,
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
                  'Berlaku s/d',
                  style: textStyle.greyText.copyWith(
                    fontSize: fontSize.small,
                  ),
                ),
                style: textStyle.blackText.copyWith(
                  fontSize: fontSize.small,
                ),
                controller: exptController,
                decoration: InputDecoration(
                  hintText: 'Berlaku s/d',
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
                isReadonly: true,
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
                  'Kuota',
                  style: textStyle.greyText.copyWith(
                    fontSize: fontSize.small,
                  ),
                ),
                style: textStyle.blackText.copyWith(
                  fontSize: fontSize.small,
                ),
                controller: kuotaController,
                decoration: InputDecoration(
                  hintText: 'Kuota',
                  hintStyle: textStyle.greyText,
                  border: InputBorder.none,
                ),
              ),
            ),
            Expanded(
              child: CustomTextBox(
                height: layoutStyle.blockVertical * 6.5,
                isReadonly: true,
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
                style: textStyle.blackText.copyWith(
                  fontSize: fontSize.small,
                ),
                controller: namaController,
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
                isReadonly: true,
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
                  'Reset',
                  style: textStyle.greyText.copyWith(
                    fontSize: fontSize.small,
                  ),
                ),
                style: textStyle.blackText.copyWith(
                  fontSize: fontSize.small,
                ),
                controller: resetController,
                decoration: InputDecoration(
                  hintText: 'Reset',
                  hintStyle: textStyle.greyText,
                  border: InputBorder.none,
                ),
              ),
            ),
            Expanded(
              child: CustomTextBox(
                height: layoutStyle.blockVertical * 6.5,
                isReadonly: true,
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
                  'Max',
                  style: textStyle.greyText.copyWith(
                    fontSize: fontSize.small,
                  ),
                ),
                style: textStyle.blackText.copyWith(
                  fontSize: fontSize.small,
                ),
                controller: maxController,
                decoration: InputDecoration(
                  hintText: 'Max',
                  hintStyle: textStyle.greyText,
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ];
    }

    Widget actionSection() {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              height: layoutStyle.blockVertical * 5,
              margin: EdgeInsets.symmetric(
                vertical: layoutStyle.defaultMargin / 2,
                horizontal: layoutStyle.defaultMargin,
              ),
              onPressed: () {
                Get.back();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith(
                  (states) => colorStyle.white,
                ),
                overlayColor: MaterialStateProperty.resolveWith(
                  (states) => colorStyle.black.withOpacity(0.1),
                ),
                side: MaterialStateProperty.resolveWith(
                  (states) => BorderSide(
                    color: colorStyle.black,
                    width: 1.0,
                  ),
                ),
                shape: MaterialStateProperty.resolveWith(
                  (states) => RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      layoutStyle.defaultMargin / 2,
                    ),
                  ),
                ),
                elevation: const MaterialStatePropertyAll(0),
              ),
              label: Text(
                'Cancel',
                style: textStyle.blackText,
              ),
            ),
          ),
          Expanded(
            child: CustomButton(
              height: layoutStyle.blockVertical * 5,
              margin: EdgeInsets.symmetric(
                vertical: layoutStyle.defaultMargin / 2,
                horizontal: layoutStyle.defaultMargin,
              ),
              onPressed: () {
                bool isValid = true;
                if (widget.memberValid.mstMembership?.membCheckName == 'Y') {
                  if (selectedMemberAnggota.isEmpty) {
                    alert.warning('Warning', 'Pilih anggota member!');
                    isValid = false;
                  }
                }
                if (isValid) {
                  Get.back();
                  widget.onNext(selectedMemberAnggota);
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith(
                  (states) => colorStyle.primary,
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
                elevation: const MaterialStatePropertyAll(0),
              ),
              label: Text(
                'OK',
                style: textStyle.whiteText,
              ),
            ),
          ),
        ],
      );
    }

    Widget columnAnggota(MemberListResponse memberListResponse) {
      // bool isSelected = selectedMemberAnggota.isNotEmpty &&
      //     selectedMemberAnggota.firstWhere((element) =>
      //             element.lsRelCode == memberListResponse.lsRelCode) !=
      //         null;
      bool isSelected = selectedMemberAnggota.any(
        (element) =>
            element.lsRelCode == memberListResponse.lsRelCode &&
            element.lsName == memberListResponse.lsName,
      );

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              height: layoutStyle.blockVertical * 8,
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorStyle.grey,
                  width: 1,
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: layoutStyle.defaultMargin / 2,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  memberListResponse.lsName ?? '',
                  style: textStyle.blackText,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: layoutStyle.blockVertical * 8,
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorStyle.grey,
                  width: 1,
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: layoutStyle.defaultMargin / 2,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  MemberRelation.getName(memberListResponse.lsRelCode ?? ''),
                  style: textStyle.blackText,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: layoutStyle.blockVertical * 8,
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorStyle.grey,
                  width: 1,
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Checkbox(
                  value: isSelected,
                  activeColor: colorStyle.primary,
                  checkColor: colorStyle.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: BorderSide(
                    color: colorStyle.primary,
                    width: 2,
                  ),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        selectedMemberAnggota.add(memberListResponse);
                      } else {
                        selectedMemberAnggota.removeWhere(
                          (element) =>
                              element.lsRelCode ==
                                  memberListResponse.lsRelCode &&
                              element.lsName == memberListResponse.lsName,
                        );
                      }
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget anggotaSection(List<MemberListResponse> memberListResponses) {
      return Container(
        width: layoutStyle.screenWidth,
        padding: EdgeInsets.symmetric(
          vertical: layoutStyle.defaultMargin / 2,
          horizontal: layoutStyle.defaultMargin,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Anggota',
              style: textStyle.blackText.copyWith(
                fontWeight: fontWeight.bold,
              ),
            ),
            SizedBox(
              height: layoutStyle.defaultMargin / 4,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: layoutStyle.blockVertical * 8,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorStyle.grey,
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: layoutStyle.defaultMargin / 2,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Nama',
                        textAlign: TextAlign.start,
                        style: textStyle.blackText,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: layoutStyle.blockVertical * 8,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorStyle.grey,
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: layoutStyle.defaultMargin / 2,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Hubungan',
                        textAlign: TextAlign.start,
                        style: textStyle.blackText,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: layoutStyle.blockVertical * 8,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorStyle.grey,
                        width: 1,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Pilih',
                        textAlign: TextAlign.center,
                        style: textStyle.blackText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ...memberListResponses
                .map((element) => columnAnggota(element))
                .toList(),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(layoutStyle.defaultMargin),
      width: layoutStyle.screenWidth / 2.5,
      decoration: BoxDecoration(
        color: colorStyle.white,
        borderRadius: const BorderRadius.all(
          Radius.circular(50),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Member Detail',
            style: textStyle.blackText.copyWith(
              fontSize: fontSize.title,
              fontWeight: fontWeight.bold,
            ),
          ),
          SizedBox(
            height: layoutStyle.defaultMargin / 2,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...formSection(),
                  if (widget.memberValid.memberListResponses != null &&
                      widget.memberValid.memberListResponses!.isNotEmpty)
                    anggotaSection(widget.memberValid.memberListResponses!),
                ],
              ),
            ),
          ),
          actionSection(),
        ],
      ),
    );
  }
}
