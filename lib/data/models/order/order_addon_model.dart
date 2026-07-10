import 'package:jaya_propertiy/data/models/order/order_rental_model.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';

class OrderAddonModel {
  AddonEntity? addOn;
  int? ordadAddonId;
  int ordadTotalAddon;
  double ordadTotalAmount;
  OrderRentalModel? rentHdrDtl;

  OrderAddonModel({
    this.addOn,
    this.ordadAddonId,
    required this.ordadTotalAddon,
    required this.ordadTotalAmount,
    this.rentHdrDtl,
  });

  factory OrderAddonModel.fromJson(Map<String, dynamic> json) {
    return OrderAddonModel(
      ordadAddonId: json['ordadAddonId'],
      ordadTotalAddon: json['ordadTotalAddon'],
      ordadTotalAmount: json['ordadTotalAmount'],
      rentHdrDtl: json['rentHdrDtl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ordadAddonId": ordadAddonId,
      "ordadTotalAddon": ordadTotalAddon,
      "ordadTotalAmount": ordadTotalAmount,
      "rentHdrDtl": rentHdrDtl?.toJson(),
    };
  }
}
