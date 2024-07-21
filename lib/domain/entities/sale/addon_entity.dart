import 'package:jaya_propertiy/app/utils/common/logger_util.dart';

class AddonEntity {
  int? productId;
  String? productName;
  String? productType;
  double? nominal;
  int? idLocation;
  String? nameLocation;
  String? state;

  AddonEntity({
    this.productId,
    this.productName,
    this.productType,
    this.nominal,
    this.idLocation,
    this.nameLocation,
    this.state,
  });

  AddonEntity.fromJson(Map<String, dynamic> json) {
    try {
      productId = json['productId'];
      productName = json['productName'];
      productType = json['productType'];
      nominal =
          json['nominal'] != null ? (json['nominal'] as num).toDouble() : null;
      idLocation = json['idLocation'];
      nameLocation = json['nameLocation'];
      state = json['state'];
    } catch (e) {
      logger.safeLog('error $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productType': productType,
      'nominal': nominal,
      'idLocation': idLocation,
      'nameLocation': nameLocation,
      'state': state,
    };
  }
}
