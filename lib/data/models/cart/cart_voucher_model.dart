import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/domain/entities/sale/voucher_entity.dart';

class CartVoucher {
  int? qtyOrder;
  double? totalPrice;
  VoucherEntity? voucher;

  CartVoucher({
    this.qtyOrder,
    this.totalPrice,
    this.voucher,
  });

  Map<String, dynamic> toJson() {
    return {
      "qtyOrder": qtyOrder,
      "totalPrice": totalPrice,
      "voucher": voucher != null ? voucher!.toJson() : [],
    };
  }

  Map<String, dynamic> toJson2() {
    return {
      "qtyOrder": qtyOrder,
      "totalPrice": totalPrice,
      "voucher": voucher != null ? voucher!.toJson2() : [],
    };
  }

  CartVoucher.fromJson(Map<String, dynamic> json) {
    try {
      qtyOrder = json['qtyOrder'];
      totalPrice = json['totalPrice'];
      if (json['voucher'] is Map<Object?, Object?>) {
        Map<String, dynamic> result =
            common.convertToMapStringDynamic(json['voucher']);
        voucher = VoucherEntity.fromJson(result);
      } else {
        voucher = VoucherEntity.fromJson(json['voucher']);
      }
    } catch (e) {
      logger.safeLog('Error $e');
    }
  }
}
