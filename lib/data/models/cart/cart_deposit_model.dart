import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/domain/entities/sale/deposit_entity.dart';

class CartDeposit {
  int? qtyOrder;
  double? totalPrice;
  DepositEntity? deposit;

  CartDeposit({
    this.qtyOrder,
    this.totalPrice,
    this.deposit,
  });

  Map<String, dynamic> toJson() {
    return {
      "qtyOrder": qtyOrder,
      "totalPrice": totalPrice,
      "deposit": deposit != null ? deposit!.toJson() : [],
    };
  }

  Map<String, dynamic> toJson2() {
    return {
      "qtyOrder": qtyOrder,
      "totalPrice": totalPrice,
      "deposit": deposit != null ? deposit!.toJson2() : [],
    };
  }

  CartDeposit.fromJson(Map<String, dynamic> json) {
    try {
      qtyOrder = json['qtyOrder'];
      totalPrice = json['totalPrice'];
      if (json['deposit'] is Map<Object?, Object?>) {
        Map<String, dynamic> result =
            common.convertToMapStringDynamic(json['deposit']);
        deposit = DepositEntity.fromJson(result);
      } else {
        deposit = DepositEntity.fromJson(json['deposit']);
      }
    } catch (e) {
      logger.safeLog('Error $e');
    }
  }}
