import 'package:flutter/material.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order_entity.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order_member.dart';

class BuktiPembayaranDetailPage extends StatelessWidget {
  const BuktiPembayaranDetailPage({super.key, required this.model});
  final TrnDetailOrderEntity model;

  @override
  Widget build(BuildContext context) {
    Widget rentProductCart(TrnDetailOrder val) {
      return Container(
        margin: EdgeInsets.symmetric(
          vertical: layoutStyle.defaultMargin / 10,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      // Text('${e.qtyOrder} X '),
                      Expanded(
                        child: Text(
                          '${val.productName} (${val.startDate != null && val.endDate != null ? '${dateTimeUtil.getFormattedDate(date: val.startDate!, format: dateFormat.hourMinutes)} - ${dateTimeUtil.getFormattedDate(date: val.endDate!, format: dateFormat.hourMinutes)}' : ''})',
                          softWrap: true,
                        ),
                      ),
                      Text(
                        'Rp.${common.currencyFormat(val.price ?? 0)}',
                        style: textStyle.blackText,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget memberList(TrnDetailOrderMember? member) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: member == null
            ? []
            : [
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: layoutStyle.defaultMargin / 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.memberName ?? '',
                            style: TextStyle(
                              fontSize: fontSize.subtitle,
                              fontWeight: fontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Rp.${common.currencyFormat(member.membershipTtlAmount ?? 0)}',
                        style: TextStyle(
                          fontSize: fontSize.body,
                        ),
                      ),
                    ],
                  ),
                )
              ],
      );
    }

    Widget potonganList() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: model.trnOrderVouchers == null
            ? []
            : model.trnOrderVouchers!
                .map(
                  (e) => Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: layoutStyle.defaultMargin / 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.voucherName ?? '',
                              style: TextStyle(
                                fontSize: fontSize.subtitle,
                                fontWeight: fontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '- Rp.${common.currencyFormat(e.voucherUnitCalcValue ?? 0)}',
                          style: TextStyle(
                            fontSize: fontSize.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      );
    }

    Widget voucherList() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: model.trnOrderVoucherPrice == null
            ? []
            : model.trnOrderVoucherPrice!
                .map(
                  (e) => Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: layoutStyle.defaultMargin / 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.voucherName ?? '',
                              style: TextStyle(
                                fontSize: fontSize.subtitle,
                                fontWeight: fontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '- Rp.${common.currencyFormat(e.voucherUnitCalcValue ?? 0)}',
                          style: TextStyle(
                            fontSize: fontSize.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      );
    }

    Widget depositList() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: model.trnOrderDeposit == null
            ? []
            : model.trnOrderDeposit!
                .map(
                  (e) => Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: layoutStyle.defaultMargin / 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.depositName ?? '',
                              style: TextStyle(
                                fontSize: fontSize.subtitle,
                                fontWeight: fontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '- Rp.${common.currencyFormat(e.depositAmount ?? 0)}',
                          style: TextStyle(
                            fontSize: fontSize.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: layoutStyle.screenWidth / 4,
                child: Padding(
                  padding: EdgeInsets.all(layoutStyle.defaultMargin),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DI TERBITKAN OLEH',
                        style: TextStyle(
                          fontSize: fontSize.header,
                          fontWeight: fontWeight.bold,
                        ),
                      ),
                      Text(
                        'Petugas: ${model.paymentDetail?.pymntCreatedBy ?? ''}',
                        style: TextStyle(
                          fontSize: fontSize.subtitle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(layoutStyle.defaultMargin),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Invoice #${model.orderNumber}',
                        style: TextStyle(
                          fontSize: fontSize.subtitle,
                        ),
                      ),
                      Text(
                        'Created: ${dateTimeUtil.getFormattedDate(date: model.orderDate!, format: dateFormat.onlyDate)} | ${dateTimeUtil.getFormattedDate(date: model.orderDate!, format: dateFormat.onlyTime)}',
                        style: TextStyle(
                          fontSize: fontSize.subtitle,
                        ),
                      ),
                      Text(
                        model.orderVoidReason != null && model.orderVoidReason!.isNotEmpty ? 'Void Reason : ${model.orderVoidReason ?? ''}' : '',
                        style: TextStyle(
                          fontSize: fontSize.subtitle,
                        ),
                      ),
                      SizedBox(
                        height: layoutStyle.defaultMargin,
                      ),
                      Text(
                        'CUSTOMER',
                        style: TextStyle(
                          fontSize: fontSize.header,
                          fontWeight: fontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: layoutStyle.defaultMargin / 5,
                      ),
                      Text(
                        // 'Nama: ${model.customerDetail?.custName ?? ''}',
                        'Nama: ${model.orderName ?? ''}',
                        style: TextStyle(
                          fontSize: fontSize.subtitle,
                        ),
                      ),
                      Text(
                        'Tanggal Pembayaran: ${dateTimeUtil.getFormattedDate(date: model.orderDate!, format: dateFormat.onlyDate)} | ${dateTimeUtil.getFormattedDate(date: model.orderDate!, format: dateFormat.onlyTime)}',
                        style: TextStyle(
                          fontSize: fontSize.subtitle,
                        ),
                      ),
                      Text(
                        // 'Metode Pembayaran: ${MapPaymentMethod[model.orderPaidBy]}',
                        'Metode Pembayaran: ${model.orderPaidByName}',
                        style: TextStyle(
                          fontSize: fontSize.subtitle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: layoutStyle.defaultMargin / 2,
              horizontal: layoutStyle.defaultMargin,
            ),
            decoration: BoxDecoration(
              color: colorStyle.lightGrey,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'INFO TIKET',
                  style: TextStyle(
                    fontWeight: fontWeight.bold,
                    fontSize: fontSize.subtitle,
                  ),
                ),
                Text(
                  'JUMLAH HARGA SATUAN',
                  style: TextStyle(
                    fontWeight: fontWeight.bold,
                    fontSize: fontSize.subtitle,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: layoutStyle.screenWidth,
            padding: EdgeInsets.all(layoutStyle.defaultMargin),
            child: Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: model.detailOrderModels == null
                      ? []
                      : model.detailOrderModels!
                          .map(
                            (e) => (e.startDate != null && e.endDate != null)
                                ? rentProductCart(e)
                                : Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical:
                                            layoutStyle.defaultMargin / 5),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              e.productName ?? '',
                                              style: TextStyle(
                                                fontSize: fontSize.subtitle,
                                                fontWeight: fontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'X ${e.quantity ?? 0}',
                                              style: TextStyle(
                                                fontSize: fontSize.subtitle,
                                                fontWeight: fontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Rp.${common.currencyFormat(e.price ?? 0)}',
                                          style: TextStyle(
                                            fontSize: fontSize.body,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          )
                          .toList(),
                ),
                if (model.trnOrderMember != null &&
                    model.trnOrderMember!.memberNo != null)
                  memberList(model.trnOrderMember),
                potonganList(),
                voucherList(),
                depositList(),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: layoutStyle.defaultMargin / 2,
              horizontal: layoutStyle.defaultMargin,
            ),
            decoration: BoxDecoration(
              color: colorStyle.lightGrey,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Harga Total: Rp.${common.currencyFormat(model.orderTotalAmt ?? 0)}',
                  style: TextStyle(
                    fontWeight: fontWeight.bold,
                    fontSize: fontSize.subtitle,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: layoutStyle.screenWidth,
            padding: EdgeInsets.all(layoutStyle.defaultMargin),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            // 'Discount:',
                            'Total Potongan:',
                            style: TextStyle(
                              fontSize: fontSize.body,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: layoutStyle.defaultMargin / 2,
                        ),
                        child: Text(
                          'Rp.${common.currencyFormat(model.orderDiskon ?? 0)}',
                          style: TextStyle(
                            fontSize: fontSize.body,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Padding(
                //   padding: EdgeInsets.all(
                //       layoutStyle.defaultMargin / 2),
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: Align(
                //           alignment:
                //               Alignment.centerRight,
                //           child: Text(
                //             'Voucher:',
                //             style: TextStyle(
                //               fontSize: fontSize.body,
                //             ),
                //           ),
                //         ),
                //       ),
                //       Padding(
                //         padding: EdgeInsets.symmetric(
                //           horizontal:
                //               layoutStyle.defaultMargin /
                //                   2,
                //         ),
                //         child: Text(
                //           'Not Set Yet',
                //           style: TextStyle(
                //             fontSize: fontSize.body,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Padding(
                  padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Biaya Admin:',
                            style: TextStyle(
                              fontSize: fontSize.body,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: layoutStyle.defaultMargin / 2,
                        ),
                        child: Text(
                          'Rp.${common.currencyFormat(model.paymentDetail?.pymntAdminFee ?? 0)}',
                          style: TextStyle(
                            fontSize: fontSize.body,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Biaya Ppn:',
                            style: TextStyle(
                              fontSize: fontSize.body,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: layoutStyle.defaultMargin / 2,
                        ),
                        child: Text(
                          'Rp.${common.isNumeric(model.ppn) ? common.currencyFormat(double.parse(model.ppn ?? '0')) : model.ppn}',
                          style: TextStyle(
                            fontSize: fontSize.body,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Total Tagihan:',
                            style: TextStyle(
                              fontSize: fontSize.body,
                              fontWeight: fontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: layoutStyle.defaultMargin / 2,
                        ),
                        child: Text(
                          'Rp.${common.currencyFormat(model.orderTotalTgh ?? 0)}',
                          style: TextStyle(
                            fontSize: fontSize.body,
                            fontWeight: fontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
