class CartRentModel {
  DateTime? startDate;
  DateTime? endDate;
  double? newBuyPrice;
  double? extraTimeBuyPrice;

  CartRentModel({
    this.startDate,
    this.endDate,
    this.newBuyPrice,
    this.extraTimeBuyPrice,
  });

  CartRentModel.fromJson(Map<String, dynamic> json) {
    startDate = json['startDate'] != null ? DateTime.parse(json['startDate']) : null;
    endDate = json['endDate'] != null ? DateTime.parse(json['endDate']) : null;
    newBuyPrice = json['newBuyPrice'] != null ? (json['newBuyPrice'] as num).toDouble() : null;
    extraTimeBuyPrice = json['extraTimeBuyPrice'] != null ? (json['extraTimeBuyPrice'] as num).toDouble() : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'newBuyPrice': newBuyPrice,
      'extraTimeBuyPrice': extraTimeBuyPrice,
    };
  }
}
