import 'package:jaya_propertiy/domain/entities/shift/shift_detail_payment_entity.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_detail_sum_potongan_entity.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_detail_sum_voucher_entity.dart';

class ShiftDetailEntity {
  final String? shftDate;
  final String? shftUserid;
  final DateTime? shftStart;
  final DateTime? shftEnd;
  final String? userFullName;
  final String? lokasiName;
  final int? tiketCount;
  final int? itemCount;
  final int? potonganCount;
  final int? voucherCount;
  final String? qrisSum;
  final String? edcSum;
  final String? travelokaSum;
  final String? ticketdotcomSum;
  final List<ShiftDetailPaymentEntity>? listSumPayment;
  final List<ShiftDetailSumVoucherEntity>? listSumVoucher;
  final List<ShiftDetailSumPotonganEntity>? listSumPotongan;

  ShiftDetailEntity({
    this.shftDate,
    this.shftUserid,
    this.shftStart,
    this.shftEnd,
    this.userFullName,
    this.lokasiName,
    this.tiketCount,
    this.itemCount,
    this.potonganCount,
    this.voucherCount,
    this.qrisSum,
    this.edcSum,
    this.travelokaSum,
    this.ticketdotcomSum,
    this.listSumPayment,
    this.listSumVoucher,
    this.listSumPotongan,
  });

  factory ShiftDetailEntity.fromJson(Map<String, dynamic> json) {
    return ShiftDetailEntity(
      shftDate: json['shftDate'],
      shftUserid: json['shftUserid'],
      shftStart: json['shftStart'] != null
          ? DateTime.parse(json['shftStart']).toLocal()
          : null,
      shftEnd: json['shftEnd'] != null
          ? DateTime.parse(json['shftEnd']).toLocal()
          : null,
      userFullName: json['userFullName'],
      lokasiName: json['lokasiName'],
      tiketCount: json['tiketCount'],
      itemCount: json['itemCount'],
      potonganCount: json['potonganCount'],
      voucherCount: json['voucherCount'],
      qrisSum: json['qrisSum'],
      edcSum: json['edcSum'],
      travelokaSum: json['travelokaSum'],
      ticketdotcomSum: json['ticketdotcomSum'],
      listSumPayment: json['listSumPayment'] != null
          ? (json['listSumPayment'] as List)
              .map((i) => ShiftDetailPaymentEntity.fromJson(i))
              .toList()
          : null,
      listSumVoucher: json['listSumVoucher'] != null
          ? (json['listSumVoucher'] as List)
              .map((i) => ShiftDetailSumVoucherEntity.fromJson(i))
              .toList()
          : null,
      listSumPotongan: json['listSumPotongan'] != null
          ? (json['listSumPotongan'] as List)
              .map((i) => ShiftDetailSumPotonganEntity.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shftDate': shftDate,
      'shftUserid': shftUserid,
      'shftStart': shftStart?.toIso8601String(),
      'shftEnd': shftEnd?.toIso8601String(),
      'userFullName': userFullName,
      'lokasiName': lokasiName,
      'tiketCount': tiketCount,
      'itemCount': itemCount,
      'potonganCount': potonganCount,
      'voucherCount': voucherCount,
      'qrisSum': qrisSum,
      'edcSum': edcSum,
      'travelokaSum': travelokaSum,
      'ticketdotcomSum': ticketdotcomSum,
      'listSumPayment': listSumPayment?.map((e) => e.toJson()).toList(),
      'listSumVoucher': listSumVoucher?.map((e) => e.toJson()).toList(),
      'listSumPotongan': listSumPotongan?.map((e) => e.toJson()).toList(),
    };
  }
}
