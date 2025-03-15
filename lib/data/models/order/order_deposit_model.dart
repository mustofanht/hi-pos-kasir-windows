import 'package:jaya_propertiy/domain/entities/sale/deposit_entity.dart';

class OrderDepositModel {
  DepositEntity? entity;
  String? odpOrderNumber;
  int? odpDpId;
  double odpTotalAmount;

  OrderDepositModel({
    this.entity,
    this.odpOrderNumber,
    this.odpDpId,
    required this.odpTotalAmount,
  });

  factory OrderDepositModel.fromJson(Map<String, dynamic> json) {
    return OrderDepositModel(
      odpOrderNumber: json['odpOrderNumber'],
      odpDpId: json['odpDpId'],
      odpTotalAmount: json['odpTotalAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "odpOrderNumber": odpOrderNumber,
      "odpDpId": odpDpId,
      "odpTotalAmount": odpTotalAmount,
    };
  }
}
