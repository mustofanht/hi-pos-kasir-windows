import 'package:jaya_propertiy/domain/entities/sale/potongan_entity.dart';

class OrderPotonganModel {
  PotonganEntity? voucher;
  int? ordvcVoucherId;
  int ordvcTotalVoucher;
  double ordvcTotalAmount;

  OrderPotonganModel({
    this.voucher,
    this.ordvcVoucherId,
    required this.ordvcTotalVoucher,
    required this.ordvcTotalAmount,
  });

  factory OrderPotonganModel.fromJson(Map<String, dynamic> json) {
    return OrderPotonganModel(
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
