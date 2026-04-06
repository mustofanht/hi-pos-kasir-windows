import 'package:jaya_propertiy/domain/entities/transaction/transaction_entity.dart';

class CartRentModel {
  DateTime? startDate;
  DateTime? endDate;
  bool? isExtraTime;
  TransactionEntity? transactionExtra;
  double? newBuyPrice;
  int? totalHours;

  CartRentModel({
    this.startDate,
    this.endDate,
    this.isExtraTime,
    this.transactionExtra,
    this.newBuyPrice,
    this.totalHours,
  });

  CartRentModel.fromJson(Map<String, dynamic> json) {
    startDate = json['startDate'] != null ? DateTime.parse(json['startDate']).toLocal() : null;
    endDate = json['endDate'] != null ? DateTime.parse(json['endDate']).toLocal() : null;
    newBuyPrice = json['newBuyPrice'] != null ? (json['newBuyPrice'] as num).toDouble() : null;
    totalHours = json['totalHours'];
    isExtraTime = json['isExtraTime'];
    transactionExtra = json['transactionExtra'];
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'newBuyPrice': newBuyPrice,
      'totalHours': totalHours,
      'isExtraTime': isExtraTime,
      'transactionExtra': transactionExtra?.toJson(),
    };
  }
}
