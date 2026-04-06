import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
import 'package:jaya_propertiy/domain/entities/masterdata/mst_payment.dart';

class CustomCardPayment extends StatelessWidget {
  final CustomIdNameEntity element;
  final Rx<CustomIdNameEntity> selectedPaymentType;
  final List<MstPayment> mstPayments;
  final Function(CustomIdNameEntity value) doSelectPaymentType;
  const CustomCardPayment({
    super.key,
    required this.element,
    required this.selectedPaymentType,
    required this.mstPayments,
    required this.doSelectPaymentType,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (element.id == null) {
          return Container();
        }
        MstPayment mstPayment = mstPayments.firstWhere(
          (e) => e.pymntCode == element.id,
        );
        String img = mstPayment.pymntImgPath ?? '';
        String label = mstPayment.pymntName ?? '-';
        // logger.safeLog('IMG : $img');
        return GestureDetector(
          onTap: () {
            doSelectPaymentType(element);
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
              color: selectedPaymentType.value.id == element.id
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
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
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
                        color: selectedPaymentType.value.id == element.id
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
      },
    );
  }
}
