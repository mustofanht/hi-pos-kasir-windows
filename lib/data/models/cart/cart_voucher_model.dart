import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/domain/entities/member/member_list.dart';
import 'package:jaya_propertiy/domain/entities/sale/voucher_entity.dart';

class CartVoucher {
  int? qtyOrder;
  double? totalPrice;
  VoucherEntity? entity;
  String? memberNo;
  List<MemberListResponse>? selectedMemberAnggota;

  CartVoucher({
    this.qtyOrder,
    this.totalPrice,
    this.entity,
    this.memberNo,
    this.selectedMemberAnggota,
  });

  Map<String, dynamic> toJson() {
    return {
      "qtyOrder": qtyOrder,
      "totalPrice": totalPrice,
      "entity": entity != null ? entity!.toJson() : [],
    };
  }

  Map<String, dynamic> toJson2() {
    return {
      "qtyOrder": qtyOrder,
      "totalPrice": totalPrice,
      "entity": entity != null ? entity!.toJson2() : [],
    };
  }

  CartVoucher.fromJson(Map<String, dynamic> json) {
    try {
      qtyOrder = json['qtyOrder'];
      totalPrice = json['totalPrice'];
      if (json['entity'] is Map<Object?, Object?>) {
        Map<String, dynamic> result =
            common.convertToMapStringDynamic(json['entity']);
        entity = VoucherEntity.fromJson(result);
      } else {
        entity = VoucherEntity.fromJson(json['entity']);
      }
    } catch (e) {
      logger.safeLog('Error $e');
    }
  }
}
