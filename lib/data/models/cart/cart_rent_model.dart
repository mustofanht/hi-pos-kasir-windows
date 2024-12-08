class CartRentModel {
  DateTime? startDate;
  DateTime? endDate;
  bool? isExtraTime;
  int? extraTransactionId;
  double? newBuyPrice;
  double? extraTimeBuyPrice;
  int? totalHours;

  CartRentModel({
    this.startDate,
    this.endDate,
    this.isExtraTime,
    this.extraTransactionId,
    this.newBuyPrice,
    this.extraTimeBuyPrice,
    this.totalHours,
  });

  CartRentModel.fromJson(Map<String, dynamic> json) {
    startDate = json['startDate'] != null ? DateTime.parse(json['startDate']).toLocal() : null;
    endDate = json['endDate'] != null ? DateTime.parse(json['endDate']).toLocal() : null;
    newBuyPrice = json['newBuyPrice'] != null ? (json['newBuyPrice'] as num).toDouble() : null;
    extraTimeBuyPrice = json['extraTimeBuyPrice'] != null ? (json['extraTimeBuyPrice'] as num).toDouble() : null;
    totalHours = json['totalHours'];
    isExtraTime = json['isExtraTime'];
    extraTransactionId = json['extraTransactionId'];
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'newBuyPrice': newBuyPrice,
      'extraTimeBuyPrice': extraTimeBuyPrice,
      'totalHours': totalHours,
      'isExtraTime': isExtraTime,
      'extraTransactionId': extraTransactionId,
    };
  }
}
