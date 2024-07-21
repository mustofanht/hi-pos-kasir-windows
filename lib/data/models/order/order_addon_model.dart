import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';

class OrderAddonModel {
  AddonEntity? addOn;
  int? ordadAddonId;
  int ordadTotalAddon;
  double ordadTotalAmount;

  OrderAddonModel({
    this.addOn,
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
