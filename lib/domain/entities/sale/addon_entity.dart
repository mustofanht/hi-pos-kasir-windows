import 'package:jaya_propertiy/app/utils/common/logger_util.dart';

class AddonEntity {
  int? productId;
  String? productName;
  String? productType;
  double? productPrice;
  int? productLoc;
  String? productLocName;
  String? productState;
  String? pathImg;
  int? minRentPrd;

  AddonEntity({
    this.productId,
    this.productName,
    this.productType,
    this.productPrice,
    this.productLoc,
    this.productLocName,
    this.productState,
    this.pathImg,
    this.minRentPrd,
  });

  AddonEntity.fromJson(Map<String, dynamic> json) {
    try {
      productId = json['productId'];
      productName = json['productName'];
      productType = json['productType'];
      productPrice =
          json['productPrice'] != null ? (json['productPrice'] as num).toDouble() : null;
      productLoc = json['productLoc'];
      productLocName = json['productLocName'];
      productState = json['productState'];
      pathImg = json['pathImg'];
      minRentPrd = json['minRentPrd'];
    } catch (e) {
      logger.safeLog('error $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productType': productType,
      'productPrice': productPrice,
      'productLoc': productLoc,
      'productLocName': productLocName,
      'productState': productState,
      'pathImg': pathImg,
      'minRentPrd': minRentPrd,
    };
  }
}
