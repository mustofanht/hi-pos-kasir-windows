import 'package:jaya_propertiy/data/models/order/order_rental_model.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';

class OrderAddonModel {
  AddonEntity? addOn;
  int? ordadAddonId;
  int ordadTotalAddon;
  double ordadTotalAmount;
  OrderRentalModel? rentHdrDtl;

  /// mst_ticket_bundle.bundle_id bila item ini datang dari bundling tiket.
  /// Backend memakainya sebagai penanda bahwa kasir SUDAH menghitung item ini,
  /// sehingga tidak disisipkan (dan ditagih) untuk kedua kalinya di server.
  int? ordadBundleId;

  OrderAddonModel({
    this.addOn,
    this.ordadAddonId,
    required this.ordadTotalAddon,
    required this.ordadTotalAmount,
    this.rentHdrDtl,
    this.ordadBundleId,
  });

  factory OrderAddonModel.fromJson(Map<String, dynamic> json) {
    return OrderAddonModel(
      ordadAddonId: json['ordadAddonId'],
      ordadTotalAddon: json['ordadTotalAddon'],
      ordadTotalAmount: json['ordadTotalAmount'],
      rentHdrDtl: json['rentHdrDtl'],
      ordadBundleId: json['ordadBundleId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ordadAddonId": ordadAddonId,
      "ordadTotalAddon": ordadTotalAddon,
      "ordadTotalAmount": ordadTotalAmount,
      "rentHdrDtl": rentHdrDtl?.toJson(),
      "ordadBundleId": ordadBundleId,
    };
  }
}
