import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/data/models/cart/cart_rent_model.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';

class CartAddon {
  int? qtyOrder;
  double? totalPrice;
  CartRentModel? rentModel;
  AddonEntity? addon;

  /// mst_ticket_bundle.bundle_id bila baris ini lahir dari bundling tiket.
  /// null = item yang dipilih kasir sendiri. Baris bundling tidak bisa diubah
  /// qty-nya di keranjang — ia mengikuti jumlah tiketnya.
  int? bundleId;

  bool get isBundle => bundleId != null;

  CartAddon({
    this.qtyOrder,
    this.totalPrice,
    this.rentModel,
    this.addon,
    this.bundleId,
  });

  Map<String, dynamic> toJson() {
    return {
      "qtyOrder": qtyOrder,
      "totalPrice": totalPrice,
      "rentModel": rentModel != null ? rentModel!.toJson() : {},
      "addon": addon != null ? addon!.toJson() : [],
      "bundleId": bundleId,
    };
  }

  CartAddon.fromJson(Map<String, dynamic> json) {
    try {
      qtyOrder = json['qtyOrder'];
      // Harga bundling gratis bisa tiba sebagai int 0 setelah melewati kanal layar
      // kedua; menugaskannya langsung ke double? melempar dan seluruh baris hilang.
      totalPrice = (json['totalPrice'] as num?)?.toDouble();
      bundleId = json['bundleId'];
      // rentModel = json['rentModel'];

      if (json['rentModel'] is Map<Object?, Object?>) {
        Map<String, dynamic> result =
            common.convertToMapStringDynamic(json['rentModel']);
        rentModel = CartRentModel.fromJson(result);
      } else {
        rentModel = CartRentModel.fromJson(json['addon']);
      }
      if (json['addon'] is Map<Object?, Object?>) {
        Map<String, dynamic> result =
            common.convertToMapStringDynamic(json['addon']);
        addon = AddonEntity.fromJson(result);
      } else {
        addon = AddonEntity.fromJson(json['addon']);
      }
    } catch (e) {
      logger.safeLog('Error $e');
    }
  }
}
