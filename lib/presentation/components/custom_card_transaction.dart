import 'package:flutter/material.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/transaction/transaction_entity.dart';

class CustomCardTransaction extends StatelessWidget {
  final TransactionEntity? selectedData;
  final Function(TransactionEntity data)? onSelect;
  final TransactionEntity? data;
  const CustomCardTransaction({
    super.key,
    this.selectedData,
    this.onSelect,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onSelect != null && data != null) {
          onSelect!.call(data!);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: layoutStyle.defaultMargin / 2),
        padding: EdgeInsets.all(layoutStyle.defaultMargin),
        decoration: BoxDecoration(
          border: Border.all(
            color: colorStyle.primary,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(
            layoutStyle.defaultMargin / 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data?.orderNumber ?? '',
                    style: textStyle.blackText.copyWith(
                      fontSize: fontSize.header,
                      fontWeight: fontWeight.bold,
                    ),
                  ),
                  Text(
                    'Lokasi : ${data?.location}',
                    style: textStyle.blackText.copyWith(
                      color: colorStyle.grey,
                    ),
                  ),
                  Text(
                    'Product : ${data?.product}',
                    style: textStyle.blackText.copyWith(
                      color: colorStyle.grey,
                    ),
                  ),
                  SizedBox(
                    height: layoutStyle.defaultMargin,
                  ),
                  Text(
                    'Durasi Sewa : ${data?.totalHours} Jam, ${dateTimeUtil.getFormattedDate(date: data!.startDate!, format: dateFormat.hourMinutes)} - ${dateTimeUtil.getFormattedDate(date: data!.endDate!, format: dateFormat.hourMinutes)}',
                    style: textStyle.blackText,
                  ),
                ],
              ),
            ),
            if (onSelect != null)
              selectedData?.orderNumber == data?.orderNumber
                  ? Icon(
                      Icons.check,
                      color: colorStyle.primary,
                    )
                  : Text(
                      'Pilih',
                      style: textStyle.primaryColor.copyWith(
                        fontWeight: fontWeight.bold,
                        fontSize: fontSize.title,
                      ),
                    )
          ],
        ),
      ),
    );
  }
}
