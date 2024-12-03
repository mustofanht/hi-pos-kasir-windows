import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/data/models/cart/cart_rent_model.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';

class CartAddon {
  int? qtyOrder;
  double? totalPrice;
  CartRentModel? rentModel;
  AddonEntity? addon;

  CartAddon({
    this.qtyOrder,
    this.totalPrice,
    this.rentModel,
    this.addon,
  });

  Map<String, dynamic> toJson() {
    return {
      "qtyOrder": qtyOrder,
      "totalPrice": totalPrice,
      "rentModel": rentModel != null ? rentModel!.toJson() : {},
      "addon": addon != null ? addon!.toJson() : [],
    };
  }

  CartAddon.fromJson(Map<String, dynamic> json) {
    try {
      qtyOrder = json['qtyOrder'];
      totalPrice = json['totalPrice'];
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
