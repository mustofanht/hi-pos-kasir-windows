import 'package:jaya_propertiy/domain/entities/sale/voucher_entity.dart';

class OrderVoucherModel {
  VoucherEntity? voucher;
  int? ordvcVoucherId;
  int ordvcTotalVoucher;
  double ordvcTotalAmount;

  OrderVoucherModel({
    this.voucher,
    this.ordvcVoucherId,
    required this.ordvcTotalVoucher,
    required this.ordvcTotalAmount,
  });

  factory OrderVoucherModel.fromJson(Map<String, dynamic> json) {
    return OrderVoucherModel(
      ordvcVoucherId: json['ordvcVoucherId'],
      ordvcTotalVoucher: json['ordvcTotalVoucher'],
      ordvcTotalAmount: json['ordvcTotalAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ordvcVoucherId": ordvcVoucherId,
      "ordvcTotalVoucher": ordvcTotalVoucher,
      "ordvcTotalAmount": ordvcTotalAmount,
    };
  }
}
