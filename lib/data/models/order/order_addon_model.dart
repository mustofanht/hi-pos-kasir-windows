class OrderAddonModel {
  int? ordadAddonId;
  int ordadTotalAddon;
  double ordadTotalAmount;

  OrderAddonModel({
    this.ordadAddonId,
    required this.ordadTotalAddon,
    required this.ordadTotalAmount,
  });

  factory OrderAddonModel.fromJson(Map<String, dynamic> json) {
    return OrderAddonModel(
      ordadAddonId: json['ordadAddonId'],
      ordadTotalAddon: json['ordadTotalAddon'],
      ordadTotalAmount: json['ordadTotalAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ordadAddonId": ordadAddonId,
      "ordadTotalAddon": ordadTotalAddon,
      "ordadTotalAmount": ordadTotalAmount,
    };
  }
}
