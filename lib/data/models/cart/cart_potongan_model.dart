import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/domain/entities/sale/potongan_entity.dart';

class CartPotongan {
  int? qtyOrder;
  double? totalPrice;
  PotonganEntity? potongan;

  CartPotongan({
    this.qtyOrder,
    this.totalPrice,
    this.potongan,
  });

  Map<String, dynamic> toJson() {
    return {
      "qtyOrder": qtyOrder,
      "totalPrice": totalPrice,
      "potongan": potongan != null ? potongan!.toJson() : [],
    };
  }

  Map<String, dynamic> toJson2() {
    return {
      "qtyOrder": qtyOrder,
      "totalPrice": totalPrice,
      "potongan": potongan != null ? potongan!.toJson2() : [],
    };
  }

  CartPotongan.fromJson(Map<String, dynamic> json) {
    try {
      qtyOrder = json['qtyOrder'];
      totalPrice = json['totalPrice'];
      if (json['potongan'] is Map<Object?, Object?>) {
        Map<String, dynamic> result =
            common.convertToMapStringDynamic(json['potongan']);
        potongan = PotonganEntity.fromJson(result);
      } else {
        potongan = PotonganEntity.fromJson(json['potongan']);
      }
    } catch (e) {
      logger.safeLog('Error $e');
    }
  }
}
